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
  historiques conservés pour les écrans des lots 0 à 9 (à supprimer en phase D).
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
  - Écarts assumés en attendant la phase D : les écrans des lots 0 à 9 utilisent encore les alias historiques ;
    `pos_widgets.dart` (ancienne caisse) subsiste jusqu'à la réécriture de `CaisseScreen`.
- **Phase C — shell et démarrage ✅** (2026-10-15) :
  - Étape 1 (données) : `modules.dart` = 17 modules du DS en 4 groupes (Général : tableau de bord, caisse,
    ventes, retours ; Stock : produits, stock, entrées (badge IA), sorties, magasins, besoins ; Tiers : clients,
    fournisseurs ; Gestion : gestion caisse, utilisateurs, zakat, historique, paramètres) + pages rattachées
    (transferts → magasins, versements → clients, clôtures → gestion caisse, situation → tableau de bord), accès
    via `idAcces`. Migration `v008_shell_ds` : compte admin / admin provisoire, `utilisateur.dernier_acces`,
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
    - Familles « Produits expirés » et « Bientôt expirés » vides : pas de dates de péremption dans le schéma.
    - Logo de la boutique non demandé à la configuration (colonne prête, saisie en phase D dans Paramètres).
    - Compte admin / admin provisoire en attendant la création de comptes par l'écran Utilisateurs (phase D).
- **Phase D — écrans 🔶** : les 17 écrans et leurs dialogs d'après les kits du bundle, listes de `ref.js`,
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
    (`annulerVente`, ⚠️ PROVISOIRE en attendant `annulerOperations`).
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
    Écarts Gestion caisse : la permission `gererTransfertsCaisse` (§9.13) n'existe pas encore (onglet ouvert à qui
    accède au module) ; pas de journal fiscal (`journal_fiscal`, ligne `CLOTURE_CAISSE`) ; une date reste
    « clôturée » dès qu'une clôture de n'importe quelle caisse la couvre (⚠️ PROVISOIRE, plus strict que par
    caisse) ; colonnes Client / Fournisseur / Code versement du grand-livre absentes (le mouvement ne porte que la
    référence) ; l'archive complète contient JSON + CSV + LISEZMOI, sans PDF ; l'écart cumulé et les sessions du
    détail portent sur l'historique chargé.
  - Écarts : colonnes d'audit « modifié le / par » absentes du schéma (seuls créé par et annulation) ;
    tendances des KPI calculées seulement pour les ventes ; ventes antérieures à la v10 valorisées au prix
    d'achat actuel ; `mouvement_stock` sans valorisation (prix_achat / prix_vente de §7.3).
    Ventes : le client d'un panier n'est pas modifiable (§9.2 le permet, mais il fait partie du ticket scellé ;
    décision : retour puis nouvelle vente) et le montant payé ne peut que monter (une baisse passe par un retour).
    Caisse : le n° de panier « PN… » du DS n'est connu qu'à l'encaissement (onglets « Vente n ») ; le
    paramètre « colis par défaut » n'est pas repris (les colis sont libres par produit) ; la clôture détaille
    fond + ventes espèces nettes, sans versements, mouvements manuels ni remboursements (rattachés à la caisse,
    pas à la session) ; le mot de passe demandé pour le prix est celui de l'utilisateur connecté.
