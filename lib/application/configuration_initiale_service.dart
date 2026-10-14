import 'package:sqflite_common/sqlite_api.dart';

import '../core/db/migrations/v002_demarrage.dart';
import '../core/securite/mot_de_passe.dart';
import '../data/boutique_repository.dart';
import '../data/parametre_repository.dart';
import '../data/utilisateur_repository.dart';
import '../domain/models/boutique.dart';
import '../domain/models/parametres_vente.dart';
import 'auth_service.dart';

/// Données saisies dans l'assistant de configuration initiale (4 étapes).
class ConfigurationInitiale {
  const ConfigurationInitiale({
    required this.boutique,
    required this.adminIdentifiant,
    required this.adminNom,
    required this.adminMotDePasse,
    required this.parametres,
    this.langue = 'fr',
  });

  final Boutique boutique;
  final String adminIdentifiant;
  final String adminNom;
  final String adminMotDePasse;
  final ParametresVente parametres;
  final String langue;
}

/// Configuration initiale : boutique, administrateur, paramètres de vente — en UNE transaction.
class ConfigurationInitialeService {
  const ConfigurationInitialeService(this.db, {this.hachage = const MotDePasse()});

  final Database db;
  final MotDePasse hachage;

  Future<bool> estTerminee() async =>
      await ParametreRepository(db).lire(ParametreRepository.cleConfigurationTerminee) == '1';

  /// Valide puis enregistre toute la configuration. En cas d'échec, rien n'est écrit.
  Future<void> terminer(ConfigurationInitiale c) async {
    if (c.boutique.nom.trim().isEmpty) throw ArgumentError('Le nom de la boutique est obligatoire');
    if (!AuthService.identifiantValide(c.adminIdentifiant)) {
      throw const CompteException(ErreurCompte.identifiantInvalide);
    }
    if (c.adminMotDePasse.length < AuthService.longueurMinMotDePasse) {
      throw const CompteException(ErreurCompte.motDePasseTropCourt);
    }
    if (c.parametres.margeDefautPct < 0 || c.parametres.margeDefautPct > 1000) {
      throw ArgumentError('Marge par défaut hors limites');
    }
    final empreinte = hachage.hacher(c.adminMotDePasse);
    await db.transaction((txn) async {
      final utilisateurs = UtilisateurRepository(txn);
      if (!await utilisateurs.identifiantDisponible(c.adminIdentifiant, saufCode: MigrationV002Demarrage.codeAdmin)) {
        throw const CompteException(ErreurCompte.identifiantPris);
      }
      await BoutiqueRepository(txn).ecrire(c.boutique.copyWith(nom: c.boutique.nom.trim()));
      await utilisateurs.mettreAJour(MigrationV002Demarrage.codeAdmin, {
        'identifiant': c.adminIdentifiant.trim(),
        'nom': c.adminNom.trim().isEmpty ? 'Administrateur' : c.adminNom.trim(),
        'mot_de_passe': empreinte,
        'actif': 1,
      });
      final parametres = ParametreRepository(txn);
      await parametres.ecrirePlusieurs(c.parametres.versCles());
      await parametres.ecrire('langue', c.langue);
      await parametres.ecrire(ParametreRepository.cleConfigurationTerminee, '1');
    });
  }
}
