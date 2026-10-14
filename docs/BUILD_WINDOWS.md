# Build Windows (lot 9)

> Le build natif exige Windows 10/11 x64, Visual Studio 2022 avec la charge « Desktop development with C++ » et
> Flutter stable 3.47.x. Sur Linux/CI, seuls `flutter analyze` et `flutter test` s'exécutent (c'est le cas de ce
> dépôt : le build ci-dessous n'a pas pu être lancé ici).

## 1. Préparer

```powershell
flutter doctor            # Windows toolchain + Visual Studio verts
flutter pub get
flutter gen-l10n
flutter analyze           # doit être vert
flutter test              # doit être vert
```

## 2. Build release

```powershell
flutter build windows --release
```

Le dossier `build\windows\x64\runner\Release\` contient `caissedz_desktop.exe`, `flutter_windows.dll`, les DLL des
plugins, `data\` (polices Plus Jakarta Sans / Cairo, ARB) et la bibliothèque SQLCipher compilée par le hook
`package:sqlite3` (`hooks.user_defines.sqlite3.source: sqlcipher` dans `pubspec.yaml`). Vérifier qu'aucune
`sqlite3.dll` en clair n'est embarquée : la base `caissedz.db` doit rester chiffrée (`AppDatabase.fichierEstChiffre`).

## 3. Paquet MSIX

Configuration dans `pubspec.yaml` (`msix_config`). Pour un paquet de test auto-signé :

```powershell
dart run msix:create --install-certificate true
```

Pour la distribution : signer avec un certificat de code (`certificate_path`, `certificate_password` ou variable
d'environnement) et publier `build\windows\x64\runner\Release\CaisseDZ-Desktop.msix`.

## 4. Alternative : installeur Inno Setup

`installer\caissedz.iss` (Inno Setup 6) : compile `build\windows\x64\runner\Release\*` en
`installer\sortie\CaisseDZ-Desktop-<version>-setup.exe` (raccourcis Bureau / menu Démarrer, désinstallation).

## 5. Recette manuelle sur poste Windows

| Point | Attendu |
|---|---|
| Fenêtre | minimum 1000×700, barre de titre personnalisée (réduire / agrandir / fermer), redimensionnement |
| Base | `%APPDATA%\caissedz_desktop\data\caissedz.db` chiffré ; clé dérivée de la machine (§4.2) |
| Activation | clé liée à l'identifiant machine, Basic / Avancé, mode démo |
| Langues | FR / AR (RTL, Cairo) / EN ; thème clair / sombre persistés |
| Impression | ticket 58/80 mm : Normale (dialogue), USB (spouleur, nom de file), Réseau (IP:port), Bluetooth (file Windows) |
| Exports | Excel, PDF (aperçu), export fiscal ZIP vérifiable, sauvegarde `.cdz` + restauration au redémarrage |
| Lecteur code-barres | saisie clavier (EAN-13, interne CDZ, QR `CDZ:PRD:`) dans l'écran Caisse |

Les parcours automatisés (tous les modules × FR/AR/EN, clair/sombre, Basic/Avancé, Admin/Caissier/Magasinier)
sont dans `test/recette/parcours_test.dart`.
