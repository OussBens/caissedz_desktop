import 'package:sqflite_common/sqlite_api.dart';

import '../data/client_repository.dart';
import '../data/historique_repository.dart';
import '../data/tiers_repository.dart';
import '../domain/code_generator.dart';
import '../domain/models/retour.dart';
import '../domain/models/tiers.dart';

enum ErreurTiers { nomVide, systeme, inconnu, nomExistant, telephoneInvalide, nifInvalide, motifObligatoire }

class TiersException implements Exception {
  const TiersException(this.erreur);
  final ErreurTiers erreur;
  @override
  String toString() => 'TiersException($erreur)';
}

/// Clients et fournisseurs : création, modification, (dés)activation.
class TiersService {
  const TiersService(this.db, {required this.utilisateurCode});

  final Database db;
  final String utilisateurCode;

  /// Téléphone algérien : mobile 05 / 06 / 07 (10 chiffres) ou fixe 02 / 03 / 04 (9 chiffres).
  static bool telephoneValide(String t) {
    final s = t.replaceAll(RegExp(r'[\s.-]'), '');
    return s.isEmpty || RegExp(r'^0[5-7]\d{8}$').hasMatch(s) || RegExp(r'^0[2-4]\d{7}$').hasMatch(s);
  }

  /// NIF : 15 chiffres.
  static bool nifValide(String nif) => nif.isEmpty || RegExp(r'^\d{15}$').hasMatch(nif);

  void _valider(String nom, String telephone, FicheTiers fiche) {
    if (nom.trim().isEmpty) throw const TiersException(ErreurTiers.nomVide);
    if (!telephoneValide(telephone.trim())) throw const TiersException(ErreurTiers.telephoneInvalide);
    if (!nifValide(fiche.nif.trim())) throw const TiersException(ErreurTiers.nifInvalide);
  }

  Future<void> _nomUnique(DatabaseExecutor txn, String table, String nom, {String? sauf}) async {
    final rows = await txn.query(
      table,
      columns: ['code'],
      where: 'LOWER(nom) = LOWER(?)${sauf == null ? '' : ' AND code != ?'}',
      whereArgs: [nom.trim(), ?sauf],
    );
    if (rows.isNotEmpty) throw const TiersException(ErreurTiers.nomExistant);
  }

  Future<Client> creerClient(Client c) async {
    _valider(c.nom, c.telephone, c.fiche);
    return db.transaction((txn) async {
      await _nomUnique(txn, 'client', c.nom);
      final repo = ClientRepository(txn);
      final code = await repo.prochainCode();
      final client = Client(
        code: code,
        nom: c.nom.trim(),
        telephone: c.telephone.trim(),
        adresse: c.adresse.trim(),
        email: c.email.trim(),
        plafondCredit: c.plafondCredit,
        actif: true,
        fiche: c.fiche,
      );
      await repo.inserer(client);
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Création',
        entite: 'client',
        entiteCode: code,
        detail: client.nom,
      );
      return client;
    });
  }

  Future<void> modifierClient(Client c) async {
    if (c.systeme) throw const TiersException(ErreurTiers.systeme);
    _valider(c.nom, c.telephone, c.fiche);
    await db.transaction((txn) async {
      await _nomUnique(txn, 'client', c.nom, sauf: c.code);
      await ClientRepository(txn).mettreAJour(c.copyWith(nom: c.nom.trim()));
      await HistoriqueRepository(txn)
          .journaliser(utilisateurCode: utilisateurCode, action: 'Modification', entite: 'client', entiteCode: c.code);
    });
  }

  Future<Fournisseur> creerFournisseur(Fournisseur f) async {
    _valider(f.nom, f.telephone, f.fiche);
    return db.transaction((txn) async {
      await _nomUnique(txn, 'fournisseur', f.nom);
      final repo = TiersRepository(txn);
      final code = await repo.prochainCode('fournisseur', CodeGenerator.fournisseur);
      final fournisseur = Fournisseur(
        code: code,
        nom: f.nom.trim(),
        telephone: f.telephone.trim(),
        adresse: f.adresse.trim(),
        email: f.email.trim(),
        fiche: f.fiche,
      );
      await repo.insererFournisseur(fournisseur);
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Création',
        entite: 'fournisseur',
        entiteCode: code,
        detail: fournisseur.nom,
      );
      return fournisseur;
    });
  }

  Future<void> modifierFournisseur(Fournisseur f) async {
    if (f.systeme) throw const TiersException(ErreurTiers.systeme);
    _valider(f.nom, f.telephone, f.fiche);
    await db.transaction((txn) async {
      await _nomUnique(txn, 'fournisseur', f.nom, sauf: f.code);
      await TiersRepository(txn).mettreAJourFournisseur(f.copyWith(nom: f.nom.trim()));
      await HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Modification',
        entite: 'fournisseur',
        entiteCode: f.code,
      );
    });
  }

  /// Annulation (désactivation) de tiers avec motif ; les tiers système sont ignorés.
  /// Retourne le nombre de tiers annulés.
  Future<int> annuler(String tiersType, List<String> codes, {required String motif}) async {
    if (motif.trim().isEmpty) throw const TiersException(ErreurTiers.motifObligatoire);
    final table = tiersType == TypesTiers.client ? 'client' : 'fournisseur';
    return db.transaction((txn) async {
      var n = 0;
      for (final code in codes) {
        n += await txn.update(table, {'actif': 0}, where: 'code = ? AND systeme = 0', whereArgs: [code]);
        await HistoriqueRepository(txn).journaliser(
          utilisateurCode: utilisateurCode,
          action: 'Annulation',
          entite: table,
          entiteCode: code,
          detail: motif.trim(),
        );
      }
      return n;
    });
  }
}
