import 'package:flutter/material.dart';
import '../../../models/wsl_instance.dart';

class InfoPanel extends StatelessWidget {
  final WslInstance instance;
  const InfoPanel({super.key, required this.instance});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _InfoSection(title: 'Général', rows: [
          _InfoRow('Nom', instance.name),
          _InfoRow('État', instance.state.name),
          _InfoRow('Version WSL', instance.version == WslVersion.wsl2 ? 'WSL 2' : 'WSL 1'),
          _InfoRow('Instance par défaut', instance.isDefault ? 'Oui' : 'Non'),
        ]),
        const SizedBox(height: 16),
        _InfoSection(title: 'Réseau', rows: [
          _InfoRow('Adresse IP', instance.ipAddress ?? '—'),
        ]),
        const SizedBox(height: 16),
        _InfoSection(title: 'Ressources', rows: [
          _InfoRow('CPU', instance.cpuPercent != null
              ? '${instance.cpuPercent!.toStringAsFixed(1)} %'
              : '—'),
          _InfoRow('RAM utilisée', instance.ramUsedMb != null
              ? '${instance.ramUsedMb} Mo / ${instance.ramTotalMb} Mo'
              : '—'),
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
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
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
            child: Text(label,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
