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
    final stopped = instance.state == WslInstanceState.stopped;
    final running = instance.state == WslInstanceState.running;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Start / Stop
        if (stopped)
          _ActionButton(
            icon: Icons.play_arrow_rounded,
            tooltip: 'Démarrer',
            color: const Color(0xFF22C55E),
            onPressed: () => ref.read(instancesProvider.notifier).start(instance.name),
          ),
        if (running)
          _ActionButton(
            icon: Icons.stop_rounded,
            tooltip: 'Arrêter',
            color: Colors.orange,
            onPressed: () => ref.read(instancesProvider.notifier).stop(instance.name),
          ),
        if (!stopped && !running)
          const SizedBox(width: 40),

        const SizedBox(width: 4),

        // "Ouvrir dans…" menu
        PopupMenuButton<String>(
          tooltip: 'Ouvrir dans…',
          icon: const Icon(Icons.open_in_new, size: 20),
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'vscode',
              child: ListTile(
                dense: true,
                leading: Icon(Icons.code, size: 18),
                title: Text('VSCode'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'terminal',
              child: ListTile(
                dense: true,
                leading: Icon(Icons.terminal, size: 18),
                title: Text('Terminal'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'explorer',
              child: ListTile(
                dense: true,
                leading: Icon(Icons.folder_open, size: 18),
                title: Text('Explorateur'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
          onSelected: (v) {
            switch (v) {
              case 'vscode':
                WslService.instance.openInVsCode(instance.name);
              case 'terminal':
                WslService.instance.openInTerminal(instance.name);
              case 'explorer':
                WslService.instance.openInExplorer(instance.name);
            }
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withAlpha(80)),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
