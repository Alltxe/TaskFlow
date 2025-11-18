import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_member.freezed.dart';
part 'group_member.g.dart';

@freezed
class GroupMemberUser with _$GroupMemberUser {
  const factory GroupMemberUser({
    required String id,
    required String username,
    String? avatarUrl,
    @Default(false) bool isAway,
    DateTime? awayUntil,
  }) = _GroupMemberUser;

  factory GroupMemberUser.fromJson(Map<String, dynamic> json) => _$GroupMemberUserFromJson(json);
}

@freezed
class GroupMember with _$GroupMember {
  const factory GroupMember({
    required String id,
    required String userId,
    required String groupId,
    required String role,
    required DateTime joinedAt,
    required DateTime roleChangedAt,
    required GroupMemberUser user,
  }) = _GroupMember;

  factory GroupMember.fromJson(Map<String, dynamic> json) => _$GroupMemberFromJson(json);
}
