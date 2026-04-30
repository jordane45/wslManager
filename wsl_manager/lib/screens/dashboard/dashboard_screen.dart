import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/instance_group.dart';
import '../../models/wsl_instance.dart';
import '../../providers/groups_provider.dart';
import '../../providers/instances_provider.dart';
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
    final groups = ref.watch(groupsProvider);

    return Column(
      children: [
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
                    value: _SortMode.name,
                    child: Text('Nom A-Z'),
                  ),
                  DropdownMenuItem(
                    value: _SortMode.state,
                    child: Text('Etat'),
                  ),
                  DropdownMenuItem(
                    value: _SortMode.version,
                    child: Text('Version WSL'),
                  ),
                ],
                onChanged: (v) => setState(() => _sort = v!),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.create_new_folder, size: 18),
                label: const Text('Groupe'),
                onPressed: () => _showCreateGroupDialog(context),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nouvelle instance'),
                onPressed: () => context.go('/create'),
              ),
            ],
          ),
        ),
        Expanded(
          child: instances.when(
            loading: () => const Center(child: CircularProgressIndicator()),
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
                    child: const Text('Reessayer'),
                  ),
                ],
              ),
            ),
            data: (list) {
              final groupsState =
                  groups.valueOrNull ?? InstanceGroupsState.empty();
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
                            ? 'Aucune instance WSL trouvee'
                            : 'Aucun resultat pour "$_search"',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return _GroupedGrid(
                instances: filtered,
                groupsState: groupsState,
                searchActive: _search.trim().isNotEmpty,
                onToggleGroup: (groupId) =>
                    ref.read(groupsProvider.notifier).toggleCollapsed(groupId),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showCreateGroupDialog(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau groupe'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nom du groupe',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Creer'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (name != null && name.trim().isNotEmpty) {
      await ref.read(groupsProvider.notifier).create(name);
    }
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

class _GroupedGrid extends StatelessWidget {
  final List<WslInstance> instances;
  final InstanceGroupsState groupsState;
  final bool searchActive;
  final ValueChanged<String> onToggleGroup;

  const _GroupedGrid({
    required this.instances,
    required this.groupsState,
    required this.searchActive,
    required this.onToggleGroup,
  });

  @override
  Widget build(BuildContext context) {
    final validGroupIds = groupsState.groups.map((g) => g.id).toSet();
    final byGroup = <String?, List<WslInstance>>{};
    for (final instance in instances) {
      final groupId = groupsState.assignments[instance.name];
      final effectiveGroupId = validGroupIds.contains(groupId) ? groupId : null;
      byGroup.putIfAbsent(effectiveGroupId, () => []).add(instance);
    }

    final sections = <Widget>[];
    for (final group in groupsState.groups) {
      final groupInstances = byGroup[group.id] ?? [];
      if (groupInstances.isEmpty && searchActive) continue;
      sections.add(
        _GroupSection(
          title: group.name,
          count: groupInstances.length,
          collapsed: group.collapsed && !searchActive,
          onToggle: () => onToggleGroup(group.id),
          instances: groupInstances,
        ),
      );
    }

    final ungrouped = byGroup[null] ?? [];
    if (ungrouped.isNotEmpty) {
      sections.add(
        _GroupSection(
          title: 'Non classees',
          count: ungrouped.length,
          collapsed: false,
          instances: ungrouped,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      children: sections,
    );
  }
}

class _GroupSection extends StatelessWidget {
  final String title;
  final int count;
  final bool collapsed;
  final VoidCallback? onToggle;
  final List<WslInstance> instances;

  const _GroupSection({
    required this.title,
    required this.count,
    required this.collapsed,
    required this.instances,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onToggle != null)
                IconButton(
                  tooltip: collapsed ? 'Deplier' : 'Replier',
                  onPressed: onToggle,
                  icon: Icon(
                    collapsed
                        ? Icons.keyboard_arrow_right
                        : Icons.keyboard_arrow_down,
                  ),
                )
              else
                const SizedBox(width: 48),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
          if (!collapsed) ...[
            const SizedBox(height: 8),
            if (instances.isEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 48, top: 8, bottom: 12),
                child: Text(
                  'Aucune instance dans ce groupe',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = math.max(
                    1,
                    math.min(4, (constraints.maxWidth / 340).floor()),
                  );
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 216,
                    ),
                    itemCount: instances.length,
                    itemBuilder: (_, index) =>
                        InstanceCard(instance: instances[index]),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }
}

enum _SortMode { name, state, version }
