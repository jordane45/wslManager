import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/config_provider.dart';
import '../providers/instances_provider.dart';
import '../services/systray_service.dart';
import '../services/wsl_service.dart';
import 'custom_title_bar.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> with WindowListener {
  bool _hasShownTrayHint = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initSystray();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    SystrayService.instance.destroy();
    super.dispose();
  }

  Future<void> _initSystray() async {
    final service = SystrayService.instance;

    service.onShowWindow = () async {
      await windowManager.show();
      await windowManager.focus();
    };

    service.onQuit = () async {
      await windowManager.setPreventClose(false);
      await windowManager.close();
    };

    service.onToggleInstance = (name, start) async {
      if (start) {
        await WslService.instance.startInstance(name);
      } else {
        await WslService.instance.stopInstance(name);
      }
      ref.read(instancesProvider.notifier).refresh();
    };

    await service.init();
  }

  @override
  void onWindowClose() async {
    final config = ref.read(configProvider).valueOrNull;
    final minimizeToTray = config?.minimizeToTray ?? true;

    if (minimizeToTray) {
      await windowManager.hide();
      if (!_hasShownTrayHint && mounted) {
        _hasShownTrayHint = true;
        // Show hint via snackbar before hiding (shown briefly before window hides)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WSL Manager tourne en arrière-plan dans le systray.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      await windowManager.setPreventClose(false);
      await windowManager.close();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Rebuild tray menu when instances change
    final instances = ref.watch(instancesProvider).valueOrNull ?? [];
    SystrayService.instance.updateMenu(instances);
  }

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/instance') || loc == '/') return 0;
    if (loc == '/templates') return 1;
    if (loc == '/snapshots') return 2;
    if (loc == '/settings') return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    // Keep tray in sync with provider changes
    ref.listen(instancesProvider, (_, next) {
      SystrayService.instance.updateMenu(next.valueOrNull ?? []);
    });

    final idx = _selectedIndex(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const CustomTitleBar(),
          Expanded(
            child: Row(
              children: [
                NavigationRail(
                  backgroundColor: Colors.transparent,
                  selectedIndex: idx,
                  labelType: NavigationRailLabelType.all,
                  onDestinationSelected: (i) {
                    switch (i) {
                      case 0:
                        context.go('/');
                      case 1:
                        context.go('/templates');
                      case 2:
                        context.go('/snapshots');
                      case 3:
                        context.go('/settings');
                    }
                  },
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.layers_outlined),
                      selectedIcon: Icon(Icons.layers),
                      label: Text('Templates'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.camera_alt_outlined),
                      selectedIcon: Icon(Icons.camera_alt),
                      label: Text('Snapshots'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Paramètres'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
