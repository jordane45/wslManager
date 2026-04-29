# WSL Manager — TODO
# Guide de développement VSCode — Flutter Windows
# Auteur : Jordane REYNET — Version 1.0.0

---

## Contexte du projet

WSL Manager est une application Windows 11 **portable** (EXE sans installation) développée avec **Flutter Windows**.
Elle permet de gérer visuellement les instances WSL2 présentes sur le poste : création, duplication, suppression,
supervision, templates, snapshots, intégration VSCode et Explorateur Windows.

---

## Stack technique

| Composant         | Technologie                          |
|-------------------|--------------------------------------|
| UI Framework      | Flutter (stable channel, >= 3.22)    |
| Langage           | Dart >= 3.4                          |
| Cible             | Windows 11 x64 uniquement            |
| Distribution      | EXE portable (flutter build windows) |
| Stockage local    | Fichiers JSON (AppData\Local\WSLManager) |
| Appels système    | dart:io Process + package win32       |
| Élévation UAC     | ShellExecuteEx runas (win32)         |
| State management  | Riverpod (^2.5.0)                    |
| Routing           | go_router (^14.0.0)                  |

---

## Packages pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Système & processus
  process_run: ^0.13.4
  win32: ^5.5.0
  path_provider: ^2.1.3
  path: ^1.9.0

  # UI / Fenêtre
  window_manager: ^0.3.9
  flutter_acrylic: ^1.1.1
  system_tray: ^2.0.3

  # State management & routing
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.0

  # Réseau
  http: ^1.2.1
  dio: ^5.4.3

  # Fichiers & formats
  file_picker: ^8.1.2
  archive: ^3.6.1
  shared_preferences: ^2.2.3

  # UI utilitaires
  percent_indicator: ^4.2.3
  flutter_animate: ^4.5.0
  timeago: ^3.6.1
  url_launcher: ^6.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  flutter_launcher_icons: ^0.13.1
```

---

## Structure du projet

```
wsl_manager/
├── lib/
│   ├── main.dart                        # Entrypoint, init window_manager, flutter_acrylic
│   ├── app.dart                         # MaterialApp.router, thème, go_router
│   ├── models/
│   │   ├── wsl_instance.dart            # WslInstance, WslInstanceState, WslVersion
│   │   ├── template.dart                # WslTemplate
│   │   ├── snapshot.dart                # WslSnapshot
│   │   └── app_config.dart              # AppConfig (paramètres utilisateur)
│   ├── services/
│   │   ├── wsl_service.dart             # Exécution commandes WSL, parsing sorties
│   │   ├── monitoring_service.dart      # Polling CPU/RAM via /proc
│   │   ├── template_service.dart        # CRUD templates + JSON
│   │   ├── snapshot_service.dart        # CRUD snapshots + JSON
│   │   ├── download_service.dart        # Téléchargement .tar.gz via URL
│   │   ├── uac_service.dart             # Détection admin + relance UAC
│   │   └── storage_service.dart         # Lecture/écriture JSON locaux
│   ├── providers/
│   │   ├── instances_provider.dart      # AsyncNotifierProvider pour la liste WSL
│   │   ├── templates_provider.dart
│   │   ├── snapshots_provider.dart
│   │   ├── monitoring_provider.dart     # StreamProvider pour CPU/RAM
│   │   └── config_provider.dart
│   ├── screens/
│   │   ├── dashboard/
│   │   │   ├── dashboard_screen.dart
│   │   │   └── widgets/
│   │   │       ├── instance_card.dart
│   │   │       ├── instance_list.dart
│   │   │       └── global_stats_bar.dart
│   │   ├── instance_detail/
│   │   │   ├── instance_detail_screen.dart
│   │   │   └── widgets/
│   │   │       ├── info_panel.dart
│   │   │       ├── actions_panel.dart
│   │   │       ├── monitoring_panel.dart
│   │   │       ├── wsl_conf_editor.dart
│   │   │       └── snapshots_tab.dart
│   │   ├── wizard/
│   │   │   ├── create_wizard_screen.dart
│   │   │   └── steps/
│   │   │       ├── step_source.dart
│   │   │       ├── step_name.dart
│   │   │       ├── step_user.dart
│   │   │       ├── step_password.dart
│   │   │       ├── step_path.dart
│   │   │       └── step_summary.dart
│   │   ├── templates/
│   │   │   ├── templates_screen.dart
│   │   │   └── widgets/
│   │   │       └── template_card.dart
│   │   ├── snapshots/
│   │   │   └── snapshots_screen.dart
│   │   └── settings/
│   │       └── settings_screen.dart
│   ├── widgets/
│   │   ├── cpu_gauge.dart               # Jauge CPU (percent_indicator)
│   │   ├── ram_gauge.dart               # Jauge RAM
│   │   ├── status_badge.dart            # Badge Running/Stopped/Installing
│   │   ├── action_button.dart           # Bouton d'action avec icône
│   │   ├── confirm_dialog.dart          # Dialogue de confirmation générique
│   │   ├── progress_dialog.dart         # Dialogue de progression (export/import)
│   │   └── uac_banner.dart              # Bannière "élévation requise"
│   └── utils/
│       ├── constants.dart               # Chemins JSON, distros officielles, etc.
│       ├── wsl_parser.dart              # Parsing sorties WSL (UTF-16 → UTF-8)
│       └── validators.dart              # Validation nom, user, password, URL
├── windows/
│   └── runner/
│       └── resources/
│           └── app.ico                  # Icône application
├── assets/
│   ├── icons/
│   │   └── distros/                     # Logos PNG : ubuntu.png, debian.png, etc.
│   └── data/
│       └── official_distros.json        # Liste statique des distros officielles
├── data/                                # Créé à l'exécution dans AppData\Local\WSLManager
│   ├── templates.json
│   ├── snapshots.json
│   └── config.json
├── scripts/
│   └── build_portable.ps1              # Script PowerShell de build portable
├── docs/
│   ├── installation.md
│   └── commandes.md
├── pubspec.yaml
└── README.md
```

---

## Schémas JSON locaux

### templates.json
```json
{
  "version": 1,
  "templates": [
    {
      "id": "uuid-v4",
      "name": "mon-template",
      "description": "Description libre",
      "source_distro": "Ubuntu-22.04",
      "tar_path": "C:\\Users\\user\\AppData\\Local\\WSLManager\\templates\\mon-template.tar",
      "size_bytes": 1234567890,
      "created_at": "2025-01-01T12:00:00.000Z"
    }
  ]
}
```

### snapshots.json
```json
{
  "version": 1,
  "snapshots": [
    {
      "id": "uuid-v4",
      "name": "snap-2025-01-01",
      "description": "Avant migration",
      "instance_name": "Ubuntu-dev",
      "tar_path": "C:\\Users\\user\\AppData\\Local\\WSLManager\\snapshots\\snap-2025-01-01.tar",
      "size_bytes": 1234567890,
      "created_at": "2025-01-01T12:00:00.000Z"
    }
  ]
}
```

### config.json
```json
{
  "version": 1,
  "templates_dir": "C:\\Users\\user\\AppData\\Local\\WSLManager\\templates",
  "snapshots_dir": "C:\\Users\\user\\AppData\\Local\\WSLManager\\snapshots",
  "monitoring_interval_seconds": 5,
  "theme": "system",
  "minimize_to_tray": true,
  "launch_at_startup": false
}
```

### assets/data/official_distros.json
```json
{
  "distros": [
    { "name": "Ubuntu 24.04 LTS",  "wsl_name": "Ubuntu-24.04",  "icon": "ubuntu.png",    "download_url": "https://cloud-images.ubuntu.com/wsl/noble/current/ubuntu-noble-wsl-amd64-wsl.rootfs.tar.gz" },
    { "name": "Ubuntu 22.04 LTS",  "wsl_name": "Ubuntu-22.04",  "icon": "ubuntu.png",    "download_url": "https://cloud-images.ubuntu.com/wsl/jammy/current/ubuntu-jammy-wsl-amd64-wsl.rootfs.tar.gz" },
    { "name": "Debian 12",         "wsl_name": "Debian",         "icon": "debian.png",    "download_url": "https://github.com/debuerreotype/docker-debian-artifacts/releases/download/dist-amd64/debian-12-slim.tar.gz" },
    { "name": "Kali Linux",        "wsl_name": "kali-linux",     "icon": "kali.png",      "download_url": "" },
    { "name": "Alpine Linux",      "wsl_name": "Alpine",         "icon": "alpine.png",    "download_url": "" },
    { "name": "openSUSE Leap 15",  "wsl_name": "openSUSE-Leap",  "icon": "opensuse.png",  "download_url": "" },
    { "name": "Oracle Linux 9",    "wsl_name": "OracleLinux_9",  "icon": "oracle.png",    "download_url": "" }
  ]
}
```

> **Note** : Les URLs de téléchargement doivent être vérifiées au moment du développement.
> Prévoir une mise à jour depuis GitHub Actions ou un JSON hébergé pour les futures versions.

---

## Commandes WSL de référence

| Action                         | Commande                                                              | Admin requis |
|--------------------------------|-----------------------------------------------------------------------|:------------:|
| Lister instances               | `wsl --list --verbose`                                                | Non          |
| Démarrer instance              | `wsl -d <name> -- exit`                                               | Non          |
| Arrêter instance               | `wsl --terminate <name>`                                              | Non          |
| Supprimer instance             | `wsl --unregister <name>`                                             | Non          |
| Exporter instance              | `wsl --export <name> <chemin.tar>`                                    | Non          |
| Importer instance              | `wsl --import <name> <dossier> <chemin.tar> [--version 2]`            | Non          |
| Définir distro par défaut      | `wsl --set-default <name>`                                            | Non          |
| Convertir WSL1 → WSL2          | `wsl --set-version <name> 2`                                          | Oui          |
| Convertir WSL2 → WSL1          | `wsl --set-version <name> 1`                                          | Oui          |
| Créer utilisateur              | `wsl -d <name> -u root -- useradd -m -s /bin/bash <user>`             | Non          |
| Définir mot de passe           | `wsl -d <name> -u root -- bash -c "echo '<user>:<pass>' \| chpasswd"` | Non          |
| Définir user par défaut        | `wsl -d <name> -- bash -c "echo '[user]\ndefault=<user>' >> /etc/wsl.conf"` | Non   |
| Lire CPU instance              | `wsl -d <name> -- bash -c "cat /proc/stat"`                           | Non          |
| Lire RAM instance              | `wsl -d <name> -- bash -c "cat /proc/meminfo"`                        | Non          |
| Lire wsl.conf                  | `wsl -d <name> -u root -- cat /etc/wsl.conf`                          | Non          |
| Écrire wsl.conf                | `wsl -d <name> -u root -- bash -c "echo '...' > /etc/wsl.conf"`       | Non          |
| Ouvrir VSCode                  | `code --remote wsl+<name>`                                            | Non          |
| Ouvrir Explorateur             | `explorer.exe \\wsl.localhost\<name>`                                 | Non          |
| Ouvrir Windows Terminal        | `wt wsl -d <name>`                                                    | Non          |
| Reset mot de passe             | `wsl -d <name> -u root -- bash -c "echo '<user>:<newpass>' \| chpasswd"` | Non       |

> **Attention** : La sortie de `wsl --list --verbose` est encodée en **UTF-16 LE** sur Windows.
> Utiliser `systemEncoding` ou decoder manuellement avec `const Utf16Codec().decode(bytes)`.

---

## Parsing wsl --list --verbose

La sortie brute ressemble à :

```
  NAME                   STATE           VERSION
* Ubuntu-22.04           Running         2
  Debian                 Stopped         2
  kali-linux             Stopped         1
```

Règles de parsing à implémenter dans `lib/utils/wsl_parser.dart` :
- Ignorer la ligne d'en-tête
- Détecter `*` en position 0 → `isDefault = true`
- Parser les colonnes par espaces multiples (regex : `\s{2,}`)
- Mapper STATE → `WslInstanceState.running / stopped / installing`
- Mapper VERSION → `WslVersion.wsl1 / wsl2`

---

## Parsing /proc/stat (CPU)

```
cpu  2255 34 2290 22625563 6290 127 456 0 0 0
cpu0 1132 34 1441 11311718 3675 127 340 0 0 0
```

Formule CPU % depuis deux lectures espacées de N ms :
```
delta_idle = idle2 - idle1
delta_total = total2 - total1
cpu_percent = 100.0 * (1.0 - delta_idle / delta_total)
```

## Parsing /proc/meminfo (RAM)

```
MemTotal:       16384000 kB
MemFree:         8192000 kB
MemAvailable:   10240000 kB
Buffers:          512000 kB
Cached:          1024000 kB
```

```
used_kb = MemTotal - MemAvailable
ram_percent = 100.0 * used_kb / MemTotal
```

---

# EPIC 1 — Setup & Infrastructure du projet

## TASK-001 — Initialiser le projet Flutter Windows

**Description** : Créer le projet Flutter et configurer le support Windows.
**Commandes** :
```bash
flutter create wsl_manager --platforms=windows --org=fr.jordanreynet
cd wsl_manager
flutter config --enable-windows-desktop
```
**Résultat attendu** : Le projet compile et s'exécute avec `flutter run -d windows`.

---

## TASK-002 — Configurer pubspec.yaml

**Description** : Ajouter tous les packages listés dans la section Stack technique.
**Fichier** : `pubspec.yaml`
**Actions** :
- Ajouter toutes les dépendances listées ci-dessus
- Déclarer les assets : `assets/icons/distros/` et `assets/data/official_distros.json`
- Configurer `flutter_launcher_icons` avec l'icône `assets/icons/app_icon.png`
**Résultat attendu** : `flutter pub get` sans erreur.

---

## TASK-003 — Configurer window_manager

**Description** : Gérer la fenêtre principale (taille min, centrage, titre, masquage barre native).
**Fichier** : `lib/main.dart`
```dart
await windowManager.ensureInitialized();
WindowOptions windowOptions = const WindowOptions(
  size: Size(1200, 750),
  minimumSize: Size(900, 600),
  center: true,
  title: 'WSL Manager',
  titleBarStyle: TitleBarStyle.hidden, // Pour custom title bar
  windowButtonVisibility: false,
);
await windowManager.waitUntilReadyToShow(windowOptions, () async {
  await windowManager.show();
  await windowManager.focus();
});
```
**Résultat attendu** : Fenêtre centrée, taille correcte, barre de titre personnalisable.

---

## TASK-004 — Appliquer l'effet Mica (Windows 11)

**Description** : Appliquer l'effet Mica ou Acrylic via `flutter_acrylic` pour un look Windows 11.
**Fichier** : `lib/main.dart`
```dart
await Window.initialize();
await Window.setEffect(
  effect: WindowEffect.mica,
  dark: false,
);
```
**Note** : Prévoir un fallback si l'effet n'est pas supporté (Windows 10 éventuel, vieux drivers).
**Résultat attendu** : Fond Mica visible sur Windows 11.

---

## TASK-005 — Créer le StorageService

**Description** : Service de persistance JSON locale dans `AppData\Local\WSLManager\`.
**Fichier** : `lib/services/storage_service.dart`
**Méthodes à implémenter** :
- `Future<Directory> getAppDataDir()` → crée le dossier si inexistant
- `Future<T?> readJson<T>(String filename, T Function(Map<String,dynamic>) fromJson)`
- `Future<void> writeJson(String filename, Map<String,dynamic> data)`
- `Future<String> getTemplatesDir()` → crée si inexistant
- `Future<String> getSnapshotsDir()` → crée si inexistant
**Dossier cible** : `%LOCALAPPDATA%\WSLManager\` via `path_provider` : `getApplicationSupportDirectory()`
**Résultat attendu** : Les fichiers JSON sont lus/écrits sans erreur, les dossiers créés automatiquement.

---

## TASK-006 — Créer les modèles de données

**Description** : Créer les 4 modèles Dart avec `fromJson` / `toJson`.

**Fichier** : `lib/models/wsl_instance.dart`
```dart
enum WslInstanceState { running, stopped, installing }
enum WslVersion { wsl1, wsl2 }

class WslInstance {
  final String name;
  final WslInstanceState state;
  final WslVersion version;
  final bool isDefault;
  // Champs enrichis (récupérés async) :
  double? cpuPercent;
  double? ramPercent;
  int? ramUsedMb;
  int? ramTotalMb;
  String? ipAddress; // ip addr depuis /proc/net/fib_trie
}
```

**Fichier** : `lib/models/template.dart`
```dart
class WslTemplate {
  final String id;        // UUID v4
  final String name;
  final String description;
  final String sourceDistro;
  final String tarPath;
  final int sizeBytes;
  final DateTime createdAt;
}
```

**Fichier** : `lib/models/snapshot.dart`
```dart
class WslSnapshot {
  final String id;        // UUID v4
  final String name;
  final String description;
  final String instanceName;
  final String tarPath;
  final int sizeBytes;
  final DateTime createdAt;
}
```

**Fichier** : `lib/models/app_config.dart`
```dart
class AppConfig {
  final String templatesDir;
  final String snapshotsDir;
  final int monitoringIntervalSeconds;
  final String theme;       // 'light' | 'dark' | 'system'
  final bool minimizeToTray;
  final bool launchAtStartup;
}
```

---

## TASK-007 — Créer les Providers Riverpod

**Description** : Créer les providers pour chaque domaine fonctionnel.
**Fichier** : `lib/providers/instances_provider.dart`
```dart
@riverpod
class InstancesNotifier extends _$InstancesNotifier {
  @override
  Future<List<WslInstance>> build() async => ref.read(wslServiceProvider).listInstances();
  Future<void> refresh() async { state = const AsyncLoading(); state = await AsyncValue.guard(() => ref.read(wslServiceProvider).listInstances()); }
}
```
**À créer de même** : `templates_provider.dart`, `snapshots_provider.dart`, `config_provider.dart`
**Fichier** : `lib/providers/monitoring_provider.dart`
```dart
@riverpod
Stream<Map<String, MonitoringData>> monitoringStream(MonitoringStreamRef ref) {
  final config = ref.watch(configProvider);
  return ref.read(monitoringServiceProvider).stream(
    interval: Duration(seconds: config.monitoringIntervalSeconds),
  );
}
```

---

## TASK-008 — Configurer go_router

**Description** : Déclarer toutes les routes de l'application.
**Fichier** : `lib/app.dart`
**Routes** :
```
/                        → DashboardScreen
/instance/:name          → InstanceDetailScreen
/create                  → CreateWizardScreen
/templates               → TemplatesScreen
/snapshots               → SnapshotsScreen
/settings                → SettingsScreen
```

---

## TASK-009 — Créer le layout principal (scaffold avec sidebar)

**Description** : Navigation principale via une `NavigationRail` ou sidebar personnalisée.
**Fichier** : `lib/screens/dashboard/dashboard_screen.dart`
**Navigation latérale** :
- Tableau de bord (icône : `dashboard`)
- Templates (icône : `layers`)
- Snapshots (icône : `camera`)
- Paramètres (icône : `settings`)
**Résultat attendu** : Navigation fonctionnelle entre les 4 sections principales.

---

# EPIC 2 — Service WSL

## TASK-010 — WslService : lister les instances

**Description** : Exécuter `wsl --list --verbose` et parser la sortie UTF-16.
**Fichier** : `lib/services/wsl_service.dart`
```dart
Future<List<WslInstance>> listInstances() async {
  final result = await Process.run(
    'wsl', ['--list', '--verbose'],
    stdoutEncoding: const SystemEncoding(), // Attention : UTF-16 sur Windows
  );
  return WslParser.parseVerboseList(result.stdout as String);
}
```
**⚠️ Piège encodage** : Si la sortie contient des caractères nuls `\x00`, décoder manuellement :
```dart
final bytes = result.stdout as List<int>;
final decoded = utf8.decode(bytes.where((b) => b != 0).toList());
```
**Cas limites** : WSL non installé, aucune instance, sortie vide, erreur d'accès.
**Résultat attendu** : Liste typée `List<WslInstance>` correctement parsée.

---

## TASK-011 — WslParser : parser la sortie --list --verbose

**Description** : Extraire les informations de chaque ligne de la sortie WSL.
**Fichier** : `lib/utils/wsl_parser.dart`
**Regex recommandée** :
```dart
final lineRegex = RegExp(r'^(\*?)\s+(\S+)\s+(\S+)\s+(\d)$');
```
**Colonnes** : [default_marker, name, state, version]
**Résultat attendu** : Parsing correct pour toutes les variantes de sortie (1 instance, 10 instances, instance en cours d'installation).

---

## TASK-012 — WslService : démarrer une instance

**Description** : Démarrer une instance arrêtée.
**Méthode** : `Future<void> startInstance(String name)`
```dart
await Process.run('wsl', ['-d', name, '--', 'exit']);
```
**Note** : La commande démarre WSL et sort immédiatement. Appeler `listInstances()` après pour vérifier l'état.

---

## TASK-013 — WslService : arrêter une instance

**Méthode** : `Future<void> stopInstance(String name)`
```dart
await Process.run('wsl', ['--terminate', name]);
```

---

## TASK-014 — WslService : supprimer une instance

**Méthode** : `Future<void> deleteInstance(String name)`
**Prérequis** : Instance doit être arrêtée. Appeler `stopInstance()` si nécessaire.
```dart
await Process.run('wsl', ['--unregister', name]);
```
**⚠️ Irréversible** : Ne pas appeler sans confirmation utilisateur explicite.

---

## TASK-015 — WslService : renommer une instance

**Description** : WSL n'a pas de commande `--rename`. Simuler via export + import + unregister.
**Méthode** : `Future<void> renameInstance(String oldName, String newName, String installDir)`
**Étapes** :
1. Arrêter l'instance (`--terminate`)
2. Exporter vers un tar temporaire dans `%TEMP%`
3. Importer sous le nouveau nom dans `installDir`
4. Supprimer l'ancienne instance (`--unregister`)
5. Supprimer le tar temporaire
**Résultat attendu** : L'instance est accessible sous le nouveau nom, l'ancienne a disparu.

---

## TASK-016 — WslService : dupliquer une instance

**Méthode** : `Future<void> duplicateInstance(String sourceName, String newName, String installDir)`
**Étapes** :
1. Arrêter l'instance source
2. Exporter vers un tar temporaire
3. Importer sous le nouveau nom
4. Supprimer le tar temporaire
**Différence avec rename** : Ne pas appeler `--unregister` sur la source.

---

## TASK-017 — WslService : exporter une instance (pour template/snapshot)

**Méthode** : `Future<void> exportInstance(String name, String tarPath, ProgressCallback? onProgress)`
```dart
await Process.run('wsl', ['--export', name, tarPath]);
```
**Note** : `wsl --export` ne fournit pas de progression native. Simuler via polling de la taille du fichier.

---

## TASK-018 — WslService : importer un tar

**Méthode** : `Future<void> importInstance(String name, String installDir, String tarPath)`
```dart
await Process.run('wsl', ['--import', name, installDir, tarPath, '--version', '2']);
```

---

## TASK-019 — WslService : définir la distro par défaut

**Méthode** : `Future<void> setDefaultDistro(String name)`
```dart
await Process.run('wsl', ['--set-default', name]);
```

---

## TASK-020 — WslService : convertir WSL1 ↔ WSL2

**Méthode** : `Future<void> setVersion(String name, int version)`
```dart
await Process.run('wsl', ['--set-version', name, version.toString()]);
```
**⚠️ Lent** : La conversion peut prendre plusieurs minutes. Afficher une progression indéterminée.
**UAC** : Cette commande peut nécessiter une élévation. Appeler `UacService.checkAndElevate()` avant.

---

## TASK-021 — WslService : configurer l'utilisateur post-import

**Description** : Créer l'utilisateur et définir son mot de passe dans l'instance fraîchement importée.
**Méthode** : `Future<void> setupUser(String instanceName, String username, String password)`
**Étapes** :
```dart
// 1. Créer l'utilisateur
await Process.run('wsl', ['-d', instanceName, '-u', 'root', '--', 'useradd', '-m', '-s', '/bin/bash', username]);
// 2. Ajouter au groupe sudo
await Process.run('wsl', ['-d', instanceName, '-u', 'root', '--', 'usermod', '-aG', 'sudo', username]);
// 3. Définir le mot de passe
await Process.run('wsl', ['-d', instanceName, '-u', 'root', '--', 'bash', '-c', 'echo "$username:$password" | chpasswd']);
// 4. Définir comme utilisateur par défaut dans wsl.conf
final wslConf = '[user]\ndefault=$username\n';
await Process.run('wsl', ['-d', instanceName, '-u', 'root', '--', 'bash', '-c', 'echo "$wslConf" > /etc/wsl.conf']);
// 5. Redémarrer l'instance pour appliquer
await Process.run('wsl', ['--terminate', instanceName]);
```
**⚠️ Sécurité** : Ne jamais logger le mot de passe. Effacer la variable String après usage.

---

## TASK-022 — WslService : lire/écrire wsl.conf

**Méthode** : `Future<String> readWslConf(String instanceName)`
**Méthode** : `Future<void> writeWslConf(String instanceName, String content)`

---

## TASK-023 — WslService : reset mot de passe utilisateur

**Méthode** : `Future<void> resetPassword(String instanceName, String username, String newPassword)`
```dart
await Process.run('wsl', ['-d', instanceName, '-u', 'root', '--', 'bash', '-c',
  'echo "$username:$newPassword" | chpasswd']);
```

---

# EPIC 3 — UAC & Élévation

## TASK-030 — UacService : détecter les droits administrateur

**Fichier** : `lib/services/uac_service.dart`
**Méthode** : `Future<bool> isElevated()`
Utiliser le package `win32` :
```dart
import 'package:win32/win32.dart';
// Ouvrir le token de processus courant et vérifier TokenElevation
final hToken = calloc<HANDLE>();
OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, hToken);
final elevation = calloc<TOKEN_ELEVATION>();
GetTokenInformation(hToken.value, TokenElevation, elevation, sizeOf<TOKEN_ELEVATION>(), calloc<DWORD>());
return elevation.ref.TokenIsElevated != 0;
```

---

## TASK-031 — UacService : relancer l'application avec élévation UAC

**Méthode** : `Future<void> relaunchAsAdmin()`
```dart
ShellExecuteEx avec lpVerb = 'runas', lpFile = Platform.resolvedExecutable
```
**Flux** :
1. Détecter que l'action nécessite admin
2. Afficher `UacBanner` informant l'utilisateur
3. Si l'utilisateur confirme → relancer avec `runas`
4. Quitter l'instance courante

---

## TASK-032 — Widget UacBanner

**Description** : Bannière non intrusive indiquant que l'application ne tourne pas en admin.
**Fichier** : `lib/widgets/uac_banner.dart`
**Comportement** :
- S'affiche en haut du Dashboard si `!isElevated`
- Bouton "Relancer en administrateur"
- Bouton de fermeture (masquer pour la session)
- Liste les fonctionnalités nécessitant l'élévation (conversion WSL1/2, certains imports)

---

# EPIC 4 — Dashboard

## TASK-040 — Écran Dashboard : structure générale

**Fichier** : `lib/screens/dashboard/dashboard_screen.dart`
**Layout** :
- Barre de titre personnalisée (titre + boutons fenêtre)
- Sidebar de navigation à gauche
- Zone principale : liste des instances + barre de stats globale en haut
- FAB ou bouton principal "Nouvelle instance"

---

## TASK-041 — Widget InstanceCard

**Fichier** : `lib/screens/dashboard/widgets/instance_card.dart`
**Contenu à afficher** :
- Logo de la distro (depuis `assets/icons/distros/`)
- Nom de l'instance
- Badge d'état coloré (`StatusBadge`)
- Badge WSL1/WSL2
- Badge "Défaut" si `isDefault`
- Jauges CPU et RAM (si instance Running)
- Boutons d'action rapide : Démarrer/Arrêter, VSCode, Terminal, Explorer
- Flèche "Voir le détail" → navigation vers `InstanceDetailScreen`
**Comportement** :
- Clic sur la carte → InstanceDetailScreen
- Jauges visibles uniquement si état = Running
- Bouton Démarrer visible uniquement si état = Stopped
- Bouton Arrêter visible uniquement si état = Running

---

## TASK-042 — Widget StatusBadge

**Fichier** : `lib/widgets/status_badge.dart`
**États** :
- Running → fond vert `#22C55E`, texte blanc
- Stopped → fond gris `#6B7280`, texte blanc
- Installing → fond orange `#F59E0B` avec animation pulsante

---

## TASK-043 — Barre de stats globale

**Fichier** : `lib/screens/dashboard/widgets/global_stats_bar.dart`
**Contenu** :
- Nombre d'instances total / en cours
- CPU global toutes instances confondues (somme)
- RAM globale totale / utilisée
- Bouton Rafraîchir

---

## TASK-044 — Recherche et filtre sur le dashboard

**Description** : Champ de recherche filtrant les instances par nom.
**Comportement** : Filtrage en temps réel côté client, pas d'appel WSL.
**Tri** : Ajouter un sélecteur de tri (nom A-Z, état, type WSL).

---

# EPIC 5 — Wizard de création d'instance

## TASK-050 — Créer CreateWizardScreen (stepper)

**Fichier** : `lib/screens/wizard/create_wizard_screen.dart`
**Structure** : `Stepper` Flutter avec 6 étapes.
**État global du wizard** : Classe `WizardState` transmise entre étapes via `StateNotifierProvider`.
**Gestion de la navigation** : Boutons Précédent / Suivant / Créer.

---

## TASK-051 — Étape 1 : Choix de la source

**Fichier** : `lib/screens/wizard/steps/step_source.dart`
**4 options affichées sous forme de cartes** :
1. **En ligne** — Télécharger une distro officielle (liste depuis `official_distros.json`)
2. **Fichier .tar** — Sélectionner un fichier local (FilePicker)
3. **URL** — Saisir une URL HTTP/HTTPS vers un .tar.gz
4. **Template** — Choisir parmi les templates locaux existants
**Règle** : Option "Template" désactivée si aucun template n'existe.

---

## TASK-052 — Étape 1a : Sélection distro officielle

**Fichier** : `lib/screens/wizard/steps/step_source.dart` (sous-section)
**Affichage** : Grille de cartes avec logo, nom, taille estimée.
**Données** : Charger `assets/data/official_distros.json`.
**Comportement** : Sélection unique, validation si une distro est choisie.

---

## TASK-053 — Étape 1b : Source fichier .tar local

**Description** : File picker filtré sur `*.tar`, `*.tar.gz`.
**Validation** : Vérifier que le fichier existe et est lisible.

---

## TASK-054 — Étape 1c : Source URL

**Description** : Champ texte avec validation d'URL.
**Validation** : Format URL valide, schéma `http://` ou `https://`, extension `.tar` ou `.tar.gz`.
**Option** : Bouton "Tester l'URL" effectuant un HEAD request pour vérifier l'accessibilité.

---

## TASK-055 — Étape 1d : Source Template

**Description** : Afficher la liste des templates disponibles avec nom, taille, date.
**Règle** : Afficher un message "Aucun template disponible" si la liste est vide.

---

## TASK-056 — Étape 2 : Nom de l'instance

**Fichier** : `lib/screens/wizard/steps/step_name.dart`
**Validation** :
- Obligatoire
- Alphanumérique + tirets et underscores uniquement
- Pas d'espace
- Longueur 2–64 caractères
- Unicité : vérifier que le nom n'existe pas déjà dans `listInstances()`
**Résultat attendu** : Champ avec message d'erreur inline.

---

## TASK-057 — Étape 3 : Nom d'utilisateur

**Fichier** : `lib/screens/wizard/steps/step_user.dart`
**Validation** :
- Obligatoire
- Minuscules, chiffres, tirets uniquement (règles Linux)
- Ne peut pas être `root`
- Longueur 1–32 caractères

---

## TASK-058 — Étape 4 : Mot de passe

**Fichier** : `lib/screens/wizard/steps/step_password.dart`
**Champs** : Mot de passe + Confirmation
**Validation** :
- Minimum 8 caractères
- Les deux champs identiques
- Affichage/masquage du mot de passe (icône œil)
**⚠️ Sécurité** : Utiliser `obscureText: true` sur les `TextField`.

---

## TASK-059 — Étape 5 : Chemin d'installation

**Fichier** : `lib/screens/wizard/steps/step_path.dart`
**Description** : Dossier où sera stockée l'image disque de l'instance.
**Comportement** :
- Valeur par défaut : `C:\WSL\<instance_name>\`
- Bouton "Parcourir" ouvrant un `DirectoryPicker`
- Vérifier que le dossier est accessible en écriture
- Vérifier l'espace disque disponible (avertissement si < 5 Go)

---

## TASK-060 — Étape 6 : Récapitulatif et création

**Fichier** : `lib/screens/wizard/steps/step_summary.dart`
**Afficher** :
- Source choisie (distro / fichier / URL / template)
- Nom de l'instance
- Nom d'utilisateur
- Chemin d'installation
**Bouton "Créer"** : Lancer la séquence de création avec dialogue de progression.
**Séquence de création** :
1. Si source = Online ou URL → `DownloadService.download()` avec barre de progression
2. `WslService.importInstance()`
3. `WslService.setupUser()`
4. Si source = Online → Supprimer le tar temporaire
5. Rafraîchir la liste des instances
6. Naviguer vers `InstanceDetailScreen`

---

## TASK-061 — Dialogue de progression de création

**Fichier** : `lib/widgets/progress_dialog.dart`
**Contenu** :
- Étapes avec icônes de statut (en attente / en cours / terminé / erreur)
- Barre de progression globale
- Message d'état courant
- Gestion des erreurs avec message explicite
- Bouton "Annuler" si l'opération le permet

---

# EPIC 6 — Détail d'une instance

## TASK-070 — InstanceDetailScreen : structure

**Fichier** : `lib/screens/instance_detail/instance_detail_screen.dart`
**Layout** :
- En-tête : nom + badge état + badge WSL version + badge défaut
- Onglets : Informations / Actions / Monitoring / wsl.conf / Snapshots

---

## TASK-071 — Onglet Informations

**Fichier** : `lib/screens/instance_detail/widgets/info_panel.dart`
**Informations à afficher** :
- Nom, état, version WSL, distro de base
- Adresse IP (extraite de `/proc/net/fib_trie` ou `ip addr`)
- Chemin d'installation sur Windows (registre : `HKCU\Software\Microsoft\Windows\CurrentVersion\Lxss\`)
- Date de création (depuis le registre ou le dossier)
- Taille de l'image disque (fichier `ext4.vhdx`)
- Instance par défaut : oui/non

---

## TASK-072 — Onglet Actions

**Fichier** : `lib/screens/instance_detail/widgets/actions_panel.dart`
**Boutons** :

| Bouton                  | Action                                         | Admin | Confirmation |
|-------------------------|------------------------------------------------|:-----:|:------------:|
| Démarrer / Arrêter      | `startInstance` / `stopInstance`               | Non   | Non          |
| Ouvrir dans VSCode      | `code --remote wsl+<name>`                     | Non   | Non          |
| Ouvrir un terminal      | `wt wsl -d <name>`                             | Non   | Non          |
| Explorer les fichiers   | `explorer.exe \\wsl.localhost\<name>`          | Non   | Non          |
| Créer un template       | `WslService.export` + `TemplateService.create` | Non   | Non          |
| Créer un snapshot       | `WslService.export` + `SnapshotService.create` | Non   | Non          |
| Dupliquer               | `WslService.duplicateInstance`                 | Non   | Oui          |
| Renommer                | `WslService.renameInstance`                    | Non   | Oui          |
| Définir comme défaut    | `WslService.setDefaultDistro`                  | Non   | Non          |
| Reset mot de passe      | `WslService.resetPassword`                     | Non   | Oui          |
| Convertir WSL1 ↔ WSL2   | `WslService.setVersion`                        | Oui   | Oui          |
| Supprimer               | `WslService.deleteInstance`                    | Non   | **Oui + saisie du nom** |

---

## TASK-073 — Onglet Monitoring

**Fichier** : `lib/screens/instance_detail/widgets/monitoring_panel.dart`
**Contenu** :
- Jauge CPU (circulaire, `percent_indicator`)
- Jauge RAM (barre linéaire avec Mo utilisés / total)
- Label "Instance arrêtée — monitoring indisponible" si stopped
- Rafraîchissement via `StreamProvider`

---

## TASK-074 — Onglet wsl.conf

**Fichier** : `lib/screens/instance_detail/widgets/wsl_conf_editor.dart`
**Description** : Éditeur de texte simple pour `/etc/wsl.conf` de l'instance.
**Comportement** :
- Charger le contenu via `WslService.readWslConf()`
- `TextField` multiligne avec monospace font
- Bouton "Sauvegarder" → `WslService.writeWslConf()`
- Bouton "Réinitialiser" → Recharger depuis l'instance
- Avertissement : "L'instance doit être redémarrée pour appliquer les modifications"
**Format wsl.conf documenté en commentaire dans l'éditeur** (si fichier vide).

---

## TASK-075 — Onglet Snapshots (vue par instance)

**Fichier** : `lib/screens/instance_detail/widgets/snapshots_tab.dart`
**Contenu** :
- Liste des snapshots de cette instance
- Bouton "Créer un snapshot"
- Actions sur chaque snapshot : Restaurer, Supprimer

---

# EPIC 7 — Templates

## TASK-080 — TemplateService : créer un template

**Fichier** : `lib/services/template_service.dart`
**Méthode** : `Future<WslTemplate> createFromInstance(String instanceName, String templateName, String description)`
**Étapes** :
1. Construire le chemin : `<templatesDir>\<templateName>.tar`
2. Appeler `WslService.exportInstance()`
3. Récupérer la taille du fichier généré
4. Créer un `WslTemplate` avec UUID v4
5. Sauvegarder dans `templates.json` via `StorageService`
**Résultat attendu** : Template créé, JSON mis à jour, fichier .tar présent.

---

## TASK-081 — TemplateService : lister les templates

**Méthode** : `Future<List<WslTemplate>> listTemplates()`
**Comportement** : Lire `templates.json`. Vérifier que chaque `.tar` référencé existe encore.
Si un .tar est manquant, marquer le template comme `orphan: true`.

---

## TASK-082 — TemplateService : supprimer un template

**Méthode** : `Future<void> deleteTemplate(String id)`
**Étapes** :
1. Trouver le template par ID
2. Supprimer le fichier .tar (si existant)
3. Mettre à jour `templates.json`

---

## TASK-083 — TemplateService : importer un template depuis un fichier .tar externe

**Méthode** : `Future<WslTemplate> importFromFile(String sourceTarPath, String templateName, String description)`
**Étapes** :
1. Copier le fichier dans `templatesDir`
2. Créer l'entrée JSON

---

## TASK-084 — TemplateService : exporter un template vers un chemin choisi

**Méthode** : `Future<void> exportToFile(String id, String destinationPath)`
**Description** : Copier le fichier .tar du template vers le chemin choisi par l'utilisateur.

---

## TASK-085 — TemplatesScreen : liste des templates

**Fichier** : `lib/screens/templates/templates_screen.dart`
**Colonnes de la liste** : Nom, Distro source, Taille, Date, Actions
**Actions par template** :
- Créer une instance depuis ce template
- Modifier le nom/description
- Exporter vers un fichier
- Supprimer
**Bouton global** : Importer un template (.tar)

---

# EPIC 8 — Snapshots

## TASK-090 — SnapshotService : créer un snapshot

**Fichier** : `lib/services/snapshot_service.dart`
**Méthode** : `Future<WslSnapshot> createSnapshot(String instanceName, String snapshotName, String description)`
**Étapes** :
1. Construire le chemin : `<snapshotsDir>\<instanceName>_<snapshotName>_<timestamp>.tar`
2. Appeler `WslService.exportInstance()`
3. Créer un `WslSnapshot` avec UUID v4
4. Sauvegarder dans `snapshots.json`

---

## TASK-091 — SnapshotService : restaurer un snapshot

**Méthode** : `Future<void> restoreSnapshot(String snapshotId, String targetInstanceName, String installDir)`
**Étapes** :
1. Trouver le snapshot par ID
2. Si l'instance cible existe → appeler `WslService.deleteInstance()` (après confirmation)
3. Appeler `WslService.importInstance()` avec le tar du snapshot
4. Rafraîchir la liste des instances
**⚠️ Irréversible** : Afficher un avertissement clair avant la restauration.

---

## TASK-092 — SnapshotService : supprimer un snapshot

**Méthode** : `Future<void> deleteSnapshot(String id)`

---

## TASK-093 — SnapshotsScreen : vue globale

**Fichier** : `lib/screens/snapshots/snapshots_screen.dart`
**Liste** groupée par instance, avec : nom, description, taille, date, actions.

---

# EPIC 9 — Supervision CPU/RAM

## TASK-100 — MonitoringService : architecture de polling

**Fichier** : `lib/services/monitoring_service.dart`
**Méthode** : `Stream<Map<String, MonitoringData>> stream({required Duration interval})`
**Architecture** :
```dart
Stream.periodic(interval).asyncMap((_) async {
  final instances = await wslService.listInstances();
  final runningInstances = instances.where((i) => i.state == WslInstanceState.running);
  final Map<String, MonitoringData> results = {};
  for (final instance in runningInstances) {
    results[instance.name] = await _getMetrics(instance.name);
  }
  return results;
})
```

---

## TASK-101 — MonitoringService : calcul CPU par instance

**Méthode** : `Future<double> _getCpuPercent(String instanceName)`
**Algorithme** :
1. Lire `/proc/stat` → extraire ligne `cpu` → parser [user, nice, system, idle, iowait, irq, softirq]
2. Attendre 500ms
3. Relire `/proc/stat`
4. Calculer : `cpu% = 100 * (1 - delta_idle / delta_total)`
**Classe de données** :
```dart
class CpuReading {
  final int total;
  final int idle;
}
```

---

## TASK-102 — MonitoringService : calcul RAM par instance

**Méthode** : `Future<(int usedMb, int totalMb)> _getRamInfo(String instanceName)`
**Parsing /proc/meminfo** :
```dart
final lines = content.split('\n');
int memTotal = _extractKb(lines, 'MemTotal');
int memAvailable = _extractKb(lines, 'MemAvailable');
int usedKb = memTotal - memAvailable;
```

---

## TASK-103 — Widget CpuGauge

**Fichier** : `lib/widgets/cpu_gauge.dart`
**Composant** : `CircularPercentIndicator` (package `percent_indicator`)
**Props** : `double cpuPercent`, `double radius`
**Couleur dynamique** :
- < 50% → vert
- 50–80% → orange
- > 80% → rouge

---

## TASK-104 — Widget RamGauge

**Fichier** : `lib/widgets/ram_gauge.dart`
**Composant** : `LinearPercentIndicator`
**Props** : `int usedMb`, `int totalMb`
**Label** : `"${usedMb} Mo / ${totalMb} Mo (${percent.toStringAsFixed(1)}%)"`

---

# EPIC 10 — Téléchargement via URL

## TASK-110 — DownloadService : télécharger un fichier via URL

**Fichier** : `lib/services/download_service.dart`
**Méthode** : `Future<String> downloadToTemp(String url, void Function(double progress) onProgress)`
**Implémentation avec Dio** :
```dart
await dio.download(
  url,
  tempFilePath,
  onReceiveProgress: (received, total) {
    if (total > 0) onProgress(received / total);
  },
);
```
**Gestion d'erreurs** :
- Timeout 5 min
- URL inaccessible → `DownloadException`
- Espace insuffisant → vérifier avant de démarrer
- Format invalide (non tar/tar.gz) → avertissement

---

## TASK-111 — Validation d'une URL de distro

**Méthode** : `Future<bool> validateUrl(String url)`
**Étapes** :
1. Vérifier le format URI (dart:core `Uri.parse`)
2. Envoyer une requête HEAD avec `http` package
3. Vérifier statut 200 et Content-Type

---

# EPIC 11 — Systray

## TASK-120 — Intégrer system_tray

**Fichier** : `lib/main.dart`
**Initialisation** :
```dart
final SystemTray systemTray = SystemTray();
await systemTray.initSystemTray(
  title: 'WSL Manager',
  iconPath: 'assets/icons/app_icon.ico',
);
```
**Note** : Le systray nécessite un fichier `.ico` natif Windows, pas un PNG.

---

## TASK-121 — Menu contextuel du systray

**Description** : Menu avec instances Running et actions rapides.
**Structure du menu** :
```
▶ Ubuntu-22.04 (Running)    →  Arrêter
▶ Debian (Stopped)          →  Démarrer
─────────────────────────
  Ouvrir WSL Manager
─────────────────────────
  Quitter
```
**Mise à jour** : Régénérer le menu à chaque changement d'état des instances.

---

## TASK-122 — Comportement à la fermeture de la fenêtre

**Description** : Intercepter l'événement de fermeture.
**Comportement selon config** :
- Si `config.minimizeToTray == true` → masquer la fenêtre au lieu de quitter
- Afficher une notification toast au premier "masquage" : "WSL Manager tourne en arrière-plan"
- L'option "Quitter" du systray ferme réellement l'application

---

# EPIC 12 — Paramètres

## TASK-130 — SettingsScreen

**Fichier** : `lib/screens/settings/settings_screen.dart`
**Sections** :

### Stockage
- Dossier des templates : champ + bouton "Parcourir"
- Dossier des snapshots : champ + bouton "Parcourir"

### Surveillance
- Intervalle de rafraîchissement : slider 2–60 secondes

### Apparence
- Thème : Sélecteur radio (Clair / Sombre / Système)

### Comportement
- Minimiser dans le systray à la fermeture : switch
- Lancer au démarrage Windows : switch (créer/supprimer clé `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`)

### À propos
- Version de l'application
- Lien vers le dépôt (si applicable)
- Bouton "Vérifier les mises à jour" (V2)

---

## TASK-131 — Persistance des paramètres

**Méthode** : Sauvegarder dans `config.json` via `StorageService` à chaque modification.
**Chargement** : Au démarrage de l'app, via `ConfigNotifierProvider`.

---

# EPIC 13 — Packaging EXE portable

## TASK-140 — Build Windows release

**Commande** :
```powershell
flutter build windows --release
```
**Sortie** : `build\windows\x64\runner\Release\`

---

## TASK-141 — Script build_portable.ps1

**Fichier** : `scripts/build_portable.ps1`
**Contenu** :
```powershell
# 1. Build Flutter
flutter build windows --release

# 2. Copier dans dossier de sortie
$dest = "dist\WSLManager"
New-Item -ItemType Directory -Force -Path $dest
Copy-Item -Recurse "build\windows\x64\runner\Release\*" $dest

# 3. Renommer l'exécutable
Rename-Item "$dest\wsl_manager.exe" "WSLManager.exe"

# 4. Créer le ZIP portable
Compress-Archive -Path $dest -DestinationPath "dist\WSLManager_portable.zip" -Force

Write-Host "Build terminé : dist\WSLManager_portable.zip"
```

---

## TASK-142 — Configurer l'icône application (.ico)

**Description** : Remplacer l'icône par défaut Flutter.
**Fichier source** : `assets/icons/app_icon.png` (256×256 minimum)
**Commande** (flutter_launcher_icons) :
```yaml
# Dans pubspec.yaml
flutter_launcher_icons:
  windows:
    generate: true
    image_path: "assets/icons/app_icon.png"
    icon_size: 256
```
```bash
dart run flutter_launcher_icons
```

---

## TASK-143 — Manifeste Windows (UAC requestedExecutionLevel)

**Fichier** : `windows\runner\Runner.exe.manifest`
**Valeur par défaut** : `asInvoker` (pas d'élévation auto)
**Justification** : L'élévation est demandée uniquement quand nécessaire via `UacService`.
```xml
<requestedExecutionLevel level="asInvoker" uiAccess="false"/>
```

---

## TASK-144 — Tester le portable sur machine sans Flutter

**Checklist** :
- [ ] Copier `dist\WSLManager\` sur une machine Windows 11 sans Flutter installé
- [ ] Vérifier que toutes les DLLs sont présentes (Flutter embarque les DLLs dans le build Release)
- [ ] Tester le démarrage
- [ ] Tester une action WSL basique (liste des instances)
- [ ] Vérifier que `AppData\Local\WSLManager\` est créé correctement

---

# Ordre de développement recommandé

```
Phase 1 — Fondations (EPIC 1 + 2)
  TASK-001 à TASK-011 : Setup projet + WslService de base

Phase 2 — Dashboard minimal (EPIC 4 partiel)
  TASK-040 à TASK-044 : Dashboard avec liste des instances fonctionnelle

Phase 3 — Actions de base (EPIC 6 partiel)
  TASK-070 à TASK-073 : Détail instance + start/stop/open VSCode/Explorer

Phase 4 — Wizard de création (EPIC 5)
  TASK-050 à TASK-061 : Wizard complet

Phase 5 — Templates et Snapshots (EPIC 7 + 8)
  TASK-080 à TASK-093

Phase 6 — Monitoring (EPIC 9)
  TASK-100 à TASK-104

Phase 7 — Téléchargement URL (EPIC 10)
  TASK-110 à TASK-111

Phase 8 — Finition (EPIC 3, 11, 12, 13)
  UAC + Systray + Paramètres + Packaging
```

---

# Fonctionnalités V2 (hors périmètre V1)

- Mise à jour automatique de l'application (auto-updater)
- Internationalisation i18n (EN/FR) — prévoir la structure `AppLocalizations` en V1
- Export configuration complète (templates + snapshots + config) en un seul ZIP
- Graphiques historiques CPU/RAM (5 dernières minutes)
- Alertes CPU/RAM dépassement de seuil (notification Windows toast)
- Détection et affichage des ports forwardés par instance
- Éditeur `.wslconfig` global (limites CPU/RAM/swap Windows ↔ WSL)
- Scripts de démarrage automatique par instance
- Intégration Git (afficher la branche courante dans l'InstanceCard)
- Mode multi-postes (partage de templates via réseau)

---

# Notes de développement importantes

1. **Encodage UTF-16** : Toujours tester la sortie de `wsl --list --verbose` sur une vraie machine Windows. L'encodage peut varier selon les versions de Windows et les paramètres de locale.

2. **Commandes WSL bloquantes** : `wsl --export` et `wsl --import` peuvent durer plusieurs minutes. Toujours les exécuter dans un `Isolate` ou en asynchrone avec `Process.start()` (non bloquant) plutôt que `Process.run()`.

3. **Élévation UAC** : Ne pas exiger l'élévation au démarrage. L'élévation "à la demande" est obligatoire uniquement pour `--set-version`.

4. **Registre Windows pour les métadonnées** : Les instances WSL sont enregistrées dans `HKCU\Software\Microsoft\Windows\CurrentVersion\Lxss\`. Cela permet de récupérer le chemin d'installation réel de chaque instance.

5. **Sécurité des mots de passe** : Ne jamais stocker les mots de passe en clair. Effacer les variables String contenant des mots de passe immédiatement après usage. Utiliser `SecureString` si disponible.

6. **Chemin des assets en mode portable** : En mode Release portable, les assets se trouvent dans `data/flutter_assets/`. Vérifier que `file_picker` et les chemins d'accès sont cohérents.

7. **Test sans WSL** : Prévoir un mode `mock` dans `WslService` pour le développement sur une machine sans WSL (`kDebugMode && Platform.isMacOS`).
