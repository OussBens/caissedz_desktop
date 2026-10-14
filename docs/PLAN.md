# Plan de réalisation — CaisseDZ Desktop

Découpage en lots. Pour chaque lot : écrans, règles (n° de § de la spec 06 et décisions du DS v2.2), tests et
cases de la checklist §15 (`docs/CONFORMITE.md`). Statut : ⬜ à faire · 🟨 en cours · ✅ terminé · ⚠️ provisoire
(dépend d'une source absente).

> **Blocage connu (2026-10-14)** : `docs/spec/06_specification_reconstruction.md` et
> `docs/design/CaisseDZ-DS-v2.2/` ne sont pas dans le dépôt. Les références de § ci-dessous reprennent celles
> données dans la commande initiale ; le détail (écrans exacts, libellés, tokens, 45 tables, checklist §15) sera
> complété dès réception des sources.

## Lot 0 — Socle 🟨 (partie indépendante des sources livrée ; partie dépendante ⚠️)

**Livrables**
- Projet Flutter Windows (fenêtre mini 1000×700, barre de titre personnalisée `window_manager`).
- Design system : tokens (ThemeExtension clair + sombre), typographie (Plus Jakarta Sans / Cairo), espacements,
  rayons, ombres, motion ; tous les widgets du DS ; page « galerie » interne (clair/sombre/RTL).
- Base chiffrée SQLCipher (clé dérivée de la machine §4.2), `foreign_keys ON`, migrations versionnées,
  schéma 45 tables, seed système (MAG0000, CIS0000, CLN0000, FOR0000, CATE0000, SC0000, admin).
- i18n FR/AR/EN (ARB), arabe en RTL.
- go_router (ShellRoute) + AppShell : sidebar Général / Stock / Tiers / Gestion, barre de titre, favoris (max 7),
  menu modules Ctrl+M, alertes, témoin Internet.

**Règles** : §4.2 (clé), §8.10 (codification, CodeGenerator), §13 (référentiel des listes, valeur stockée FR),
§16 (dette à éviter), LISEZ-MOI.md (décisions DS).

**Tests** (37, verts) : ouverture/migration de la base chiffrée, clé incorrecte refusée, FK appliquées,
idempotence, dérivation de clé, CodeGenerator, référentiel (valeur stockée = FR), garde anti double-clic de
`DsButton`, DsDataTable (tri, sélection, colonnes, pagination, menu contextuel, totaux), favoris (max 7,
persistés), AppShell FR/AR(RTL, Cairo)/EN, Ctrl+M, alertes, galerie clair/sombre/RTL.

**Note technique** : les tests de widgets utilisent une base SQLCipher en mémoire (`AppDatabase.ouvrirEnMemoire`),
car la zone asynchrone simulée de `testWidgets` ne termine jamais les E/S fichier réelles.

**Checklist §15** : cases « socle » (à identifier dans la spec).

**État détaillé**
| Élément | Statut |
|---|---|
| Projet Flutter, dépendances, structure `lib/` | ✅ |
| Fenêtre Windows mini 1000×700 + barre de titre personnalisée | ✅ |
| Tokens ThemeExtension clair/sombre + typographie + RTL | ⚠️ structure en place, valeurs provisoires (attente DS) |
| Widgets du DS : DsButton (garde anti double-clic), DsIconButton, DsDataTable (tri, sélection multiple, colonnes masquables, pagination, menu contextuel, totaux), DsDialog / confirmation / résultat / sélecteur, DsCard, DsBadge, DsTextField, DsStatCard | ✅ comportement ; ⚠️ apparence provisoire (attente DS) |
| Widgets métier du DS (CartLine, Numpad, Calculator, PaymentPanel, PermissionGrid, LicenseGate, charts) | ⬜ attendent le DS (libellés et dispositions exacts) ; livrés avec les lots 1 et 4 |
| Page galerie clair/sombre/RTL | ✅ pour les widgets existants |
| Base chiffrée + migrations + `foreign_keys` | ✅ plomberie ; clé §4.2 provisoire |
| Schéma 45 tables + seed système | ⚠️ attente spec (migration v1 = tables système minimales) |
| i18n FR/AR/EN | ✅ plomberie + libellés du shell ; libellés métier attendent DS/ref.js |
| go_router + AppShell (sidebar 4 groupes, favoris max 7, Ctrl+M, alertes, Internet) | ✅ structure ; liste des 17 modules provisoire |

## Lot 1 — Démarrage ⬜
Écrans : activation (clé SHA-256 64 car.), mode démo demo/demo, connexion, configuration initiale 4 étapes (dont
marge), Mon compte (changement d'identifiant), licences Basic/Avancé, rôles et 7 permissions d'action
(voirPrixAchat, colonnes masquées, écran « Accès refusé »).
Règles : §8 (permissions, licences), §9 (workflows démarrage), LISEZ-MOI (décisions L2…).
Tests : validation de clé, hachage mot de passe, gating licence, grille de permissions, parcours de configuration.
Checklist §15 : activation / sécurité / rôles.

## Lot 2 — Produits & catalogue ⬜
Écrans : catégories, produits (modes détaillé et IA : cascade CaisseDZ → Mantouj → Open Food Facts → Open Beauty
Facts, synchro catalogue), colis, packs, remises, codes-barres (EAN-13, CAISSEDZ+date, QR), 2ᵉ stock « nombre »,
import Excel, étiquettes.
Règles : §8 (prix, marge, codes-barres), §8.10, §13, §11 (étiquettes).
Tests : EAN-13 (checksum), génération CAISSEDZ+date, calcul marge, import Excel, cascade IA (mocks).
Checklist §15 : produits / codes-barres / import.

## Lot 3 — Stock ⬜
Écrans : journal des mouvements, magasins (principal = premier magasin de l'utilisateur), transferts TRM, besoins
(En attente / Commande / Disponible), sorties (Casse, Périmé, Perte/vol, Consommation interne, Don, Échantillon +
onglet Ventes).
Règles : §8 (stock = journal des mouvements, répartition multi-magasin), §8.10 (TRM), §13 (motifs).
Tests : stock calculé depuis le journal, transfert = 2 mouvements, répartition multi-magasin, garde de stock.
Checklist §15 : stock.

## Lot 4 — Caisse POS ⬜
Écrans : sessions obligatoires, 5 ventes en parallèle, scan, colis, nombre, réservation de stock entre paniers,
remises, paiements (Espèces, Carte, Chèque, Virement, Points), versé/reste, points gagnés, 16 raccourcis + aide,
calculatrice, ticket scellé, impression ticket 58/80 mm FR/AR et facture A4.
Règles : §8 (calculs, versé/reste, fidélité, scellement SHA-256 chaîné), §9 (workflow POS), §11 (impression),
LISEZ-MOI (K7, T12…).
Tests : VenteService.encaisser (transaction unique), versé/reste, points, réservation entre paniers,
scellement chaîné, rendu ticket.
Checklist §15 : caisse / ticket / scellement.

## Lot 5 — Ventes, retours, tiers, versements ⬜
Écrans : ventes, retours, clients, fournisseurs, versements imputés aux documents ouverts (plus ancien d'abord),
versement lié à un retour verrouillé.
Règles : §8 (imputation FIFO, verrouillage), §9, §8.10 (CLN, FOR).
Tests : RetourService.creer, VersementService.imputer (plus ancien d'abord), verrouillage.
Checklist §15 : ventes / retours / tiers.

## Lot 6 — Entrées / achats + Smart Scan IA ⬜
Écrans : entrées/achats, Smart Scan IA (quota serveur, quota atteint, demande d'offre).
Règles : §8 (prix d'achat, stock), §9, LISEZ-MOI.
Tests : AchatService.enregistrer (transaction unique, mouvements de stock), quota (mocks).
Checklist §15 : achats.

## Lot 7 — Gestion caisse, clôtures Z, export fiscal ⬜
Écrans : caisses (types Physique/Compte, caisse sans magasin), transferts TRF (2 mouvements), clôtures Z chaînées
immuables, annulation refusée en période clôturée, export fiscal (archive + JSON vérifiable).
Règles : §8, §12 (conformité fiscale), §8.10 (TRF).
Tests : chaînage SHA-256 des clôtures, immuabilité, refus d'annulation, vérification du JSON exporté.
Checklist §15 : clôtures / fiscal.

## Lot 8 — Tableau de bord, Situation, Zakat, Historique, Paramètres, sauvegarde, exports ⬜
Écrans : tableau de bord (6 KPI, 5 graphiques), Situation (10 rapports), Zakat (nissab, taux), Historique,
Paramètres complets (marge, fidélité, seuils globaux, garde de stock toujours active, boutique RC/e-mail,
imprimante bluetooth/USB/réseau/normale), sauvegarde/restauration, exports Excel/PDF avec aperçu.
Règles : §8 (zakat, seuils), §11, §12.
Tests : KPI, rapports, calcul zakat, sauvegarde/restauration (base chiffrée), exports.
Checklist §15 : rapports / paramètres / sauvegarde.

## Lot 9 — Recette ⬜
Parcours FR/AR/EN, clair/sombre, Basic/Avancé, rôles Admin/Caissier/Magasinier ; `docs/CONFORMITE.md`
entièrement cochée ; build Windows (msix ou installeur).
