import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/wsl_instance.dart';
import '../../../providers/monitoring_provider.dart';

class InfoPanel extends ConsumerWidget {
  final WslInstance instance;
  const InfoPanel({super.key, required this.instance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monitoring = ref.watch(monitoringProvider);
    final data = monitoring.valueOrNull?[instance.name];
    final unavailable = instance.state == WslInstanceState.running
        ? 'En attente...'
        : 'Non disponible';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _InfoSection(title: 'Général', rows: [
          _InfoRow('Nom', instance.name),
          _InfoRow('État', instance.state.name),
          _InfoRow(
            'Version WSL',
            instance.version == WslVersion.wsl2 ? 'WSL 2' : 'WSL 1',
          ),
          _InfoRow('Instance par défaut', instance.isDefault ? 'Oui' : 'Non'),
        ]),
        const SizedBox(height: 16),
        _InfoSection(title: 'Réseau', rows: [
          _InfoRow('Adresse IP', data?.ipAddress ?? unavailable),
        ]),
        const SizedBox(height: 16),
        _InfoSection(title: 'Ressources', rows: [
          _InfoRow(
            'CPU',
            data != null
                ? '${data.cpuPercent.toStringAsFixed(1)} %'
                : unavailable,
          ),
          _InfoRow(
            'RAM utilisée',
            data != null
                ? '${data.ramUsedMb} Mo / ${data.ramTotalMb} Mo'
                : unavailable,
          ),
        ]),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<_InfoRow> rows;
  const _InfoSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Divider(height: 16),
            ...rows,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
