# CaisseDZ Design System v2.2 — fichiers sources

Version 2.2 du design system « CaisseDZ Design Profondu » : le plan d'action (5 phases) appliqué à la v2.1.

## Contenu

| Dossier / fichier | Rôle |
|---|---|
| `CaisseDZ-DS-v2.2.html` | La page complète, autonome : ouvrez-la dans un navigateur, sans connexion. |
| `nouveaux-composants/` | Les **nouveaux** composants et écrans v2.2, en JSX (à ajouter au projet). |
| `donnees/ref.js` | Référentiel unique des listes de valeurs (FR / AR / EN) et codification §8.10. |
| `donnees/grid.json` | Grille de conformité re-notée (172 exigences, v2.1 → v2.2). |
| `bundle-v2.2/` | Le bundle v2.1 **corrigé** (composants + kits) et les données de démo corrigées, plus le script `harmonize.py` qui liste chaque correction. |
| `page/` | Le code de la page unique (navigation, sections, galerie). |

## Importer dans Claude Design

1. **Nouveaux fichiers** : ajoutez au projet les fichiers de `nouveaux-composants/`
   - `charts.jsx` → `components/data/` (LineChart, RankedBars)
   - `components.jsx` → `components/` (ContextMenu, Calculator, Code128, QRCode, BarcodeCardV22, CodeBarrePickerDialog, NombreField, CartLineQN, QuantiteNombreDialog, AccessDenied)
   - `previews.jsx` → `components/overlays/` (TicketThermique, FactureA4, ExcelSheet, PreviewDialog)
   - `screens.jsx` → `ui_kits/desktop/` (DashboardV22, ParametresV22, ProduitIADialog, ProduitDetailleDialog, VersementImputationDialog, NombreShowcase, états métier, raccourcis…)
   - Ces fichiers utilisent `import` : dans Claude Design, remplacez les imports par l'accès global (`window.CaisseDZDesignSystem_9ce617`) comme dans les autres kits, ou demandez-le à Claude Design.
2. **Corrections des fichiers existants** : appliquez la liste ci-dessous (chaque ligne = un fichier du projet). Le plus simple : collez cette section dans Claude Design comme consigne.

## Corrections à appliquer aux fichiers existants

**Composants**
- `components/actions/Button.jsx` — garde anti double-clic : ignorer un clic à moins de 450 ms du précédent ; si `onClick` renvoie une promesse, afficher le chargement jusqu'à sa fin.
- `components/data/DataTable.jsx` — prop `onRowContextMenu(row, event)` sur chaque ligne (clic droit).
- `components/core/LicenseGate.jsx` — nouvel état `kind="refuse"` : icône `shield-x`, titre « Accès refusé », action « Retour au tableau de bord ».
- `components/module/StatusBadge.jsx` — statuts `commande` (info, « Commande ») et `disponible` (success, « Disponible »).
- `components/core/Logo.jsx` — glyphe par défaut intégré (plus de lien vers un PNG absent).

**Kits (ui_kits/desktop)**
- `ShellKit.jsx` — clé de licence SHA-256 : `KeyInput groups={8} size={8}`, clé complète = 64 caractères ; carte d'activation `maxWidth: 700` ; `Logo size={32}` ; Smart Scan IA retiré du palier Avancé (« selon quota serveur » sur les deux paliers).
- `GestionKit.jsx` — types de caisse **Physique / Compte** ; champ et colonne « Magasin » retirés de la caisse ; « Crédit client » → « Points » dans le rapport Z ; export fiscal : ajout du « JSON de contrôle » ; Historique « accès selon le rôle ».
- `UtilisateursKit.jsx` — « Paramètres et Historique s'attribuent comme les autres modules. »
- `StockKit.jsx` — drapeau « Principal » retiré des magasins (principal = premier magasin de l'utilisateur) ; statuts des besoins **En attente / Commande / Disponible**.
- `PaniersScreen.jsx`, `CaisseKit.jsx`, `CaisseScreen.jsx` — modes de paiement : Espèces, Carte CIB, Chèque, Virement, **Points fidélité** (« Crédit » retiré : le crédit est un reste) ; Encaisser BL / SC affiche le N° de panier (PN).
- `ParametresScreen.jsx` — modes de paiement sans « Crédit client » ni « Edahabia » ; « Bloquer la vente en rupture » remplacé par « Garde de stock » toujours active ; Smart Scan IA retiré du texte de licence.
- `FournisseurKit.jsx` — types : Usine, Société, Importateur, Grossiste, Semi-Grossiste, Détaillant, Autre.
- `ProduitsScreen.jsx` — « Date d'emprunt » → « Date d'expiration ».
- `RetoursScreen.jsx` — « Non — défectueux, sortie « Casse » ».
- `EntreesScreen.jsx` — Magasin : « Par défaut : votre magasin principal » ; « Répartition (option) ».
- `LoginScreen.jsx` — « Mot de passe oublié ? Voyez l'administrateur » (sans lien) ; encart mode démo (demo / demo).
- `DashboardScreen.jsx` — remplacé par `DashboardV22` : 6 KPI (ventes, période précédente, achats, net, dette fournisseurs, crédit clients) et 5 graphiques (courbe des ventes, CA par jour, ventes par caissier, modes de paiement, top produits).
- `data.js` — types de clients Consommateur / Détaillant / Société ; aucune vente en mode « Crédit ».
- **Codification §8.10 partout** : PAN → PN, CLI → CL, CAI → CS, ENT → SS, SOR → SRT, SCT → SC, BES → BL, TRF → TRM (marchandise), TRC → TRF (caisse), MVM → MVC, Z-nnnnnn → CLTnnnnnn, SES00 → SES, ZKT-AAAA-0001 → ZKT00000n.

## Décisions à reporter dans la spécification 06
D2 (catégories du menu), H5 (retour défectueux + sortie Casse), L2 (types de sortie), T3 (seuil par produit + seuils globaux par défaut).
