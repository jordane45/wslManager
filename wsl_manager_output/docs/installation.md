# Installation — WSL Manager

## Prérequis système

- Windows 11 x64 (22H2 minimum recommandé)
- WSL2 activé : `wsl --install` depuis une session PowerShell administrateur
- PowerShell 7+ recommandé

---

## Prérequis de développement

### 1. Flutter SDK

```powershell
# Télécharger Flutter stable depuis https://docs.flutter.dev/get-started/install/windows
# Extraire dans C:\flutter
# Ajouter C:\flutter\bin au PATH système
flutter doctor
```

Résoudre tous les avertissements signalés par `flutter doctor`, en particulier :
- **Visual Studio** : installer avec workload "Desktop development with C++"
- **Android toolchain** : non requis pour ce projet (ignorer l'avertissement)

### 2. Activer le support Windows Desktop

```powershell
flutter config --enable-windows-desktop
flutter channel stable
flutter upgrade
```

### 3. Volta (gestion Node/npm pour les scripts utilitaires)

```powershell
# Installer Volta depuis https://volta.sh/
winget install Volta.Volta
volta install node
volta install npm
```

### 4. Visual Studio 2022

Installer depuis https://visualstudio.microsoft.com/ avec les workloads :
- Desktop development with C++
- Windows 10/11 SDK

---

## Installation du projet

```powershell
# Cloner ou décompresser le projet
cd wsl_manager

# Installer les dépendances Dart
flutter pub get

# Générer les icônes
dart run flutter_launcher_icons

# Générer le code Riverpod (providers)
dart run build_runner build --delete-conflicting-outputs
```

---

## Lancer en développement

```powershell
flutter run -d windows
```

> Pour afficher les logs Flutter dans un terminal séparé :
> ```powershell
> flutter run -d windows --verbose 2>&1 | Tee-Object -FilePath flutter_debug.log
> ```

---

## Build EXE portable

```powershell
.\scripts\build_portable.ps1
```

Le fichier `dist\WSLManager_portable.zip` contient l'EXE et toutes les DLLs nécessaires.

---

## Vérification de l'encodage des fichiers

Tous les fichiers texte du projet doivent être en **UTF-8 sans BOM** avec des **fins de lignes LF**.

Vérifier avec PowerShell :
```powershell
# Vérifier l'encodage d'un fichier
$content = Get-Content .\pubspec.yaml -Raw -Encoding Byte
if ($content[0] -eq 0xEF -and $content[1] -eq 0xBB -and $content[2] -eq 0xBF) {
    Write-Warning "BOM détecté dans pubspec.yaml"
}
```

Si un fichier contient un BOM ou des fins de lignes CRLF incorrectes :
1. Ouvrir le fichier dans VSCode
2. Cliquer sur l'indicateur d'encodage en bas à droite
3. Sélectionner "Enregistrer avec l'encodage..." → UTF-8
4. Modifier les fins de lignes via le sélecteur en bas à droite → LF

---

## Configuration VSCode recommandée

Créer `.vscode/settings.json` :
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "Dart-Code.dart-code",
  "files.eol": "\n",
  "files.encoding": "utf8",
  "[dart]": {
    "editor.rulers": [120],
    "editor.tabSize": 2
  }
}
```

Extensions VSCode recommandées :
- `Dart-Code.dart-code`
- `Dart-Code.flutter`
- `usernamehw.errorlens`
- `streetsidesoftware.code-spell-checker-french`

---

## Dépannage

### `flutter doctor` signale Visual Studio manquant
Installer Visual Studio 2022 Community (gratuit) avec le workload C++ Desktop.

### La fenêtre s'ouvre mais WSL n'est pas détecté
Vérifier que WSL est installé : `wsl --version` dans PowerShell.
Si WSL n'est pas installé, l'application affiche un message d'erreur explicite.

### L'effet Mica n'apparaît pas
Vérifier que Windows 11 est à jour. Sur Windows 10, l'effet se dégrade gracieusement.

### Erreur d'encodage UTF-16 lors du parsing WSL
La sortie de `wsl --list --verbose` est en UTF-16 LE sur certaines configurations Windows.
Voir `lib/utils/wsl_parser.dart` pour la gestion de l'encodage.
