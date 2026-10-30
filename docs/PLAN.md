# Plan de réalisation — CaisseDZ Desktop

Découpage en lots. Pour chaque lot : écrans, règles (n° de § de la spec 06 et décisions du DS v2.2), tests et
cases de la checklist §15 (`docs/CONFORMITE.md`). Statut : ⬜ à faire · 🟨 en cours · ✅ terminé · ⚠️ provisoire
(dépend d'une source absente).

> **Sources reçues (2026-10-14)** : `docs/spec/06_specification_reconstruction.md` et
> `docs/design/CaisseDZ-DS-v2.2/` sont maintenant dans le dépôt. Les lots 0 à 9 avaient été livrés sous hypothèses ;
> le réalignement sur les sources est mené en quatre phases (voir « Réalignement DS v2.2 » en fin de document).

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

## Lot 6 — Entrées / achats + Smart Scan IA ✅ (sous hypothèses ⚠️)
Écrans : entrées/achats, Smart Scan IA (quota serveur, quota atteint, demande d'offre).
Règles : §8 (prix d'achat, stock), §9, LISEZ-MOI.
Tests : AchatService.enregistrer (transaction unique, mouvements de stock), quota (mocks).
Checklist §15 : achats.

**Livré**
- `AchatService.enregistrer` en UNE transaction : contrôle fournisseur / produits / quantités / prix, code `ACH`,
  entrée de stock par mouvement (type Achat, référence = code de l'achat), mise à jour optionnelle du prix
  d'achat (et du prix de vente + marge si saisi), paiement immédiat = versement fournisseur imputé à l'achat,
  reste dû = total − imputations (réglable ensuite par `VersementService.imputer`, plus ancien d'abord).
- `AchatService.annuler` : stock ressorti via la garde (refus si déjà vendu), statut Annulé, refus en période
  clôturée (crochet `periodeCloturee`, branché au lot 7).
- `SmartScanService` : `GET /smart-scan/quota`, `POST /smart-scan/analyser` (multipart image/PDF), 429 → quota
  atteint, `POST /smart-scan/demande-offre` ; non configuré tant que `serveur_url` est vide.
- Écrans : Entrées / Achats (liste avec total / versé / reste masqués sans `voirPrixAchat`, source Manuel ou
  Smart Scan, statut, annulation contextuelle avec confirmation), formulaire d'entrée (fournisseur, magasin,
  référence, lignes quantité / prix d'achat / nouveau prix de vente, versé + mode, mise à jour du prix),
  dialog Smart Scan (quota, choix du fichier, analyse, rapprochement automatique par code-barres ou désignation,
  association manuelle, état « quota atteint » avec demande d'offre, création de l'entrée pré-remplie).
- Tests : 3 unitaires (achat, annulation, Smart Scan mocké) + 3 widget (entrée manuelle et annulation, Smart Scan
  complet, quota atteint + demande d'offre).

**Hypothèses (⚠️)** : API Smart Scan hypothétique (`/smart-scan/quota|analyser|demande-offre`, JSON
`{utilise, total}` et `{fournisseur, reference, lignes[{designation, code_barres, quantite, prix_achat}], quota}`,
en-tête `X-Api-Key`) ; le paiement immédiat d'un achat est un versement fournisseur imputé à l'achat ; le prix de
vente n'est modifié que si un nouveau prix est saisi ; les achats sur `FOR0000` (fournisseur divers) ne créent
pas de versement.

## Lot 7 — Gestion caisse, clôtures Z, export fiscal ✅ (sous hypothèses ⚠️)
Écrans : caisses (types Physique/Compte, caisse sans magasin), transferts TRF (2 mouvements), clôtures Z chaînées
immuables, annulation refusée en période clôturée, export fiscal (archive + JSON vérifiable).
Règles : §8, §12 (conformité fiscale), §8.10 (TRF).
Tests : chaînage SHA-256 des clôtures, immuabilité, refus d'annulation, vérification du JSON exporté.
Checklist §15 : clôtures / fiscal.

**Livré**
- Migration v7 : `mouvement_caisse` (journal, jamais un solde modifié à la main), `transfert_caisse` (TRF),
  `cloture` (Z) protégée par des déclencheurs SQL `RAISE(ABORT)` sur UPDATE et DELETE (immuabilité garantie par
  le moteur).
- Journal de caisse alimenté par les services existants, dans leur transaction : ouverture de session (fond
  initial), ventes (une entrée par paiement hors points, espèces nettes de la monnaie rendue), annulation de
  vente (sortie miroir), versements (encaissement / décaissement), remboursement de retour, paiement immédiat
  d'achat, fermeture de session (écart puis retrait des espèces comptées). Suppression d'un versement = retrait
  de ses mouvements.
- `CaisseService` : caisses Physique / Compte avec ou sans magasin, activation, apport / dépense, `transferer`
  (TRF, UNE transaction, 2 mouvements sortie + entrée, solde insuffisant refusé, caisse inactive refusée).
- `ClotureService` : aperçu puis `cloturer` (UNE transaction) sur la période écoulée depuis la clôture
  précédente : nb ventes / annulations, totaux ventes / remises / retours / encaissements / décaissements,
  encaissements par mode, soldes des caisses, dernier ticket et son hash, hash SHA-256 chaîné au Z précédent ;
  refus si une session est ouverte ou si rien n'est à clôturer ; `verifierChaine` ; `periodeCloturee` branché
  sur `VenteService.annuler`, `RetourService.creer` et `AchatService.annuler`.
- `ExportFiscal` (§12) : archive ZIP `export.json` (ventes scellées avec lignes / paiements, clôtures chaînées,
  empreinte SHA-256 globale, boutique, logiciel, période), `ventes.csv`, `clotures.csv`, `LISEZMOI.txt` ;
  `verifier` recalcule l'empreinte et les deux chaînes depuis l'archive ou le JSON brut.
- Écrans : Gestion de caisse (onglets Caisses avec soldes espèces / total, Mouvements filtrables avec totaux,
  Transferts entre caisses), Clôtures Z (cartes du dernier Z, liste, aperçu avant scellement, détail, vérification
  de la chaîne, export fiscal avec choix de période, vérification d'une archive ; export soumis à la permission
  `exporterDonnees`).
- DS : `DsActionContextuelle.visible`, libellés du menu contextuel tronqués proprement.
- Tests : 7 unitaires (caisses, journal alimenté par les services, TRF, chaînage Z, immuabilité SQL + altération
  détectée, refus d'annulation en période clôturée, export vérifié / altéré) + 3 widget.

**Hypothèses (⚠️)** : clôture Z globale (toutes caisses) par période, exigeant la fermeture de toutes les sessions ;
à la fermeture d'une session la caisse physique est vidée (retrait du montant compté, écart journalisé) ; les
paiements carte / chèque / virement sont journalisés sur la caisse de la session avec leur mode ; caisse par
défaut d'un versement = caisse de la session ouverte de l'utilisateur, sinon `CIS0000` ; format de l'export
fiscal déduit de la commande.

## Lot 8 — Tableau de bord, Situation, Zakat, Historique, Paramètres, sauvegarde, exports ✅ (sous hypothèses ⚠️)
Écrans : tableau de bord (6 KPI, 5 graphiques), Situation (10 rapports), Zakat (nissab, taux), Historique,
Paramètres complets (marge, fidélité, seuils globaux, garde de stock toujours active, boutique RC/e-mail,
imprimante bluetooth/USB/réseau/normale), sauvegarde/restauration, exports Excel/PDF avec aperçu.
Règles : §8 (zakat, seuils), §11, §12.
Tests : KPI, rapports, calcul zakat, sauvegarde/restauration (base chiffrée), exports.
Checklist §15 : rapports / paramètres / sauvegarde.

**Livré**
- `StatistiquesRepository` (lecture seule, SQL d'agrégation) : 6 KPI (CA du jour, tickets, panier moyen, CA du
  mois, produits sous seuil, créances clients), 5 séries (CA 30 jours, encaissements par mode, top 5 produits,
  ventes par catégorie, CA mensuel 12 mois), valeur du stock au prix d'achat, soldes des caisses, créances /
  dettes (restes ouverts − avances non imputées), et les 10 rapports de Situation (ventes par jour / produit /
  catégorie / client / vendeur et caisse, encaissements par mode, achats par fournisseur, retours, état du stock
  valorisé, créances et dettes) sous forme de `Rapport` générique (colonnes typées, totaux).
- `CalculZakat` (domaine pur) : assiette = stock + caisses + créances − dettes, nissab = 85 g × cours de l'or,
  taux 2,5 %.
- `ParametresService` : boutique (RC, NIF, e-mail…), vente (marge, devise, seuil global, fidélité, points), impression
  (Normale / USB spouleur / Réseau IP:port / Bluetooth, largeur 58-80), serveurs (CaisseDZ, clé API, Mantouj),
  cours de l'or ; validations, UNE transaction + historique par écriture.
- `SauvegardeService` : sauvegarde SQLCipher (`sqlcipher_export`) chiffrée avec un mot de passe utilisateur
  (restaurable sur une autre machine), vérification (boutique, nb ventes / produits, version du schéma),
  restauration préparée dans `<base>.restaurer` re-chiffrée avec la clé machine et appliquée par
  `AppDatabase.ouvrir` au démarrage suivant (jamais de remplacement à chaud) ; annulation possible.
- `ExportExcel` (xlsx) et `RapportPdf` (A4 paysage, police Cairo en arabe) pour tout `Rapport` ; aperçu PDF via
  `PdfPreview` (printing) dans l'écran Situation.
- DS : `DsGraphiqueLignes`, `DsGraphiqueBarres`, `DsGraphiqueSecteurs`, `DsCarteGraphique` (fl_chart habillé aux
  tokens, palette sémantique).
- Écrans : Tableau de bord (6 cartes KPI + 5 graphiques responsives), Situation (choix du rapport, période,
  tableau DsDataTable avec totaux, export Excel et aperçu PDF soumis à `exporterDonnees`), Zakat (cours de l'or
  enregistré, composantes, assiette, nissab, montant, assujettissement), Historique (journal d'audit filtrable par
  entité et recherche), Paramètres (onglets Général [rôles, licence], Boutique, Vente, Impression, Serveurs,
  Sauvegarde [création, restauration avec confirmation, restauration en attente]).
- Tests : 5 unitaires (KPI et séries, 10 rapports + Excel + PDF, zakat, paramètres, sauvegarde / restauration au
  redémarrage) + 5 widget (tableau de bord, Situation + export Excel, Zakat, Historique, Paramètres + sauvegarde).

**Hypothèses (⚠️)** : liste des 6 KPI, des 5 graphiques et des 10 rapports déduite de la commande ; coût des ventes
estimé au prix d'achat actuel (pas de coût historisé par ligne) ; zakat = 85 g d'or, 2,5 % ; format de sauvegarde
`.cdz` = base SQLCipher chiffrée par mot de passe ; la garde de stock n'est pas paramétrable.

## Lot 9 — Recette ✅ (build Windows à exécuter sur un poste Windows)
Parcours FR/AR/EN, clair/sombre, Basic/Avancé, rôles Admin/Caissier/Magasinier ; `docs/CONFORMITE.md`
entièrement cochée ; build Windows (msix ou installeur).

**Livré**
- `test/recette/parcours_test.dart` : les 20 modules montés en FR, AR (RTL vérifié) et EN sans exception ni
  accès refusé (admin Avancé) ; thème sombre puis clair sur 5 modules ; licence Basic : LicenceGate exactement
  sur les modules `niveauRequis = Avancé` ; rôles Caissier et Magasinier : Accès refusé exactement hors des
  modules du rôle (`Roles.modulesParDefaut`).
- Empaquetage : `msix_config` dans `pubspec.yaml` (`dart run msix:create`), `installer/caissedz.iss` (Inno
  Setup), procédure et recette manuelle dans `docs/BUILD_WINDOWS.md`.
- `docs/CONFORMITE.md` : toutes les cases cochées sauf celles qui dépendent des sources absentes (tokens et
  fidélité visuelle du DS v2.2, 45 tables, clé §4.2, widgets métier « exacts »).

**Reste (hors périmètre d'un poste Linux)** : exécuter `flutter build windows --release` puis `dart run
msix:create` sur Windows ; recette manuelle de l'impression (USB / réseau / Bluetooth) et du lecteur de codes-barres.

## Réalignement DS v2.2 (après réception des sources) 🟨

Référence : `docs/design/CaisseDZ-DS-v2.2/CaisseDZ-DS-v2.2.html`, `bundle-v2.2/ds-bundle.v2.2.js` (66 composants,
17 écrans), `nouveaux-composants/*.jsx`, `donnees/ref.js`, `LISEZ-MOI.md` ; règles : spec 06.

- **Phase A — tokens ✅** : `ds_colors.dart` (clair / sombre exacts, primitives violet / ink / teal, chart-1..6,
  teintes, dégradés brand / night / bar, ombres), `ds_typography.dart` (échelle `--type-*`, chiffres tabulaires,
  Cairo), `ds_metrics.dart` (espacements, rayons, mouvement, dimensions shell / page / contrôles). Alias
  historiques supprimés en fin de phase D.
- **Phase B — composants ✅** : réécriture fidèle au bundle, mêmes APIs publiques (ou compatibles) :
  - `ds_button.dart` : variantes primary / secondary / ghost / soft / danger / accent / inverse, tailles 32 / 36 /
    44, puce `kbd`, garde 450 ms, `DsIconButton` (ghost / outline, badge), `DsKbd`, `DsIconBox`.
  - `ds_primitives.dart` : `DsCard` (en-tête icône + actions + info), `DsBadge` (7 tons, point, sm),
    `DsStatusBadge` + presets, `DsTrendBadge`, `DsStatCard`, `DsTextField`, `DsAvatar`, `DsLogo` (glyphe
    panier), `DsProgressBar`, `DsKeyValueGrid`, `DsDetailSection`, `DsStatsStrip`, `DsToast`.
  - `ds_forms.dart` : `DsCheckbox`, `DsSearchField`, `DsDateField`, `DsFormRow` (+ bouton ≡), `DsSegmentedControl`,
    `DsChoiceCards`, `DsChipGroup` (+ couleurs produit), `DsKeyInput`, `DsOrderedMultiSelect`, `DsPeriodFilter`
    (+ `DsPeriode.calculer`), `DsRangeFilter`, `DsSplitAllocator`, `DsPhotoUploader`.
  - `ds_page.dart` : `DsPage` (PageHeader + zone 24 / 32), `DsOnglets` (compteurs), `DsSelect` (liste flottante
    en route transparente), `DsSwitch`, `DsVide` (EmptyState), formatage `formaterNombre` / `formaterK` / `lireNombre`.
  - `ds_dialog.dart` : `DsDialog` (icône tonale, description, pied), `afficherConfirmation` (genres confirm /
    danger / warning / refuse), `afficherResultat`, `DsPickerDialog` (recherche, sélection simple ou multiple,
    double-clic, « Nouveau »), `afficherActionLot` (BulkActionDialog), `afficherReglageColonnes`
    (ColumnSettings : obligatoires / par défaut / autres, « Garder ma sélection »), `afficherMenuContextuel`.
  - `ds_data_table.dart` : en-tête capitales 11 px, lignes 52 / 40, colonnes fortes / atténuées / mono,
    verrous implicites (`code` + première colonne forte), dialog colonnes avec compteur, totaux, menu contextuel,
    pagination DS.
  - `ds_module.dart` : `DsFilterPanel`, `DsPagination`, `DsSelectionBar` (règles une / plusieurs), `DsExportMenu`.
  - `ds_navigation.dart` : `DsSidebar` / `DsNavItem` (248 / 72, badges), `DsTopBar`, `DsTemoinLigne`,
    `DsThemeToggle`, `DsStoreSwitcher`, `DsFavorisBar`, `DsModuleLauncher` (tuiles, favoris 7 max, verrous).
  - `ds_charts.dart` : `DsLineChart` (séries, aire, grille pointillée, « k »), `DsBarChart`, `DsRankedBars`,
    `DsDonutChart` ; enveloppes de compatibilité `DsGraphique*`.
  - `ds_pos.dart` : `DsCartLineHeader` / `DsCartLine` (grille CART_COLS) / `DsCartLineQN`, `DsCashSessionCard`,
    `DsNumpad`, `DsPaymentPanel` (bandeau nuit, paiement complet, à rendre / reste), `DsProductTile`,
    `DsQuotaCard`, `DsSaleTabs`, `DsTotalPanel`, `DsCalculator` (parenthèses, %, clavier).
  - `ds_barcode.dart` : `DsBarcode` (EAN-13, CODE128, QR via `barcode`), `DsBarcodeCard`, code auto §8.10.
  - `ds_line_items.dart` : `DsLineItemsEditor`. `licence_gate.dart` : genres licence / role / refuse /
    activation. `ds_stepper.dart`, `permission_grid.dart` (+ `DsPermissionTiles` = MODULES / SPECIAL du DS).
  - Libellés des composants : clés ARB `ds*` (FR / AR / EN).
  - Écarts de la phase B levés en phase D : alias historiques et `pos_widgets.dart` supprimés.
- **Phase C — shell et démarrage ✅** (2026-10-15) :
  - Étape 1 (données) : `modules.dart` = 17 modules du DS en 4 groupes (Général : tableau de bord, caisse,
    ventes, retours ; Stock : produits, stock, entrées (badge IA), sorties, magasins, besoins ; Tiers : clients,
    fournisseurs ; Gestion : gestion caisse, utilisateurs, zakat, historique, paramètres) + pages rattachées
    (transferts → magasins, versements → clients, clôtures → gestion caisse, situation → tableau de bord), accès
    via `idAcces`. Migration `v008_shell_ds` : `utilisateur.dernier_acces`,
    boutique NIS / article / message ticket / logo, renommage des anciens identifiants de modules (rôles,
    favoris). Services `ConfigurationInitialeService` (4 étapes, une transaction, journal) et `AlertesService`
    (§5.3, familles visibles selon l'accès au module, masquage du jour). Séquence de connexion (§4.4) : droits →
    favoris → magasins (magasin courant, Admin = tous) → alertes ; journal Connexion / Déconnexion ; « Rester
    connecté ». Application non activée : demo / demo active le mode démo (§4.3). Accueil = `/caisse`.
  - Étape 2 (écrans) : `app_shell.dart` (DsSidebar filtrée par accès, sélecteur de magasin Avancé,
    déconnexion ; DsTopBar avec favoris, témoin Internet, cloche, thème, compte, contrôles de fenêtre ;
    bandeau démo ; portes Accès refusé / palier Avancé ; Ctrl+M `MenuModulesDialog` = DsModuleLauncher),
    séquence post-connexion §4.5 (configuration 1ʳᵉ fois pour l'admin → alertes s'il y en a → menu des
    modules), `alertes_dialog.dart`, `connexion_page.dart` (split + panneau nuit, langue, thème, Rester connecté,
    encart démo), `activation_page.dart` (DsKeyInput 8×8, palier détecté en direct, cartes Basic / Avancé),
    `configuration_dialog.dart` (4 étapes), `mon_compte_dialog.dart` (Profil / Mot de passe / Préférences).
    Supprimés : `sidebar.dart`, `title_bar.dart`, `modules_menu.dart`, `alertes_panel.dart`,
    `cadre_demarrage.dart`, `configuration_page.dart`, `mon_compte_page.dart`, `acces_refuse_page.dart`.
  - Tests : `pumpApp(sequence: false)` par défaut (opt-out de la séquence post-connexion) ; tests démarrage,
    connexion, activation, configuration, Mon compte, shell, accès et recette réécrits.
  - Décisions et hypothèses ⚠️ :
    - Spec > DS : configuration en 4 étapes (Langue & devise / Boutique / Paiements / Marge et stock), le DS
      en montre 3 ; proposée après la connexion de l'admin, « Plus tard » possible.
    - Seuls Magasins et Transferts exigent le palier Avancé (§6.1) ; Retours et Zakat passent en Basic.
    - Pages rattachées routables mais absentes de la barre latérale et du menu jusqu'à la phase D.
    - Familles « Produits expirés » et « Bientôt expirés » branchées en phase D sur `produit.date_expiration`
      (migration v13) : date passée / dans au plus 30 jours, produits en stock seulement.
    - Logo de la boutique non demandé à la configuration (colonne prête, saisie en phase D dans Paramètres).
    - ~~Compte admin / admin provisoire~~ : supprimé le 2026-10-24 (l'administrateur prend le mot de passe du
      compte BENS, voir « Plus de compte admin / admin »).
- **Phase D — écrans ✅** (2026-10-15) : les 17 écrans et leurs dialogs d'après les kits du bundle, listes de `ref.js`,
  tests réécrits, suppression des alias.
  - ✅ Briques communes : `DsModuleTable`, `DsEntityDetailDialog`, `PageModule` (fil d'Ariane, favori, onglets),
    export Excel / PDF des tableaux, barre de sélection qui passe à la ligne sous 1300 px.
  - ✅ Clients / Fournisseurs (`TiersKit`) : onglets [Tiers | Versements], KPI, filtres Type / Wilaya / Crédit,
    colonnes masquables (fiche §7.6), formulaire 920 px (téléphone algérien, NIF 15 chiffres, nom unique),
    détail (5 derniers documents), Situation (relevé débit / crédit / solde), annulation avec motif.
    Versements : sens reçu / retour, modification, annulation douce (motif, caisse rétablie), versement retour.
    La route `/versements` ouvre l'onglet Versements des clients.
  - ✅ Tableau de bord (`DashboardV22`) + onglet Situation (`SituationScreen`) : `SituationRepository` (10 analyses
    de §9.14), migration v10 (coût d'achat figé sur `vente_ligne`), inventaire validé en une transaction
    (`StockService.inventorierLot`). Les anciens rapports génériques sont retirés ; `/situation` ouvre l'onglet.
  - ✅ Ventes (`PaniersScreen`) : KPI (nombre, CA, marge si `voirPrixAchat`, encaissé, crédit), période du jour
    par défaut, filtres Type / Statut / Caissier / Client / Caisse / Session / Montant, colonnes masquables,
    détail 1100 px (stats, paiement et marge, produits, audit avec empreinte), modification 980 px, annulation
    en lot avec motif (bloquée si déjà annulé ou retour lié), « Nouvelle vente » ouvre la caisse.
    Migration v11 : `vente.type_panier` (Ticket / BL / BL_SC, hors scellement). `VenteService.modifier` : le
    complément payé devient un versement imputé d'abord sur ce panier ; `annuler` annule les versements liés.
  - ✅ Retours (`RetoursScreen`) : onglets Retours clients / Retours fournisseurs, KPI, période, filtres tiers /
    règlement / état, formulaire 920 px (type, tiers, pièce d'origine, produit, plafond = quantité d'origine −
    déjà retourné, n° de série, règlement, remise en stock), détail 960 px, annulation en lot avec motif.
    Migration v12 : table `retour` reconstruite (type, `document_code`, client OU fournisseur, règlement,
    remise en stock, annulation douce) via `Migration.reconstruitTables` (clés étrangères coupées puis
    vérifiées). `RetourService.creer / modifier / annuler` (client : stock réintégré ou sortie « Casse »,
    remboursement ou avoir ; fournisseur : sortie de stock, dette déduite ou remboursement espèces).
    Une entrée ou une vente avec un retour actif n'est plus annulable. `DsTextField.valeurInitiale` est
    désormais affichée (elle était ignorée).
  - ✅ Caisse (`CaisseScreen` + `CaisseKit`) : en-tête avec session compacte (ouverture, mouvement manuel,
    clôture avec solde théorique et écart), Ventes du jour, Recette produit, masquer les produits, paramètres
    du poste (caisse, magasin) ; 5 ventes en onglets (pièces · total ou client) ; recherche / scan (F2),
    recherche avancée multi-sélection (F3), produit introuvable ; Produits / Packs, catégories, grille ou liste
    avec entrée rapide ; dialog « Quantité et colis » (unité, colis, vente à la pièce, pavé, contrôle du stock
    réservé, ajout automatique au bout de 3 s) ; panier 540 px : client (liste + recherche + création),
    remise du référentiel (montant recalculé sur le sous-total), mode de paiement, lignes (double-clic : prix
    avec mot de passe et portée ticket / catalogue ; clic sur le colis : changement), total, Enregistrer
    (F6, crédit), BL / SC (F5, `type_panier = BL_SC`, facture A4 imprimée ou PDF) et Encaisser (F4, ticket
    ESC/POS direct ou choix 58 / 80 / A4). Toast avec « Réimprimer ».
  - ✅ Produits (`ProduitsScreen` + `ProduitKit` / `CatalogueKit`) : onglets Produits / Catégories / Sous-catégories /
    Remises / Packs avec compteurs. Produits : KPI (actifs, valeur du stock si `voirPrixAchat`, sous seuil,
    rupture), filtres catégorie / état du stock / prix / marque, vue grille (cartes) par défaut ou liste, colonnes
    masquables. Formulaire 960 px en 3 modes (Rapide, Détaillé en 3 étapes, IA par code-barres) : photos (4 max,
    copiées dans `photos/` à côté de la base), codes secondaires, marge % ou montant, TVA, boîte / carton, stock
    initial, taille / couleur, fournisseur. Détail 1120 px (stats prix moyen d'achat et vendus), étiquette 760 px
    (A4 38×21, rouleau 40 / 58), affectation en lot, suppression bloquée si stock ≠ 0, import Excel en 3 étapes
    avec correspondance des colonnes et stock initial. Catégories / sous-catégories 600 px, Remises (DocForm
    980 px, portée Par Produit / Par Montant avec seuil), Packs (940 px, économie calculée).
    Migration v13 : `produit_photo`, `remise.portee` / `remise.seuil`, champs de fiche.
    Écarts Produits : le bouton « Synchro catalogue » passe dans Paramètres ; tailles / couleurs stockées en
    liste sur le produit (pas de produits variantes) ; pas de « jours d'alerte » de péremption (aucune date de
    péremption au schéma) ; libellés de tailles enfant non traduits ; « Annuler » désactive (catégorie avec
    produits bloquée) ; le mode IA est gardé comme 3ᵉ segment (§9.4 exige 3 modes).
  - ✅ Stock / Sorties / Magasins / Besoins (`StockKit`) : migration v14 (annulation douce des sorties et
    transferts, prix d'achat figé sur les lignes de sortie, magasin téléphone / responsable / observation, liste
    de besoins = document fournisseur `BL…` avec lignes et livraison souhaitée ; chaque ancien besoin devient une
    liste d'une ligne au fournisseur système). `StockService` : `modifierSortie` / `annulerSorties`,
    `modifierTransfert` / `annulerTransferts` (mouvements défaits puis réécrits, §8.3), `distribuer` (écarts soldés
    par transferts, total conservé), `changerEtatMagasins` (bloqué si magasin principal d'un utilisateur ou stock
    non nul), nom de magasin unique, listes de besoins (créer, modifier, statut, annuler). Préfixes alignés sur
    §8.10 : `SRT` (sorties) et `BL` (listes de besoins). Écrans : Stock (une colonne par magasin consultable, KPI,
    filtres magasin / catégorie / état, colonnes masquables, détail 1000 px, distribution 680 px, onglet
    Mouvements filtrable avec « Voir la pièce » vers vente / retour / sortie / transfert), Sorties (DocForm avec
    stock du magasin, détail 940 px, annulation avec motif), Magasins + onglet Transferts (la route
    `/transferts` ouvre l'onglet), Besoins (Listes, Ruptures & seuils → « Créer une liste », Expirés → sortie
    « Périmé » pré-remplie ou retour fournisseur ; détail avec « PDF fournisseur »).
    Écarts Stock : l'onglet « Vente » de §9.7 n'est pas repris (le DS n'a qu'un tableau ; les ventes restent
    visibles dans Stock › Mouvements, filtre Vente) ; colonnes catégorie / sous-catégorie d'une sortie absentes
    (une sortie a plusieurs lignes) ; pas de lots ni de « jours d'alerte » : les expirés viennent de la date
    d'expiration du produit (fenêtre de 30 jours) ; la sortie « Périmé » ouvre le formulaire pré-rempli au lieu
    de sortir directement ; le statut « Commande » d'une liste n'a pas encore de déclencheur ; en l'absence de la permission `voirStockTousMagasins`, l'administrateur voit
    tous les magasins (⚠️ PROVISOIRE) ; l'entrée manuelle et l'inventaire unitaire de l'ancien écran sont retirés
    (inventaire dans Situation, entrées dans Entrées).
  - ✅ Entrées (`EntreesScreen`) : migration v15 (annulation douce des entrées, liste de besoins d'origine, table
    `bon_reception` = file des bons lus par l'IA, statut Reçu / Traité / Erreur avec lignes détectées). Préfixe des
    entrées aligné sur §8.10 : `SS` ; bons `BON`. `AchatService` : `modifier` (mouvements défaits puis réécrits,
    paiement immédiat ajusté, créé ou annulé), `annulerEntrees` en lot avec motif (paiement immédiat annulé),
    `blocage` (déjà annulée, période clôturée, retour lié, produits déjà vendus), répartition d'une ligne entre
    magasins, mise à jour du prix d'achat au choix (garder / prix moyen pondéré / dernier prix), versé / reste /
    nb de versements calculés depuis les imputations (§8.5), liste de besoins passée « Disponible » et bon marqué
    « Traité » dans la même transaction. Écrans : onglets Smart Scan (KPI, filtres fournisseur / paiement /
    magasin, colonnes masquables, détail 1060 px avec « Imprimer ») et Mode IA (bandeau, quota, file des bons :
    Traiter, Voir le bon, Supprimer) ; nouvelle entrée Smart Scan 1040 px en 2 étapes (bon & paiement, puis scan
    continu par code ou code-barres + « Liste ») ; Entrée rapide 720 px (un produit payé intégralement, réparti
    entre magasins ; « Modifier » y renvoie quand l'entrée n'a qu'un produit) ; Reçu IA 1040 px en 3 étapes
    (photo + quota, rapprochement avec suggestions par similarité et « + Créer », fournisseur pré-résolu et
    paiement) ; « Créer l'entrée » depuis une liste de besoins.
    Écarts Entrées : pas de contrôle « session de caisse ouverte » (§9.6 étape 1, déjà absent des lots 5–6) ;
    « Depuis le téléphone » inactif (pas d'application mobile) ; pas de raccourci `E` d'entrée rapide en caisse ;
    la confiance n'est affichée que si le serveur la renvoie ; le prix de vente reste éditable dans les lignes
    (règle §8 « vente > achat », colonne en lecture seule dans le DS) ; « Imprimer » produit le PDF du tableau
    des lignes (pas encore de bon de réception mis en page) ; l'annulation exige la permission « Annuler »
    (`annulerOperations` depuis la v17).
  - ✅ Gestion caisse (`GestionCaisseScreen` + `GestionKit`) : migration v16 (caisse : solde initial proposé comme
    fond d'ouverture, observation ; transfert entre caisses : annulation douce ; clôture : `caisse_code`,
    `total_annule`). Clôture Z **par caisse** (§9.13, §12.3) : agrège les tickets de la caisse depuis sa dernière
    clôture (validés, annulés, montant annulé, répartition des paiements, espèces nettes de la monnaie rendue),
    chaîne SHA-256 propre à chaque caisse ; les clôtures globales des lots 7–9 forment leur propre chaîne et bornent
    la première clôture par caisse ; `Cloture.verifierChaines` (service et export fiscal) vérifie chaque chaîne.
    La clôture Z n'exige plus que les sessions soient fermées (le DS clôture une caisse dont la session est
    ouverte). Préfixes §8.10 : caisses créées `CS` (la caisse système reste `CIS0000`), clôtures `CLT`.
    `CaisseService` : solde initial / observation, `desactiver` en lot et `blocageDesactivation` (caisse système,
    session ouverte, solde non nul), transfert daté (refusé en période clôturée), `annulerTransferts` avec motif
    (mouvements retirés du journal, refus si la caisse destinataire n'a plus le montant). `SessionCaisseService`
    ferme une session désignée (onglet Sessions). Écrans : onglets Caisses (cartes de session par caisse
    physique : ouvrir avec fond pré-rempli, mouvement, clôturer ; tableau avec soldes, détail 940 px, formulaire
    620 px, désactivation en lot), Transferts (620 px avec solde disponible et aperçu, annulation avec motif),
    Clôtures Z (filtre caisse, nouvelle clôture 820 px avec confirmation explicite, détail 940 px avec intégrité,
    PDF, export de contrôle fiscal 760 px : archive complète, JSON, PDF des clôtures ou CSV des tickets, état de la
    chaîne, vérification d'une archive), Mouvements (grand-livre filtrable par caisse, session déduite, type ;
    mouvement manuel avec choix de la caisse) et Sessions (théorique, réel, écart ; mouvements de la session,
    clôture). La route `/clotures` ouvre l'onglet Clôtures Z ; l'ancien écran Clôtures est supprimé. Libellés des
    types de mouvement alignés sur le DS (Versement client, Entrée manuelle, Ouverture…).
    Écarts Gestion caisse : pas de journal fiscal (`journal_fiscal`, ligne `CLOTURE_CAISSE`) ; une date reste
    « clôturée » dès qu'une clôture de n'importe quelle caisse la couvre (⚠️ PROVISOIRE, plus strict que par
    caisse) ; colonnes Client / Fournisseur / Code versement du grand-livre absentes (le mouvement ne porte que la
    référence) ; l'archive complète contient JSON + CSV + LISEZMOI, sans PDF ; l'écart cumulé et les sessions du
    détail portent sur l'historique chargé.
  - ✅ Utilisateurs (`UtilisateursScreen` + `UtilisateursKit`, remplace l'écran Rôles) : migration v17 — table
    `role` (codes `ROL`, nom unique, observation, état ; Admin `ROL0000` système, Caissier `ROL0001`, Magasinier
    `ROL0002`), `role_permission` / `role_module` reliés par **code**, `utilisateur.role_code` (le nom du rôle
    n'est plus stocké), prénom, téléphone, caisse attachée, observation, créé / modifié par. Les 7 permissions
    d'action sont désormais celles du §6.2 (`voirPrixAchat`, `voirMarge`, `modifierPrixVente`,
    `annulerOperations`, `changerCaisseMagasin`, `gererTransfertsCaisse`, `voirStockTousMagasins`) ; conversion
    des anciennes : prix / remise → `modifierPrixVente`, annuler / supprimer → `annulerOperations`, gérer les
    utilisateurs → accès au module Utilisateurs, exporter → supprimée (l'export suit l'accès au module).
    Appliquées : marge des ventes (`voirMarge`), onglet Transferts de Gestion caisse (`gererTransfertsCaisse`,
    sinon « accès refusé »), magasins consultables du Stock (`voirStockTousMagasins`), caisse et magasin du poste
    (`changerCaisseMagasin`, sinon caisse attachée de l'utilisateur ouverte par défaut à l'écran Caisse) ; la
    remise Par Montant du panier n'exige plus de permission (§8.9). L'Admin a toujours tout (accès total, rôle
    non modifiable, non assignable : admin unique). `UtilisateurService` (créer / modifier / réinitialiser le mot
    de passe / désactiver, une transaction, journal Historique) et `RoleService` (créer / modifier / désactiver).
    Écrans : onglet Utilisateurs (KPI actifs, ventes 30 j, total vendu ; filtres rôle et état ; avatar ;
    formulaire 900 px avec identifiant unique, jauge de robustesse du mot de passe — force 2 exigée à la
    création —, rôle hors Admin, caisse attachée, magasins ordonnés dont le premier est le défaut ; détail 940 px
    avec la grille des permissions du rôle ; mot de passe temporaire ; désactivation en lot bloquée pour
    l'administrateur principal et son propre compte) et onglet Rôles (modules, spéciales, utilisateurs ;
    assistant 900 px en 3 étapes avec confirmation à la modification ; Admin non modifiable ; dupliquer ;
    désactivation bloquée si des utilisateurs ont le rôle). `PermissionGrid` refait d'après le DS (tuiles).
    Écarts Utilisateurs : « Crédit caissier » (KPI, stat, colonne, blocage de désactivation) non repris faute de
    règle dans la spec (`utilisateur.credit` sans calcul décrit) ; la réinitialisation donne un mot de passe
    temporaire affiché à l'administrateur, sans obligation de le changer à la connexion ; `userparam` /
    `caisseparam` ne sont pas créés (préférences et poste gérés ailleurs) ; marges de Situation non soumises à
    `voirMarge` (elles suivent `voirPrixAchat`).
  - ✅ Zakat (`ZakatScreen` + `ZakatFormDialog` / `ZakatDetailDialog`, §9.15) : migration v18 — table `zakat`
    (codes `ZKT`, année, début du hawl, échéance, stock, liquidités, créances, dettes, nissab, taux, statut
    Brouillon / Non payé / Payée, date de paiement, observation, annulation avec motif, audit) ; l'ancien
    paramètre « prix du gramme d'or » devient `zakat_nissab` (prix × 85 g) et le taux `zakat_taux` (2,5 % par
    défaut). `ZakatService` (créer / modifier / marquer payée / annuler, une transaction, journal Historique) ;
    capital = stock + liquidités + créances − dettes, obligatoire si capital ≥ nissab > 0, montant = capital ×
    taux, échéance = début + 354 jours. Écran : 4 KPI (capital provisoire de l'année, nissab, zakat estimée,
    jours avant la prochaine échéance), tableau avec totaux et colonnes masquables, formulaire 860 px pré-rempli
    depuis le patrimoine courant (bouton de reprise par poste) avec résumé capital / obligation / montant, détail
    900 px (calcul et audit). « Exonérée » et « Annulée » sont des statuts d'affichage dérivés.
    Nissab et taux se règlent dans Paramètres › Système. Écart Zakat : le taux n'est pas modifiable par calcul (il suit le paramètre au moment de la création).
  - ✅ Historique (`HistoriqueScreen`, §9.17) : migration v19 — colonne `historique.poste` (nom de la machine,
    renseigné par `HistoriqueRepository` sur chaque ligne) et index utilisateur. Chaque ligne est rattachée à un
    module (entité → module, connexions et déconnexions sous « Connexion ») et à une famille d'action du DS
    (Création, Modification, Annulation, Connexion, Export) qui donne le ton du badge ; l'action stockée (valeur
    FR) est traduite à l'affichage. Écran : 4 KPI sur 7 jours, période (7 derniers jours par défaut), filtres
    Module / Action / Utilisateur / Poste, recherche réf. ou description, colonnes du DS (+ code `H…` masqué),
    export, détail 860 px (Action, Contexte).
    Écarts Historique : pas de suppression de lignes (§9.17 la prévoit, le DS ne la montre pas ; le journal reste
    inaltérable, cohérent avec la conformité fiscale) ; pas de tableau « Changements » avant / après (les services
    ne journalisent qu'une description) ; pas de version ni d'adresse IP dans le contexte. Exports et sauvegardes : journalisés depuis la phase E.
  - ✅ Paramètres (`ParametresScreen` + compléments `ParametresV22`, §9.16) : navigation latérale fixe en 7 groupes
    (Système, Boutique, Caisse et ventes, Impression, Alertes, Sauvegarde, Licence), badge « Modifications non
    enregistrées » et barre d'enregistrement unique : `ParametresService.enregistrerTout` valide tout puis écrit
    boutique et paramètres dans UNE transaction avec une ligne d'historique. Thème et langue s'appliquent tout de
    suite (préférences du poste). Nouveaux paramètres de la spec appliqués : type de marge (`Pourcentage` /
    `Montant`, valeur proposée à la création d'un produit), seuil maximum, vente sous le prix d'achat
    (`Interdire` / `Avertir` / `Autoriser`, contrôlée à la modification du prix en caisse), moyens de paiement
    visibles (Points compris, proposés en caisse seulement si le bonus fidélité est actif), nissab et taux de la
    zakat ; côté DS : alertes à la connexion (désactivables) et seuil de crédit client signalé. Services en ligne
    (URL CaisseDZ, clé, Mantouj) avec bouton « Synchroniser le catalogue ». Imprimante : 4 cartes de type, adresse,
    largeur et « Imprimer un test » (page ESC/POS). Sauvegarde : mot de passe demandé dans un dialog, restauration
    confirmée puis vérifiée avant préparation. Licence : palier, clé masquée, accès à l'activation.
    Écarts Paramètres : densité, réduction des animations, TVA par défaut, remise ticket maximale, mode de paiement
    par défaut, impression automatique, tiroir-caisse, imprimante A4, postes activés et quota Smart Scan, marge
    gros et valeur d'un point non repris (aucune règle ni donnée derrière dans la spec ou le schéma actuel) ;
    fenêtre « Bientôt expiré » fixe à 30 jours (§5.3). Sauvegarde automatique, 2ᵉ stock « nombre », seuil
    maximum des besoins, arrondi de la marge et aperçu du ticket : faits en phase E.
  - ✅ Nettoyage final : alias historiques des tokens supprimés (couleurs `fond` / `texte` / `primaire`…,
    typographie `petit` / `legende`…, espacements, mouvement, variante de bouton `succes`) ; tous les écrans
    utilisent les noms du DS (`surfaceApp`, `textPrimary`, `bodySm`, `DsSpacing.s4`…). Enveloppes de graphiques
    `DsGraphique*` et page provisoire de module supprimées (les 17 modules et les 4 pages rattachées sont routés ;
    Transferts, Versements, Clôtures et Situation ouvrent l'onglet de leur module parent). Clés ARB jamais
    référencées retirées des trois langues (`tool/arb_nettoyer.py`).
  - Écarts : tendances des KPI calculées seulement pour les ventes ; ventes antérieures à la v10 valorisées au prix
    d'achat actuel ; `mouvement_stock` sans valorisation (prix_achat / prix_vente de §7.3).
    Ventes : le client d'un panier n'est pas modifiable (§9.2 le permet, mais il fait partie du ticket scellé ;
    décision : retour puis nouvelle vente) et le montant payé ne peut que monter (une baisse passe par un retour).
    Caisse : le n° de panier « PN… » du DS n'est connu qu'à l'encaissement (onglets « Vente n ») ; le
    paramètre « colis par défaut » n'est pas repris (les colis sont libres par produit) ; la clôture détaille
    fond + ventes espèces nettes, sans versements, mouvements manuels ni remboursements (rattachés à la caisse,
    pas à la session) ; le mot de passe demandé pour le prix est celui de l'utilisateur connecté.

## Phase E — Écarts §15 ✅ (2026-10-15)

- ✅ Session de caisse ouverte exigée pour une entrée / un achat, un retour et un versement (§8.4, §9.6), vérifiée
  dans la transaction du service (`sessionRequise`) et avant l'ouverture des formulaires ; touche `E` en caisse
  pour l'entrée rapide (produit sélectionné pré-rempli).
- ✅ Historique : chaque export (Excel, PDF, CSV, archive fiscale) écrit une ligne `Export` rattachée au module
  d'origine (`JournalService.export`) ; sauvegardes (`Sauvegarde`, famille Export) et restaurations journalisées.
- ✅ Marge en pourcentage arrondie au multiple de 5 DA supérieur (§8, `CalculsPrix.prixVenteDepuisMarge`).
- ✅ Besoins : suggestion = seuil maximum − stock quand un maximum est défini (sinon 2 × seuil − stock).
- ✅ Aperçu du ticket (58 / 80 mm, latin ou arabe) depuis le résultat de vente et Paramètres › Impression, avec
  impression ESC/POS ou PDF.
- ✅ Sauvegarde automatique (§9.16) : dossier, fréquence (Désactivée / À chaque démarrage / Quotidienne), mot de
  passe conservé dans la base chiffrée, lancée au démarrage, 30 archives `caissedz_auto_*` conservées, journalisée
  sous l'utilisateur `SYSTEME`.
- ✅ Audit (migration v20) : `cree_le`, `cree_par`, `modifie_le`, `modifie_par` sur 17 tables métier, renseignés
  par triggers depuis `audit_contexte` (utilisateur connecté) ; affichés dans le détail d'un panier.
- ✅ 2ᵉ stock « nombre » (§8.1) : paramètre global `nombre_actif` (Paramètres › Système) ; quand il est actif ou
  que le produit le suit, le nombre est obligatoire (> 0) dans les entrées, achats, sorties et transferts
  (colonne « Nombre » proposée à quantité × pièces par unité), réparti au prorata entre magasins.
  ⚠️ PROVISOIRE : en caisse, la vente à l'unité sort les pièces correspondantes (unités × pièces par unité) sans
  saisie séparée ; un pack étant éclaté en lignes produit, ses produits suivent la même règle.
- Restent ouverts : tableau « Changements » avant / après dans le détail de l'Historique, `journal_fiscal` distinct
  avec ligne `CLOTURE_CAISSE`, période clôturée par caisse, Bluetooth natif, règle du crédit caissier, dérivation de
  la clé §4.2.
- Décisions conservées par défaut : Historique inaltérable (pas de suppression de lignes) ; client d'une vente
  scellée non modifiable (retour puis nouvelle vente).

## Retours utilisateur — Caisse ✅ (2026-10-15)

- ✅ Dialog quantité / colis : saisie directe au clavier, barre d'ajout automatique sur toute la largeur.
- ✅ Raccourcis clavier actifs (écoute globale, ignorés pendant une saisie ou un dialog).
- ✅ Photos sur les cartes produit ; cartes plus basses, bouton « Entrée » flottant au survol (violet, délai).
- ✅ Mode de paiement choisi dans le dialog d'encaissement (retiré du panier) ; Points proposés seulement si la
  fidélité est active et le client identifié.
- ✅ Recherche produit (F3) : filtres catégorie, fourchette de stock, fourchette de prix ; hauteur fixe des dialogs
  recette produit, ventes du jour et recherche.
- ✅ Clients inactifs masqués en caisse.
- ✅ Vente au montant (migration v21) : produit système `PRD0000` « Vente au montant » (service, masqué du catalogue,
  des ruptures et de l'inventaire) ; boutons +200 / +500 / +1000 et « Autre montant » cumulés sur une seule ligne,
  modifiable par double-clic. Les services ne passent plus par le journal de stock.
- ✅ Packs éclatés : une ligne par produit (quantité dans le pack × nombre de packs, colonne colis « Pack »), prix
  du pack réparti au prorata des prix de vente, ajout tout ou rien selon le stock, quantité modifiable, ligne
  distincte du même produit ajouté seul. `vente_ligne.composant_pack` (v21) distingue ces lignes des anciennes lignes
  de pack à l'annulation ; elles sont retournables comme un produit.
  ⚠️ PROVISOIRE : montants rapides fixes (200 / 500 / 1000), non paramétrables.

## Retours utilisateur — Général et Ventes ✅ (2026-10-15)

- ✅ Listes déroulantes et menus contextuels positionnés dans l'overlay du navigateur qui les affiche (navigateur
  imbriqué du shell) : la liste s'ouvre sous son champ.
- ✅ `DsDataTable` : bouton « colonnes » au début (après les cases à cocher) ; défilement horizontal de l'en-tête,
  des lignes et des totaux quand la somme des largeurs minimales (`largeurMin`, 110 px par défaut, 180 px si flex > 1)
  dépasse la largeur disponible.
- ✅ Filtres de période : Du, Au et Période rapide occupent chacun une cellule de la grille des filtres, dans tous
  les modules.
- ✅ Ventes : action « Liste des produits » (dialog des lignes du panier, colonne Colis) ; aperçu PDF des exports
  avec « Imprimer » à côté de « Fermer ».

## Retours utilisateur — Listes métier et vues grille ✅ (2026-10-15)

- ✅ Bouton « Rechercher dans la liste » à côté des listes déroulantes métier, dans les dialogs et les filtres
  (`DsSelect.recherche` → `choisirDansListe`, `features/commun/selecteurs.dart`) : produit, catégorie,
  sous-catégorie, remise, pack, client, fournisseur, magasin, caisse, session, utilisateur, vente ; dialogs
  d'entrée, d'entrée rapide, de sortie, de transfert, de stock, de retour, de versement, de caisse et filtres des
  modules. Le dialog reprend les seules options de la liste (recherche, filtres propres à la liste, affichage
  liste ou cartes pour produit, client, fournisseur et vente).
- ✅ Choix du client en caisse, du client / fournisseur et du ticket d'origine des retours, et ajout de produits
  aux documents : mêmes dialogs, avec cartes.
- ✅ Affichage liste ou grille (`CarteEntite`) dans Clients, Fournisseurs, Ventes et Utilisateurs (Produits
  l'avait déjà) ; les cartes coupent leur contenu dans une grille à hauteur fixe au lieu de déborder.

## Retours utilisateur — Dialogs, Retours et Remises ✅ (2026-10-15)

- ✅ `DsDialog` : boutons du pied centrés dans tous les dialogs (le contenu de début de pied reste à gauche).
- ✅ Panneaux de filtres : une même largeur de libellé dans toutes les cellules (`DsLargeurLibelle`), colonnes
  alignées ; Retours : période sur la 1ʳᵉ ligne, Client / Fournisseur, Remboursement et État sur la 2ᵉ.
- ✅ Retours : « Nouveau retour client » et « Nouveau retour fournisseur » selon l'onglet ; le dialog n'affiche que
  la carte du type de l'onglet (plus de bascule client / fournisseur).
- ✅ Remises : type (Par produit / Par montant) en tête du formulaire ; une remise par montant n'a plus d'éditeur de
  produits et s'enregistre sans ligne (elle était bloquée) ; option « Cumulable » retirée (colonne conservée en base,
  toujours 0) ; champ Observation.
- ✅ Remises : état calculé sur la période (`Remise.estActive`, bornes incluses à la journée) : Active / Inactive,
  Annulée si annulée. Une remise inactive n'est proposée ni dans les listes, ni dans le dialog de sélection, ni en
  caisse, et ne s'applique pas aux produits.

## Retours utilisateur — Audit, détails, produits et suppressions ✅ (2026-10-15)

- ✅ Audit : tous les modèles affichés en tableau portent `Audit` (créé le / par, modifié le / par) ; migration v22
  (sessions, mouvements de caisse et de stock, bons de réception, zakat) ; quatre colonnes masquées par défaut
  (`colonnesAudit`) dans tous les tableaux. Les clôtures, immuables, prennent leur création de `date` / auteur.
- ✅ Double-clic sur une ligne ou une carte : détail du module, ou à défaut dialog de détail générique
  (`afficherDetailLigne`) listant toutes les colonnes autorisées.
- ✅ Formulaires : titres de section colorés avec icône (`DsSubHead`) ; nouveau produit : description par mode, textes
  IA raccourcis ; filtres Produits : quantité en stock et prix d'achat (le prix de vente existait).
- ✅ Catégorie, sous-catégorie, remise, pack : « Supprimer » remplace « Annuler » (suppression réelle, une
  transaction, journalisée). Produits d'une catégorie / sous-catégorie supprimée basculés vers Sans catégorie
  (CATE0000 / SC0000) ; remise supprimée retirée des produits ; un pack déjà vendu ne peut pas être supprimé.

## Retours utilisateur — Stock, mouvements, entrées, sorties, transferts, besoins ✅ (2026-10-15)

- ✅ Panneau de filtres : `periodeSeule` (marqueur `DsFinLigne`) place Du / Au / Période rapide seuls sur la 1ʳᵉ
  ligne ; Mouvements (4 filtres sur la 2ᵉ ligne), Entrées, Sorties, Transferts et Listes de besoins.
- ✅ Filtres : Stock (Produit, Marque), Mouvements (Produit), Entrées (Type d'entrée rapide / normale, Produit),
  Sorties (Produit) ; filtre Produit commun (`filtreProduit`).
- ✅ « Liste des produits » à côté de « Détail » : Entrées, Sorties, Transferts, Listes de besoins.
- ✅ Sorties et transferts : quand il ne reste plus de pièces (2ᵉ stock) dans le magasin, le nombre n'est plus exigé
  et la quantité restante peut sortir jusqu'à 0 ; nombre proposé plafonné aux pièces disponibles (erreur sinon).
- ✅ Nouveau transfert : colonnes Stock total et Qté (Depuis).
- ✅ Nouvelle liste de besoins : boutons « Produits sous le seuil » et « Produits en rupture » (quantité suggérée).

## Retours utilisateur — Infobulles et pied des dialogs ✅ (2026-10-16)

- ✅ Barre latérale repliée : infobulle des modules (et « Replier / Déplier » des catégories) à droite de l'icône
  (à gauche en RTL), centrée verticalement (`positionLaterale`) ; elle ne masque plus le module suivant.
- ✅ `DsDialog` avec contenu de début de pied (« * obligatoire », « Précédent »…) : boutons au centre exact du pied
  (deux zones égales de part et d'autre) dans tous les dialogs d'insertion.

## Retours utilisateur — Tiers, retours, situations, caisse ✅ (2026-10-16)

- ✅ Versements clients : plus de bouton « Versement retour » (un remboursement client passe uniquement par un
  retour) ; il reste côté fournisseurs.
- ✅ Retour client non remis en stock (produit cassé) : l'entrée Retour est compensée par une sortie « Casse »
  équivalente (SRT…, migration v23 `sortie_stock.retour_code`), valorisée au prix d'achat de la vente, dans la même
  transaction. La sortie est verrouillée (ni modification ni annulation seule) ; modifier ou annuler le retour la
  remplace ou l'annule.
- ✅ Retour fournisseur : champ « Remise en stock » supprimé (le produit repart chez le fournisseur).
- ✅ Champs Remboursement (retour client) et Règlement (retour fournisseur) supprimés : le montant va directement au
  solde (avoir client, déduction du crédit fournisseur) ; le client de passage, sans solde, est remboursé en
  espèces. Colonne et filtre Règlement retirés de l'écran Retours (colonne masquable conservée).
- ✅ Situation client / fournisseur : dialog plus haut, filtres alignés sur une ligne (Du, Au, Période, Type),
  colonnes « Solde avant » et « Solde après » pour chaque opération.
- ✅ Cartes clients / fournisseurs redessinées : initiales, téléphone et code, statut, bandeau Total achats / Crédit ;
  adresse et étoiles retirées.
- ✅ Caisse : carte produit moins haute (172 au lieu de 196) et photo deux fois plus haute (104 au lieu de 52).

## Retours utilisateur — Listes, codes ENT, type de panier, packs, remises, filtres ✅ (2026-10-16)

- ✅ Dialogs de listes de produits plus hauts : la hauteur suit l'écran (`hauteurListeDialog`, `DsDataTable.reserveEcran`,
  `DsLineItemsEditor` par défaut) — liste des produits d'un document ou d'un panier, détail d'entrée / sortie /
  transfert / besoin, lignes des formulaires, sélecteur de produits, recherche caisse, ventes du jour.
- ✅ Entrées (normales et rapides) codées `ENT` au lieu de `SS` ; migration v24 : les entrées existantes sont renommées
  partout où leur code est repris (lignes, bons reçus, imputations, retours fournisseurs, mouvements, historique).
- ✅ Type de panier (Ticket / BL / BL SC) supprimé : bouton BL / SC et raccourci F5 de la caisse, filtre et colonne
  Type des Ventes et des ventes du jour, badge et ligne du détail, référentiel `typePannier`. La colonne
  `vente.type_panier` reste en base (valeur par défaut), hors scellement.
- ✅ Recherche produit (caisse) : « Réinitialiser » en bouton icône seule (infobulle).
- ✅ Caisse : les lignes d'un pack vont ensemble — supprimer un produit retire tout le pack ; changer la quantité
  d'une ligne ramène tout le pack à un nombre entier de packs (contrôle de stock sur chaque produit).
- ✅ Nouvelle / modifier remise : sections Type de remise, Informations générales, Valeur de la remise, Période de
  validité, Produits concernés.
- ✅ Filtres Produits : 1ʳᵉ ligne Catégorie, Stock, Marque ; 2ᵉ ligne Quantité, Prix de vente, Prix d'achat.
- ✅ Mouvements : Produit sur la 1ʳᵉ ligne avec Du / Au / Période ; Type, Magasin, Utilisateur sur la 2ᵉ.

## Audit des workflows — correctifs critiques ✅ (2026-10-16)

Rapport complet (3 critiques, 12 majeurs, 15 mineurs, manques vs références, plan) : document « Audit CaisseDZ —
workflows et calculs » du projet.

- ✅ C1 : codes au-delà de 9 999 — dernier code lu par numéro (`CodeGenerator.ordreDecroissant` : longueur puis
  texte) dans tous les `prochainCode`, la chaîne de scellement, la clôture Z et l'export fiscal.
- ✅ C2 : espèces attendues à la fermeture de session = solde Espèces du journal de caisse depuis la fermeture
  précédente (`CaisseRepository.especesSession`) : versements, paiements, remboursements, dépenses compris.
- ✅ C3 : migration v25 — références « SS… » des paiements immédiats d'entrées passées en ENT.
- ○ Majeurs M1–M12 et mineurs m1–m15 : voir le plan du rapport (journal de caisse en ajout seul, solde unique des
  tiers, retours, coûts / crédit, intégrité fiscale, TVA / timbre / facture).

## Plan d'amélioration — points 1 à 3 ✅ (2026-10-16)

- ✅ M9 — Journal de caisse en ajout seul : annuler / modifier un versement, un retour, un paiement d'entrée ou un
  transfert contre-passe (écriture inverse datée du jour, même référence, `CaisseRepository.contrePasserReference`) ;
  versements refusés si leur date (ancienne ou nouvelle) est dans une période clôturée de leur caisse ; migration
  v26 : déclencheurs interdisant DELETE et la réécriture des colonnes financières de `mouvement_caisse`.
- ✅ M1 / M2 / m4 — Solde unique des tiers : vue `solde_tiers` (migration v27) = restes à la pièce − règlements
  (avoirs compris) + argent rendu hors retour, indépendante des imputations ; lue par la liste, la caisse, la
  situation, les alertes, le tableau de bord et la zakat. Relevé : payé = total − reste (hors monnaie rendue) ;
  graphique des modes : monnaie déduite des espèces ; entrée réduite sous le payé : excédent désimputé (avance).
- ✅ M10 — Retour daté du jour, possible après la Z du jour de la vente ; période contrôlée sur la date du retour,
  par caisse (`retour.caisse_code`, vérificateur de clôture par caisse pour ventes, retours, versements).
- ✅ M3 — CA (tableau de bord, CA par jour, ventes par caissier, top produits, recette par produit) et marges (par
  panier, par période) nets des retours clients à leur date ; un retour « Casse » garde son coût (perte affichée).
- ✅ M6 / M5 — Points gagnés repris au prorata du montant retourné (`retour.points_repris`, rendus si le retour est
  annulé) ; pièces réintégrées au prorata de la ligne ; inventaire avec colonnes pièces théoriques / comptées.
- ✅ m2 / m1 — Retour par ligne de vente (`retour_ligne.ordre_origine`, plafond par ligne) ; unités figées sur
  `vente_ligne.unites` (migration v28) ; annulation de vente d'après les mouvements de stock réels.

## Plan d'amélioration — points 4 à 7 ✅ (2026-10-16)

- ✅ Point 4 (M4, M7, M8, migration v29) — Coût d'une vente au nombre = pièces × prix d'achat ÷ pièces par unité ;
  plafond de crédit client bloquant (permission « Dépasser le plafond de crédit ») ; prix d'achat / vente avant et
  après figés par ligne d'entrée et restaurés à l'annulation ou à la modification.
- ✅ Point 5 (M11, M12, m7, migration v30) — `journal_fiscal` chaîné en ajout seul (VENTE, ANNULATION_VENTE,
  RETOUR, MODIFICATION / ANNULATION_RETOUR, CLOTURE_CAISSE, FACTURE, AVOIR), dans l'export fiscal (format 2,
  extrait de période vérifiable) ; déclencheurs d'immuabilité (ticket, lignes, paiements, stock ; « Annulée »
  seulement avec son événement) ; ticket scellé v2 ; caisse Coffre `CIS0001` ; Z sans fond / retrait / écart /
  coffre / transferts.
- ✅ Point 6 (migration v31) — TVA par ligne de vente (collectée) et d'entrée (déductible), prix TTC, régime Réel /
  IFU ; factures FAC et avoirs AVO (numérotations distinctes, identités fiscales figées, article d'imposition des
  tiers, TVA par taux, montant en lettres, scellement, jamais modifiées ; annulation ou retour d'une vente
  facturée → avoir) ; droit de timbre sur la part espèces (⚠️ PROVISOIRE : ≤ 300 DA exonéré, 1 % / 1,5 % / 2 %,
  minimum 5 DA) encaissé en caisse ; facture A4 (duplicata, avoirs, reste du jour) ; export G50 (Excel).
- ✅ Point 7 (migration v32) — m3 retour fournisseur selon la répartition d'origine ; m5 seuil « ≤ » et périmètre
  magasins de l'utilisateur partout ; m6 écart d'arrondi de la remise globale sur la dernière ligne, retour qui
  solde une ligne = reste exact ; m8 document INV au théorique figé, annulable (service) ; m9 pas de monnaie au-delà
  des espèces ; m10 session exigée (complément de paiement, modification / annulation de retour) ; m11 magasin de
  la caisse ouverte ; m12 points sur l'encaissé hors points et crédit, jamais négatifs ; m13 prix à la pièce
  pour une ligne « pièces seules » ; m14 types `Stock initial` et `Annulation`, transferts ignorés tous magasins ;
  m15 facture : reste dû du jour.
- ○ Restent : écran de liste des inventaires (annulation INV sans interface), barème du timbre et présentation
  G50 à confirmer avec la spécification 06, Bluetooth natif, vue avant / après de l'Historique.

## Caisse, stock et vérification des workflows ✅ (2026-10-16)

- ✅ Scan d'un produit déjà au panier (unité, sans colis ni pack) : quantité + 1 sans dialog ; dialog de sélection
  ouvert : une rafale du lecteur (frappes ≤ 60 ms, ≥ 4 caractères, Entrée) ajoute 1 si c'est le même produit,
  sinon valide le dialog et traite le nouveau code ; la quantité saisie n'est plus polluée par le code-barres.
- ✅ Écran Stock : la colonne « Total » reste la somme de tous les magasins consultables quand le filtre magasin
  est posé (seule la colonne du magasin filtré est affichée à côté).
- ✅ Vérification des 11 scénarios (retour client / fournisseur créé, modifié, annulé ; sortie créée, modifiée,
  annulée ; vente créée, annulée ; versement client / fournisseur créé, modifié, annulé) : stock, caisse (solde et
  espèces de session) et soldes tiers cohérents à chaque étape (`test/application/workflows_coherence_test.dart`).
  Corrigé : modifier / annuler un versement exige une session ouverte (comme la saisie) ; l'annulation d'une vente n'annule un versement que s'il est
  entièrement imputé sur ce panier (sinon l'imputation est libérée et le versement reste en avance).

## Fonctionnalités commerciales et fiscales manquantes ✅ (2026-10-17)

- ✅ Téléphone client / fournisseur 10 chiffres maximum (mobile 05/06/07 + 8 chiffres, fixe 02/03/04 + 7) ; solde
  initial saisi sur la fiche du client et du fournisseur (compté dans le solde unique) ; filtre client / fournisseur
  dans Versements.
- ✅ TVA HT / TVA / TTC par taux (19 %, 9 %, exonéré) sur le ticket, la clôture Z, la liste des ventes, les entrées
  (TVA déductible) et l'analyse TVA de Situation ; régime IFU ou Réel ; aide G50 (export Excel existant).
- ✅ Onglet Factures & avoirs dans Ventes : numérotation FAC / AVO propre et continue, NIF / NIS / RC / AI du vendeur
  et du client, montant en lettres, avoir automatique sur retour ou annulation d'une vente facturée.
- ✅ Module « Devis & commandes » (migration v34) : devis DEV et proformas PRO (statuts En cours, Accepté, Refusé,
  Transformé, Expiré calculé, Annulé ; aucun effet sur stock ni solde), commandes clients BCC livrées en une ou
  plusieurs fois (chaque livraison crée la vente et le bon LIV dans une transaction, session ouverte exigée, reste
  au crédit du client), BL imprimable pour une vente de caisse depuis Ventes.
- ✅ Module « Commandes fournisseurs » BCF : réception partielle par les entrées (formulaire pré-rempli du reste),
  statut calculé, « Solder » pour clore le reliquat, modification / annulation bloquées après une réception ;
  création depuis une liste de besoins.
- ✅ Workflow HTML de l'application (`docs/workflow/workflow.html`, généré par `tool/workflow_html.py`) sur le
  modèle de l'ancienne version, avec captures régénérées par `CAPTURES=1 flutter test test/outils/captures_workflow_test.dart`.


## Retours interface, prix HT, documents et caisse ✅ (2026-10-17)

- ✅ Boutons Modifier / Annuler des barres d'outils en icône seule (crayon, X) avec infobulle ; dialog de période
  du tableau de bord élargi ; date et heure (24 h) dans les tableaux et détails.
- ✅ Aperçu avant impression (Enregistrer en PDF, Imprimer, Fermer) pour les factures, avoirs, devis, proformas,
  commandes et bons de livraison ; nouvelle mise en page A4 (en-tête émetteur, cartes référence / client, tableau
  zébré, totaux encadrés, montant en lettres, filigrane DUPLICATA / Annulé, pied numéroté avec empreinte).
- ✅ Arabe dans les PDF (factures, devis, proformas, BL, rapports, étiquettes) : un texte arabe s'écrit de droite à
  gauche, lettres liées, même dans un document en français (`core/print/texte_pdf.dart`).
- ✅ Recherche globale (barre du haut, Ctrl+K) : produits, tiers, ventes, factures, documents, entrées, commandes,
  retours, versements, sorties, transferts, besoins ; ouvre le module sur le bon onglet avec la recherche remplie.
- ✅ Prix de vente du produit saisi HT : TTC = HT + TVA du produit en caisse, devis / commandes, sélecteurs et
  étiquettes (TTC = HT au régime IFU) ; prix des packs inchangés (prix final) ; prix d'achat inchangés (TTC).
- ✅ Points rouges de nouvelle activité sur les modules (barre latérale) et leurs onglets, par utilisateur, éteints
  à la consultation (`domain/pastilles.dart`).
- ✅ Clôture de session : solde théorique ventilé par type de mouvement, avertissement si négatif (comptage ≥ 0) ;
  le coffre ne s'ouvre plus comme une caisse.
- ✅ Téléphone contrôlé dans le formulaire utilisateur (même règle que les tiers) ; « Accès non autorisé » court dans
  le menu des modules ; sélecteur de magasin retiré de la barre latérale.
- ✅ Caisse, admin : produit en rupture ou quantité au-delà du stock du magasin de la caisse → si un autre magasin a
  assez de stock, proposition d'un transfert TRF du manque (le mieux pourvu) puis ajout au panier.
- ✅ Logo de la boutique (Paramètres › Boutique) en tête des factures, avoirs, devis, proformas, commandes, BL et
  tickets PDF ; la couleur des documents (bandeaux, en-têtes de tableau, traits) est la couleur la plus utilisée du
  logo (`core/print/couleur_logo.dart`, assombrie si trop claire), violet du DS sans logo.
- ✅ Caisse : le stock d'une carte produit rebondit et passe à la couleur primaire quand il baisse (produit mis au
  panier, `DsStockAnime`).
- ✅ Paramètres › Règles de vente : « Vente en caisse avec TVA » et « Devis, proformas et commandes avec TVA »
  (`tva_caisse`, `tva_documents`, Oui par défaut). Non : prix HT, lignes au taux 0 (ticket, facture, G50 sans TVA) ;
  la livraison d'une commande suit le paramètre des documents.
- ✅ Retours clients et fournisseurs : « Montant retour » obligatoire (somme rendue au client ou remboursée par le
  fournisseur). Enregistré dans la même transaction que le retour : un versement en espèces de ce montant, daté
  comme le retour (décaissement pour un client, encaissement pour un fournisseur, journal de caisse), et un avoir
  pour le reste (total − montant). Client de passage : montant = total, champ verrouillé. Annuler le retour annule
  les deux versements. Montant visible dans le détail et en colonne de la liste.
- ✅ Retours : bouton « Montant complet » à côté du montant retour (reporte le total, aucun avoir).
- ✅ Tableau de bord : les 6 cartes KPI sont cliquables (Ventes et Période précédente → Ventes, Achats → Entrées,
  Net → Situation, Dette → Fournisseurs, Crédit → Clients) et de même hauteur ; les légendes sous les deux premiers
  chiffres sont supprimées (l'intervalle précédent passe dans l'info-bulle).
- ✅ Barre supérieure : la recherche globale devient une icône (Ctrl K), raccourcis (favoris) limités à 5.

## Formules, compte BENS et licences signées ✅ (2026-10-19)

Desktop — Plans & Pricing (Trial / Basic / Advanced / Ultra) et le compte BENS du gérant. Remplace les
hypothèses 1, 4 et 5 du lot 1 (clé SHA-256, répartition Basic/Avancé, mode démo).

- **Premier écran : les formules** (`features/offres/offres_page.dart`) : Basic, Advanced, Ultra, chacune
  commençant par 14 jours d'essai gratuit (prix et offres de bens_ds `GET /api/app/caissedz-desktop/offers`,
  hors ligne les paliers connus). Choisir une formule → **créer le compte** (nom, commerce, téléphone, mot de
  passe) : l'essai du palier choisi commence (une fois par numéro et par poste, côté serveur). « Se
  connecter » pour un compte existant ; « Mot de passe oublié » : un code de récupération à envoyer à BENS sur
  WhatsApp, puis le code de réinitialisation reçu (`features/compte_bens/`). « J'ai une clé » : la clé signée
  collée (secours hors ligne).
- **Licence BENS signée** (`packages/bens_license`, copie de bens_ds) : liée au code du poste `CD-XXXX-XXXX`
  (MachineGuid), vérifiée hors ligne à chaque lancement ; palier signé 0 Basic, 1 Advanced, 2 Ultra.
  Elle arrive par le compte (inscription, connexion, check-in au lancement en arrière-plan), et repart avec
  lui (compte passé sur un autre poste, révocation, remboursement). `LicenceService`, stockage dans
  `parametre_app` (`LicenceRepository`), `lib/core/licence/license_config.dart` (clé publique à coller
  depuis le tableau de bord : vide, toute clé est refusée).
- **Comptes locaux** inchangés (admin, caissiers) ; sur un poste neuf, l'administrateur prend le mot de passe
  du compte BENS et s'ouvre directement après l'inscription (`AuthService.ouvrirAdminInitial`).
- **Paliers** (`domain/modules.dart`) : devis et commandes, commandes fournisseurs et besoins à partir
  d'Advanced ; magasins et transferts en Ultra. Écran verrouillé et barre latérale nomment le palier requis.
- **Mode démo retiré** (migration v035 : compte demo désactivé, ancienne clé effacée) ; bandeau « Essai … :
  N jours restants » dans le shell et la connexion, vers les formules. Paramètres › Licence : palier, fin,
  compte BENS (déconnecter ce poste), code du poste, clé.
- Tests : `test/application/licence_service_test.dart` (clés, compte avec un serveur simulé), activation
  et formules, redirections, connexion, shell ; clés signées par un signataire jetable
  (`test/helpers/licence_test_helper.dart`).

- **Fin de l'essai : lecture seule** (`Licence.lectureSeule`, licence expirée gardée) : la connexion reste
  possible et ouvre le tableau de bord ; bandeau « Essai terminé… » vers les formules ; seuls les modules de
  consultation s'ouvrent (`modulesLectureSeule` : tableau de bord, ventes, produits, stock, tiers, historique,
  zakat, paramètres), les autres (caisse, entrées et Smart Scan, retours, gestion de caisse…) affichent
  « Lecture seule » ; dans les listes (`DsLectureSeule` autour des modules), ni création, ni modification,
  ni export, seulement le détail. Les données sont gardées ; acheter une formule débloque au check-in.
- **Limites du palier** : caissiers (comptes actifs hors administrateur) et magasins actifs, à la création et à
  la réactivation (`UtilisateurService.maxCaissiers`, `StockService.maxMagasins`, depuis la licence) :
  Basic et Advanced 1 magasin / 5 caissiers, Ultra 15 / 15 ; l'essai a ceux du palier choisi.
- **Caisses du palier** (Desktop — Plans & Pricing, ligne « Cashiers ») : caisses actives hors coffre,
  Basic 1, Advanced 5, Ultra 15 (`NiveauLicence.caisses`, `CaisseService.maxCaisses`, à la création et à la
  réactivation). Basic, une seule caisse : ni « Nouvelle caisse », ni onglet Transferts, ni transfert entre
  caisses (refusé par le service) ; la grille des rôles ne propose que les modules et permissions du palier.
  Écran des formules : Basic le socle, Advanced et Ultra « Tout <palier précédent>, plus : » et leurs ajouts,
  puis magasins, caisses et Smart Scans.
- **Restauration d'une sauvegarde d'un autre PC** : la licence et le compte BENS de ce poste sont gardés
  (`LicenceRepository.clesDuPoste`), le reste vient de la sauvegarde.

- **Lecture seule jusque dans les dialogs** : `DsLectureSeule` est posé à la racine de l'application ; un
  `DsEntityDetailDialog` n'y montre ni Modifier ni ses actions de pied (impression, versement).
- **Smart Scan au vrai protocole** (`SmartScanService`, catalog-api.bensds.com/smartscan/*) : le poste
  s'authentifie par sa licence BENS signée (`X-Device-Id` = identifiant brut, `X-License-Key`) ; OCR
  (`/scan`, un scan compté seulement si du texte est lu) puis extraction des lignes (`/extract`, consigne de
  CaisseDZ Mobile). Les scans sont ceux du compte BENS, comptés par bens_ds : inclus dans la formule puis
  packs (le plus proche de l'expiration d'abord). Photos JPG, PNG, WEBP. Plus de scans : un pack demandé à
  BENS depuis le compte (Petit, Boutique, Grossiste) ; bandeau de rappel quand des scans expirent dans les
  30 jours.

**Reste à faire** : client-serveur multi-postes (plus tard).

## Application mobile CaisseDZ Scan ✅ (2026-10-19)

Téléphone relié au poste sur le réseau de la boutique (projet `caissedz-scan-mobile`, design system de
CaisseDZ mobile `cdz_ui`).

- **Serveur du poste** (`application/serveur_mobile.dart`, HTTP + JSON sur `/api/v1`, port 8787 ou suivant) :
  démarré depuis l'icône téléphone de la barre du haut (Admin seul) et relancé au démarrage s'il était activé
  (`parametre_app.mobile_actif`). Toute écriture passe par les services du poste (`CatalogueService.creerProduit`,
  `AchatService.enregistrer` source « Entrée rapide », `SessionCaisseService.ouvrir`, `AchatService.deposerBon`),
  avec le contexte d'audit de l'utilisateur du téléphone (rétabli ensuite sur celui du poste) ; refusée en
  lecture seule ; écrans du poste rafraîchis après coup.
- **Appairage** : QR (adresses IPv4 locales, port, code valable 10 min) ; jeton d'appareil dont seule
  l'empreinte SHA-256 est gardée (migration v036, table `appareil_mobile`) ; liste des téléphones et
  révocation dans le dialog « Application mobile ».
- **Connexion** : identifiant et mot de passe du poste ; seuls l'Admin et les rôles ayant la nouvelle permission
  `utiliserMobile` (« Application mobile », Utilisateurs › Rôles) ; modules et permissions du rôle appliqués
  (prix d'achat et marge selon `voirPrixAchat` / `voirMarge`, magasins selon `voirStockTousMagasins`) ;
  pause de 30 s après 5 échecs ; session en mémoire (12 h glissantes).
- **Côté téléphone** : ventes du jour et détail des tickets, stock par magasin, création de produit Rapide ou IA
  (sources du catalogue IA du poste), entrée rapide (ouvre la session de caisse si besoin), photos de factures
  déposées dans la file Entrées › Mode IA (lues plus tard par Smart Scan sur le poste).
- Tests : `test/application/serveur_mobile_test.dart` (appairage, connexion et permission, produit, entrée
  rapide avec session de caisse, facture, lecture seule, révocation).

**Limites** : HTTP en clair sur le réseau local (mot de passe compris) ; Windows demande d'autoriser le pare-feu
au premier démarrage (réseaux privés).

## Allègement de l'interface ✅ (2026-10-20)

- **Chiffres repliés** : les cartes de chiffres des modules (`DsModuleTable.kpis`) sont dans un bloc
  « Chiffres clés » repliable (`DsChiffresRepliables`), fermé par défaut ; ouvert, il le reste pour ce module
  le temps de la session. Le tableau de bord, fait de chiffres, n'est pas concerné.
- **Filtres fermés** par défaut dans tous les modules (plus de `filtresOuverts: true`).
- **Barre latérale** : groupes fermés par défaut sauf celui du module ouvert ; un groupe fermé montre le
  point rouge de ses modules sur son en-tête.
- **Barre d'actions** dans cet ordre : autres actions (export, vue, bouton secondaire, actions métier),
  Détail, Supprimer / Annuler / Désactiver, Modifier, puis Nouveau ; Détail, suppression et modification en
  icône seule, libellé en infobulle (`DsActionModule.place`, déduite de l'action ; `genre` pour l'imposer).
  « Modifier » des dialogs de détail en icône seule aussi.
- **Pas de champ Code à la création** (produit, catégorie, remise, pack, client, fournisseur, versement,
  retour, entrée, sortie, transfert, magasin, besoins, documents, caisse, utilisateur, rôle) : le code est
  attribué à l'enregistrement ; il reste affiché en lecture seule en modification.
- **Entrée rapide** : ni magasin ni répartition avec un seul magasin (Basic, Advanced) ; tout va au magasin
  principal.
- **Après la connexion** : configuration initiale (1ʳᵉ fois), alertes, puis la Caisse directement (plus de
  menu des modules par-dessus).
- **Cartes cliquables** (`DsStatCard.onTap`, tableau de bord et modules) : une flèche ↗ (↖ en arabe) au lieu de
  l'icône « info » dit qu'on part vers un autre module ; l'explication reste en infobulle sur la flèche.
- **Menu des modules** (Ctrl+M, choix des favoris) : les modules hors formule n'y sont plus (plus de « Réservé
  au palier … ») ; ceux que le rôle ou la lecture seule ferment restent avec leur cadenas.
- **Alertes de rupture en Basic** : sans module Besoins, ni « Créer une liste de besoins » ni « Commander » ;
  « Ouvrir le module » et l'action de ligne (« Voir le stock ») mènent au Stock.
- **Favoris de la barre supérieure** : quand leurs libellés ne tiennent pas (petite fenêtre), icônes seules,
  sans défilement ; au survol, le favori s'élargit (libellé et croix) avec une animation.
- **CaisseDZ Scan — QR personnel par utilisateur** (migration 37, `appareil_mobile.utilisateur_code`) : l'icône
  téléphone de la barre du haut s'affiche pour tout utilisateur ayant la permission « Application mobile »
  (l'Admin l'a toujours), plus seulement l'Admin. Chacun y affiche **son** QR code (valable 10 min, usage
  unique, annulé quand il se déconnecte du poste). Le téléphone qui le scanne est lié à ce compte et connecté
  directement : plus de choix du compte ni de mot de passe sur le téléphone (aucun mot de passe sur le Wi-Fi).
  Ensuite il rouvre seul sa session avec son jeton d'appareil (redémarrage du poste, 12 h sans usage) ; un
  compte désactivé ou privé de la permission n'entre plus. L'Admin voit et révoque tous les téléphones (avec
  leur propriétaire) et seul il désactive le service ; les autres voient et révoquent les leurs. API :
  `POST /appairer` renvoie aussi la session, `POST /connexion` sans corps, `POST /oublier` (le téléphone se
  délie lui-même) ; `GET /comptes` et la pause après 5 échecs de mot de passe sont retirés. Les téléphones
  appairés avant la version 37 doivent scanner un nouveau QR code.
- Téléphone unique dans la liste (v42, 2026-10-22) : CaisseDZ Scan envoie à l'appairage un `identifiant`
  d'installation (créé une fois, gardé tant que l'application n'est pas réinstallée) ; rescanner un QR depuis
  le même téléphone remplace son ancien appairage (ancien jeton et sessions fermés) au lieu d'ajouter une ligne.
  Sans identifiant (ancienne version de l'app) : même utilisateur, nom et plateforme. La migration garde le
  plus récent des doublons existants et ajoute `modele`.
- Vente du téléphone enregistrée une seule fois (v46, 2026-10-30) : CaisseDZ Scan envoie avec le panier un
  `idVente` (gardé tant que le panier ne change pas) ; `vente_mobile` le relie à sa vente, dans la transaction
  de l'encaissement. Un panier renvoyé faute de réponse à temps, ou pendant son encaissement, reçoit la vente
  déjà enregistrée au lieu d'en créer une seconde. Sans `idVente` (ancienne version de l'app) : comme avant.

## Retours utilisateur — caisse, sous-textes, Entrées et vente sur téléphone ✅ (2026-10-20)

- **Connexion du téléphone** : le pare-feu Windows bloquait le port du serveur mobile (règle « Bloquer » sur le
  profil Public pour l'exécutable de débogage). Le QR met d'abord l'adresse Wi-Fi, écarte les cartes virtuelles
  (WSL, Hyper-V, VirtualBox, VMware, Docker) et met le partage de connexion (192.168.137.x) en dernier
  (`ServeurMobile.ordonnerAdresses`). Le téléphone interroge toutes les adresses à la fois (`GET /info`) et
  n'envoie le code d'appairage qu'à celle qui répond.
- **Offre Basic** : plus de bouton « Paramètres de la caisse » (⚙, à côté de la calculatrice et des raccourcis)
  dans l'écran Caisse ; le groupe Caisse des Paramètres reste.
- **Panier de la Caisse** : le bouton afficher / masquer les produits est dans l'en-tête du panier, à droite.
  Produits masqués : une seule barre — client, remise, nouveau produit, nouveau client, vider, afficher les
  produits.
- **Codification** : après `PRD9999` vient `PRD10000` (compteur sans limite, tri par longueur puis texte),
  pour tous les codes (`CodeGenerator`).
- **Dialog « Application mobile »** : sans sous-titre ni adresse IP, étapes courtes ; pastille « Connecté »
  pour les téléphones actifs depuis moins de 5 min (`ServeurMobile.appareilsConnectes`), affichés en premier.
- **Bande de caisse** (en-tête de la Caisse) : seulement la caisse au repos ; au survol, l'état, l'heure, le
  solde et Mouvement / Clôturer se déplient avec une animation ; fermée, « Ouvrir » reste visible.
- **Reçu IA** : bouton « Créer le produit » sur chaque ligne non rapprochée ; le formulaire s'ouvre rempli
  (désignation lue, code-barres, fournisseur du bon, prix d'achat) et le produit créé est choisi pour la ligne.
  Le stock initial reste à 0 : la quantité du bon entre en stock avec l'entrée elle-même.
- **Sous-textes retirés** : sous-titres des modules (`DsPage`), descriptions des dialogs (`DsDialog`,
  sélecteur, formulaires de documents), descriptions des étapes (`DsStepper`). `DsDialog.message` ne sert plus
  qu'aux confirmations, résultats, avertissements d'action en lot et au détail d'une entité.
- **Entrées** : onglets « Entrée » et « Smart Scan » (`/entrees?onglet=1`). Une photo de facture envoyée par le
  téléphone affiche un pop-up avec « Ouvrir Smart Scan » (pour qui a accès à Entrées).
- **Vente depuis le téléphone** (`application/vente_mobile_service.dart`) : `GET /caisse` (modes de paiement,
  clients), `GET /caisse/article/<code>` (produit, colis ou pack au prix de la Caisse : TTC, remise produit),
  `POST /ventes` (panier, client, un paiement) → `VenteService.encaisser` sur la session ouverte de
  l'utilisateur, dans une transaction ; ni crédit ni points ; stock gardé par l'encaissement. Module `caisse`
  requis.
- **CaisseDZ Scan** : le bouton de scan remplit le panier (pour qui vend) puis l'ouvre ; panier comme celui de
  la Caisse (client, quantités, suppression, total), encaissement (mode, montant reçu, monnaie), ouverture de
  la session de caisse si besoin ; tuile « Vendre » sur l'accueil. Sous-textes retirés aussi.
- **Smart Scan (suite)** : dialog Reçu IA élargi de 20 % (1248 px) ; à l'étape 1, aperçu de la photo choisie au
  lieu de son nom et des formats ; « Traiter » en violet, tout à droite de la barre (`DsGenreAction.principale`).
  Produit créé depuis une ligne du bon : stock initial à 0 (non modifiable), avec la mention « {quantité}
  entreront en stock avec l'entrée du bon » : la quantité entre une seule fois, par l'entrée.
  Au traitement, chaque ligne lue reprise dans l'entrée garde son produit (`produit_code` dans `lignes_json`) ;
  le détail du bon affiche, dans « Lignes lues », le produit et le badge « Traité » de ces lignes.
  Détail du bon élargi (1320 px) : photo à gauche, lignes lues à droite (`DsSectionDetail.flex`). Aperçus de
  photo zoomables (`DsImageZoom`) : molette pour zoomer, clic maintenu pour faire glisser, boutons zoom avant /
  arrière et « Image entière ».
- **Fiche produit** : le bouton de génération du code-barres réserve un code interne `CDZ` + date + séquence
  (`CatalogueService.reserverCodeBarresInterne`) au lieu d'un EAN-13 aléatoire. Formulaire réorganisé (1040 px) en
  blocs sobres à libellés au-dessus des champs (`DsFormRow.empile`) : Identification + Photos côte à côte, Prix sur
  une rangée (achat, marge, vente HT, TVA, TTC) ; Stock sur une rangée, Emballages boîte | carton ; Variantes, puis
  Options (codes multiples, interrupteurs en cases, description et observation). Tous les champs sont conservés ;
  textes d'aide explicatifs retirés ; étapes « Produit et prix », « Stock », « Variantes ».
- **Panier, produits masqués** : lignes à gauche sous le titre et ses boutons (comme en mode produits affichés),
  panneau d'encaissement à droite (420 px, fond atténué) : Client, Remise, puis montants rapides, total,
  Enregistrer et Encaisser en bas. « Autre montant » réduit à son icône dans une colonne étroite (montants lisibles).
- **Un magasin / une caisse** : aucun choix de magasin quand le palier n'en a qu'un (Basic, Avancé :
  `plusieursMagasinsProvider`), aucun choix de caisse en Basic (`plusieursCaissesProvider`) : formulaires
  (entrée, Reçu IA, sortie, produit, documents, commandes fournisseurs, utilisateur, ouverture de session,
  mouvement, clôture Z, versement, paiement d'une entrée) et filtres (Entrées, Sorties, Stock, Gestion de caisse,
  Ventes, Situation). Tout va au magasin principal et à la caisse principale ; l'inventaire de la Situation porte
  alors sur le magasin principal.

## Rayons du catalogue BENS à l'accueil ✅ (2026-10-20)

Après la connexion d'un poste neuf (avant la configuration initiale), l'utilisateur qui a accès à Produits
choisit des **rayons** selon son activité ; leurs produits les mieux classés entrent dans le catalogue local.
Trois dépôts : catalog-api (rayons, tri, exclusion), bens_ds (choix de chaque client, tableau de bord), et ici.

- **catalog-api.bensds.com** : les 50 517 catégories brutes (Open Food / Beauty Facts, multilingues) sont
  rangées dans 16 rayons (`catalog_rayon`, noms FR/AR/EN, icône, mots-clés modifiables dans `admin_rayons.php`) ;
  porc et alcool exclus (`catalog_product.exclu`, charcuterie gardée si halal / volaille / bœuf). Chaque rayon
  propose ses **2 000 produits les mieux classés** : recherches par code-barres × 100 (comptées dès maintenant
  sur `GET /products/barcode/{code}`), + 50 si code-barres algérien (613…), + 10 avec photo. `GET /rayons`,
  `GET /rayons/{code}/products`. Reclassement : `admin_rayons.php` ou `php catalogue_core/reclasser.php`.
- **Écran des rayons** (`CatalogueRayonsDialog`) : cartes à cocher (icône, nom dans la langue, nombre de
  produits, « Déjà téléchargé »), Tout sélectionner, compteur « n rayons · N produits », Plus tard / Appliquer ;
  progression page par page ; **bilan** : produits ajoutés et leur part (%) des rayons choisis, rayon par
  rayon, déjà présents. Hors ligne : message et Réessayer. Rouvert depuis **Produits › Catalogue BENS**.
- **Base locale** (`CatalogueRayonsService.telecharger`, migration v38) : produits dans `produit`
  (source `Catalogue`, **sans prix ni stock**, photo = adresse du catalogue, codes-barres secondaires),
  une catégorie + sous-catégorie par rayon (réutilise une catégorie du même nom), `catalogue_rayon` garde le
  lien ; un code-barres déjà connu n'est jamais ajouté deux fois. Réception d'abord, puis UNE transaction.
- **Alertes** : un produit du catalogue jamais entré en stock n'est pas une rupture (alertes, chiffre du
  tableau de bord, Situation, Besoins), sinon 30 000 produits à stock 0 seraient « en rupture ».
- **bens_ds** : `POST /api/app/{product}/catalog-choice` (session du compte) enregistre chaque Appliquer
  (`app_catalog_choices`) ; hors ligne, le choix est gardé et renvoyé au check-in suivant
  (`LicenceService.signalerChoixCatalogue`). Tableau de bord : Official apps › l'app › **Catalogue** (rayons les
  plus choisis, puis chaque client : téléchargés / proposés, %) et la fiche du client.
- Tests : `catalogue_rayons_service_test.dart` (téléchargement, doublons, hors ligne, alertes, envoi à BENS),
  `features/produits/catalogue_rayons_test.dart` (parcours complet, Plus tard, hors ligne) ; catalog-api
  `catalogue_core/tests/rayons_test.php` (62 vérifications) ; bens_ds `ApiTest` (catalog picks) et
  `licenses_test.dart` (onglet Catalogue).
- À venir (docs « Product alerts and catalogue », partie 1) : les 18 alertes produits. La partie 2 (nom arabe et
  tendance) est faite : voir ci-dessous.

## Nom arabe et tendance du catalogue BENS ✅ (2026-10-21)

Partie 2 du document « Product alerts and catalogue ». Les produits téléchargés vont directement dans `produit`
(décision du 2026-10-20) : pas de table `catalogue_reference` séparée ; la tendance enrichit les rayons déjà
téléchargés et le code-barres inconnu est cherché dans le catalogue à la caisse.

- **Nom arabe** (`produit.designation_ar`, migration v39, facultatif) : champ « Nom arabe » à côté de la
  désignation dans la fiche produit (saisi de droite à gauche), cherché comme la désignation (Caisse, F3,
  Ctrl+K, documents, liste Produits), colonne « Nom arabe » de la liste Produits (visible en arabe), tuiles et
  recherche F3 de la Caisse sous le nom arabe en arabe (`Produit.nom(langue)`), colonne `designation_ar` de
  l'import Excel et de son modèle. Tickets (ESC/POS et PDF), facture A4 de vente, devis, proforma, bons de
  commande et de livraison, commandes fournisseurs imprimés en arabe : nom arabe des produits
  (`VenteLigne.nomImprime`, `DocumentsPdf.nomProduit`), désignation gardée pour un colis ou un ancien pack.
  La facture fiscale scellée garde ses désignations ; la vente n'a aucune colonne de plus (scellement inchangé).
- **Catalogue BENS** (catalog-api) : `catalog_product.nom_ar` (le nom lui-même s'il est en arabe, sinon le premier
  nom arabe proposé par un poste) ; renvoyé par les rayons et `GET /products/barcode/{code}` ; repris au
  téléchargement d'un rayon et complété sur les produits du catalogue qui n'en avaient pas.
- **Tendance** (`TendanceService`, au lancement après le check-in, licence active) : `POST /tendance` (licence
  BENS signée du poste, comme Smart Scan) avec, par jour et par code-barres EAN, le nombre de tickets validés qui
  le contenaient, et les fiches saisies ou modifiées (code-barres et codes secondaires EAN, nom, nom arabe,
  marque, catégorie hors Divers ; services, codes internes et produits du catalogue jamais modifiés exclus) ;
  ni prix, ni quantités, ni stocks, ni clients. Ventes depuis le dernier jour envoyé (compris), 30 jours au plus
  après une longue absence ; fiches depuis la dernière envoyée ; hors ligne ou refusé, tout repart au lancement
  suivant. Le serveur (`catalogue_core/Tendance.php`) compte sur 90 jours les boutiques et les tickets
  (50 au plus par boutique et par jour), ajoute 1 000 points par boutique + 10 par ticket au classement du rayon
  et marque **tendance** un produit vendu dans au moins **3 boutiques et 20 tickets** (`.env`
  `TENDANCE_POSTES_MIN`, `TENDANCE_TICKETS_MIN` ; `tendance_le` : depuis quand). Chaque rayon propose
  désormais ses **5 000** premiers (`Rayons::PLAFOND`, `ResultatTelechargement.plafond`).
  Administration : `admin_rayons.php` → Tendance (plus vendus, contributions, recalcul).
- **Fiches apportées au catalogue** (`catalogue_core/Contributions.php`) : un code-barres inconnu du catalogue
  y devient aussitôt un produit (d'une seule boutique, `contribue_par`), rangé dans son rayon ; un produit
  connu ne reçoit que ses champs vides (nom, nom arabe, marque, catégorie, codes-barres en plus), jamais
  remplacés ; chaque création ou complément est noté par poste (`catalog_contribution`).
- **Confirmation des produits ajoutés par une boutique** (`catalogue_core/Confirmations.php`) : score de départ 2 ;
  à la Caisse, un code inconnu du poste trouvé dans le catalogue BENS « à confirmer » ouvre « Produit proposé par
  une boutique » : « Oui, c'est ce produit » (+1, fiche remplie) ou « Ce n'est pas ce produit » (−1, fiche avec le
  seul code-barres) ; `TendanceService.voter` l'envoie tout de suite, hors ligne il part avec l'envoi suivant
  (`parametre_app.tendance_votes_attente`). Un vote par poste et par produit, pas celui du créateur ; à 5 :
  confirmé et proposé dans les rayons ; à 0 : supprimé du catalogue (`.env` `CONFIRMATION_*`). Tableau de bord BENS :
  à confirmer, confirmés, supprimés, et l'état de chaque contribution.
- **Administration du catalogue dans le tableau de bord BENS** (admin.bensds.com → Catalogue, remplace
  `admin_rayons.php`) : vue d'ensemble (chiffres, graphiques par jour sur 90 jours, rayons, qualité du catalogue),
  rayons (noms FR/AR/EN, icône, ordre, type, mots-clés, aperçu des 50 premiers, ajout), tendances, produits à
  confirmer (confirmer / supprimer à la main), maintenance (tables, reclassement par lots avec progression,
  recalcul forcé des tendances). catalog-api `catalogue_core/Admin.php` (`/admin/*`, jeton `REV_SERVER_TOKEN`),
  bens_ds `CatalogAdmin` (`/api/admin/catalog/*`, historique). Documentation HTML : `docs/workflow/index.html`
  (architecture, formules et licences, catalogue et tendances, Smart Scan, CaisseDZ Scan, tableau de bord).
- **Tableau de bord BENS** : Official apps → CaisseDZ → **Trending** (bens_ds `GET /api/admin/rev/catalog-trends`,
  qui lit `GET /tendance/stats` de catalog-api avec `REV_SERVER_TOKEN`) : chiffres, tendances par rayon, plus
  vendus, chaque boutique avec son client (code du poste → `app_accounts.device`), produits ajoutés et fiches
  complétées par les boutiques.
- **Produits devenus tendance** (`CatalogueRayonsService.actualiserTendances`, au lancement) : pour chaque rayon
  téléchargé, `GET /rayons/{code}/products?depuis=<dernière demande>` ; seuls les produits marqués `tendance` (un
  serveur pas encore à jour, qui ignorerait `depuis`, n'ajoute rien) ; les nouveaux entrent dans la catégorie du
  rayon (sans prix ni stock), `catalogue_rayon.tendance_le` retient le jour ; listes de produits rafraîchies.
  Écran des rayons : « N en tendance » sur chaque carte.
- **Code-barres inconnu à la Caisse** : le dialog « Produit introuvable » cherche le code dans le catalogue BENS
  pendant qu'il est ouvert (`SourceBens`, 5 s) ; trouvé : « Trouvé dans le catalogue BENS » (photo, nom, nom
  arabe, marque) et « Créer depuis le catalogue » ouvre la fiche remplie ; sinon la fiche avec le code-barres.
  Enregistré avec un prix, le produit passe au panier. Le catalogue BENS est aussi la 1ʳᵉ source du mode IA de
  la fiche produit (puis CaisseDZ, Mantouj, Open Food / Beauty Facts).
- Tests : `tendance_service_test.dart` (tickets par jour, ventes annulées et codes internes exclus, reprise,
  licence absente, refus, hors ligne), `catalogue_rayons_service_test.dart` (nom arabe, `actualiserTendances`),
  `core/print/noms_arabes_test.dart`, `app/synchro_lancement_test.dart`, widgets Produits (nom arabe, mode IA
  BENS) et Caisse (code inconnu trouvé / absent) ; catalog-api `catalogue_core/tests/tendance_test.php`
  (66 vérifications : seuils, fiches créées / complétées, statistiques) ; bens_ds `ApiTest` (catalog trends, non lancé ici faute de Postgres) et `licenses_test.dart` (onglet Trending).
- **Mise en service** : déployer catalog-api, puis `admin_rayons.php` → « Installer / mettre à jour les tables »
  et « Reclasser tout le catalogue » (reprend les noms arabes). Sans ce déploiement, l'envoi des ventes est
  refusé (rien n'est perdu, il repart au lancement suivant).

## Prix HT / TVA / TTC, entrée manuelle, appairage par l'Admin, colis nommés, 20 alertes produits ✅ (2026-10-21)

- **Affichage des prix** (Paramètres › Caisse et ventes › Affichage des prix, `parametre.affichage_prix` : `TTC`,
  `TVA` ou `TVA et TTC`, défaut) : les cartes produits de la Caisse montrent le seul prix de vente (HT, sans TVA) ;
  chaque ligne du panier détaille le prix appliqué (« HT … · TVA 19 % … · TTC … ») quand la TVA s'applique
  (`texteDetailPrix`). Devis, proformas et commandes clients suivent le même choix : formulaire (P.U. HT, TVA
  unitaire, P.U. TTC ; HT saisi quand le TTC n'est pas affiché), détail et impression A4 (totaux complets).
- **Nouvelle entrée › Manuel** : un produit choisi dans la liste (recherche), quantité reçue, prix d'achat et de
  vente proposés depuis sa fiche, nombre de pièces si le 2ᵉ stock est exigé ; un produit déjà présent reçoit la
  quantité en plus.
- **Appairage d'un téléphone par l'Admin** : le QR de l'Admin ouvre sur le poste « Nouveau téléphone à connecter »
  (nom, système, modèle, adresse IP du téléphone et liste des utilisateurs actifs, ceux sans autorisation mobile
  grisés) ; le téléphone s'ouvre avec le compte choisi (`ServeurMobile.choisirUtilisateur`, réponse attendue 2 min
  au plus, sinon `appairageRefuse`). Le QR d'un autre utilisateur relie toujours le téléphone à son seul compte.
  CaisseDZ Scan (dépôt `caissedz-scan-mobile`) envoie système et modèle, attend 3 min et affiche l'attente.
- **Colis nommés** : jusqu'à 5 colis par produit (`CatalogueService.maxColis`), chacun avec son nom (boîte,
  carton, palette…), ses pièces et son prix ; liés par leur code (renommer garde le colis, retirer le désactive) ;
  code-barres des colis conservé à la modification de la fiche.
- **20 alertes produits** (`AlertesProduitsService`, lecture seule ; seuils et alertes désactivées dans
  `parametre`, `SeuilsAlertesProduits`) : 1 meilleures ventes (top N, couverture < Y j), 2 stock dormant,
  3 candidats à une remise (remise conseillée), 4 marge faible / vente à perte, 5 retours élevés, 6 en hausse,
  7 stock lent, 8 jamais vendus, 9 remises sans effet, 10 stock anormal (négatif, casses, écart d'inventaire),
  11 hausse du prix fournisseur (prix conseillé), 12 achetés ensemble, 13 stock déséquilibré entre magasins
  (transfert conseillé), 14 rupture sans commande (ou commande en retard), 15 produits de saison (an passé),
  16 ruptures fréquentes (ventes perdues estimées), 17 fiche incomplète, 18 bonne marge peu vendu,
  19 nouveautés du marché et 20 tendances du marché que vous n'avez pas (catalogue BENS, produits jamais entrés
  en stock ; migration v40 `produit.tendance_le`). Ventes nettes des retours ; hors Admin, magasins de
  l'utilisateur ; alertes 3, 4, 11 et 18 avec « Voir les prix d'achat ».
  Écrans : carte « Alertes produits » du tableau de bord, analyse Situation › Alertes produits (filtres, export,
  bouton d'action : besoin, remise, fiche produit, transfert, commande fournisseur, pack, retours, mouvements),
  Paramètres › Alertes › Alertes produits, point rouge sur le Tableau de bord tant que de nouvelles alertes ne sont
  pas consultées. Calcul à la connexion, à l'ouverture du tableau de bord ou de la Situation, après les Paramètres
  et toutes les 15 minutes (jamais à chaque vente).
  Écart au document de proposition (résolu, voir ci-dessous) : l'alerte 18 ouvrait la fiche du produit.
- Tests : `detail_prix_test.dart`, `entrees_page_test.dart` (Manuel), `serveur_mobile_test.dart` et
  `choix_utilisateur_mobile_test.dart` (appairage), `catalogue_service_test.dart` et `produits_page_test.dart`
  (colis), `alertes_produits_service_test.dart` (les 20 règles, permissions, seuils),
  `alertes_produits_test.dart` (carte, Situation, action, point rouge, Paramètres).

## Favoris de la caisse et nouveautés du marché (alertes 18 et 19) ✅ (2026-10-21)

- **Favoris de la caisse** (migration v41, table `favori_caisse` : code produit + ordre, communs à tous les postes) :
  onglet « Favoris » de la Caisse (Produits · Favoris · Packs, dans l'ordre d'ajout ; réduit à des icônes dans une
  colonne étroite) ; Produits › action « Favori caisse » (ajoute la sélection, ou la retire si tout y est déjà) et
  colonne masquable ; l'action de l'alerte 18 « Bonne marge, peu vendus » ajoute le produit aux favoris, et un
  favori ne déclenche plus cette alerte. Un produit supprimé quitte les favoris.
- **Nouveautés du marché** (alerte 19) : catalog-api (`GET /rayons/{code}/products?depuis=`) renvoie aussi les
  produits apportés par une boutique CaisseDZ puis confirmés par les autres depuis ce jour, avec `nouveau_le`
  (jour de confirmation). Au lancement, le poste les ajoute avec les tendances et note `produit.nouveau_le`
  (migration v41) ; l'alerte 19 = produit du catalogue jamais entré en stock, confirmé nouveau depuis moins de
  X jours. Remplace l'ancienne approximation (produits arrivés après le téléchargement du rayon). Les postes plus
  anciens ignorent ces produits (ils ne gardent que ceux marqués tendance).
- Tests : `favoris_service_test.dart` (FavorisCaisseRepository), `pos_page_test.dart` (onglet Favoris, RTL),
  `alertes_produits_service_test.dart` (alertes 18 et 19), `catalogue_rayons_service_test.dart` (nouveautés) ;
  catalog-api : `tendance_test.php` (nouveautés et `nouveau_le`).
- **À déployer** : catalog-api (commit « Ajoute les nouveautés du marché aux produits des rayons »). Sans ce
  déploiement, l'alerte 19 reste vide (le reste fonctionne).

## Grandes listes : chargement et affichage par tranches ✅ (2026-10-22)

- Constat (20 000 produits du catalogue BENS) : la vue grille de Produits construisait toutes les cartes d'un coup
  (gel : 3 frappes de recherche = 9 s avec 2 000 produits) ; chaque survol de ligne retriait la liste et recalculait
  les totaux ; la Caisse reconstruisait toutes ses tuiles à chaque frappe ; « Aucun produit » s'affichait pendant la
  lecture.
- `DsModuleTable` (tous les modules : produits, clients, fournisseurs, ventes, entrées, stock, caisse…) : vue grille
  par pages (24 / 48 / 96 cartes, `DsPagination`), recherche sur un index calculé une fois par liste (résultat
  gardé), `chargement` : lignes fantômes et « Chargement… » tant que la liste n'est pas lue (`enChargement`,
  `features/commun/chargement.dart`, branché sur les 33 tableaux de module).
- `DsDataTable` : tri et totaux gardés tant que la liste et les colonnes ne changent pas ; le survol ne repeint que
  le fond de la ligne (`ValueNotifier`) ; `chargement`.
- Caisse : grille et liste paresseuses (`GridView.builder`), index de recherche des produits calculé une fois ;
  tuiles par pages (24, 48 ou 96, comme la grille du module Produits), retour à la page 1 à chaque recherche,
  catégorie ou onglet.
- La base reste lue en entier (SQLCipher dans un isolate, rapide) : c'est l'affichage qui est découpé en tranches.
- Mesure (tests, mode debug) avec 20 000 produits : ouverture 0,4 s, 3 frappes 0,7 s, survol de 10 lignes 90 ms.
- Tests : `ds_module_table_test.dart` (grille par pages, recherche après mise à jour, chargement, tri en cache).


## Retours utilisateur — caisse et alertes ✅ (2026-10-22)

- Caisse : produits par pages (24, 48 ou 96) en grille et en liste ; tuile en rupture à opacité normale, un clic la
  fait clignoter en rouge (rien n'est ajouté ; l'admin garde la proposition de transfert).
- Quantité disponible 0 (clic admin, scan) : dialog « Produit en rupture » (quantité 0, entrée rapide ; admin :
  « Transférer » si un autre magasin en a, puis quantité et transfert du manque) au lieu de « Quantité et colis »,
  qui ajoutait seul au bout de 3 s.
- Dialog Alertes (cloche) : anciennes et nouvelles alertes réunies, sans doublon. « Urgent » (expirés, sessions
  ouvertes), puis les 20 alertes produits par groupe (Ventes, Stock, Prix, Qualité, Marché ; types qui ont des
  alertes), puis « À surveiller » (bientôt expirés, crédits clients, dettes fournisseurs). L'ancienne famille
  « Ruptures et seuils » est retirée : l'alerte #14 « Rupture sans commande » les signale. Chaque ligne produit
  propose son action (besoin, remise, fiche, transfert, commande…), « Voir l'analyse » ouvre Situation › Alertes
  produits sur ce type ; un type consulté éteint le point rouge du tableau de bord. La cloche compte les deux
  (« 99+ » au-delà de 99) ; à la connexion, le dialog s'ouvre s'il y a des alertes de l'un ou l'autre type.
- Téléphones appairés : un seul enregistrement par téléphone (v42, voir « Application mobile »).

## Suppression ou archivage des fiches ✅ (2026-10-24)

- Problème : un produit, client, fournisseur… déjà utilisé ne pouvait pas être supprimé (clés étrangères), seulement
  désactivé ; il encombrait les listes.
- **Règle** (`ArchivageService`, une transaction) : une fiche sans historique est **supprimée** (avec ses tables de
  détail : photos, codes secondaires, colis, favoris, droits du rôle, magasins de l'utilisateur, téléphones) ; une
  fiche référencée ailleurs est **archivée** : la ligne reste en base (`archive_le`, `archive_par`, `actif = 0`,
  migration v43), donc les anciens documents, rapports, soldes, clôtures et le journal du stock ne bougent pas.
- **Références** lues sur le schéma réel (`ArchivageRepository.references`) : clés étrangères vers la table et
  colonnes nommées comme ses codes (`produit_code`, `client_code`, `cree_par`, `modifie_par`…), plus les
  versements (`tiers_type` + `tiers_code`). Une table ajoutée plus tard est couverte sans changer ce code ; le
  journal `historique` ne compte que pour les utilisateurs (auteurs des actions).
- **Blocages** (ni supprimé ni archivé) : élément système ; produit avec stock non nul ou composant d'un pack non
  archivé ; client / fournisseur au solde non nul ; magasin avec stock ou magasin principal d'un compte ; caisse
  avec session ouverte ou solde non nul ; compte connecté ; rôle encore attribué à des comptes non archivés.
- **Objets** : groupe 1 (produit, pack, client, fournisseur) et groupe 2 (magasin, caisse, utilisateur, rôle,
  qui gardent aussi « Désactiver »). Catégories, sous-catégories et remises gardent la suppression réelle ; les
  documents gardent l'annulation douce (`etat = 0` + motif).
- **Écrans** : action « Supprimer » (dialog de lot : « Sera supprimé » / « Sera archivé (a un historique) », motifs
  de blocage) ; bouton « Archives (n) » qui bascule sur la vue Archives (bandeau, colonnes Archivé le / par,
  Détail, Restaurer). La restauration réactive la fiche et respecte la limite du palier (magasins, caisses,
  caissiers).
- **Lectures** : les fournisseurs de données (produits, clients, magasins…) gardent les archivés, car ils servent de
  dictionnaire code → nom pour l'historique ; ils sont retirés des listes de gestion, du sélecteur commun, de
  l'écran Stock, des besoins par état, de la recherche globale et de la synchronisation vers le catalogue BENS.
  La caisse, la connexion, le mobile et les alertes filtrent déjà `actif = 1`.
- **Noms uniques** (casse et espaces autour ignorés) parmi les fiches non archivées : client, fournisseur, magasin,
  et désormais produit, pack et caisse (création et renommage ; un doublon antérieur reste modifiable tant que son
  nom ne change pas). Une fiche archivée libère son nom (pas son code ni son code-barres) ; la **restaurer** est
  bloqué tant qu'une fiche active porte ce nom (« renommez l'une des deux »), et deux archives du même nom ne
  reviennent pas ensemble. Rôle (nom) et utilisateur (identifiant) restent uniques en base, archives comprises.
  Import Excel : ligne « Nom déjà utilisé » ; catalogue BENS : un produit au nom déjà pris est ignoré (compté dans
  « ignorés ») ; la synchro BENS ne renomme pas un produit vers un nom déjà pris.
- Remplace `CatalogueService.supprimerProduits` / `supprimerPacks` (refus dès le premier mouvement ou la première
  vente).
- Tests : `archivage_service_test.dart` (les 8 objets : suppression, archivage, blocages, restauration, limite du
  palier, noms uniques, import Excel) ; `catalogue_rayons_service_test.dart` (nom déjà pris ignoré) ;
  `archives_test.dart` (écrans Produits et Clients).

## Plus de compte admin / admin ✅ (2026-10-24)

- **Constat** : l'administrateur (`USR0000`) recevait `admin` / `admin` à l'installation et ne prenait le mot de
  passe du compte BENS que si la licence était déjà valable juste après l'inscription ou la connexion au compte.
  Essai refusé (déjà utilisé sur ce poste ou avec ce numéro), clé renvoyée mais refusée, compte sans formule puis
  « Actualiser » après paiement, ou activation par clé collée : à chaque fois, la connexion locale s'ouvrait avec
  `admin` / `admin`.
- **Règle** : quel que soit le chemin (essai de 14 jours, formule payée, clé), le client crée (ou connecte) son
  compte BENS, et c'est avec ce compte qu'il se connecte : numéro ou `admin`, et le mot de passe du compte.
- **Données** : la v008 ne pose plus de mot de passe ; la migration `v044_admin_sans_mot_de_passe` efface le mot
  de passe `admin` d'origine sur les postes existants (un autre mot de passe est gardé).
- **Service** : `AuthService.adminPrendCompteBens` (poste neuf : l'administrateur sans mot de passe prend celui du
  compte et son nom) et `adminPrendMotDePasseReinitialise` (toujours, après le code de BENS). Ils sont appelés par
  `SessionNotifier.apresCompteBens` juste après l'inscription, la connexion ou la réinitialisation, **même sans
  licence valable** ; la session s'ouvre seulement si la licence le permet et que personne n'est connecté.
- **Écrans** : l'activation par clé sans compte BENS mène à la création du compte (formule de la clé) ; la
  connexion locale, quand aucun administrateur n'a de mot de passe, montre l'encart « Créer votre compte » /
  « Se connecter ». Message `connexionErreurNonConfigure` reformulé (FR / AR / EN).
- Tests : `demarrage_services_test.dart` (seed sans mot de passe, prise du mot de passe une seule fois,
  réinitialisation, migration v44) ; `connexion_test.dart` (essai refusé puis formule payée, encart sans
  administrateur) ; `activation_test.dart` (clé sans compte → création du compte). Les tests se connectent avec le
  mot de passe du compte BENS de test (`donnerMotDePasseAdmin`).

## Reconnaissance IA confirmée, TVA de la caisse, modification d'une vente ✅ (2026-10-25)

- **Reconnaissance IA** (formulaire produit, mode IA) : la fiche trouvée n'est plus appliquée d'office. Le dialog
  `afficherFicheIa` la montre (photo, nom et nom arabe, code-barres, marque, quantité, catégorie, prix, source,
  « à confirmer » pour un produit ajouté par une boutique) avec « C'est ça » / « Ce n'est pas ça ». Pour une fiche
  du catalogue BENS, la réponse est un vote de confirmation (`TendanceService.voter`, +1 / −1, gardé hors ligne).
  « C'est ça » remplit le formulaire rapide ; « Ce n'est pas ça » ne remplit rien. Le catalogue BENS donne aussi
  sa catégorie (la plus précise, « Sans Categorie » ignorée).
- **Vente avec TVA** en caisse : **désactivée par défaut** (`tva_caisse` absent = sans TVA ; les documents restent
  avec TVA par défaut). Interrupteur « Vente avec TVA » dans l'en-tête de la caisse (régime du réel seulement),
  en plus de Paramètres › Caisse et ventes (`ParametresService.changerTvaCaisse`). Le prix d'une ligne étant fixé à
  son ajout, il ne change que lorsqu'aucun panier n'a de ligne.
- **Modification d'une vente** : le ticket scellé ne peut pas changer (déclencheurs v30 / v31 sur les lignes, le
  client et les totaux). Choix retenu : **annuler et remplacer**.
  - Entrées : « Éditer » dans Ventes du jour (caisse) et « Ajouter des produits » dans Ventes › Modifier le panier.
    `PosController.modifierVente` recharge la vente dans un panier (le courant s'il est vide, sinon un nouveau) :
    ses lignes sont reprises **verrouillées** (`PanierLigne.reprise` : ni retirées, ni modifiées, prix / remise /
    coût / unités / TVA du ticket d'origine, pas de réservation de stock), le client se change, des produits
    s'ajoutent ; pas de remise globale. Bandeau « Modification de la vente … (déjà payé …) » + « Abandonner ».
  - Contrôles (`VenteService.preparerModification`) : vente ni annulée, ni en période clôturée, sans retour lié.
  - Encaissement (`VenteService.encaisser`, UNE transaction) : la vente d'origine est annulée (journal fiscal
    `ANNULATION_VENTE` chaîné, motif « Remplacée par VTE… », stock rétabli puis ressorti à l'identique, points
    rendus, avoir si elle était facturée, **pas** de sortie de caisse) ; le nouveau ticket scellé reprend ses
    paiements (espèces nettes de la monnaie rendue) et, pour le même client, ses points et ses versements imputés
    (imputations déplacées). Client changé : ses versements redeviennent une avance de l'ancien client. Seuls les
    nouveaux paiements entrent au journal de caisse ; le dialog Encaisser demande la différence (« Déjà payé »).
- `DsCartLine` : sans action, les boutons ± sont estompés et la corbeille disparaît.
- Tests : `modification_vente_test.dart` (remplacement, caisse, journal fiscal, chaîne, crédit et versements, client
  changé) ; `pos_controller_test.dart` (rechargement verrouillé, déjà chargée, abandon ; TVA désactivée par
  défaut) ; `pos_page_test.dart` (Ventes du jour → Éditer → ajout → encaissement) ; `ventes_page_test.dart`
  (« Ajouter des produits ») ; `produits_page_test.dart` (fiche IA : confirmée, refusée, votes).

## Session partagée, transfert du manque pour un non-Admin, traçabilité des détails, détail des mouvements ✅ (2026-10-28)

- **Session de caisse partagée** : un utilisateur rattaché à une caisse (`utilisateur.caisse_code`) dont la session
  est déjà ouverte par un collègue **continue cette session** (ventes, versements, achats, retours, fermeture) au
  lieu d'être bloqué. `VenteRepository.sessionAccessible` (la sienne d'abord, sinon celle de sa caisse attachée)
  sert à `SessionCaisseService.courante` / `sessionOuverte` / `ouvrir` / `fermer`, à `VenteService` (complément
  encaissé) et à `CaisseRepository.caisseParDefaut`. Sans caisse attachée, pas d'accès à la session d'un autre.
  Après un changement d'utilisateur, la caisse reprend celle de la session (sinon la caisse attachée du non-Admin).
- **Transfert du manque (caisse)** : n'est plus réservé à l'Admin. Un non-Admin qui a plusieurs magasins se voit
  proposer le transfert (produit en rupture, quantité au-delà du stock) **depuis ses seuls magasins**
  (`utilisateur_magasin`) ; l'Admin puise toujours dans tous les magasins. `PosController.depassementPermis`
  autorise la quantité au-delà du stock dans « Quantité et colis » quand un transfert est possible (formule Ultra).
- **Traçabilité dans tous les détails** : section commune « Traçabilité » (`sectionAudit` / `GrilleAudit`,
  `features/commun/colonnes_audit.dart`), ouverte et toujours en dernier : créé le / par, modifié le / par,
  archivé le / par, puis les compléments propres au document (validation, annulation, empreinte…). Elle remplace
  les anciennes sections d'audit repliées. Ajoutée aux détails produit, catégorie, sous-catégorie, remise, pack,
  stock, sortie, transfert, magasin, besoin, entrée, bon de réception, commande fournisseur, document client,
  caisse, clôture, session, retour, panier, tiers, versement, utilisateur, rôle et zakat.
- **Catégorie** : le détail liste ses **sous-catégories** (code, nom, nombre de produits, état) au lieu des
  produits. **Sous-catégorie** : le détail liste ses **produits** (code, désignation, stock, prix de vente).
- **Mouvements de stock** : chaque type a son détail (`features/stock/mouvement_dialogs.dart`). Double-clic : la
  pièce d'origine (vente ou vente annulée, entrée, sortie, transfert, retour, **inventaire** — nouveau détail INV
  avec théorique / compté / écart), sinon (stock initial, entrée manuelle) le **détail du mouvement** (quantité
  signée, produit, magasin, référence, motif, observation, traçabilité, « Voir la pièce » s'il y en a une).
  Actions « Détail du mouvement » et « Voir la pièce » dans l'onglet Mouvements.
- Tests : `vente_service_test.dart` (session continuée par un collègue de la même caisse, refusée sans caisse
  attachée) ; `pos_controller_test.dart` (transfert limité aux magasins du non-Admin) ; `stock_pages_test.dart`
  (détail du stock initial, pièce d'inventaire).
