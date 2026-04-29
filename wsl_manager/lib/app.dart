import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/config_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/instance_detail/instance_detail_screen.dart';
import 'screens/wizard/create_wizard_screen.dart';
import 'screens/templates/templates_screen.dart';
import 'screens/snapshots/snapshots_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'widgets/app_shell.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
        GoRoute(
          path: '/instance/:name',
          builder: (_, state) =>
              InstanceDetailScreen(name: state.pathParameters['name']!),
        ),
        GoRoute(path: '/templates', builder: (_, __) => const TemplatesScreen()),
        GoRoute(path: '/snapshots', builder: (_, __) => const SnapshotsScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      ],
    ),
    GoRoute(path: '/create', builder: (_, __) => const CreateWizardScreen()),
  ],
);

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeConfig = ref.watch(configProvider).valueOrNull?.theme ?? 'system';
    final themeMode = switch (themeConfig) {
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };

    return MaterialApp.router(
      title: 'WSL Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0078D4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
