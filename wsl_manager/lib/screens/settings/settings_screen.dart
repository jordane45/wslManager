import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/app_config.dart';
import '../../providers/config_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: config.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (cfg) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Section(title: 'Stockage', children: [
              _DirRow(
                label: 'Dossier des templates',
                value: cfg.templatesDir,
                onChanged: (v) => _save(ref, cfg.copyWith(templatesDir: v)),
              ),
              _DirRow(
                label: 'Dossier des snapshots',
                value: cfg.snapshotsDir,
                onChanged: (v) => _save(ref, cfg.copyWith(snapshotsDir: v)),
              ),
            ]),
            const SizedBox(height: 16),
            _Section(title: 'Surveillance', children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Intervalle de rafraîchissement : '
                        '${cfg.monitoringIntervalSeconds}s',
                        style: const TextStyle(fontSize: 13)),
                    Slider(
                      value: cfg.monitoringIntervalSeconds.toDouble(),
                      min: 2,
                      max: 60,
                      divisions: 29,
                      label: '${cfg.monitoringIntervalSeconds}s',
                      onChanged: (v) => _save(
                          ref,
                          cfg.copyWith(
                              monitoringIntervalSeconds: v.round())),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _Section(title: 'Apparence', children: [
              ...['system', 'light', 'dark'].map((t) => RadioListTile<String>(
                    dense: true,
                    title: Text(switch (t) {
                      'system' => 'Système',
                      'light' => 'Clair',
                      'dark' => 'Sombre',
                      _ => t,
                    }),
                    value: t,
                    groupValue: cfg.theme,
                    onChanged: (v) =>
                        _save(ref, cfg.copyWith(theme: v)),
                  )),
            ]),
            const SizedBox(height: 16),
            _Section(title: 'Comportement', children: [
              SwitchListTile(
                dense: true,
                title: const Text('Minimiser dans le systray à la fermeture'),
                value: cfg.minimizeToTray,
                onChanged: (v) =>
                    _save(ref, cfg.copyWith(minimizeToTray: v)),
              ),
              SwitchListTile(
                dense: true,
                title: const Text('Lancer au démarrage Windows'),
                value: cfg.launchAtStartup,
                onChanged: (v) =>
                    _save(ref, cfg.copyWith(launchAtStartup: v)),
              ),
            ]),
            const SizedBox(height: 16),
            _Section(title: 'À propos', children: [
              ListTile(
                dense: true,
                title: const Text('Version'),
                trailing: const Text('1.0.0',
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _save(WidgetRef ref, AppConfig cfg) {
    ref.read(configProvider.notifier).save(cfg);
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const Divider(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DirRow extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  const _DirRow(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13)),
                Text(value,
                    style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.folder_open, size: 18),
            tooltip: 'Parcourir',
            onPressed: () async {
              final result = await FilePicker.platform.getDirectoryPath(
                  dialogTitle: 'Choisir le dossier');
              if (result != null) onChanged(result);
            },
          ),
        ],
      ),
    );
  }
}
