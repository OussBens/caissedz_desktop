# Checklist de conformité (§15 de la spécification 06)

À recopier intégralement depuis `docs/spec/06_specification_reconstruction.md` §15 et à cocher au fil des lots.

> ⚠️ 2026-10-14 : la spécification n'est pas dans le dépôt ; la checklist §15 ne peut pas encore être recopiée.
> En attendant, les cases ci-dessous reprennent les exigences explicites de la commande initiale, regroupées par lot.
> Elles seront remplacées par le texte exact du §15 dès réception.

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
- [x] go_router ShellRoute + AppShell (sidebar Général/Stock/Tiers/Gestion, favoris max 7, menu modules Ctrl+M,
      alertes, témoin Internet)
- [x] Relations par code, aucune valeur traduite en base (règle appliquée dès le socle)

## Démarrage (lot 1)
- [x] Activation par clé SHA-256 (64 caractères) — règle de résolution de la clé provisoire (hypothèse n° 1 du plan)
- [x] Mode démo demo/demo
- [x] Connexion, mots de passe hachés (PBKDF2-HMAC-SHA256), déconnexion
- [x] Configuration initiale en 4 étapes (dont marge) — contenu des étapes provisoire
- [x] Mon compte : changement d'identifiant et de mot de passe
- [x] Licences Basic / Avancé (LicenceGate, modules réservés) — répartition des modules provisoire
- [x] Rôles et 7 permissions d'action (voirPrixAchat, colonnes masquées, écran « Accès refusé ») — 6 permissions provisoires
- [ ] Fidélité visuelle des écrans au DS v2.2 (FR/AR, clair/sombre) — impossible à vérifier, DS absent

## Produits (lot 2)
- [x] Catégories / sous-catégories (système protégé), produits en mode détaillé avec marge, colis, packs, remises
- [x] Codes-barres EAN-13, CAISSEDZ+date, QR — format interne provisoire
- [x] Mode IA avec cascade CaisseDZ → Mantouj → Open Food Facts → Open Beauty Facts — API CaisseDZ/Mantouj provisoires
- [x] 2ᵉ stock « nombre » (pièces par unité) — interprétation provisoire
- [x] Import Excel, étiquettes (PDF A4 / rouleau), synchro catalogue (protocole provisoire)

## Stock (lot 3)
- [x] Stock = journal des mouvements (SUM), garde de stock toujours active, 2ᵉ stock « nombre »
- [x] Magasins, principal = premier magasin de l'utilisateur
- [x] Transferts TRM (2 mouvements par ligne, une transaction), besoins En attente / Commande / Disponible,
      sorties avec motifs §13 + onglet Ventes

## Caisse (lot 4)
- [x] Sessions obligatoires, 5 ventes en parallèle, réservation de stock entre paniers
- [x] Scan (EAN-13, interne, QR), colis, vente à la pièce (« nombre »), remises ligne / globale
- [x] Paiements Espèces / Carte / Chèque / Virement / Points, versé/reste, points gagnés
- [x] 16 raccourcis + aide, calculatrice
- [x] Ticket scellé (SHA-256 chaîné), impression 58/80 mm FR/AR (ESC/POS et PDF) et facture A4 — Bluetooth via
      file d'impression Windows (écart)

## Ventes, retours, tiers (lot 5)
- [x] Ventes : liste, ticket, annulation (permission), vérification du scellement
- [x] Retours : stock restitué, avoir, remboursement
- [x] Clients / fournisseurs : fiches, soldes
- [x] Versements imputés aux documents ouverts, plus ancien d'abord
- [x] Versement lié à un retour verrouillé

## Achats (lot 6)
- [x] Entrées / achats : transaction unique, stock par mouvements, prix d'achat, dette fournisseur
- [x] Smart Scan IA : quota serveur, quota atteint, demande d'offre

## Gestion caisse et fiscal (lot 7)
- [x] Caisses Physique / Compte, caisse sans magasin ; journal des mouvements ; transferts TRF = 2 mouvements
- [x] Clôtures Z chaînées immuables ; annulation refusée en période clôturée
- [x] Export fiscal : archive + JSON vérifiable

## Rapports et paramètres (lot 8)
- [x] Tableau de bord 6 KPI / 5 graphiques ; Situation 10 rapports ; Zakat
- [x] Historique (journal d'audit) ; Paramètres complets (boutique, vente, impression, serveurs)
- [x] Sauvegarde / restauration ; exports Excel / PDF avec aperçu

## Recette (lot 9)
- [x] Parcours FR/AR/EN, clair/sombre, Basic/Avancé, Admin/Caissier/Magasinier (`test/recette/parcours_test.dart`)
- [x] Build Windows (configuration MSIX `msix_config`, script Inno Setup, procédure `docs/BUILD_WINDOWS.md`) — build
      non exécuté ici (poste Linux sans toolchain Windows)
