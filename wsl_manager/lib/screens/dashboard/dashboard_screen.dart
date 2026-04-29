import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/wsl_instance.dart';
import '../../providers/instances_provider.dart';
import '../../widgets/custom_title_bar.dart';
import '../../widgets/uac_banner.dart';
import 'widgets/global_stats_bar.dart';
import 'widgets/instance_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _search = '';
  _SortMode _sort = _SortMode.name;

  @override
  Widget build(BuildContext context) {
    final instances = ref.watch(instancesProvider);

    return Column(
      children: [
        const CustomTitleBar(),
        const UacBanner(),
        const GlobalStatsBar(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Rechercher une instance...',
                    prefixIcon: Icon(Icons.search, size: 18),
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<_SortMode>(
                value: _sort,
                isDense: true,
                items: const [
                  DropdownMenuItem(
                      value: _SortMode.name, child: Text('Nom A–Z')),
                  DropdownMenuItem(
                      value: _SortMode.state, child: Text('État')),
                  DropdownMenuItem(
                      value: _SortMode.version, child: Text('Version WSL')),
                ],
                onChanged: (v) => setState(() => _sort = v!),
              ),
            ],
          ),
        ),
        Expanded(
          child: instances.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 8),
                  Text('Erreur : $e'),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () =>
                        ref.read(instancesProvider.notifier).refresh(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
            data: (list) {
              final filtered = list
                  .where((i) =>
                      i.name.toLowerCase().contains(_search.toLowerCase()))
                  .toList()
                ..sort(_comparator);

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.terminal, size: 56, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        list.isEmpty
                            ? 'Aucune instance WSL trouvée'
                            : 'Aucun résultat pour "$_search"',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 4, bottom: 80),
                itemCount: filtered.length,
                itemBuilder: (_, i) => InstanceCard(instance: filtered[i]),
              );
            },
          ),
        ),
      ],
    );
  }

  int _comparator(WslInstance a, WslInstance b) {
    switch (_sort) {
      case _SortMode.name:
        return a.name.compareTo(b.name);
      case _SortMode.state:
        return a.state.index.compareTo(b.state.index);
      case _SortMode.version:
        return a.version.index.compareTo(b.version.index);
    }
  }
}

enum _SortMode { name, state, version }
