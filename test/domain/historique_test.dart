import 'package:caissedz_desktop/domain/historique.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ModulesHistorique', () {
    test('module déduit de l’entité, connexions à part', () {
      expect(ModulesHistorique.module('produit', 'Création'), 'produits');
      expect(ModulesHistorique.module('cloture', 'Clôture Z'), 'gestion_caisse');
      expect(ModulesHistorique.module('utilisateur', 'Modification'), 'utilisateurs');
      expect(ModulesHistorique.module('utilisateur', 'Connexion'), ModulesHistorique.connexion);
      expect(ModulesHistorique.module('inconnue', 'Création'), 'inconnue');
      expect(ModulesHistorique.module('export', 'Export', 'clotures_z'), 'gestion_caisse');
      expect(ModulesHistorique.module('export', 'Export', 'ventes'), 'ventes');
      expect(ModulesHistorique.module('sauvegarde', 'Sauvegarde'), 'parametres');
    });

    test('familles d’actions du DS', () {
      expect(ModulesHistorique.categorie('Encaissement'), CategorieAction.creation);
      expect(ModulesHistorique.categorie('Paramètres'), CategorieAction.modification);
      expect(ModulesHistorique.categorie('Désactivation'), CategorieAction.annulation);
      expect(ModulesHistorique.categorie('Déconnexion'), CategorieAction.connexion);
      expect(ModulesHistorique.categorie('Export'), CategorieAction.export);
      expect(ModulesHistorique.categorie('Sauvegarde'), CategorieAction.export);
    });

    test('code H à 6 chiffres', () {
      final e = EntreeHistorique(id: 42, date: DateTime(2026), utilisateurCode: 'USR0000', action: 'A', entite: 'b');
      expect(e.code, 'H000042');
    });
  });
}
