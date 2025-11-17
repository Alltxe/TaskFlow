import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/datasources/group_remote_datasource.dart';
import 'package:mobile/data/providers/graphql_provider.dart';
import 'package:mobile/data/repositories/group_repository.dart';
import 'package:mobile/data/repositories/group_repository_impl.dart';
import 'package:mobile/domain/usecases/group/get_groups_usecase.dart';
import 'package:mobile/domain/usecases/group/get_group_detail_usecase.dart';
import 'package:mobile/domain/usecases/group/get_group_members_usecase.dart';
import 'package:mobile/domain/usecases/group/create_group_usecase.dart';
import 'package:mobile/domain/usecases/group/update_group_usecase.dart';
import 'package:mobile/domain/usecases/group/delete_group_usecase.dart';
import 'package:mobile/domain/usecases/group/join_group_usecase.dart';
import 'package:mobile/domain/usecases/group/leave_group_usecase.dart';
import 'package:mobile/domain/usecases/group/remove_member_usecase.dart';
import 'package:mobile/domain/usecases/group/update_member_role_usecase.dart';
import 'package:mobile/domain/usecases/group/regenerate_invite_token_usecase.dart';

// DataSource Provider
final groupRemoteDataSourceProvider = Provider<GroupRemoteDataSource>((ref) {
  final graphQLClient = ref.watch(graphqlClientProvider);
  return GroupRemoteDataSource(graphQLClient);
});

// Repository Provider
final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  final remoteDataSource = ref.watch(groupRemoteDataSourceProvider);
  return GroupRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Use Case Providers
final getGroupsUseCaseProvider = Provider<GetGroupsUseCase>((ref) {
  final repository = ref.watch(groupRepositoryProvider);
  return GetGroupsUseCase(repository);
});

final getGroupDetailUseCaseProvider = Provider<GetGroupDetailUseCase>((ref) {
  final repository = ref.watch(groupRepositoryProvider);
  return GetGroupDetailUseCase(repository);
});

final getGroupMembersUseCaseProvider = Provider<GetGroupMembersUseCase>((ref) {
  final repository = ref.watch(groupRepositoryProvider);
  return GetGroupMembersUseCase(repository);
});

final createGroupUseCaseProvider = Provider<CreateGroupUseCase>((ref) {
  final repository = ref.watch(groupRepositoryProvider);
  return CreateGroupUseCase(repository);
});

final updateGroupUseCaseProvider = Provider<UpdateGroupUseCase>((ref) {
  final repository = ref.watch(groupRepositoryProvider);
  return UpdateGroupUseCase(repository);
});

final deleteGroupUseCaseProvider = Provider<DeleteGroupUseCase>((ref) {
  final repository = ref.watch(groupRepositoryProvider);
  return DeleteGroupUseCase(repository);
});

final joinGroupUseCaseProvider = Provider<JoinGroupUseCase>((ref) {
  final repository = ref.watch(groupRepositoryProvider);
  return JoinGroupUseCase(repository);
});

final leaveGroupUseCaseProvider = Provider<LeaveGroupUseCase>((ref) {
  final repository = ref.watch(groupRepositoryProvider);
  return LeaveGroupUseCase(repository);
});

final removeMemberUseCaseProvider = Provider<RemoveMemberUseCase>((ref) {
  final repository = ref.watch(groupRepositoryProvider);
  return RemoveMemberUseCase(repository);
});

final updateMemberRoleUseCaseProvider = Provider<UpdateMemberRoleUseCase>((ref) {
  final repository = ref.watch(groupRepositoryProvider);
  return UpdateMemberRoleUseCase(repository);
});

final regenerateInviteTokenUseCaseProvider =
    Provider<RegenerateInviteTokenUseCase>((ref) {
  final repository = ref.watch(groupRepositoryProvider);
  return RegenerateInviteTokenUseCase(repository);
});
