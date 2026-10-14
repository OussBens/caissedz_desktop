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
| Schéma 45 tables + seed système | ⚠️ attente spec ; v2 (lot 1) crée des tables minimales `magasin`, `caisse`, `categorie`, `sous_categorie`, `client`, `fournisseur`, `utilisateur` et seed MAG0000, CIS0000, CLN0000, FOR0000, CATE0000, SC0000, admin (USR0000) |
| i18n FR/AR/EN | ✅ plomberie + libellés du shell ; libellés métier attendent DS/ref.js |
| go_router + AppShell (sidebar 4 groupes, favoris max 7, Ctrl+M, alertes, Internet) | ✅ structure ; liste des 17 modules provisoire |

## Lot 1 — Démarrage ✅ (sous hypothèses ⚠️, sources toujours absentes le 2026-10-14)
Écrans : activation (clé SHA-256 64 car.), mode démo demo/demo, connexion, configuration initiale 4 étapes (dont
marge), Mon compte (changement d'identifiant), licences Basic/Avancé, rôles et 7 permissions d'action
(voirPrixAchat, colonnes masquées, écran « Accès refusé »).
Règles : §8 (permissions, licences), §9 (workflows démarrage), LISEZ-MOI (décisions L2…).
Tests : validation de clé, hachage mot de passe, gating licence, grille de permissions, parcours de configuration.
Checklist §15 : activation / sécurité / rôles.

**Livré**
- Parcours : activation → configuration initiale → connexion → application (redirections `go_router`).
- Activation : identifiant machine affiché + copie, clé 64 hex validée, erreurs format / clé inconnue, bouton
  « Essayer en mode démo », badge de licence ; accessible aussi depuis Paramètres › Licence.
- Configuration initiale 4 étapes : Boutique (nom, RC, NIF, adresse, téléphone, e-mail) → Administrateur
  (identifiant, nom, mot de passe + confirmation) → Marge et vente (marge par défaut %, seuil de stock global,
  fidélité, points/dinar, devise) → Récapitulatif ; validations par étape ; écriture en UNE transaction
  (`ConfigurationInitialeService.terminer`).
- Connexion : identifiant + mot de passe (PBKDF2-HMAC-SHA256), messages d'erreur, indice demo/demo en mode démo,
  bandeau « Mode démo » dans le shell, menu utilisateur (Mon compte, Se déconnecter) dans la barre de titre.
- Mon compte : changement d'identifiant (mot de passe exigé, unicité), changement de mot de passe, préférences
  langue/thème ; compte démo en lecture seule.
- Licences : `NiveauLicence` Basic/Avancé, `niveauRequis` par module, `LicenceGate` (page et compact), cadenas
  dans la sidebar.
- Rôles : Admin / Caissier / Magasinier, 7 permissions d'action, modules accessibles par rôle, `PermissionGrid`,
  page Paramètres › Rôles et permissions (permission `gererUtilisateurs`, Admin verrouillé à « tous les
  droits »), écran « Accès refusé », colonnes à permission masquées dans `DsDataTable` (`DsColonne.permission`).
- Tests : 27 unitaires (hachage avec vecteur PBKDF2, clés, services, transaction annulée) + 13 widget
  (activation FR/AR, assistant complet, connexion, accès refusé, garde de licence, rôles, Mon compte, colonnes).

**Hypothèses à confirmer dès réception de la spec 06 et du DS v2.2 (⚠️)**
1. Clé d'activation liée à la machine : `SHA-256("CAISSEDZ|BASIC|<id machine>")` ou `…|AVANCE|…`
   (`core/licence/cle_activation.dart`). Toute autre règle (serveur, clé signée) remplacera ce résolveur.
2. Les 6 permissions autres que `voirPrixAchat` : modifierPrix, appliquerRemise, annulerVente,
   supprimerDocument, exporterDonnees, gererUtilisateurs ; permissions et modules par défaut des rôles
   (`domain/permissions.dart`).
3. Contenu des 4 étapes de configuration et paramètres de vente (`ParametresVente`).
4. Répartition Basic/Avancé des modules (`domain/modules.dart`, `niveauRequis`).
5. Mode démo : licence Avancé sans clé ; demo/demo accepté uniquement tant qu'aucune vraie licence n'est active ;
   compte démo non modifiable.
6. Codes utilisateurs `USR0000` (admin système) / `USR0001` (demo) ; schéma minimal v2 des tables seedées.
7. Apparence des écrans : tokens provisoires du lot 0 (aucune comparaison avec `CaisseDZ-DS-v2.2.html`
   possible).

## Lot 2 — Produits & catalogue ✅ (sous hypothèses ⚠️)
Écrans : catégories, produits (modes détaillé et IA : cascade CaisseDZ → Mantouj → Open Food Facts → Open Beauty
Facts, synchro catalogue), colis, packs, remises, codes-barres (EAN-13, CAISSEDZ+date, QR), 2ᵉ stock « nombre »,
import Excel, étiquettes.
Règles : §8 (prix, marge, codes-barres), §8.10, §13, §11 (étiquettes).
Tests : EAN-13 (checksum), génération CAISSEDZ+date, calcul marge, import Excel, cascade IA (mocks).
Checklist §15 : produits / codes-barres / import.

**Livré**
- Migration v3 : `produit`, `colis`, `pack` + `pack_ligne`, `remise`, `historique` (journal d'audit),
  `sequence_code_barres`.
- Module Produits (onglets Produits / Catégories / Colis / Packs / Remises) : tableau avec colonne prix d'achat
  soumise à `voirPrixAchat`, formulaire détaillé (marge ↔ prix de vente, 2ᵉ stock « nombre »), mode IA
  (cascade CaisseDZ → Mantouj → Open Food Facts → Open Beauty Facts, fiche pré-remplie), import Excel (analyse,
  rapport, modèle), étiquettes PDF (planche A4 / rouleau, EAN-13, CODE128, QR), synchro catalogue.
- `CatalogueService` (transactions, codes PRD/COL/PCK/REM, unicité des codes-barres sur produits + colis + packs,
  meilleure remise applicable), `ImportProduitsService`, `CatalogueIaService`, `SynchroCatalogueService`,
  `EtiquettesPdf`, `CodesBarres` (EAN-13, interne `CDZ` + AAAAMMJJ + séquence, QR `CDZ:PRD:<code>`).
- Widgets DS ajoutés : `DsPage`, `DsOnglets`, `DsSelect`, `DsSwitch`, `DsVide`, `formaterMontant`.
- Tests : 13 unitaires + 6 widget (FR/AR, mode IA avec client HTTP simulé, catégories, import).

**Hypothèses (⚠️)** : format du code interne (`CDZ` + date + séquence), sens du 2ᵉ stock « nombre »
(pièces par unité), colonnes Excel attendues, API CaisseDZ / Mantouj (`GET <base>/catalogue/produits/<ean>`),
protocole de synchro, dimensions d'étiquettes 50×30 mm.

## Lot 3 — Stock ✅ (sous hypothèses ⚠️)
Écrans : journal des mouvements, magasins (principal = premier magasin de l'utilisateur), transferts TRM, besoins
(En attente / Commande / Disponible), sorties (Casse, Périmé, Perte/vol, Consommation interne, Don, Échantillon +
onglet Ventes).
Règles : §8 (stock = journal des mouvements, répartition multi-magasin), §8.10 (TRM), §13 (motifs).
Tests : stock calculé depuis le journal, transfert = 2 mouvements, répartition multi-magasin, garde de stock.
Checklist §15 : stock.

**Livré**
- Migration v4 : `mouvement_stock` (journal signé, quantité + nombre, référence, motif), `utilisateur_magasin`,
  `transfert_stock` + lignes, `besoin`, `sortie_stock` + lignes.
- `StockService` : stock = SUM(mouvements) (jamais un compteur), garde de stock toujours active (sortie refusée
  si stock négatif, aucune écriture), entrée manuelle, inventaire (mouvement d'écart), transfert TRM = 2
  mouvements par ligne en UNE transaction, sorties avec motif du référentiel, besoins (cycle En attente →
  Commande → Disponible, génération sous seuil propre ou global), magasin principal = premier magasin de
  l'utilisateur (repli : MAG0000).
- Écrans : Stock (niveaux par magasin avec seuil et valeur au PA soumise à `voirPrixAchat`, journal filtrable,
  entrée manuelle, inventaire), Magasins (+ « mes magasins », principal), Transferts, Besoins (filtres par
  statut), Sorties (onglet Sorties + onglet Ventes), éditeur de lignes partagé (quantité + nombre).
- Tests : 5 unitaires (journal, 2ᵉ stock, inventaire, transferts, besoins) + 5 widget.

**Hypothèses (⚠️)** : colonnes des tables de stock, règle « magasin principal » (ordre de la liste
`utilisateur_magasin`), génération des besoins (quantité = 2 × seuil − stock), module « Magasins » séparé dans
le groupe Stock.

## Lot 4 — Caisse POS ✅ (sous hypothèses ⚠️)
Écrans : sessions obligatoires, 5 ventes en parallèle, scan, colis, nombre, réservation de stock entre paniers,
remises, paiements (Espèces, Carte, Chèque, Virement, Points), versé/reste, points gagnés, 16 raccourcis + aide,
calculatrice, ticket scellé, impression ticket 58/80 mm FR/AR et facture A4.
Règles : §8 (calculs, versé/reste, fidélité, scellement SHA-256 chaîné), §9 (workflow POS), §11 (impression),
LISEZ-MOI (K7, T12…).
Tests : VenteService.encaisser (transaction unique), versé/reste, points, réservation entre paniers,
scellement chaîné, rendu ticket.
Checklist §15 : caisse / ticket / scellement.

**Livré**
- Migration v5 : `session_caisse`, `vente` (scellée : `hash`, `hash_precedent`), `vente_ligne`, `vente_paiement`,
  points / plafond de crédit sur `client`.
- Domaine : `Panier` immuable (agrégation, remises ligne et globale, versé / reste / monnaie, réservations),
  `Fidelite`, `Scellement` (SHA-256 chaîné sur forme canonique, vérification de chaîne).
- `SessionCaisseService` (session obligatoire, unique par utilisateur et par caisse, écart à la fermeture =
  compté − (fond + espèces − monnaie rendue)), `VenteService.encaisser` en UNE transaction (vente, lignes,
  paiements, mouvements de stock avec garde, points, scellement), `annuler` (stock et points restitués, ticket
  conservé, crochet « période clôturée » pour le lot 7), `verifierChaine`.
- Impression : `TicketEscPos` 58 / 80 mm (CP1252 / CP1256 pour l'arabe, CODE128 du ticket, tiroir, coupe),
  `DocumentsPdf` (ticket rouleau et facture A4, police Cairo en arabe), transports réseau IP:port, USB via le
  spouleur Windows (winspool par FFI), Bluetooth via la file d'impression Windows, `ImprimanteMemoire` (tests).
- Écran Caisse : barre de session (ouvrir / fermer), grille de produits avec scan / recherche / catégories,
  5 paniers en onglets, lignes `CartLine`, client, remise globale (permission), `PaymentPanel` (5 modes, pavé,
  billets rapides, versé / reste / monnaie), vente à crédit pour client identifié, 16 raccourcis (F1–F12,
  Ctrl+N, Ctrl+Tab, Suppr, +/−) et aide, calculatrice, dialogue de résultat avec ticket 58 / 80 mm et facture A4.
- Widgets DS : `CartLine`, `Numpad`, `Calculator`, `PaymentPanel`.
- Tests : 11 unitaires (panier, scellement, sessions, encaissement, annulation, altération détectée,
  impression) + 4 contrôleur + 4 widget.

**Hypothèses (⚠️)** : 1 point = 1 DA à l'utilisation, points gagnés = ⌊net × points/dinar⌋ (client identifié
seulement), chaîne de scellement globale ordonnée par code de vente, forme canonique JSON des tickets, liste des
16 raccourcis, prix à la pièce = prix de vente / pièces par unité, écart de caisse calculé sur les espèces,
Bluetooth via file d'impression Windows (écart : pas d'accès série direct).

## Lot 5 — Ventes, retours, tiers, versements ✅ (sous hypothèses ⚠️)
Écrans : ventes, retours, clients, fournisseurs, versements imputés aux documents ouverts (plus ancien d'abord),
versement lié à un retour verrouillé.
Règles : §8 (imputation FIFO, verrouillage), §9, §8.10 (CLN, FOR).
Tests : RetourService.creer, VersementService.imputer (plus ancien d'abord), verrouillage.
Checklist §15 : ventes / retours / tiers.

**Livré**
- Migration v6 : `retour` + lignes, `versement` + `versement_imputation`, `achat` + lignes (préparé pour le
  lot 6), adresse / e-mail fournisseur.
- `VersementService.imputer` : répartition automatique sur les documents ouverts du tiers (ventes à crédit ou
  achats) du plus ancien au plus récent, excédent conservé en avance ; suppression refusée si verrouillé.
- `RetourService.creer` en UNE transaction : contrôle des quantités (déjà retournées incluses), stock restitué,
  remboursement = versement verrouillé lié au retour, reste de l'avoir imputé aux documents ouverts du client ;
  refus sur vente annulée / période clôturée.
- `TiersService` (clients, fournisseurs), soldes calculés (documents ouverts − avances).
- Écrans : Ventes (filtres, ticket, annulation avec permission, retour, vérification du scellement), Retours,
  Clients (solde, fiche avec documents ouverts et versements, encaissement), Fournisseurs (règlement),
  Versements (aperçu des imputations avant validation, suppression sauf verrouillé).
- Tests : 4 unitaires + 5 widget.

**Hypothèses (⚠️)** : avoir non remboursé = versement interne « Avoir » verrouillé et imputé ; prix de retour =
prix net payé sur la ligne ; les packs ne se retournent pas ligne à ligne ; solde client = Σ restes − avances.

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
