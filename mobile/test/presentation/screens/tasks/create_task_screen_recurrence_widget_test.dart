import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/auth_response.dart';
import 'package:taskflow/data/models/auth_tokens.dart';
import 'package:taskflow/data/models/create_group_request.dart';
import 'package:taskflow/data/models/create_task_request.dart';
import 'package:taskflow/data/models/group.dart';
import 'package:taskflow/data/models/group_member.dart';
import 'package:taskflow/data/models/join_group_request.dart';
import 'package:taskflow/data/models/login_request.dart';
import 'package:taskflow/data/models/register_request.dart';
import 'package:taskflow/data/models/task.dart';
import 'package:taskflow/data/models/update_group_request.dart';
import 'package:taskflow/data/models/update_task_request.dart';
import 'package:taskflow/data/models/user.dart';
import 'package:taskflow/data/providers/auth_providers.dart';
import 'package:taskflow/data/providers/group_providers.dart';
import 'package:taskflow/data/repositories/auth_repository.dart';
import 'package:taskflow/data/repositories/group_repository.dart';
import 'package:taskflow/data/repositories/task_repository.dart';
import 'package:taskflow/domain/usecases/group/get_group_members_usecase.dart';
import 'package:taskflow/domain/usecases/task/create_task_usecase.dart';
import 'package:taskflow/domain/usecases/task/task_usecase_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/screens/tasks/create_task_screen.dart';

class _CapturingTaskRepository implements TaskRepository {
  CreateTaskRequest? lastRequest;

  @override
  Future<dartz.Either<Failure, Task>> createTask(CreateTaskRequest request) async {
    lastRequest = request;
    return const dartz.Left(
      UnknownFailure(message: 'Intentional test error to keep screen open'),
    );
  }

  @override
  Future<dartz.Either<Failure, Task>> approveTask(
    String taskId,
    bool approved, {
    String? rejectionReason,
  }) {
    return Future.value(const dartz.Left(UnknownFailure(message: 'Not used')));
  }

  @override
  Future<dartz.Either<Failure, Task>> claimTask(String taskId) {
    return Future.value(const dartz.Left(UnknownFailure(message: 'Not used')));
  }

  @override
  Future<dartz.Either<Failure, Task>> completeTask(String taskId) {
    return Future.value(const dartz.Left(UnknownFailure(message: 'Not used')));
  }

  @override
  Future<dartz.Either<Failure, void>> deleteTask(String taskId) {
    return Future.value(const dartz.Left(UnknownFailure(message: 'Not used')));
  }

  @override
  Future<dartz.Either<Failure, List<Task>>> getGroupTasks(
    String groupId, {
    String? status,
  }) {
    return Future.value(const dartz.Left(UnknownFailure(message: 'Not used')));
  }

  @override
  Future<dartz.Either<Failure, List<Task>>> getRecurringTemplates(
    String groupId,
  ) {
    return Future.value(const dartz.Left(UnknownFailure(message: 'Not used')));
  }

  @override
  Future<dartz.Either<Failure, Task>> getTask(String taskId) {
    return Future.value(const dartz.Left(UnknownFailure(message: 'Not used')));
  }

  @override
  Future<dartz.Either<Failure, List<Task>>> getUserTasks({String? status}) {
    return Future.value(const dartz.Left(UnknownFailure(message: 'Not used')));
  }

  @override
  Future<dartz.Either<Failure, Task>> updateTask(
    String taskId,
    UpdateTaskRequest request,
  ) {
    return Future.value(const dartz.Left(UnknownFailure(message: 'Not used')));
  }
}

class _FakeAuthRepository implements AuthRepository {
  const _FakeAuthRepository(this.user);

  final User user;

  @override
  Future<User?> getCurrentUser() async => user;

  @override
  Future<bool> isAuthenticated() async => true;

  @override
  Future<void> logout() async {}

  @override
  Future<bool> needsTokenRefresh() async => false;

  @override
  Future<AuthTokens> refreshToken() {
    throw UnimplementedError();
  }

  @override
  Future<AuthResponse> login(LoginRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) {
    throw UnimplementedError();
  }
}

class _FakeGroupRepository implements GroupRepository {
  const _FakeGroupRepository(this.members);

  final List<GroupMember> members;

  @override
  Future<dartz.Either<Failure, List<GroupMember>>> getGroupMembers(
    String groupId,
  ) async => dartz.Right(members);

  @override
  Future<dartz.Either<Failure, Group>> createGroup(CreateGroupRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<dartz.Either<Failure, void>> deleteGroup(String groupId) {
    throw UnimplementedError();
  }

  @override
  Future<dartz.Either<Failure, Group>> getGroup(String groupId) {
    throw UnimplementedError();
  }

  @override
  Future<dartz.Either<Failure, List<Group>>> getUserGroups() {
    throw UnimplementedError();
  }

  @override
  Future<dartz.Either<Failure, Group>> joinGroup(JoinGroupRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<dartz.Either<Failure, void>> leaveGroup(String groupId) {
    throw UnimplementedError();
  }

  @override
  Future<dartz.Either<Failure, Group>> regenerateInviteToken(String groupId) {
    throw UnimplementedError();
  }

  @override
  Future<dartz.Either<Failure, void>> removeMember(String groupId, String userId) {
    throw UnimplementedError();
  }

  @override
  Future<dartz.Either<Failure, Group>> updateGroup(
    String groupId,
    UpdateGroupRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<dartz.Either<Failure, GroupMember>> updateMemberRole(
    String groupId,
    String userId,
    String role,
  ) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('CreateTaskScreen sends recurring task template payload', (
    tester,
  ) async {
    final initialDeadline = DateTime(2026, 3, 20, 10, 0);
    final taskRepository = _CapturingTaskRepository();
    final groupRepository = _FakeGroupRepository([
      GroupMember(
        id: 'gm-1',
        userId: 'u-admin',
        groupId: 'g1',
        role: 'ADMIN',
        joinedAt: DateTime(2026, 1, 1),
        roleChangedAt: DateTime(2026, 1, 1),
        user: const GroupMemberUser(id: 'u-admin', username: 'admin'),
      ),
    ]);
    const authRepository = _FakeAuthRepository(
      User(id: 'u-admin', email: 'admin@test.dev', username: 'admin'),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          getGroupMembersUseCaseProvider.overrideWithValue(
            GetGroupMembersUseCase(groupRepository),
          ),
          createTaskUseCaseProvider.overrideWithValue(
            CreateTaskUseCase(taskRepository),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: CreateTaskScreen(
            groupId: 'g1',
            initialDeadline: initialDeadline,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Recurring kitchen cleanup');

    final scrollable = find.byType(Scrollable).first;
    final recurringToggleText = find.text('Recurring template');
    await tester.scrollUntilVisible(recurringToggleText, 200, scrollable: scrollable);
    await tester.tap(recurringToggleText);
    await tester.pumpAndSettle();

    expect(find.text('Deadline'), findsNothing);
    expect(
      find.text(
        'For recurring templates, choose a relative deadline interval (day/week/month)',
      ),
      findsOneWidget,
    );

    expect(find.text('Deadline for each generated task'), findsOneWidget);

    final submitButton = find.byType(ElevatedButton);
    await tester.scrollUntilVisible(submitButton, 250, scrollable: scrollable);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(taskRepository.lastRequest, isNotNull);
    expect(taskRepository.lastRequest!.isRecurring, isTrue);
    expect(taskRepository.lastRequest!.recurrenceRule, 'FREQ=DAILY');
    final now = DateTime.now();
    final generatedDeadline = taskRepository.lastRequest!.deadline;
    expect(generatedDeadline.isAfter(now), isTrue);
    expect(
      generatedDeadline.isBefore(now.add(const Duration(days: 2))),
      isTrue,
    );
  });

  testWidgets('CreateTaskScreen uses temporary custom RRULE override for testing', (
    tester,
  ) async {
    final initialDeadline = DateTime(2026, 3, 20, 10, 0);
    final taskRepository = _CapturingTaskRepository();
    final groupRepository = _FakeGroupRepository([
      GroupMember(
        id: 'gm-1',
        userId: 'u-admin',
        groupId: 'g1',
        role: 'ADMIN',
        joinedAt: DateTime(2026, 1, 1),
        roleChangedAt: DateTime(2026, 1, 1),
        user: const GroupMemberUser(id: 'u-admin', username: 'admin'),
      ),
    ]);
    const authRepository = _FakeAuthRepository(
      User(id: 'u-admin', email: 'admin@test.dev', username: 'admin'),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          getGroupMembersUseCaseProvider.overrideWithValue(
            GetGroupMembersUseCase(groupRepository),
          ),
          createTaskUseCaseProvider.overrideWithValue(
            CreateTaskUseCase(taskRepository),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: CreateTaskScreen(
            groupId: 'g1',
            initialDeadline: initialDeadline,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'Recurring minute test',
    );

    final scrollable = find.byType(Scrollable).first;
    final recurringToggleText = find.text('Recurring template');
    await tester.scrollUntilVisible(
      recurringToggleText,
      200,
      scrollable: scrollable,
    );
    await tester.tap(recurringToggleText);
    await tester.pumpAndSettle();

    final customRuleField = find.widgetWithText(
      TextFormField,
      'Temporary test RRULE (optional)',
    );
    await tester.scrollUntilVisible(customRuleField, 200, scrollable: scrollable);
    await tester.enterText(customRuleField, 'FREQ=MINUTELY;INTERVAL=1');

    final submitButton = find.byType(ElevatedButton);
    await tester.scrollUntilVisible(submitButton, 250, scrollable: scrollable);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(taskRepository.lastRequest, isNotNull);
    expect(taskRepository.lastRequest!.isRecurring, isTrue);
    expect(taskRepository.lastRequest!.recurrenceRule, 'FREQ=MINUTELY;INTERVAL=1');
  });
}
