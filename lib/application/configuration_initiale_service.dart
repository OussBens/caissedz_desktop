import 'package:sqflite_common/sqlite_api.dart';

import '../data/boutique_repository.dart';
import '../data/historique_repository.dart';
import '../data/parametre_repository.dart';
import '../domain/models/boutique.dart';
import '../domain/models/parametres_paiement.dart';
import '../domain/models/parametres_vente.dart';

enum ErreurConfiguration { nomBoutiqueVide, margeHorsLimites, seuilInvalide, deviseVide }

class ConfigurationException implements Exception {
  const ConfigurationException(this.erreur);
  final ErreurConfiguration erreur;
  @override
  String toString() => 'ConfigurationException($erreur)';
}

/// Données de l'assistant de configuration initiale (§4.5, 4 étapes) : langue et devise, boutique,
/// paiements, marge et stock.
class ConfigurationInitiale {
  const ConfigurationInitiale({
    required this.boutique,
    this.langue = 'fr',
    this.paiements = const ParametresPaiement(),
    this.parametres = const ParametresVente(),
  });

  final String langue;
  final Boutique boutique;
  final ParametresPaiement paiements;

  /// Marge, seuil de rupture, fidélité, devise et décimales des quantités.
  final ParametresVente parametres;
}

/// Configuration initiale, proposée à l'administrateur à sa première connexion — en UNE transaction.
class ConfigurationInitialeService {
  const ConfigurationInitialeService(this.db);

  final Database db;

  Future<bool> estTerminee() async =>
      await ParametreRepository(db).lire(ParametreRepository.cleConfigurationTerminee) == '1';

  /// Valeurs déjà enregistrées (reprise de l'assistant après « Plus tard »).
  Future<ConfigurationInitiale> lire() async {
    final parametres = ParametreRepository(db);
    final m = await parametres.lirePlusieurs([...ParametresVente.cles, ...ParametresPaiement.cles, 'langue']);
    return ConfigurationInitiale(
      boutique: await BoutiqueRepository(db).lire() ?? const Boutique(nom: ''),
      langue: m['langue'] ?? 'fr',
      paiements: ParametresPaiement.depuisCles(m),
      parametres: ParametresVente.depuisCles(m),
    );
  }

  /// Valide puis enregistre toute la configuration. En cas d'échec, rien n'est écrit.
  Future<void> terminer(ConfigurationInitiale c, {required String utilisateurCode}) async {
    if (c.boutique.nom.trim().isEmpty) throw const ConfigurationException(ErreurConfiguration.nomBoutiqueVide);
    final p = c.parametres;
    if (p.margeDefautPct < 0 || p.margeDefautPct > 1000) {
      throw const ConfigurationException(ErreurConfiguration.margeHorsLimites);
    }
    if (p.seuilStockGlobal < 0) throw const ConfigurationException(ErreurConfiguration.seuilInvalide);
    if (p.devise.trim().isEmpty) throw const ConfigurationException(ErreurConfiguration.deviseVide);
    await db.transaction((txn) async {
      await BoutiqueRepository(txn).ecrire(c.boutique.copyWith(nom: c.boutique.nom.trim()));
      final parametres = ParametreRepository(txn);
      await parametres.ecrirePlusieurs(p.copyWith(devise: p.devise.trim()).versCles());
      await parametres.ecrirePlusieurs(c.paiements.versCles());
      await parametres.ecrire('langue', c.langue);
      await parametres.ecrire(ParametreRepository.cleConfigurationTerminee, '1');
      await HistoriqueRepository(txn)
          .journaliser(utilisateurCode: utilisateurCode, action: 'Configuration initiale', entite: 'parametre');
    });
  }
}
