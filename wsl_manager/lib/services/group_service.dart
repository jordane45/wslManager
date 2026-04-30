import 'package:uuid/uuid.dart';

import '../models/instance_group.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class GroupService {
  static GroupService? _instance;
  static GroupService get instance => _instance ??= GroupService._();
  GroupService._();

  final _uuid = const Uuid();

  Future<InstanceGroupsState> load() async {
    final state = await StorageService.instance.readJson(
      kGroupsFile,
      InstanceGroupsState.fromJson,
    );
    return state ?? InstanceGroupsState.empty();
  }

  Future<void> save(InstanceGroupsState state) async {
    await StorageService.instance.writeJson(kGroupsFile, state.toJson());
  }

  Future<InstanceGroupsState> createGroup(String name) async {
    final state = await load();
    final trimmed = name.trim();
    if (trimmed.isEmpty) return state;

    final group = InstanceGroup(
      id: _uuid.v4(),
      name: trimmed,
      order: state.groups.length,
    );
    final next = state.copyWith(groups: [...state.groups, group]);
    await save(next);
    return next;
  }

  Future<InstanceGroupsState> assignInstance(
    String instanceName,
    String? groupId,
  ) async {
    final state = await load();
    final assignments = Map<String, String>.from(state.assignments);
    if (groupId == null || groupId.isEmpty) {
      assignments.remove(instanceName);
    } else {
      assignments[instanceName] = groupId;
    }
    final next = state.copyWith(assignments: assignments);
    await save(next);
    return next;
  }

  Future<InstanceGroupsState> toggleCollapsed(String groupId) async {
    final state = await load();
    final groups = state.groups
        .map((group) => group.id == groupId
            ? group.copyWith(collapsed: !group.collapsed)
            : group)
        .toList();
    final next = state.copyWith(groups: groups);
    await save(next);
    return next;
  }
}
