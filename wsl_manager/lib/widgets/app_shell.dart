import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';
import 'custom_title_bar.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    await windowManager.hide();
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
