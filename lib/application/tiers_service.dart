import 'package:sqflite_common/sqlite_api.dart';

import '../data/client_repository.dart';
import '../data/historique_repository.dart';
import '../data/tiers_repository.dart';
import '../domain/code_generator.dart';
import '../domain/models/tiers.dart';

enum ErreurTiers { nomVide, systeme, inconnu }

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

  Future<Client> creerClient(Client c) async {
    if (c.nom.trim().isEmpty) throw const TiersException(ErreurTiers.nomVide);
    return db.transaction((txn) async {
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
    if (c.nom.trim().isEmpty) throw const TiersException(ErreurTiers.nomVide);
    await ClientRepository(db).mettreAJour(c.copyWith(nom: c.nom.trim()));
  }

  Future<Fournisseur> creerFournisseur(Fournisseur f) async {
    if (f.nom.trim().isEmpty) throw const TiersException(ErreurTiers.nomVide);
    return db.transaction((txn) async {
      final repo = TiersRepository(txn);
      final code = await repo.prochainCode('fournisseur', CodeGenerator.fournisseur);
      final fournisseur = Fournisseur(
        code: code,
        nom: f.nom.trim(),
        telephone: f.telephone.trim(),
        adresse: f.adresse.trim(),
        email: f.email.trim(),
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
    if (f.nom.trim().isEmpty) throw const TiersException(ErreurTiers.nomVide);
    await TiersRepository(db).mettreAJourFournisseur(f.copyWith(nom: f.nom.trim()));
  }
}
