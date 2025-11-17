import 'package:freezed_annotation/freezed_annotation.dart';

part 'group.freezed.dart';
part 'group.g.dart';

@freezed
class Group with _$Group {
  const factory Group({
    required String id,
    required String name,
    String? description,
    required String inviteToken,
    required bool requiresApproval,
    required String rotationType,
    required bool gamificationEnabled,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String createdById,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}
