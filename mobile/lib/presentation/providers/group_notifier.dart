import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/data/providers/group_providers.dart';
import 'package:taskflow/presentation/providers/group_state.dart';

class GroupNotifier extends StateNotifier<GroupState> {
  final Ref ref;

  GroupNotifier(this.ref) : super(const GroupState.initial());

  Future<void> loadGroups() async {
    state = const GroupState.loading();
    try {
      final useCase = ref.read(getGroupsUseCaseProvider);
      final result = await useCase();

      result.fold(
        (failure) => state = GroupState.error(failure.message),
        (groups) => state = GroupState.loaded(groups),
      );
    } catch (e) {
      state = GroupState.error(e.toString());
    }
  }

  Future<void> refresh() async {
    await loadGroups();
  }
}

// Provider
final groupNotifierProvider =
    StateNotifierProvider<GroupNotifier, GroupState>((ref) {
  return GroupNotifier(ref);
});
