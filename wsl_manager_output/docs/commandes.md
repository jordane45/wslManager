# Commandes utiles — WSL Manager

## Flutter

```powershell
# Lancer en développement
flutter run -d windows

# Build release
flutter build windows --release

# Mettre à jour les dépendances
flutter pub get

# Mettre à jour les packages
flutter pub upgrade

# Générer le code Riverpod (après modification des providers)
dart run build_runner build --delete-conflicting-outputs

# Générer le code Riverpod en mode watch
dart run build_runner watch --delete-conflicting-outputs

# Analyser le code
flutter analyze

# Formater le code
dart format lib/

# Lancer les tests
flutter test

# Nettoyer le build
flutter clean
```

---

## Build portable

```powershell
# Build et packaging en un seul script
.\scripts\build_portable.ps1

# Build seul
flutter build windows --release

# Chemin de sortie
# build\windows\x64\runner\Release\wsl_manager.exe
```

---

## WSL (référence développement)

```powershell
# Lister les instances
wsl --list --verbose

# Démarrer une instance
wsl -d Ubuntu-22.04

# Arrêter une instance
wsl --terminate Ubuntu-22.04

# Arrêter toutes les instances
wsl --shutdown

# Supprimer une instance
wsl --unregister Ubuntu-22.04

# Exporter une instance
wsl --export Ubuntu-22.04 C:\backup\ubuntu.tar

# Importer une instance
wsl --import Ubuntu-dev C:\WSL\Ubuntu-dev C:\backup\ubuntu.tar --version 2

# Définir la distro par défaut
wsl --set-default Ubuntu-22.04

# Convertir en WSL2
wsl --set-version Ubuntu-22.04 2

# Mettre à jour le kernel WSL
wsl --update

# Vérifier la version WSL
wsl --version
```

---

## Débogage Flutter Windows

```powershell
# Voir les logs en temps réel
flutter run -d windows 2>&1

# Profiling
flutter run -d windows --profile

# Inspecter le widget tree (DevTools)
flutter run -d windows --devtools-port=9100
# Ouvrir http://localhost:9100 dans Chrome
```

---

## Gestion des dépendances Dart

```powershell
# Ajouter un package
flutter pub add <package_name>

# Supprimer un package
flutter pub remove <package_name>

# Vérifier les packages obsolètes
flutter pub outdated

# Vérifier les vulnérabilités
dart pub audit
```

---

## Encodage (vérification)

```powershell
# Vérifier l'encodage d'un fichier .dart
Get-Content .\lib\main.dart -Raw -Encoding Byte | Select-Object -First 3

# Convertir un fichier en UTF-8 sans BOM
$content = Get-Content .\fichier.dart -Raw -Encoding UTF8
[System.IO.File]::WriteAllText(".\fichier.dart", $content, [System.Text.UTF8Encoding]::new($false))
```
