import 'package:sqflite_common/sqlite_api.dart';

import '../data/caisse_repository.dart';
import '../data/historique_repository.dart';
import '../domain/calculs_prix.dart';
import '../domain/code_generator.dart';
import '../domain/models/caisse.dart';
import '../domain/referentiel/referentiel.dart';

enum ErreurCaisse {
  nomVide,
  typeInvalide,
  magasinInconnu,
  caisseInconnue,
  caisseInactive,
  caisseSysteme,
  montantInvalide,
  modeInvalide,
  memeCaisse,
  soldeInsuffisant,
  sessionOuverte,
  soldeNonNul,
  transfertInconnu,
  dejaAnnule,
  motifObligatoire,
  periodeCloturee,
}

class CaisseException implements Exception {
  const CaisseException(this.erreur, [this.detail]);
  final ErreurCaisse erreur;
  final String? detail;
  @override
  String toString() => 'CaisseException($erreur${detail == null ? '' : ', $detail'})';
}

/// Gestion de caisse (§9.13) : caisses (Physique / Compte, solde initial proposé comme fond d'ouverture),
/// journal des mouvements, apports / dépenses, transferts TRF (= 2 mouvements dans UNE transaction) et leur
/// annulation (mouvements retirés du journal, transfert conservé avec son motif).
class CaisseService {
  const CaisseService(this.db, {required this.utilisateurCode});

  final Database db;
  final String utilisateurCode;

  CaisseRepository get _repo => CaisseRepository(db);

  /// Journalise un mouvement dans la transaction courante (utilisé par les autres services).
  static Future<int> journaliser(
    DatabaseExecutor ex, {
    required String caisseCode,
    required String type,
    required String sens,
    required double montant,
    required String utilisateurCode,
    String mode = 'Espèces',
    String? referenceType,
    String? referenceCode,
    String? commentaire,
    DateTime? date,
  }) {
    final m = CalculsPrix.arrondir(montant);
    if (m <= 0) return Future.value(0);
    return CaisseRepository(ex).insererMouvement(
      MouvementCaisse(
        date: date ?? DateTime.now(),
        caisseCode: caisseCode,
        type: type,
        sens: sens,
        montant: m,
        mode: mode,
        referenceType: referenceType,
        referenceCode: referenceCode,
        utilisateurCode: utilisateurCode,
        commentaire: commentaire,
      ),
    );
  }

  // ---- Caisses ----
  Future<List<Caisse>> caisses({bool actives = false}) => _repo.caisses(actives: actives);

  /// Code qu'aura la prochaine caisse créée (affiché dans le formulaire).
  Future<String> prochainCode() => _repo.prochainCode('caisse', CodeGenerator.caisse);

  Future<Caisse> creer({
    required String nom,
    String type = TypesCaisse.physique,
    String? magasinCode,
    double soldeInitial = 0,
    String? observation,
  }) async {
    _validerCaisse(nom, type, soldeInitial);
    return db.transaction((txn) async {
      final repo = CaisseRepository(txn);
      await _verifierMagasin(txn, magasinCode);
      final code = await repo.prochainCode('caisse', CodeGenerator.caisse);
      final c = Caisse(
        code: code,
        nom: nom.trim(),
        type: type,
        magasinCode: magasinCode,
        soldeInitial: CalculsPrix.arrondir(soldeInitial),
        observation: _texte(observation),
      );
      await repo.insererCaisse(c);
      await HistoriqueRepository(txn)
          .journaliser(utilisateurCode: utilisateurCode, action: 'Création', entite: 'caisse', entiteCode: code);
      return c;
    });
  }

  /// Modifie une caisse ; sa désactivation suit les règles de [blocageDesactivation].
  Future<Caisse> modifier(Caisse c) async {
    _validerCaisse(c.nom, c.type, c.soldeInitial);
    return db.transaction((txn) async {
      final repo = CaisseRepository(txn);
      final existante = await repo.caisse(c.code);
      if (existante == null) throw const CaisseException(ErreurCaisse.caisseInconnue);
      if (existante.actif && !c.actif) {
        final e = await _blocageDesactivation(txn, existante);
        if (e != null) throw CaisseException(e);
      }
      await _verifierMagasin(txn, c.magasinCode);
      final maj = c.copyWith(nom: c.nom.trim(), observation: () => _texte(c.observation));
      await repo.mettreAJourCaisse(maj);
      await HistoriqueRepository(txn)
          .journaliser(utilisateurCode: utilisateurCode, action: 'Modification', entite: 'caisse', entiteCode: c.code);
      return maj;
    });
  }

  /// Raison empêchant de désactiver [c] : caisse système, session ouverte, ou solde non nul (à transférer).
  Future<ErreurCaisse?> blocageDesactivation(Caisse c) => _blocageDesactivation(db, c);

  Future<ErreurCaisse?> _blocageDesactivation(DatabaseExecutor ex, Caisse c) async {
    if (c.systeme) return ErreurCaisse.caisseSysteme;
    if (!c.actif) return ErreurCaisse.caisseInactive;
    final ouvertes = await ex.query(
      'session_caisse',
      columns: ['code'],
      where: 'caisse_code = ? AND statut = ?',
      whereArgs: [c.code, 'Ouverte'],
      limit: 1,
    );
    if (ouvertes.isNotEmpty) return ErreurCaisse.sessionOuverte;
    if ((await CaisseRepository(ex).solde(c.code)).total.abs() >= 0.005) return ErreurCaisse.soldeNonNul;
    return null;
  }

  /// Désactive plusieurs caisses dans UNE transaction (refus global si l'une est bloquée).
  Future<void> desactiver(List<String> codes) => db.transaction((txn) async {
    final repo = CaisseRepository(txn);
    for (final code in codes) {
      final c = await repo.caisse(code);
      if (c == null) throw const CaisseException(ErreurCaisse.caisseInconnue);
      final e = await _blocageDesactivation(txn, c);
      if (e != null) throw CaisseException(e, code);
      await repo.mettreAJourCaisse(c.copyWith(actif: false));
      await HistoriqueRepository(txn)
          .journaliser(utilisateurCode: utilisateurCode, action: 'Désactivation', entite: 'caisse', entiteCode: code);
    }
  });

  Future<SoldeCaisse> solde(String caisseCode) => _repo.solde(caisseCode);

  Future<List<MouvementCaisse>> mouvements({String? caisseCode, int limite = 1000}) =>
      _repo.mouvements(caisseCode: caisseCode, limite: limite);

  Future<List<TransfertCaisse>> transferts() => _repo.transferts();

  /// Apport (entrée) ou dépense (sortie) manuel.
  Future<MouvementCaisse> mouvementManuel({
    required String caisseCode,
    required bool apport,
    required double montant,
    String mode = 'Espèces',
    String? commentaire,
  }) async {
    if (montant <= 0) throw const CaisseException(ErreurCaisse.montantInvalide);
    if (!Referentiel.modesPaiement.contient(mode) || mode == 'Points') {
      throw const CaisseException(ErreurCaisse.modeInvalide);
    }
    return db.transaction((txn) async {
      final repo = CaisseRepository(txn);
      await _verifierCaisse(repo, caisseCode);
      final m = MouvementCaisse(
        date: DateTime.now(),
        caisseCode: caisseCode,
        type: apport ? TypesMouvementCaisse.apport : TypesMouvementCaisse.depense,
        sens: apport ? SensMouvementCaisse.entree : SensMouvementCaisse.sortie,
        montant: CalculsPrix.arrondir(montant),
        mode: mode,
        utilisateurCode: utilisateurCode,
        commentaire: commentaire,
      );
      final id = await repo.insererMouvement(m);
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: apport ? 'Apport' : 'Dépense',
        entite: 'mouvement_caisse',
        entiteCode: '$id',
        detail: '$caisseCode $montant',
      );
      return MouvementCaisse.depuisLigne({...m.versLigne(), 'id': id});
    });
  }

  /// Transfert TRF entre deux caisses : UNE transaction, 2 mouvements (sortie source, entrée destination).
  Future<TransfertCaisse> transferer({
    required String caisseSource,
    required String caisseDestination,
    required double montant,
    String mode = 'Espèces',
    String? commentaire,
    DateTime? date,
  }) async {
    if (montant <= 0) throw const CaisseException(ErreurCaisse.montantInvalide);
    if (caisseSource == caisseDestination) throw const CaisseException(ErreurCaisse.memeCaisse);
    if (!Referentiel.modesPaiement.contient(mode) || mode == 'Points') {
      throw const CaisseException(ErreurCaisse.modeInvalide);
    }
    return db.transaction((txn) async {
      final repo = CaisseRepository(txn);
      await _verifierCaisse(repo, caisseSource);
      await _verifierCaisse(repo, caisseDestination);
      final d = date ?? DateTime.now();
      if (await repo.periodeCloturee(d)) throw const CaisseException(ErreurCaisse.periodeCloturee);
      final disponible = (await repo.solde(caisseSource)).parMode[mode] ?? 0;
      if (disponible + 0.0001 < montant) {
        throw CaisseException(ErreurCaisse.soldeInsuffisant, 'disponible $disponible');
      }
      final code = await repo.prochainCode('transfert_caisse', CodeGenerator.transfertCaisse);
      final t = TransfertCaisse(
        code: code,
        date: d,
        caisseSource: caisseSource,
        caisseDestination: caisseDestination,
        montant: CalculsPrix.arrondir(montant),
        mode: mode,
        utilisateurCode: utilisateurCode,
        commentaire: _texte(commentaire),
      );
      await repo.insererTransfert(t);
      for (final (caisse, sens) in [
        (caisseSource, SensMouvementCaisse.sortie),
        (caisseDestination, SensMouvementCaisse.entree),
      ]) {
        await repo.insererMouvement(
          MouvementCaisse(
            date: d,
            caisseCode: caisse,
            type: TypesMouvementCaisse.transfert,
            sens: sens,
            montant: t.montant,
            mode: mode,
            referenceType: 'transfert_caisse',
            referenceCode: code,
            utilisateurCode: utilisateurCode,
            commentaire: t.commentaire,
          ),
        );
      }
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Transfert',
        entite: 'transfert_caisse',
        entiteCode: code,
        detail: '$caisseSource → $caisseDestination $montant',
      );
      return t;
    });
  }

  /// Raison empêchant d'annuler [t] : déjà annulé, période clôturée, ou solde de la caisse destinataire
  /// devenu insuffisant pour reprendre le montant.
  Future<ErreurCaisse?> blocageAnnulationTransfert(TransfertCaisse t) => _blocageTransfert(db, t);

  Future<ErreurCaisse?> _blocageTransfert(DatabaseExecutor ex, TransfertCaisse t) async {
    if (!t.actif) return ErreurCaisse.dejaAnnule;
    final repo = CaisseRepository(ex);
    if (await repo.periodeCloturee(t.date)) return ErreurCaisse.periodeCloturee;
    final disponible = (await repo.solde(t.caisseDestination)).parMode[t.mode] ?? 0;
    if (disponible + 0.0001 < t.montant) return ErreurCaisse.soldeInsuffisant;
    return null;
  }

  /// Annule des transferts dans UNE transaction : leurs 2 mouvements quittent le journal (soldes rétablis),
  /// le transfert reste visible, marqué annulé avec son motif.
  Future<void> annulerTransferts(List<String> codes, {required String motif}) async {
    if (motif.trim().isEmpty) throw const CaisseException(ErreurCaisse.motifObligatoire);
    return db.transaction((txn) async {
      final repo = CaisseRepository(txn);
      for (final code in codes) {
        final t = await repo.transfert(code);
        if (t == null) throw const CaisseException(ErreurCaisse.transfertInconnu);
        final e = await _blocageTransfert(txn, t);
        if (e != null) throw CaisseException(e, code);
        await repo.supprimerMouvementsReference('transfert_caisse', code);
        await repo.annulerTransfert(code, par: utilisateurCode, motif: motif.trim(), le: DateTime.now());
        await HistoriqueRepository(txn).journaliser(
          utilisateurCode: utilisateurCode,
          action: 'Annulation',
          entite: 'transfert_caisse',
          entiteCode: code,
          detail: motif.trim(),
        );
      }
    });
  }

  void _validerCaisse(String nom, String type, double soldeInitial) {
    if (nom.trim().isEmpty) throw const CaisseException(ErreurCaisse.nomVide);
    if (!Referentiel.typesCaisse.contient(type)) throw const CaisseException(ErreurCaisse.typeInvalide);
    if (soldeInitial < 0) throw const CaisseException(ErreurCaisse.montantInvalide);
  }

  static String? _texte(String? s) => s == null || s.trim().isEmpty ? null : s.trim();

  Future<void> _verifierMagasin(DatabaseExecutor ex, String? magasinCode) async {
    if (magasinCode == null) return;
    final rows = await ex.query('magasin', columns: ['code'], where: 'code = ?', whereArgs: [magasinCode]);
    if (rows.isEmpty) throw const CaisseException(ErreurCaisse.magasinInconnu);
  }

  Future<void> _verifierCaisse(CaisseRepository repo, String code) async {
    final c = await repo.caisse(code);
    if (c == null) throw const CaisseException(ErreurCaisse.caisseInconnue);
    if (!c.actif) throw const CaisseException(ErreurCaisse.caisseInactive);
  }
}
