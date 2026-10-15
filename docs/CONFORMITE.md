# Checklist de conformité (§15 de la spécification 06)

À recopier intégralement depuis `docs/spec/06_specification_reconstruction.md` §15 et à cocher au fil des lots.

> 2026-10-14 : les sources sont reçues ; le réalignement est en cours (voir `docs/PLAN.md`, « Réalignement DS
> v2.2 »). Les cases ci-dessous reprennent les exigences de la commande initiale, regroupées par lot ; la recopie
> intégrale du §15 et son pointage écran par écran sont faits en phase D.
>
> Phase A / B faites : tokens exacts du DS v2.2 (clair / sombre, typographie, espacements) et composants du
> bundle (66 + v2.2) traduits en Flutter avec les libellés FR / AR / EN.
>
> Phase C faite (2026-10-15) : shell et démarrage conformes au DS v2.2 et aux §4.3 à §5.4 de la spec.

## Socle (lot 0)
- [x] Fenêtre Windows minimale 1000×700, barre de titre personnalisée
- [ ] Tokens du DS v2.2 (clair + sombre) traduits en ThemeExtension — provisoire (DS absent)
- [ ] Tous les widgets du DS disponibles et vérifiés dans la galerie (clair/sombre/RTL) — primitives, DsButton,
      DsDataTable et dialogues faits ; widgets métier en attente du DS
- [x] Base SQLite chiffrée SQLCipher, `foreign_keys ON`, migrations versionnées
- [ ] Clé dérivée de la machine conforme §4.2 — provisoire
- [ ] Schéma des 45 tables
- [x] Seed système : MAG0000, CIS0000, CLN0000, FOR0000, CATE0000, SC0000, admin (migration v2 ; colonnes minimales, à compléter avec la spec)
- [x] i18n FR/AR/EN (ARB), arabe en RTL
- [x] go_router ShellRoute + AppShell DS v2.2 : 17 modules en 4 groupes (Général/Stock/Tiers/Gestion) filtrés par
      accès, favoris max 7 dans la barre supérieure, menu des modules Ctrl+M, cloche + alertes du jour (§5.3),
      témoin Internet, sélecteur de magasin (Avancé), bandeau démo
- [x] Séquence post-connexion (§4.4 / §4.5) : droits → favoris → magasins → alertes ; accueil Caisse, puis
      configuration (1ʳᵉ fois), alertes (s'il y en a), menu des modules
- [x] Relations par code, aucune valeur traduite en base (règle appliquée dès le socle)

## Démarrage (lot 1)
- [x] Activation par clé SHA-256 (64 caractères) — règle de résolution de la clé provisoire (hypothèse n° 1 du plan)
- [x] Mode démo demo/demo — seul compte accepté tant que l'application n'est pas activée (§4.3)
- [x] Connexion (« Rester connecté »), mots de passe hachés (PBKDF2-HMAC-SHA256), déconnexion, journal
      Connexion / Déconnexion, dernier accès
- [x] Configuration initiale en 4 étapes (langue et devise, boutique, paiements, marge et stock), une transaction
- [x] Mon compte (dialog DS) : profil / identifiant, mot de passe, préférences, déconnexion ; démo en lecture seule
- [x] Licences Basic / Avancé (LicenceGate, modules réservés) — répartition des modules provisoire
- [x] Rôles et 7 permissions d'action (voirPrixAchat, colonnes masquées, écran « Accès refusé ») — 6 permissions provisoires
- [x] Fidélité visuelle au DS v2.2 des écrans de démarrage (connexion, activation, configuration, Mon compte,
      alertes, shell) ; les 17 écrans de modules suivent en phase D

## Produits (lot 2)
- [x] Catégories / sous-catégories (système protégé), produits en mode détaillé avec marge, colis, packs, remises
- [x] Codes-barres EAN-13, CAISSEDZ+date, QR — format interne provisoire
- [x] Mode IA avec cascade CaisseDZ → Mantouj → Open Food Facts → Open Beauty Facts — API CaisseDZ/Mantouj provisoires
- [x] 2ᵉ stock « nombre » (pièces par unité) — interprétation provisoire
- [x] Import Excel, étiquettes (PDF A4 / rouleau), synchro catalogue (protocole provisoire)
- [x] Écran Produits fidèle au DS v2.2 (phase D) : 5 onglets, formulaire Rapide / Détaillé / IA, photos, codes
      secondaires, remises Par Produit / Par Montant avec seuil, packs, import avec correspondance des colonnes

## Stock (lot 3)
- [x] Stock = journal des mouvements (SUM), garde de stock toujours active, 2ᵉ stock « nombre »
- [x] Magasins, principal = premier magasin de l'utilisateur
- [x] Transferts TRM (2 mouvements par ligne, une transaction), besoins En attente / Commande / Disponible,
      sorties avec motifs §13
- [x] Écrans DS v2.2 (phase D) : Stock (quantités par magasin, détail, distribution Avancé, onglet Mouvements
      avec « Voir la pièce »), Sorties (modifier, annuler avec motif → stock réintégré), Magasins (téléphone,
      responsable, désactivation bloquée si principal ou stock non nul) + onglet Transferts (modifier, annuler),
      Besoins (listes fournisseur multi-lignes BL, ruptures & seuils, expirés)

## Caisse (lot 4)
- [x] Sessions obligatoires, 5 ventes en parallèle, réservation de stock entre paniers
- [x] Scan (EAN-13, interne, QR), colis, vente à la pièce (« nombre »), remises ligne / globale
- [x] Paiements Espèces / Carte / Chèque / Virement / Points, versé/reste, points gagnés
- [x] 16 raccourcis + aide, calculatrice
- [x] Écran et dialogs du DS v2.2 (onglets de ventes, quantité et colis avec ajout auto 3 s, encaisser ticket /
      BL-SC / crédit, prix avec mot de passe et portée, ventes du jour, recette produit, session compacte)
- [x] Ticket scellé (SHA-256 chaîné), impression 58/80 mm FR/AR (ESC/POS et PDF) et facture A4 — Bluetooth via
      file d'impression Windows (écart)

## Ventes, retours, tiers (lot 5)
- [x] Ventes : liste, ticket, annulation (permission), vérification du scellement
- [x] Ventes DS v2.2 : KPI, filtres, détail, modification (complément en versement imputé), annulation en lot
      avec motif obligatoire, refusée si un retour est lié (phase D) — client non modifiable (ticket scellé)
- [x] Retours : stock restitué, avoir, remboursement
- [x] Retours client / fournisseur depuis la pièce d'origine (panier / entrée), plafond de quantité, versement
      et mouvements liés, modification et annulation avec motif (phase D, migration v12)
- [x] Clients / fournisseurs : fiches complètes §7.6 (wilaya, type, NIF / NIS / RC, banque), soldes calculés,
      situation (relevé), annulation avec motif — écrans DS v2.2 (phase D)
- [x] Versements imputés aux documents ouverts, plus ancien d'abord ; versement retour ; annulation douce
      avec motif (phase D)
- [x] Versement lié à un retour verrouillé

## Achats (lot 6)
- [x] Entrées / achats : transaction unique, stock par mouvements, prix d'achat, dette fournisseur
- [x] Smart Scan IA : quota serveur, quota atteint, demande d'offre
- [x] Entrées DS v2.2 (phase D, migration v15) : Smart Scan 2 étapes, entrée rapide répartie entre magasins,
      Reçu IA 3 étapes avec file `bon_reception`, modification et annulation en lot avec motif, versé / reste
      calculés, réception d'une liste de besoins
- [ ] Session de caisse ouverte obligatoire pour une entrée (§9.6) ; raccourci `E` en caisse

## Gestion caisse et fiscal (lot 7)
- [x] Caisses Physique / Compte, caisse sans magasin ; journal des mouvements ; transferts TRF = 2 mouvements
- [x] Clôtures Z chaînées immuables ; annulation refusée en période clôturée
- [x] Export fiscal : archive + JSON vérifiable
- [x] Gestion caisse DS v2.2 (phase D, migration v16) : 5 onglets Caisses · Transferts · Clôtures Z · Mouvements ·
      Sessions ; solde initial pré-rempli à l'ouverture (§9.13) ; transferts annulables avec motif ; désactivation
      bloquée (session ouverte, solde non nul, caisse système)
- [x] Clôture Z par caisse, chaînage par caisse (§12.3), tickets annulés et répartition des paiements ; export de
      contrôle fiscal en archive / JSON / PDF / CSV avec état de la chaîne
- [ ] Permission `gererTransfertsCaisse` (§9.13) ; journal fiscal `journal_fiscal` avec ligne `CLOTURE_CAISSE` (§12.3)
- [ ] Période clôturée évaluée par caisse (aujourd'hui : toute clôture couvrant la date bloque, ⚠️ PROVISOIRE)

## Rapports et paramètres (lot 8)
- [x] Tableau de bord §9.14 (phase D) : période Jour / Semaine / Mois / Période, 6 KPI (ventes, période précédente,
      achats, net, dette fournisseurs, crédit clients), 5 graphiques, dernières ventes, produits en rupture
- [x] Situation : les 10 analyses de la spec (recette par panier / produit, mouvement caisse / produit, marge par
      panier / période sur coût figé à la vente, inventaire validable, coût produit, situation client / fournisseur),
      filtres, export Excel / PDF ; analyses de coût réservées à `voirPrixAchat`
- [x] Zakat
- [x] Historique (journal d'audit) ; Paramètres complets (boutique, vente, impression, serveurs)
- [x] Sauvegarde / restauration ; exports Excel / PDF avec aperçu

## Recette (lot 9)
- [x] Parcours FR/AR/EN, clair/sombre, Basic/Avancé, Admin/Caissier/Magasinier (`test/recette/parcours_test.dart`)
- [x] Build Windows (configuration MSIX `msix_config`, script Inno Setup, procédure `docs/BUILD_WINDOWS.md`) — build
      non exécuté ici (poste Linux sans toolchain Windows)
