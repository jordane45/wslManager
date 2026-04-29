# WSL Manager

Application Windows 11 portable pour gérer visuellement les instances WSL.

**Auteur** : Jordane REYNET
**Version** : 1.0.0
**Stack** : Flutter Windows (Dart >= 3.4)

---

## Fonctionnalités V1

- Lister les instances WSL avec état, version et supervision CPU/RAM
- Créer une instance via wizard (distro officielle, fichier .tar, URL, template)
- Démarrer / Arrêter une instance
- Supprimer une instance
- Dupliquer et renommer une instance
- Ouvrir VSCode, Windows Terminal ou l'Explorateur dans une instance
- Créer et utiliser des templates d'instances
- Créer et restaurer des snapshots d'instances
- Éditer le fichier wsl.conf de chaque instance
- Icône systray avec accès rapide
- EXE portable (aucune installation requise)

---

## Prérequis de développement

- Windows 11 x64
- [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) >= 3.22 (stable channel)
- [Visual Studio 2022](https://visualstudio.microsoft.com/) avec workload **Desktop development with C++**
- [Volta](https://volta.sh/) pour la gestion Node/npm (scripts utilitaires)
- WSL2 installé et au moins une distro présente pour les tests

---

## Installation de l'environnement

Voir `docs/installation.md` pour les instructions détaillées.

```powershell
# Vérifier Flutter
flutter doctor

# Installer les dépendances Dart
flutter pub get

# Lancer en développement
flutter run -d windows

# Build release portable
.\scripts\build_portable.ps1
```

---

## Structure du projet

Voir `TODO.md` pour l'arborescence complète et le guide de développement.

---

## Fichiers de données locaux

L'application stocke ses données dans :
```
%LOCALAPPDATA%\WSLManager\
├── templates.json
├── snapshots.json
├── config.json
├── templates\    ← fichiers .tar des templates
└── snapshots\    ← fichiers .tar des snapshots
```

---

## Encodage des fichiers

- Encodage : **UTF-8 sans BOM**
- Fins de lignes : **LF (Unix)**
- Voir `docs/installation.md` pour vérifier l'encodage des fichiers `.env` si applicable

---

## Licence

Usage privé — Jordane REYNET
