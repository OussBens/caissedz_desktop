import 'package:sqflite_common/sqlite_api.dart';

import '../data/boutique_repository.dart';
import '../data/caisse_repository.dart';
import '../data/facture_repository.dart';
import '../data/historique_repository.dart';
import '../data/journal_fiscal_repository.dart';
import '../data/parametre_repository.dart';
import '../data/tiers_repository.dart';
import '../data/vente_repository.dart';
import '../domain/calculs_prix.dart';
import '../domain/fiscalite.dart';
import '../domain/models/caisse.dart';
import '../domain/models/facture.dart';
import '../domain/models/journal_fiscal.dart';
import '../domain/models/retour.dart';
import '../domain/models/vente.dart';
import '../domain/montant_en_lettres.dart';
import '../domain/scellement.dart';
import 'caisse_service.dart';

enum ErreurFacture { venteInconnue, venteAnnulee, factureInconnue, pasUneFacture, dejaAnnulee, motifObligatoire }

class FactureException implements Exception {
  const FactureException(this.erreur, [this.detail]);
  final ErreurFacture erreur;
  final String? detail;
  @override
  String toString() => 'FactureException($erreur${detail == null ? '' : ', $detail'})';
}

/// Facturation conforme (audit, point 6) : facture (FAC) et facture d'avoir (AVO), numérotations continues
/// distinctes, identités fiscales du vendeur et du client figées, TVA par taux, droit de timbre sur la part
/// payée en espèces, montant en lettres, scellement chaîné et événement au journal fiscal. Une facture émise
/// n'est jamais modifiée : une annulation ou un retour produit un avoir.
class FactureService {
  const FactureService(this.db, {required this.utilisateurCode});

  final Database db;
  final String utilisateurCode;

  static const String prefixeFacture = 'FAC';
  static const String prefixeAvoir = 'AVO';

  FactureRepository get _repo => FactureRepository(db);

  Future<Facture?> factureDeVente(String venteCode) => _repo.factureDeVente(venteCode);
  Future<List<Facture>> factures({DateTime? debut, DateTime? fin}) => _repo.factures(debut: debut, fin: fin);
  Future<List<Facture>> avoirsDe(String factureCode) => _repo.avoirsDe(factureCode);

  /// Émet la facture d'une vente validée ; si elle existe déjà, la retourne (réimpression = duplicata).
  Future<Facture> emettre(String venteCode) =>
      db.transaction((txn) => emettreDansTransaction(txn, venteCode, utilisateurCode: utilisateurCode));

  static Future<Facture> emettreDansTransaction(
    Transaction txn,
    String venteCode, {
    required String utilisateurCode,
  }) async {
    final repo = FactureRepository(txn);
    final existante = await repo.factureDeVente(venteCode);
    if (existante != null) return existante;
    final v = await VenteRepository(txn).vente(venteCode);
    if (v == null) throw const FactureException(ErreurFacture.venteInconnue);
    if (v.statut == StatutsVente.annulee) throw const FactureException(ErreurFacture.venteAnnulee);
    final lignes = [
      for (final l in v.lignes)
        FactureLigne(
          produitCode: l.produitCode,
          designation: l.designation,
          quantite: l.quantite,
          prixUnitaire: l.quantite == 0 ? 0 : CalculsPrix.arrondir(l.total / l.quantite),
          tauxTva: l.tauxTva,
          montantHt: l.montantHt,
          montantTva: l.montantTva,
          montantTtc: l.total,
        ),
    ];
    final timbreActif = await ParametreRepository(txn).lire(Fiscalite.cleTimbre) != '0';
    final especes = v.paiements.where((p) => p.mode == 'Espèces').fold(0.0, (s, p) => s + p.montant) - v.monnaie;
    final timbre = timbreActif ? Fiscalite.timbre(especes) : 0.0;
    final modes = {for (final p in v.paiements) p.mode}.toList();
    final mode = [...modes, if (v.reste > 0.004) 'À terme'].join(' + ');
    final f = await _construire(
      txn,
      type: TypesFacture.facture,
      vente: v,
      lignes: lignes,
      timbre: timbre,
      mode: mode.isEmpty ? 'À terme' : mode,
      utilisateurCode: utilisateurCode,
    );
    if (timbre > 0) {
      await CaisseService.journaliser(
        txn,
        caisseCode: await CaisseRepository(txn).caisseParDefaut(utilisateurCode),
        type: TypesMouvementCaisse.timbre,
        sens: SensMouvementCaisse.entree,
        montant: timbre,
        referenceType: 'facture',
        referenceCode: f.code,
        utilisateurCode: utilisateurCode,
        date: f.date,
      );
    }
    return f;
  }

  /// Avoir total d'une facture (annulation de la vente) ou partiel ([retour] client sur la vente facturée).
  Future<Facture> emettreAvoir(String factureCode, {required String motif}) {
    if (motif.trim().isEmpty) throw const FactureException(ErreurFacture.motifObligatoire);
    return db.transaction((txn) async {
      final f = await FactureRepository(txn).facture(factureCode);
      if (f == null) throw const FactureException(ErreurFacture.factureInconnue);
      if (f.estAvoir) throw const FactureException(ErreurFacture.pasUneFacture);
      return _avoirTotal(txn, f, motif: motif.trim(), utilisateurCode: utilisateurCode);
    });
  }

  /// Annulation d'une vente facturée : avoir total (dans la transaction de l'annulation) ; `null` sans facture.
  static Future<Facture?> avoirPourAnnulation(
    Transaction txn,
    String venteCode, {
    required String motif,
    required String utilisateurCode,
  }) async {
    final f = await FactureRepository(txn).factureDeVente(venteCode);
    if (f == null) return null;
    return _avoirTotal(txn, f, motif: motif, utilisateurCode: utilisateurCode);
  }

  /// Retour client sur une vente facturée : avoir des lignes retournées ; `null` sans facture.
  static Future<Facture?> avoirPourRetour(Transaction txn, Retour r, {required String utilisateurCode}) async {
    if (!r.estClient) return null;
    final f = await FactureRepository(txn).factureDeVente(r.documentCode);
    if (f == null) return null;
    final v = (await VenteRepository(txn).vente(r.documentCode))!;
    final lignes = <FactureLigne>[];
    for (final l in r.lignes) {
      final origine =
          v.lignes.where((x) => x.ordre == l.ordreOrigine).firstOrNull ??
          v.lignes.where((x) => x.produitCode == l.produitCode).firstOrNull;
      final taux = origine?.tauxTva ?? 0;
      final ventile = Fiscalite.ventiler(l.total, taux);
      lignes.add(
        FactureLigne(
          produitCode: l.produitCode,
          designation: l.designation,
          quantite: l.quantite,
          prixUnitaire: l.prixUnitaire,
          tauxTva: taux,
          montantHt: ventile.ht,
          montantTva: ventile.tva,
          montantTtc: l.total,
        ),
      );
    }
    return _construire(
      txn,
      type: TypesFacture.avoir,
      vente: v,
      lignes: lignes,
      timbre: 0,
      mode: r.reglement,
      utilisateurCode: utilisateurCode,
      retourCode: r.code,
      origine: f.code,
      motif: 'Retour ${r.code}',
    );
  }

  static Future<Facture> _avoirTotal(
    Transaction txn,
    Facture f, {
    required String motif,
    required String utilisateurCode,
  }) async {
    final deja = await FactureRepository(txn).avoirsDe(f.code);
    if (deja.any((a) => a.retourCode == null)) throw const FactureException(ErreurFacture.dejaAnnulee);
    // Reste à annuler : lignes de la facture moins les avoirs partiels déjà émis (retours).
    final restant = <String, double>{};
    for (final a in deja) {
      for (final l in a.lignes) {
        restant[l.produitCode] = (restant[l.produitCode] ?? 0) + l.montantTtc;
      }
    }
    final lignes = <FactureLigne>[];
    for (final l in f.lignes) {
      final dejaAvoir = restant[l.produitCode] ?? 0;
      final pris = dejaAvoir > l.montantTtc ? l.montantTtc : dejaAvoir;
      if (pris > 0) restant[l.produitCode] = dejaAvoir - pris;
      final ttc = CalculsPrix.arrondir(l.montantTtc - pris);
      if (ttc <= 0.004) continue;
      final ventile = Fiscalite.ventiler(ttc, l.tauxTva);
      lignes.add(
        FactureLigne(
          produitCode: l.produitCode,
          designation: l.designation,
          quantite: l.montantTtc == 0 ? l.quantite : CalculsPrix.arrondir(l.quantite * ttc / l.montantTtc),
          prixUnitaire: l.prixUnitaire,
          tauxTva: l.tauxTva,
          montantHt: pris == 0 ? l.montantHt : ventile.ht,
          montantTva: pris == 0 ? l.montantTva : ventile.tva,
          montantTtc: ttc,
        ),
      );
    }
    final v = (await VenteRepository(txn).vente(f.venteCode))!;
    return _construire(
      txn,
      type: TypesFacture.avoir,
      vente: v,
      lignes: lignes,
      timbre: 0,
      mode: f.modePaiement,
      utilisateurCode: utilisateurCode,
      origine: f.code,
      motif: motif,
    );
  }

  static Future<Facture> _construire(
    Transaction txn, {
    required String type,
    required Vente vente,
    required List<FactureLigne> lignes,
    required double timbre,
    required String mode,
    required String utilisateurCode,
    String? retourCode,
    String? origine,
    String? motif,
  }) async {
    final repo = FactureRepository(txn);
    final boutique = await BoutiqueRepository(txn).lire();
    final client = await txn.query('client', where: 'code = ?', whereArgs: [vente.clientCode]);
    String s(String k) => client.isEmpty ? '' : ((client.first[k] as String?) ?? '');
    double somme(double Function(FactureLigne) f) => CalculsPrix.arrondir(lignes.fold(0.0, (t, l) => t + f(l)));
    final ttc = somme((l) => l.montantTtc);
    final net = CalculsPrix.arrondir(ttc + timbre);
    final code = await repo.prochainCode(type == TypesFacture.avoir ? prefixeAvoir : prefixeFacture);
    final precedent = await repo.dernierHash() ?? Scellement.genese;
    final f = Facture(
      code: code,
      type: type,
      date: DateTime.now(),
      venteCode: vente.code,
      retourCode: retourCode,
      factureOrigine: origine,
      clientCode: vente.clientCode,
      vendeur: IdentiteFiscale(
        nom: boutique?.nom ?? '',
        adresse: boutique?.adresse ?? '',
        telephone: boutique?.telephone ?? '',
        nif: boutique?.nif ?? '',
        nis: boutique?.nis ?? '',
        rc: boutique?.rc ?? '',
        ai: boutique?.article ?? '',
      ),
      client: IdentiteFiscale(
        nom: s('nom'),
        adresse: s('adresse'),
        telephone: s('telephone'),
        nif: s('nif'),
        nis: s('nis'),
        rc: s('nrc'),
        ai: s('ai'),
      ),
      lignes: lignes,
      totalHt: somme((l) => l.montantHt),
      totalTva: somme((l) => l.montantTva),
      totalTtc: ttc,
      timbre: timbre,
      netAPayer: net,
      modePaiement: mode,
      montantLettres: MontantEnLettres.fr(net),
      utilisateurCode: utilisateurCode,
      motif: motif,
      hash: '',
      hashPrecedent: precedent,
    );
    final scellee = f.avecHash(Scellement.hacher(f.versCanonique(), precedent));
    await repo.inserer(scellee);
    await JournalFiscalRepository(txn).ajouter(
      type: type == TypesFacture.avoir ? TypesEvenementFiscal.avoir : TypesEvenementFiscal.facture,
      referenceCode: code,
      caisseCode: vente.caisseCode,
      utilisateurCode: utilisateurCode,
      montant: type == TypesFacture.avoir ? -net : net,
      details: {'hash': scellee.hash, 'vente': vente.code, 'origine': origine, 'tva': scellee.totalTva},
      date: scellee.date,
    );
    await HistoriqueRepository(txn).journaliser(
      utilisateurCode: utilisateurCode,
      action: type == TypesFacture.avoir ? 'Avoir' : 'Facture',
      entite: 'facture',
      entiteCode: code,
      detail: '${vente.code} · net $net${origine == null ? '' : ' · $origine'}',
    );
    return scellee;
  }

  /// Reste dû aujourd'hui sur la vente (audit m15) : reste figé au ticket moins les versements imputés depuis.
  Future<double> resteAujourdhui(Vente v) async {
    if (v.reste <= 0) return 0;
    final r = CalculsPrix.arrondir(v.reste - await TiersRepository(db).imputeSur('vente', v.code));
    return r > 0 ? r : 0;
  }

  /// Vérifie la chaîne des factures et avoirs ; `null` = intacte, sinon code du premier document altéré.
  Future<String?> verifierChaine() async {
    final tous = await _repo.factures();
    final i = Scellement.verifier([
      for (final f in tous) (doc: f.versCanonique(), hashPrecedent: f.hashPrecedent, hash: f.hash),
    ]);
    return i == null ? null : tous[i].code;
  }
}
