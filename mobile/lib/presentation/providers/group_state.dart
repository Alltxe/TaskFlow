import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile/data/models/group.dart';

part 'group_state.freezed.dart';

@freezed
class GroupState with _$GroupState {
  const factory GroupState.initial() = GroupStateInitial;
  const factory GroupState.loading() = GroupStateLoading;
  const factory GroupState.loaded(List<Group> groups) = GroupStateLoaded;
  const factory GroupState.error(String message) = GroupStateError;
}
