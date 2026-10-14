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
}

class CaisseException implements Exception {
  const CaisseException(this.erreur, [this.detail]);
  final ErreurCaisse erreur;
  final String? detail;
  @override
  String toString() => 'CaisseException($erreur${detail == null ? '' : ', $detail'})';
}

/// Gestion de caisse : caisses (Physique / Compte, avec ou sans magasin), journal des mouvements,
/// apports / dépenses, transferts TRF (= 2 mouvements dans UNE transaction).
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

  Future<Caisse> creer({required String nom, String type = TypesCaisse.physique, String? magasinCode}) async {
    _validerCaisse(nom, type);
    return db.transaction((txn) async {
      final repo = CaisseRepository(txn);
      await _verifierMagasin(txn, magasinCode);
      final code = await repo.prochainCode('caisse', CodeGenerator.caisse);
      final c = Caisse(code: code, nom: nom.trim(), type: type, magasinCode: magasinCode);
      await repo.insererCaisse(c);
      await HistoriqueRepository(txn)
          .journaliser(utilisateurCode: utilisateurCode, action: 'Création', entite: 'caisse', entiteCode: code);
      return c;
    });
  }

  Future<Caisse> modifier(Caisse c) async {
    _validerCaisse(c.nom, c.type);
    return db.transaction((txn) async {
      final repo = CaisseRepository(txn);
      final existante = await repo.caisse(c.code);
      if (existante == null) throw const CaisseException(ErreurCaisse.caisseInconnue);
      if (existante.systeme && !c.actif) throw const CaisseException(ErreurCaisse.caisseSysteme);
      await _verifierMagasin(txn, c.magasinCode);
      final maj = c.copyWith(nom: c.nom.trim());
      await repo.mettreAJourCaisse(maj);
      await HistoriqueRepository(txn)
          .journaliser(utilisateurCode: utilisateurCode, action: 'Modification', entite: 'caisse', entiteCode: c.code);
      return maj;
    });
  }

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
      final disponible = (await repo.solde(caisseSource)).parMode[mode] ?? 0;
      if (disponible + 0.0001 < montant) {
        throw CaisseException(ErreurCaisse.soldeInsuffisant, 'disponible $disponible');
      }
      final code = await repo.prochainCode('transfert_caisse', CodeGenerator.transfertCaisse);
      final d = DateTime.now();
      final t = TransfertCaisse(
        code: code,
        date: d,
        caisseSource: caisseSource,
        caisseDestination: caisseDestination,
        montant: CalculsPrix.arrondir(montant),
        mode: mode,
        utilisateurCode: utilisateurCode,
        commentaire: commentaire,
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
            commentaire: commentaire,
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

  void _validerCaisse(String nom, String type) {
    if (nom.trim().isEmpty) throw const CaisseException(ErreurCaisse.nomVide);
    if (!Referentiel.typesCaisse.contient(type)) throw const CaisseException(ErreurCaisse.typeInvalide);
  }

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
