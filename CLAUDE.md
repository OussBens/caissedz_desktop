# CaisseDZ Desktop — guide pour Claude Code

Logiciel de point de vente (caisse) + gestion de stock et commerciale pour Windows, développé from scratch en Flutter.

## ⚠️ Avant chaque lot : relire les sources de vérité

1. `docs/spec/06_specification_reconstruction.md` — le COMPORTEMENT attendu : 45 tables, règles métier (§8),
   workflows des 17 modules (§9), impression (§11), exports et conformité fiscale (§12), listes de valeurs (§13),
   checklist de conformité (§15), dette technique à NE PAS reproduire (§16).
2. `docs/design/CaisseDZ-DS-v2.2/` — le design system v2.2 (référence visuelle React/HTML, à TRADUIRE en Flutter,
   jamais embarqué) :
   - `CaisseDZ-DS-v2.2.html` : référence visuelle de chaque écran, dialog, état, FR/AR, clair/sombre.
   - `bundle-v2.2/ds-bundle.v2.2.js` : tokens, tailles, libellés exacts, comportements des composants et des 17 écrans.
   - `nouveaux-composants/*.jsx` : composants et écrans ajoutés en v2.2.
   - `donnees/ref.js` : référentiel unique des listes de valeurs (valeur stockée FR + libellés FR/AR/EN) et codification §8.10.
   - `LISEZ-MOI.md` : décisions v2.2 (D2, H5, L2, T3, O4, M4, M5, K7, T12, W2, W3…).

**Conflit** : le design v2.2 l'emporte pour l'apparence et les décisions de `LISEZ-MOI.md` ;
la spécification 06 l'emporte pour tout le reste (données, règles, calculs).

> État au 2026-10-14 (lots 0 et 1) : ces deux sources ne sont PAS encore présentes dans le dépôt (voir `docs/spec/README.md`
> et `docs/design/README.md`). Tout ce qui en dépend (tokens, 45 tables, libellés exacts, §15) est marqué
> « PROVISOIRE » dans le code et dans `docs/PLAN.md`, et doit être réaligné dès qu'elles sont ajoutées.

## Hypothèses prises faute de sources (à réaligner en priorité)

Listées dans `docs/PLAN.md` (lot 1, « Hypothèses à confirmer ») : règle de la clé d'activation, 6 permissions,
contenu des 4 étapes de configuration, répartition Basic/Avancé des modules, règles du mode démo, codes `USR`,
schéma minimal v2. Chaque hypothèse est marquée `⚠️ PROVISOIRE` dans le code.

## Stack imposée

- Flutter stable (3.47.x, Dart 3.13) pour Windows desktop. Fenêtre minimale 1000×700, barre de titre
  personnalisée via `window_manager`.
- Offline-first : SQLite chiffré SQLCipher (`sqflite_common_ffi` + `sqlite3` avec `sqlcipher_flutter_libs`),
  clé dérivée de la machine (§4.2), `PRAGMA foreign_keys = ON`, migrations versionnées (`PRAGMA user_version`).
- Navigation `go_router` (ShellRoute). État : `flutter_riverpod`. Modèles immuables (`freezed`).
- Tableaux : UN seul composant `DsDataTable` maison (tri, sélection multiple, colonnes masquables, pagination,
  menu contextuel, totaux). Pas de Syncfusion.
- Graphiques : `fl_chart` habillé aux tokens du DS.
- Impression : `pdf` + `printing`, ESC/POS (USB via spouleur Windows, réseau IP:port, bluetooth), CODE128 et QR.
- Exports : `excel`, `archive`. i18n : `intl` + ARB FR/AR/EN, arabe en RTL (police Cairo), latin Plus Jakarta Sans,
  icônes Lucide (`lucide_icons_flutter`).

## Architecture

```
lib/
  core/design_system/   tokens (ThemeExtension clair + sombre), typographie, espacements, rayons, ombres, motion ;
                        widgets du DS (DsButton avec garde anti double-clic intégrée, DsDataTable, DsDialog /
                        ConfirmDialog / ResultDialog / PickerDialog, StatCard, charts, CartLine, Numpad,
                        Calculator, PaymentPanel, PermissionGrid, LicenseGate…)
  core/db/              ouverture chiffrée, schéma, migrations, seed des éléments système
                        (MAG0000, CIS0000, CLN0000, FOR0000, CATE0000, SC0000, admin)
  core/i18n/            délégués de localisation, ARB, RTL
  core/print/           ESC/POS, PDF ticket/facture, codes-barres
  core/export/          Excel, archive, JSON fiscal
  core/licence/         activation, Basic/Avancé, mode démo
  domain/               modèles immuables, référentiel des listes (valeur stockée FR), CodeGenerator §8.10
  data/                 repositories (SQL uniquement ici)
  application/          UN service par cas d'usage ; chaque écriture multi-tables dans UNE transaction
                        (VenteService.encaisser, AchatService.enregistrer, RetourService.creer,
                        VersementService.imputer…)
  features/<module>/    écrans + dialogs + controllers, SANS logique SQL
```

## Règles non négociables

- Les widgets n'utilisent QUE les tokens sémantiques (`context.ds.colors.*`, `context.ds.spacing.*`…),
  jamais `Colors.*` ni des valeurs numériques en dur.
- Relations toujours par **code** (jamais par nom). Aucune valeur traduite en base : la valeur stockée est la
  valeur FR du référentiel, la traduction se fait à l'affichage.
- Toute écriture multi-tables passe par un service `application/` dans UNE transaction.
- Stock = journal des mouvements (jamais un compteur modifié à la main).
- Tout le §16 (dette technique) est évité.
- Tout bouton d'action passe par `DsButton` (garde anti double-clic intégrée).
- Pas de `print()` : utiliser le logger.
- Tests : unitaires des services (calculs, transactions, versé/reste, stock, répartition multi-magasin,
  scellement SHA-256 chaîné) + widget des écrans clés. `flutter analyze` et `flutter test` doivent être verts
  avant chaque commit.

## Commandes

```bash
flutter pub get                      # dépendances
dart run build_runner build -d       # génère freezed / riverpod / json (après modif des modèles)
flutter gen-l10n                     # génère les classes de localisation depuis lib/core/i18n/arb/*.arb
flutter analyze                      # doit être vert
flutter test                         # doit être vert
flutter run -d windows               # lancer l'application (Windows)
flutter build windows --release      # build Windows (lot 9 : msix / installeur)
```

Sur une machine Linux/CI sans toolchain Windows, `analyze` et `test` fonctionnent ; `run`/`build windows`
nécessitent Windows + Visual Studio (Desktop development with C++).

## Conventions de nommage

- Fichiers : `snake_case.dart`. Classes : `PascalCase`. Widgets du DS préfixés `Ds` (`DsButton`, `DsDataTable`).
- Services : `<Entité>Service` avec une méthode par cas d'usage, nom métier en français
  (`encaisser`, `enregistrer`, `creer`, `imputer`, `cloturer`).
- Repositories : `<Entité>Repository` dans `data/`, retournent des modèles `domain/`.
- Providers Riverpod : suffixe `Provider` ; controllers d'écran : `<Ecran>Controller` (Notifier).
- Tables / colonnes SQL : `snake_case`, noms français cohérents avec la spec 06.
- Codes : préfixes du §8.10 (`MAG`, `CIS`, `CLN`, `FOR`, `CATE`, `SC`, `TRM`, `TRF`…) via `CodeGenerator`.
- Clés ARB : `camelCase`, préfixées par module (`shellNavGeneral`, `posPayButton`…).
- Commits : un commit par étape logique, message en français, à l'impératif (« Ajoute… », « Corrige… »).
- Branche de travail : `claude/fervent-curie-fg6apc`.

## Façon de travailler par lot

1. Relire la spec 06 et le DS v2.2 pour le périmètre du lot (`docs/PLAN.md`).
2. Code + tests ; `flutter analyze` et `flutter test` verts.
3. Mettre à jour `docs/PLAN.md` (état du lot) et `docs/CONFORMITE.md` (cases §15).
4. Un commit par étape logique ; compte rendu à la fin du lot.
5. Ne pas demander de validation pour les détails ; poser une question seulement si la spec et le DS se
   contredisent sans décision écrite.
