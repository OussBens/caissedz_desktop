# Checklist de conformité (§15 de la spécification 06)

À recopier intégralement depuis `docs/spec/06_specification_reconstruction.md` §15 et à cocher au fil des lots.

> 2026-10-14 : les sources sont reçues ; le réalignement est en cours (voir `docs/PLAN.md`, « Réalignement DS
> v2.2 »). Les cases par lot reprennent les exigences de la commande initiale ; la recopie intégrale du §15 et son
> pointage figurent à la fin de ce fichier (phase D, 2026-10-15).
>
> Phase A / B faites : tokens exacts du DS v2.2 (clair / sombre, typographie, espacements) et composants du
> bundle (66 + v2.2) traduits en Flutter avec les libellés FR / AR / EN.
>
> Phase C faite (2026-10-15) : shell et démarrage conformes au DS v2.2 et aux §4.3 à §5.4 de la spec.
>
> Phase D faite (2026-10-15) : les 17 écrans de modules et leurs dialogs suivent le DS v2.2 ; les alias historiques
> des tokens sont supprimés.

## Socle (lot 0)
- [x] Fenêtre Windows minimale 1400×700 (1000 × 1,4, demande du 2026-10-17), barre de titre personnalisée
- [x] Tokens du DS v2.2 (clair + sombre) traduits en ThemeExtension, sans alias historiques
- [x] Widgets du DS (bundle v2.2 + nouveaux composants) disponibles dans la galerie (clair / sombre / RTL)
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
- [x] Rôles (table `role`, codes ROL) : accès modules + les 7 permissions d'action du §6.2, admin unique non
      assignable, colonnes masquées et écran « Accès refusé » (phase D, migration v17)
- [x] Utilisateurs DS v2.2 : onglets Utilisateurs · Rôles, caisse attachée, magasins ordonnés, assistant de rôle
      en 3 étapes, réinitialisation du mot de passe, désactivations bloquées (admin principal, rôle utilisé)
- [ ] Crédit caissier (§7 `utilisateur.credit`) : règle de calcul absente de la spec
- [x] Fidélité visuelle au DS v2.2 des écrans de démarrage (connexion, activation, configuration, Mon compte,
      alertes, shell) et des 17 écrans de modules (phase D)
- [x] Alertes « Produits expirés » (date passée) et « Bientôt expirés » (≤ 30 jours), produits en stock

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
      avec motif obligatoire, refusée si un retour est lié (phase D) — le ticket scellé ne change jamais :
      changer le client ou ajouter des produits rouvre la vente dans la caisse (lignes verrouillées), puis
      annulation chaînée + nouveau ticket scellé dans UNE transaction (2026-10-25)
- [x] Retours : stock restitué, avoir, remboursement
- [x] Retours client / fournisseur depuis la pièce d'origine (panier / entrée), plafond de quantité, versement
      et mouvements liés, modification et annulation avec motif (phase D, migration v12)
- [x] Clients / fournisseurs : fiches complètes §7.6 (wilaya, type, NIF / NIS / RC, banque), soldes calculés,
      situation (relevé), annulation avec motif — écrans DS v2.2 (phase D)
- [x] Versements imputés aux documents ouverts, plus ancien d'abord ; versement retour ; annulation douce
      avec motif (phase D)
- [x] Versement lié à un retour verrouillé
- [x] Modification / annulation d'un versement : session ouverte exigée ; cohérence
      stock / caisse / soldes vérifiée sur les 11 scénarios retours, sorties, ventes, versements (2026-10-16)

## Achats (lot 6)
- [x] Entrées / achats : transaction unique, stock par mouvements, prix d'achat, dette fournisseur
- [x] Smart Scan IA : quota serveur, quota atteint, demande d'offre
- [x] Entrées DS v2.2 (phase D, migration v15) : Smart Scan 2 étapes, entrée rapide répartie entre magasins,
      Reçu IA 3 étapes avec file `bon_reception`, modification et annulation en lot avec motif, versé / reste
      calculés, réception d'une liste de besoins
- [x] Session de caisse ouverte obligatoire pour une entrée, un retour et un versement (§9.6, §8.4) ; raccourci
      `E` (entrée rapide) en caisse

## Gestion caisse et fiscal (lot 7)
- [x] Caisses Physique / Compte, caisse sans magasin ; journal des mouvements ; transferts TRF = 2 mouvements
- [x] Clôtures Z chaînées immuables ; annulation refusée en période clôturée
- [x] Export fiscal : archive + JSON vérifiable
- [x] Gestion caisse DS v2.2 (phase D, migration v16) : 5 onglets Caisses · Transferts · Clôtures Z · Mouvements ·
      Sessions ; solde initial pré-rempli à l'ouverture (§9.13) ; transferts annulables avec motif ; désactivation
      bloquée (session ouverte, solde non nul, caisse système)
- [x] Clôture Z par caisse, chaînage par caisse (§12.3), tickets annulés et répartition des paiements ; export de
      contrôle fiscal en archive / JSON / PDF / CSV avec état de la chaîne
- [x] Permission `gererTransfertsCaisse` (§9.13) : onglet Transferts en « accès refusé » sans elle
- [x] Journal fiscal `journal_fiscal` chaîné (ventes, annulations, retours, `CLOTURE_CAISSE`, factures, avoirs),
      en ajout seul, vérifié par l'export fiscal (migration v30)
- [x] Immuabilité en base : colonnes scellées des tickets, lignes, paiements, journal de stock, factures
      (déclencheurs v30 / v31) ; ticket scellé v2 (coût, unités, TVA)
- [x] Caisse Coffre (dépôt à la fermeture, fond pris à l'ouverture) ; Z sans mouvements techniques
- [x] TVA figée par ligne (vente et entrée), régime Réel / IFU ; factures FAC et avoirs AVO à numérotation propre,
      identités fiscales (NIF, NIS, RC, AI), montant en lettres ; droit de timbre (barème ⚠️ PROVISOIRE) ;
      export G50 (Excel)
- [x] Période clôturée évaluée par caisse (ventes, retours, versements ; les entrées, sans caisse, restent bloquées
      par toute clôture couvrant la date)
- [x] Journal de caisse en ajout seul : contre-passations au lieu de suppressions, déclencheurs (migration v26)
- [x] TVA HT / TVA / TTC affichée sur ticket, clôture Z, ventes, entrées (TVA déductible) et analyse TVA par taux ;
      onglet Factures & avoirs (FAC / AVO, duplicata, vérification de la chaîne)
- [x] Documents commerciaux (migration v34) : devis DEV, proforma PRO, commande client BCC livrée en une ou plusieurs
      fois par bons de livraison LIV (vente + BL dans une transaction), commande fournisseur BCF réceptionnée en
      partie par les entrées, soldable ; impressions A4 avec montant en lettres
- [x] Téléphone client / fournisseur limité à 10 chiffres, solde initial des tiers, filtre par tiers des versements

## Rapports et paramètres (lot 8)
- [x] Tableau de bord §9.14 (phase D) : période Jour / Semaine / Mois / Période, 6 KPI (ventes, période précédente,
      achats, net, dette fournisseurs, crédit clients), 5 graphiques, dernières ventes, produits en rupture
- [x] Situation : les 10 analyses de la spec (recette par panier / produit, mouvement caisse / produit, marge par
      panier / période sur coût figé à la vente, inventaire validable, coût produit, situation client / fournisseur),
      filtres, export Excel / PDF ; analyses de coût réservées à `voirPrixAchat`
- [x] Zakat DS v2.2 (phase D, migration v18) : calculs annuels enregistrés (codes `ZKT`), nissab et taux en
      paramètres, statut Brouillon / Non payé / Payée, annulation avec motif, KPI provisoires de l'année
- [x] Nissab et taux de la Zakat éditables dans Paramètres
- [x] Historique DS v2.2 (phase D, migration v19) : module, famille d'action, utilisateur, poste et période ; KPI
      7 jours ; détail ; export
- [x] Historique : exports (action `Export`, module d'origine) et sauvegardes / restaurations journalisés
- [ ] Historique : changements avant / après dans le détail
- [x] Paramètres DS v2.2 (phase D) : 7 groupes, barre d'enregistrement unique en une transaction, marge Montant /
      Pourcentage, seuils min / max, vente sous achat, moyens de paiement visibles, zakat, alertes, imprimante avec
      test, sauvegarde / restauration, licence
- [x] Règle « vente sous achat » (Interdire / Avertir / Autoriser) à la modification du prix en caisse
- [x] Seuil maximum utilisé par les besoins (suggestion = maximum − stock) ; marge % arrondie au multiple de 5 DA
      supérieur ; 2ᵉ stock « nombre » global (Paramètres › Système)
- [x] Sauvegarde automatique au démarrage (dossier, fréquence, mot de passe, 30 fichiers conservés) ; aperçu du
      ticket 58 / 80 mm latin / arabe (caisse et Paramètres)
- [x] Colonnes d'audit `cree_le / cree_par / modifie_le / modifie_par` sur 17 tables (migration v20, triggers)
- [x] Sauvegarde / restauration ; exports Excel / PDF avec aperçu

## Recette (lot 9)
- [x] Parcours FR/AR/EN, clair/sombre, Basic/Avancé, Admin/Caissier/Magasinier (`test/recette/parcours_test.dart`)
- [x] Build Windows (configuration MSIX `msix_config`, script Inno Setup, procédure `docs/BUILD_WINDOWS.md`) — build
      non exécuté ici (poste Linux sans toolchain Windows)

## Pointage intégral du §15 (phase D, 2026-10-15)

Recopie de la checklist de la spec 06. `[x]` = fait et testé ; `[ ]` = manquant ou partiel (écart en note).

### Socle
- [ ] Windows desktop, offline-first, SQLite chiffré (clé dérivée machine), `.mid` sauvegardé avec la base —
      fait, sauf : règle de dérivation de la clé provisoire ; la sauvegarde est re-chiffrée par mot de passe
      (restaurable sur une autre machine) au lieu d'embarquer le `.mid`
- [x] Schéma des 45 tables (§ 7) ou équivalent, migrations versionnées (v1 → v20), seed des éléments système
- [x] Colonnes d'audit + annulation douce avec motif sur les opérations (migration v20 : créé / modifié le / par
      sur 17 tables, alimentés par triggers depuis l'utilisateur connecté)
- [x] Fiches (produit, pack, client, fournisseur, magasin, caisse, utilisateur, rôle) : supprimées si elles n'ont
      aucun historique, archivées sinon (migration v43 : `archive_le` / `archive_par`, `actif = 0`) ; l'archive garde
      la ligne (documents, rapports, soldes et journal du stock intacts), masquée des listes et des sélecteurs,
      restaurable dans la limite du palier
- [x] Historique de toutes les actions, exports et sauvegardes / restaurations compris (détail avant / après non
      détaillé)
- [x] Codification lisible par préfixes (§ 8.10)
- [x] FR / AR (RTL) / EN, valeurs de listes stockées en français
- [x] Activation par clé machine, paliers Basic / Avancé, mode démo (règle de clé ⚠️ provisoire)
- [x] Login + « Rester connecté », mot de passe haché, Mon compte
- [x] Séquence post-login : configuration initiale (1ʳᵉ fois) → alertes → menu modules → ouverture de caisse
- [x] Sidebar par catégories filtrée par permissions et licence, favoris (7), cloche alertes, témoin Internet
- [x] Rôles : 16 accès modules + 7 permissions d'action, admin unique non assignable

### Stock
- [x] Stock calculé uniquement depuis le journal des mouvements (règles de sens § 8.1)
- [x] Garde de stock (jamais négatif) sur création / modification / annulation
- [x] 2ᵉ stock « nombre » (global + par produit), obligatoire quand actif (entrées, achats, sorties, transferts ;
      en caisse, pièces déduites de la vente à l'unité ⚠️ provisoire)
- [x] Petit / grand colis (pièces × prix)
- [x] Multi-magasin : magasins ordonnés par utilisateur, répartition (§ 8.3), consultation limitée, distribution,
      transfert
- [x] Produits service sans stock, dates d'expiration, codes-barres multiples uniques, code-barres auto

### Ventes
- [x] Caisse multi-paniers persistants, réservation de stock entre paniers
- [x] Scan code-barres (ajout direct, enchaînement, création si introuvable)
- [x] Tous les raccourcis clavier (§ 9.1)
- [x] Remises Par Produit / Par Montant conditionnelle datées, packs
- [x] Modification de prix avec permission + règle vente sous achat
- [x] Encaisser ticket / facture / enregistrer, paiement partiel (crédit), 5 modes dont Points, modes visibles
      paramétrables
- [x] Bonus fidélité (accrual, reprise à l'annulation)
- [x] Ticket scellé + journal fiscal ; contenu verrouillé ; annulation avec motif, interdite en période clôturée
      de la caisse de la vente
- [x] Liste des paniers avec versé/reste dynamiques, détail, réimpression
- [x] Retours client/fournisseur depuis le document d'origine, plafond de quantité, versement et mouvements liés
- [x] Retour client par ligne de vente, daté du jour (possible après la Z), unités figées à la vente, pièces et
      points de fidélité repris au prorata ; CA et marges nets des retours, casse en perte
- [x] Prix de vente saisi HT, TTC = HT + TVA du produit à la caisse (régime IFU : TTC = HT) ; admin : transfert
      proposé depuis un autre magasin quand le magasin de la caisse manque de stock

### Achats
- [x] Smart Scan multi-produits → magasin principal, mise à jour des prix, paiement partiel
- [x] Entrée rapide 1 produit payée intégralement (aussi depuis la caisse, touche `E`)
- [x] Smart Scan IA 3 étapes avec quota serveur, matching, création de produits (API serveur provisoire)
- [x] Sorties exceptionnelles (Expiration / Don / Autre)
- [x] Listes de besoin, ruptures, expirés

### Tiers et argent
- [x] Clients / fournisseurs avec stats calculées (crédit / dette), situations, versements et conventions de sens
      (§ 8.5) ; solde unique (vue `solde_tiers`) partout : liste, caisse, relevé, alertes, tableau de bord, zakat
- [x] Versements liés à un retour verrouillés
- [x] Caisses (Physique / Compte), sessions (1 ouverte max par caisse), grand-livre (§ 8.6), mouvements manuels
- [x] Session obligatoire pour vente / achat / retour / versement
- [x] Clôture de session (théorique / réel / écart), clôture Z scellée + PDF, export contrôle fiscal avec
      `journal_fiscal` distinct (ligne `CLOTURE_CAISSE`)
- [x] Transferts d'argent entre caisses (permission dédiée)

### Pilotage
- [x] Dashboard : 6 KPI, 5 graphiques, ruptures, sélecteur de période
- [x] 10 rapports de situation
- [x] Zakat (formule § 9.15)
- [x] Alertes (§ 5.3)

### Paramètres, sorties
- [x] Paramètres Système / Boutique / Avancé (§ 9.16) — écarts listés dans `docs/PLAN.md` (Paramètres)
- [ ] Impression thermique 4 types + facture A4 FR/AR + aperçus — aperçu du ticket et de tous les documents A4
      (facture, avoir, devis, proforma, commande, BL), arabe lié dans les PDF ; reste : Bluetooth via la file
      d'impression Windows
- [x] Exports Excel de tous les modules + PDF dérivé de l'Excel
- [x] Sauvegarde zip, auto-backup (au démarrage, quotidienne ou à chaque démarrage), restauration
- [x] Catalogue partagé + cascade de recherche code-barres
