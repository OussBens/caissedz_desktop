import 'code_generator.dart';
import 'historique.dart';
import 'models/retour.dart';

/// Points rouges de nouvelle activité : chaque opération journalisée (Historique) allume les onglets des modules
/// qu'elle touche, sous la forme « module#onglet » ; consulter l'onglet l'éteint.
///
/// Exemple : une vente allume Ventes › Paniers, Gestion caisse › Mouvements, Stock › Mouvements et, hors client de
/// passage, Clients.
abstract final class PastillesModules {
  static String cible(String module, int onglet) => '$module#$onglet';

  /// Module d'une cible « module#onglet ».
  static String module(String cible) => cible.split('#').first;

  // Onglets des pages (ordre de `PageModule.onglets`).
  static const _mouvementsCaisse = 'gestion_caisse#3';
  static const _mouvementsStock = 'stock#1';

  /// Cibles allumées par une ligne d'historique. [tiersType] : type du tiers d'un retour ou d'un versement ;
  /// [clientCode] : client d'une vente ou d'une livraison.
  static Set<String> cibles({
    required String entite,
    required String action,
    String? entiteCode,
    String? tiersType,
    String? clientCode,
  }) {
    if (entite == 'export' || entite == 'parametre' || entite == 'sauvegarde') return const {};
    if (ModulesHistorique.categorie(action) case CategorieAction.connexion || CategorieAction.export) return const {};
    final client = clientCode != null && clientCode != 'CLN0000' ? 'clients#0' : null;
    final tiers = tiersType == TypesTiers.fournisseur ? 'fournisseurs' : 'clients';
    final code = entiteCode ?? '';
    return switch (entite) {
      'vente' => {'ventes#0', _mouvementsCaisse, _mouvementsStock, ?client},
      'facture' => {'ventes#1'},
      'document_client' => {
        code.startsWith(CodeGenerator.proforma)
            ? 'documents#1'
            : code.startsWith(CodeGenerator.commandeClient)
            ? 'documents#2'
            : 'documents#0',
      },
      'bon_livraison' => {'documents#3', 'documents#2', 'ventes#0', _mouvementsCaisse, _mouvementsStock, ?client},
      'retour' => {tiersType == TypesTiers.fournisseur ? 'retours#1' : 'retours#0', _mouvementsStock, '$tiers#0'},
      'achat' => {'entrees#0', _mouvementsStock, 'fournisseurs#0', _mouvementsCaisse},
      'commande_fournisseur' => {'commandes_fournisseurs#0'},
      'sortie_stock' => {'sorties#0', _mouvementsStock},
      'transfert_stock' => {'magasins#1', _mouvementsStock},
      'besoin' => {'besoins#0'},
      'versement' => {'$tiers#1', '$tiers#0', _mouvementsCaisse},
      'client' => {'clients#0'},
      'fournisseur' => {'fournisseurs#0'},
      'produit' => {'produits#0'},
      'categorie' => {'produits#1'},
      'sous_categorie' => {'produits#2'},
      'remise' => {'produits#3'},
      'pack' => {'produits#4'},
      'magasin' => {'magasins#0'},
      'caisse' => {'gestion_caisse#0'},
      'transfert_caisse' => {'gestion_caisse#1', _mouvementsCaisse},
      'cloture' => {'gestion_caisse#2'},
      'mouvement_caisse' => {_mouvementsCaisse},
      'session_caisse' => {'gestion_caisse#4', _mouvementsCaisse},
      'inventaire' => {'stock#0', _mouvementsStock},
      'zakat' => {'zakat#0'},
      'utilisateur' => {'utilisateurs#0'},
      'role' => {'utilisateurs#1'},
      _ => const {},
    };
  }
}
