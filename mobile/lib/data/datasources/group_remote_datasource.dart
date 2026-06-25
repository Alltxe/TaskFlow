import 'package:gql/language.dart' as gql_lang;
import 'package:gql_exec/gql_exec.dart';
import 'package:taskflow/core/config/graphql_client.dart';
import 'package:taskflow/core/errors/exceptions.dart' as app_exceptions;
import 'package:taskflow/data/models/create_group_request.dart';
import 'package:taskflow/data/models/group.dart';
import 'package:taskflow/data/models/group_member.dart';
import 'package:taskflow/data/models/group_preview.dart';
import 'package:taskflow/data/models/join_group_request.dart';
import 'package:taskflow/data/models/update_group_request.dart';

class GroupRemoteDataSource {
  GroupRemoteDataSource();

  // GraphQL Fragments
  static const String _groupFragment = r'''
    fragment GroupFields on GroupType {
      id
      name
      description
      inviteToken
      requiresApproval
      rotationType
      gamificationEnabled
      createdAt
      updatedAt
      createdById
    }
  ''';

  static const String _groupMemberUserFragment = r'''
    fragment GroupMemberUserFields on GroupMemberUserType {
      id
      username
      # email is not available on GroupMemberUserType in the backend schema
      avatarUrl
      isAway
      awayUntil
    }
  ''';

  static const String _groupMemberFragment = r'''
    fragment GroupMemberFields on GroupMemberType {
      id
      userId
      groupId
      role
      joinedAt
      roleChangedAt
      user {
        ...GroupMemberUserFields
      }
    }
  ''';

  Future<List<Group>> getUserGroups() async {
    const query = r'''
      query GetUserGroups {
        getUserGroups {
          ...GroupFields
        }
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query + _groupFragment),
          operationName: 'GetUserGroups',
        ),
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      final List<dynamic> groupsData = response.data?['getUserGroups'] ?? [];
      return groupsData.map((json) => Group.fromJson(json)).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(
        message: 'Failed to fetch user groups: ${e.toString()}',
      );
    }
  }

  Future<Group> getGroup(String groupId) async {
    const query = r'''
      query GetGroup($groupId: String!) {
        getGroup(groupId: $groupId) {
          ...GroupFields
        }
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query + _groupFragment),
          operationName: 'GetGroup',
        ),
        variables: {'groupId': groupId},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final groupData = response.data?['getGroup'];
      if (groupData == null) {
        throw const app_exceptions.ServerException(message: 'Group not found');
      }

      return Group.fromJson(groupData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to fetch group: ${e.toString()}');
    }
  }

  Future<GroupPreview> getGroupPreviewByInviteToken(String inviteToken) async {
    const query = r'''
      query GetGroupPreviewByInviteToken($inviteToken: String!) {
        getGroupPreviewByInviteToken(inviteToken: $inviteToken) {
          id
          name
          description
          memberCount
          requiresApproval
        }
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query),
          operationName: 'GetGroupPreviewByInviteToken',
        ),
        variables: {'inviteToken': inviteToken},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final data = response.data?['getGroupPreviewByInviteToken'];
      if (data == null) {
        throw const app_exceptions.ServerException(message: 'Invalid invite token');
      }

      return GroupPreview.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(
        message: 'Failed to fetch group preview: ${e.toString()}',
      );
    }
  }

  Future<List<GroupMember>> getGroupMembers(String groupId) async {
    const query = r'''
      query GetGroupMembers($groupId: String!) {
        getGroupMembers(groupId: $groupId) {
          ...GroupMemberFields
        }
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query + _groupMemberFragment + _groupMemberUserFragment),
          operationName: 'GetGroupMembers',
        ),
        variables: {'groupId': groupId},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final List<dynamic> membersData = response.data?['getGroupMembers'] ?? [];
      return membersData.map((json) => GroupMember.fromJson(json)).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(
        message: 'Failed to fetch group members: ${e.toString()}',
      );
    }
  }

  // Mutations

  Future<Group> createGroup(CreateGroupRequest request) async {
    const mutation = r'''
      mutation CreateGroup($input: CreateGroupInput!) {
        createGroup(input: $input) {
          ...GroupFields
        }
      }
    ''';

    try {
      final inputJson = request.toJson();
      print('[CreateGroup] Request JSON: $inputJson');

      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutation + _groupFragment),
          operationName: 'CreateGroup',
        ),
        variables: {'input': inputJson},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        print('[CreateGroup] GraphQL Errors: ${response.errors}');
        _handleGraphQLErrors(response.errors!);
      }

      final groupData = response.data?['createGroup'];
      if (groupData == null) {
        throw const app_exceptions.ServerException(message: 'Failed to create group');
      }

      return Group.fromJson(groupData);
    } catch (e) {
      print('[CreateGroup] Error: $e');
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to create group: ${e.toString()}');
    }
  }

  Future<Group> updateGroup(String groupId, UpdateGroupRequest request) async {
    const mutation = r'''
      mutation UpdateGroup($groupId: String!, $input: UpdateGroupInput!) {
        updateGroup(groupId: $groupId, input: $input) {
          ...GroupFields
        }
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutation + _groupFragment),
          operationName: 'UpdateGroup',
        ),
        variables: {'groupId': groupId, 'input': request.toJson()},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final groupData = response.data?['updateGroup'];
      if (groupData == null) {
        throw const app_exceptions.ServerException(message: 'Failed to update group');
      }

      return Group.fromJson(groupData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to update group: ${e.toString()}');
    }
  }

  Future<void> deleteGroup(String groupId) async {
    const mutation = r'''
      mutation DeleteGroup($groupId: String!) {
        deleteGroup(groupId: $groupId)
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutation),
          operationName: 'DeleteGroup',
        ),
        variables: {'groupId': groupId},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to delete group: ${e.toString()}');
    }
  }

  Future<Group> joinGroup(JoinGroupRequest request) async {
    const mutation = r'''
      mutation JoinGroup($input: JoinGroupInput!) {
        joinGroup(input: $input) {
          ...GroupFields
        }
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutation + _groupFragment),
          operationName: 'JoinGroup',
        ),
        variables: {'input': request.toJson()},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final groupData = response.data?['joinGroup'];
      if (groupData == null) {
        throw const app_exceptions.ServerException(message: 'Failed to join group');
      }

      return Group.fromJson(groupData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to join group: ${e.toString()}');
    }
  }

  Future<void> leaveGroup(String groupId) async {
    const mutation = r'''
      mutation LeaveGroup($groupId: String!) {
        leaveGroup(groupId: $groupId)
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(document: gql_lang.parseString(mutation), operationName: 'LeaveGroup'),
        variables: {'groupId': groupId},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to leave group: ${e.toString()}');
    }
  }

  Future<void> removeMember(String groupId, String userId) async {
    const mutation = r'''
      mutation RemoveMember($groupId: String!, $userId: String!) {
        removeMember(groupId: $groupId, userId: $userId)
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutation),
          operationName: 'RemoveMember',
        ),
        variables: {'groupId': groupId, 'userId': userId},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to remove member: ${e.toString()}');
    }
  }

  Future<GroupMember> updateMemberRole(String groupId, String userId, String role) async {
    const mutation = r'''
      mutation UpdateMemberRole($groupId: String!, $input: UpdateMemberRoleInput!) {
        updateMemberRole(groupId: $groupId, input: $input) {
          ...GroupMemberFields
        }
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(
            mutation + _groupMemberFragment + _groupMemberUserFragment,
          ),
          operationName: 'UpdateMemberRole',
        ),
        variables: {
          'groupId': groupId,
          'input': {'userId': userId, 'role': role},
        },
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final memberData = response.data?['updateMemberRole'];
      if (memberData == null) {
        throw const app_exceptions.ServerException(message: 'Failed to update member role');
      }

      return GroupMember.fromJson(memberData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(
        message: 'Failed to update member role: ${e.toString()}',
      );
    }
  }

  Future<Group> regenerateInviteToken(String groupId) async {
    const mutation = r'''
      mutation RegenerateInviteToken($groupId: String!) {
        regenerateInviteToken(groupId: $groupId) {
          ...GroupFields
        }
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutation + _groupFragment),
          operationName: 'RegenerateInviteToken',
        ),
        variables: {'groupId': groupId},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final groupData = response.data?['regenerateInviteToken'];
      if (groupData == null) {
        throw const app_exceptions.ServerException(message: 'Failed to regenerate invite token');
      }

      return Group.fromJson(groupData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(
        message: 'Failed to regenerate invite token: ${e.toString()}',
      );
    }
  }

  // Error handling

  void _handleGraphQLErrors(List<GraphQLError> errors) {
    if (errors.isEmpty) return;

    final error = errors.first;
    final message = error.message;
    final code = error.extensions?['code'] as String?;

    if (code == 'UNAUTHENTICATED' || code == 'FORBIDDEN') {
      throw app_exceptions.AuthException(message: message, code: code);
    } else if (code == 'VALIDATION_ERROR') {
      throw app_exceptions.ValidationException(message: message, code: code);
    } else {
      throw app_exceptions.ServerException(message: message, code: code);
    }
  }
}
