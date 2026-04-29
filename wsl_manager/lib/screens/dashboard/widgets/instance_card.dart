import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/wsl_instance.dart';
import '../../../providers/instances_provider.dart';
import '../../../providers/monitoring_provider.dart';
import '../../../services/wsl_service.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/cpu_gauge.dart';
import '../../../widgets/ram_gauge.dart';

class InstanceCard extends ConsumerWidget {
  final WslInstance instance;
  const InstanceCard({super.key, required this.instance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monitoring = ref.watch(monitoringProvider);
    final data = monitoring.valueOrNull?[instance.name];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/instance/${instance.name}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Distro icon
              _DistroIcon(name: instance.name),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(instance.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                )),
                        const SizedBox(width: 8),
                        StatusBadge(state: instance.state),
                        const SizedBox(width: 6),
                        _VersionBadge(version: instance.version),
                        if (instance.isDefault) ...[
                          const SizedBox(width: 6),
                          _DefaultBadge(),
                        ],
                      ],
                    ),
                    if (instance.state == WslInstanceState.running && data != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          CpuGauge(cpuPercent: data.cpuPercent, radius: 28),
                          const SizedBox(width: 24),
                          RamGauge(usedMb: data.ramUsedMb, totalMb: data.ramTotalMb),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Quick actions
              _QuickActions(instance: instance, ref: ref),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _DistroIcon extends StatelessWidget {
  final String name;
  const _DistroIcon({required this.name});

  String get _iconAsset {
    final n = name.toLowerCase();
    if (n.contains('ubuntu')) return 'assets/icons/distros/ubuntu.png';
    if (n.contains('debian')) return 'assets/icons/distros/debian.png';
    if (n.contains('kali')) return 'assets/icons/distros/kali.png';
    if (n.contains('alpine')) return 'assets/icons/distros/alpine.png';
    if (n.contains('opensuse')) return 'assets/icons/distros/opensuse.png';
    if (n.contains('oracle')) return 'assets/icons/distros/oracle.png';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (_iconAsset.isEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.terminal, size: 22),
      );
    }
    return Image.asset(_iconAsset, width: 40, height: 40,
        errorBuilder: (_, __, ___) => const Icon(Icons.terminal, size: 40));
  }
}

class _VersionBadge extends StatelessWidget {
  final WslVersion version;
  const _VersionBadge({required this.version});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        version == WslVersion.wsl2 ? 'WSL2' : 'WSL1',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('Défaut',
          style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onPrimaryContainer)),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final WslInstance instance;
  final WidgetRef ref;
  const _QuickActions({required this.instance, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (instance.state == WslInstanceState.stopped)
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Démarrer',
            onPressed: () => ref.read(instancesProvider.notifier).start(instance.name),
          ),
        if (instance.state == WslInstanceState.running)
          IconButton(
            icon: const Icon(Icons.stop),
            tooltip: 'Arrêter',
            onPressed: () => ref.read(instancesProvider.notifier).stop(instance.name),
          ),
        IconButton(
          icon: const Icon(Icons.code),
          tooltip: 'VSCode',
          onPressed: () => WslService.instance.openInVsCode(instance.name),
        ),
        IconButton(
          icon: const Icon(Icons.terminal),
          tooltip: 'Terminal',
          onPressed: () => WslService.instance.openInTerminal(instance.name),
        ),
        IconButton(
          icon: const Icon(Icons.folder_open),
          tooltip: 'Explorateur',
          onPressed: () => WslService.instance.openInExplorer(instance.name),
        ),
      ],
    );
  }
}
