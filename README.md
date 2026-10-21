# CaisseDZ Desktop

Logiciel de point de vente (caisse), gestion de stock et gestion commerciale pour Windows, en Flutter.
Hors ligne d'abord : base SQLite chiffrée (SQLCipher) sur le poste ; internet ne sert qu'aux services BENS.
Interface en français, arabe (de droite à gauche) et anglais.

## Ce que fait l'application

- **Vente** : Caisse (panier, codes-barres, colis et packs, remises, paiements mixtes, crédit client, tickets
  ESC/POS et PDF), Ventes, Retours, Gestion de caisse (sessions, mouvements, clôtures Z scellées SHA-256).
- **Catalogue et stock** : Produits (nom arabe, emballages, variantes, codes multiples, import Excel), Stock
  (journal des mouvements), Entrées (dont Smart Scan, la lecture IA des factures), Sorties, Transferts,
  Magasins, Besoins, Commandes fournisseurs.
- **Commercial et tiers** : Documents (devis, proforma, bons de commande et de livraison, factures),
  Clients, Fournisseurs, Versements, Situation, Zakat.
- **Administration** : Utilisateurs et rôles, Historique, Paramètres, Tableau de bord.
- **Formules** : Basic, Advanced, Ultra, chacune avec 14 jours d'essai ; licence BENS signée, liée au poste
  (`CD-XXXX-XXXX`) et vérifiée hors ligne ; fin de l'essai : lecture seule.

## Services en ligne (BENS)

| Service | Serveur | |
|---|---|---|
| Compte BENS, licences, formules, packs Smart Scan | bensds.com (`bens_ds`) | inscription, connexion, check-in au lancement |
| Catalogue BENS | catalog-api.bensds.com | rayons à l'accueil (5 000 produits par rayon, sans prix), recherche par code-barres |
| Tendance | catalog-api.bensds.com | au lancement : tickets par code-barres et fiches de la boutique envoyés (ni prix, ni quantités, ni clients) ; produits devenus tendance ajoutés aux rayons téléchargés |
| Smart Scan | catalog-api.bensds.com | OCR des factures, scans comptés par bens_ds |
| CaisseDZ Scan (téléphone) | le poste lui-même, sur le Wi-Fi | ventes, stock, produits, entrées et photos de factures depuis un téléphone appairé par QR code |

Hors ligne, tout continue ; les envois attendent le lancement suivant.

## Documentation

- Guide de développement (stack, architecture, règles) : `CLAUDE.md`
- Plan par lots et état de chaque lot : `docs/PLAN.md`
- Checklist de conformité (§15) : `docs/CONFORMITE.md`
- Build Windows (release, MSIX ou Inno Setup) : `docs/BUILD_WINDOWS.md`
- Sources de vérité attendues : `docs/spec/06_specification_reconstruction.md` et `docs/design/CaisseDZ-DS-v2.2/`

## Commandes

```bash
flutter pub get                      # dépendances
dart run build_runner build -d       # code généré (après modification des modèles)
flutter gen-l10n                     # traductions FR / AR / EN (lib/core/i18n/arb/*.arb)
flutter analyze                      # doit être vert
flutter test                         # doit être vert
flutter run -d windows               # lancer l'application
flutter build windows --release      # build Windows
```

`run` et `build windows` demandent Windows et Visual Studio (Desktop development with C++) ; `analyze` et
`test` fonctionnent partout. Branche principale : `main`.
