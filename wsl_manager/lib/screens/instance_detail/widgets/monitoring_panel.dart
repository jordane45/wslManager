import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/wsl_instance.dart';
import '../../../providers/monitoring_provider.dart';
import '../../../widgets/cpu_gauge.dart';
import '../../../widgets/ram_gauge.dart';

class MonitoringPanel extends ConsumerWidget {
  final WslInstance instance;
  const MonitoringPanel({super.key, required this.instance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (instance.state != WslInstanceState.running) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.monitor_heart_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('Instance arrêtée — monitoring indisponible',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final monitoring = ref.watch(monitoringProvider);
    final data = monitoring.valueOrNull?[instance.name];

    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Processeur',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  CpuGauge(cpuPercent: data.cpuPercent, radius: 60),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Mémoire vive',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  RamGauge(
                      usedMb: data.ramUsedMb, totalMb: data.ramTotalMb),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
