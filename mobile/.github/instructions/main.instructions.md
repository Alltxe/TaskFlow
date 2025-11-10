---
applyTo: '**'
---

# LLM Development Instructions - CLEAR Framework (TaskFlow Mobile)

## Context: Understanding Before Acting

**ALWAYS** gather context before making changes:

1. **Consult PRD First**: Check `.docs/PRD.md` for mobile app requirements, business rules, and UI/UX specifications
2. **Review Roadmap**: Check `.docs/ROADMAP.md` for current phase, completed features, and planned mobile features
3. **Check Backend API**: Review `backend.docs/API_DOCUMENTATION.md` for GraphQL schema and available endpoints
4. **Read Related Files**: Use `read_file` or `semantic_search` to understand existing patterns
5. **Check Dependencies**: Identify package dependencies in `pubspec.yaml`
6. **Review Similar Code**: Look for existing implementations to maintain consistency
7. **Understand State Management**: Trace how data flows through widgets and state management
8. **Consult Flutter Documentation**: When unsure about Flutter/Dart APIs or widget patterns

**Never assume** - if you're unsure about existing code structure, search for it first.

### Critical Documentation Files

**MUST READ** before making changes to core functionality:

- **`.docs/PRD.md`** (Mobile Product Requirements Document)
  - Source of truth for mobile app requirements and UI/UX specifications
  - Defines user flows, screen layouts, and interaction patterns
  - Specifies functional requirements for all mobile features
  - Contains mobile-specific business rules and validations
  - Performance requirements (app startup, response times, offline mode)
  - **Use this to validate**: "Does this mobile implementation align with PRD requirements?"

- **`.docs/ROADMAP.md`** (Mobile Development Roadmap)
  - Current mobile development phase and completion status
  - Recently completed screens and features
  - Planned features and their implementation order
  - Testing status and known issues
  - **Use this to understand**: "Is this feature completed, in progress, or planned?"

- **`backend.docs/API_DOCUMENTATION.md`** (Backend API Documentation)
  - Complete GraphQL schema reference (shared with backend)
  - Available queries, mutations, and subscriptions
  - Authentication requirements and token handling
  - Error response formats
  - **Use this to verify**: "Does the backend API support this feature?"

- **`backend.docs/PRD.md`** (Backend Product Requirements - Reference Only)
  - Backend business logic and data model definitions
  - Useful for understanding server-side validation rules
  - Reference when mobile PRD refers to backend behavior
  - **Use this when**: Mobile PRD references backend features or data structures

**Never assume** - if you're unsure about existing code structure, search for it first.

### Project Architecture Overview

This is a **Flutter mobile application** with the following planned structure:

```
lib/
├── main.dart                  # Application entry point
├── core/
│   ├── config/               # App configuration (API URLs, constants)
│   ├── constants/            # App-wide constants
│   ├── theme/                # Material theme configuration
│   ├── router/               # Navigation configuration (go_router)
│   └── utils/                # Utility functions and helpers
├── data/
│   ├── models/               # Data models (from GraphQL schema)
│   ├── repositories/         # Data repositories (GraphQL client)
│   └── providers/            # API service providers
├── domain/
│   ├── entities/             # Business entities
│   └── usecases/             # Business logic use cases
├── presentation/
│   ├── screens/              # Full-screen pages
│   ├── widgets/              # Reusable widgets
│   ├── providers/            # Riverpod state providers
│   └── theme/                # UI theme components
└── l10n/                     # Internationalization (i18n)
    ├── app_en.arb           # English translations
    └── app_ru.arb           # Russian translations
```

**⚠️ IMPORTANT**: This structure represents the **planned state**. The current mobile app is a basic Flutter template.

**Planned but NOT YET IMPLEMENTED**:
- ⏳ **GraphQL Client Setup** - Apollo/Graphql_flutter integration
- ⏳ **Authentication Flow** - JWT token management, login/register screens
- ⏳ **State Management** - Riverpod providers setup
- ⏳ **Navigation** - go_router configuration
- ⏳ **Data Models** - GraphQL code generation
- ⏳ **UI Screens** - All feature screens (tasks, groups, profile, etc.)
- ⏳ **Offline Support** - Local caching with Hive/Isar
- ⏳ **Push Notifications** - Firebase Cloud Messaging

**Before adding new features**:
1. Check if backend API endpoint exists in `backend.docs/API_DOCUMENTATION.md`
2. Verify feature is not already planned in `.docs/PRD.md` or `.docs/ROADMAP.md`
3. Consult `.docs/PRD.md` for mobile requirements and UI specifications
4. Reference `backend.docs/PRD.md` if understanding backend business logic
5. Check `backend.docs/DEVELOPMENT_ROADMAP.md` for backend API readiness

### Complete Mobile App Features (from PRD)

The mobile app must implement the following screens and features:

**Authentication Screens**:
- **Login Screen** - Email/password authentication with JWT tokens
- **Register Screen** - User registration with validation
- **Password Reset** - Forgot password flow (if backend supports)

**Main Screens** (Bottom Navigation):
- **Tasks Screen** - View assigned tasks, Up-for-Grabs pool, task details
- **Groups Screen** - List user's groups, group details, member list
- **Rewards Screen** - Reward catalog, redemption history, point balance
- **Profile Screen** - User profile, statistics, settings

**Secondary Screens**:
- **Task Details** - Task information, completion flow, attachment upload
- **Task Completion** - Mark complete, add proof, submit for approval
- **Group Details** - Group settings (admin), member list, rotation schedule
- **Create/Edit Group** - Group configuration (admin only)
- **Invite Members** - Generate invite links (admin only)
- **Reward Details** - Reward information, redemption flow
- **Leaderboard** - Group rankings, user statistics
- **Notifications** - Push notification list, settings

**Key Features to Implement**:
1. **JWT Authentication** (PRD Section 3.1.1)
   - Secure token storage (flutter_secure_storage)
   - Automatic token refresh
   - Logout and session management

2. **Task Management** (PRD Section 3.3)
   - Display assigned tasks with priority and deadline
   - Task completion flow with photo upload
   - Up-for-Grabs task pool
   - Task filtering and sorting

3. **Group Management** (PRD Section 3.2)
   - Join group via invite link
   - View group members and roles
   - Admin controls (create/edit/delete group)
   - Leave group functionality

4. **Gamification** (PRD Section 3.5)
   - Display point balance
   - Reward catalog browsing
   - Point redemption flow
   - Leaderboard with rankings

5. **Rotation System** (PRD Section 3.4)
   - Display next executor schedule
   - Mark as "Away" to skip rotation
   - View rotation history

6. **Notifications** (PRD Section 3.6)
   - Push notifications for task assignments
   - Deadline reminders
   - Approval notifications
   - Notification preferences

**Critical Business Rules** (from PRD Section 7):
1. **Point Calculation** (PRD 7.2.1):
   - `Points = BaseScore × Multiplier`
   - On-time: 1.0x, Late: 0.5x, Up-for-Grabs: 1.5x, Rejected/Overdue: 0.0x
   
2. **Task State UI** (PRD 3.3.4):
   - Created → Assigned → In Progress → Awaiting Approval → Completed/Rejected
   - Any state → Overdue (if deadline passed)
   - UI must reflect current task state with appropriate colors/icons
   
3. **Permission Enforcement** (PRD 2.2):
   - Hide/disable admin features for non-admin users
   - Validate permissions client-side before API calls
   - Display appropriate error messages for unauthorized actions

### Key Technologies & Patterns

- **Framework**: Flutter 3.x with Dart 3.x
- **State Management**: Riverpod (recommended) or Provider
- **Navigation**: go_router
- **GraphQL Client**: graphql_flutter or ferry (code generation)
- **Local Storage**: flutter_secure_storage (tokens), Hive/Isar (caching)
- **Notifications**: firebase_messaging
- **Image Handling**: image_picker, cached_network_image
- **Internationalization**: flutter_localizations, intl
- **Testing**: flutter_test (widget tests), integration_test (e2e tests)

### Common Patterns in Flutter Projects

#### Screen Structure (Feature-First)
```
presentation/screens/tasks/
├── tasks_screen.dart              # Main screen widget
├── widgets/
│   ├── task_list_item.dart        # Reusable task card
│   ├── task_filter_bar.dart       # Filter UI component
│   └── empty_tasks_placeholder.dart
└── providers/
    └── tasks_provider.dart        # Riverpod state provider
```

#### Widget Pattern (StatelessWidget with Riverpod)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: tasksAsync.when(
        data: (tasks) => TaskListView(tasks: tasks),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorWidget(error: error),
      ),
    );
  }
}
```

#### Riverpod Provider Pattern
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/models/task.dart';

// Repository provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.read(graphQLClientProvider));
});

// Tasks provider (auto-refresh)
final tasksProvider = FutureProvider<List<Task>>((ref) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getMyTasks();
});

// Task detail provider (with parameter)
final taskDetailProvider = FutureProvider.family<Task, String>((ref, taskId) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getTaskById(taskId);
});
```

#### GraphQL Repository Pattern
```dart
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/task.dart';

class TaskRepository {
  final GraphQLClient client;

  TaskRepository(this.client);

  Future<List<Task>> getMyTasks() async {
    const query = r'''
      query GetMyTasks {
        myTasks {
          id
          title
          description
          priority
          deadline
          status
          points
          assignee {
            id
            username
          }
        }
      }
    ''';

    final result = await client.query(QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.networkOnly,
    ));

    if (result.hasException) {
      throw result.exception!;
    }

    final List<dynamic> tasksJson = result.data?['myTasks'] ?? [];
    return tasksJson.map((json) => Task.fromJson(json)).toList();
  }

  Future<Task> completeTask(String taskId, {String? comment, List<String>? attachments}) async {
    const mutation = r'''
      mutation CompleteTask($input: CompleteTaskInput!) {
        completeTask(input: $input) {
          id
          status
          completedAt
        }
      }
    ''';

    final result = await client.mutate(MutationOptions(
      document: gql(mutation),
      variables: {
        'input': {
          'taskId': taskId,
          'comment': comment,
          'attachments': attachments,
        },
      },
    ));

    if (result.hasException) {
      throw result.exception!;
    }

    return Task.fromJson(result.data!['completeTask']);
  }
}
```

#### Data Model Pattern (from GraphQL)
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    String? description,
    required TaskPriority priority,
    required DateTime deadline,
    required TaskStatus status,
    required int points,
    User? assignee,
    DateTime? completedAt,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}

enum TaskStatus {
  @JsonValue('CREATED') created,
  @JsonValue('ASSIGNED') assigned,
  @JsonValue('IN_PROGRESS') inProgress,
  @JsonValue('AWAITING_APPROVAL') awaitingApproval,
  @JsonValue('COMPLETED') completed,
  @JsonValue('REJECTED') rejected,
  @JsonValue('OVERDUE') overdue,
}

enum TaskPriority {
  @JsonValue('LOW') low,
  @JsonValue('MEDIUM') medium,
  @JsonValue('HIGH') high,
  @JsonValue('CRITICAL') critical,
}
```

### When to Consult Documentation

**Mobile PRD Documentation** (`.docs/PRD.md`):
- ✅ **UI/UX specifications** - "What should this screen look like?"
- ✅ **User interaction flows** - "How should the user navigate through this feature?"
- ✅ **Mobile-specific business rules** - "What validations should happen on the client side?"
- ✅ **Screen layouts and components** - "What widgets and components are required?"
- ✅ **Performance requirements** - "What are the response time and loading expectations?"
- ✅ **Offline behavior** - "What should work without internet connection?"
- ✅ **Permission UI handling** - "How should admin vs. participant features be displayed?"

**Mobile Roadmap Documentation** (`.docs/ROADMAP.md`):
- ✅ **Current phase understanding** - What's completed, in-progress, or planned?
- ✅ **Known issues** - Don't fix what's already documented as technical debt
- ✅ **Feature dependencies** - Some features require others to be completed first
- ✅ **Testing status** - What test coverage exists for each screen?
- ✅ **Recent changes** - What was fixed/added recently?

**Backend API Documentation** (`backend.docs/API_DOCUMENTATION.md`):
- ✅ **Available endpoints** - What queries/mutations exist?
- ✅ **Request/Response formats** - Exact GraphQL schema
- ✅ **Authentication headers** - How to pass JWT tokens
- ✅ **Error handling** - Expected error response formats
- ✅ **API readiness** - Is the endpoint implemented and tested?

**Backend PRD** (`backend.docs/PRD.md` - Reference Only):
- ✅ **Data model understanding** - Entity relationships and constraints
- ✅ **Server-side validation rules** - What validations happen on backend
- ✅ **Business logic formulas** - e.g., point calculation, rotation algorithms
- ✅ **Permission matrix** - What backend enforces (complement client-side checks)

**Flutter Official Docs**:
- ✅ Widget composition and lifecycle
- ✅ State management patterns
- ✅ Navigation and routing
- ✅ Platform-specific code (iOS/Android)
- ✅ Asset management and localization
- ✅ Testing strategies

**Example Workflow**:
```
User asks: "Add a screen to exchange points for rewards"

1. CHECK MOBILE PRD (.docs/PRD.md):
   - Section: Rewards Screen specification
   - UI Layout: Grid view of rewards with images and point costs
   - User Flow: Tap reward → Show detail → Confirm redemption → Show pending status
   - Client Validation: Check user has enough points before allowing redemption
   - Offline Behavior: Can browse catalog offline, must be online to redeem

2. CHECK MOBILE ROADMAP (.docs/ROADMAP.md):
   - Phase X: Gamification Features
   - Status: Rewards catalog screen (completed/in-progress/planned)
   - Dependencies: Points display widget must be implemented first

3. CHECK BACKEND API (backend.docs/API_DOCUMENTATION.md):
   - Query: getUserRewards, getRewardCatalog
   - Mutation: requestReward
   - Verify endpoints are implemented and ready

4. (Optional) CHECK BACKEND PRD (backend.docs/PRD.md):
   - Section 3.5.4: Backend approval workflow
   - Understand server-side state transitions (Requested → Approved/Rejected)
   - This helps design mobile UI to reflect approval states

5. PLAN: Implement according to Mobile PRD specification
   - Create RewardsScreen with catalog grid (as per mobile PRD layout)
   - Create RewardDetailScreen with redemption flow
   - Add point balance widget in AppBar
   - Handle pending/approved/rejected states with appropriate UI
   - Show loading states and error messages (mobile PRD UX guidelines)
```

## List: Task Decomposition Strategy

### When to Use Todo Lists

Use the `manage_todo_list` tool for ANY task that involves **2 or more distinct steps**:

- ✅ Adding a new screen with providers + widgets + navigation
- ✅ Implementing GraphQL client setup with code generation
- ✅ Setting up state management with Riverpod
- ✅ Creating authentication flow with token storage
- ✅ Implementing new feature with multiple screens
- ✅ Debugging UI issues requiring investigation + fix

**DO NOT** use todo lists for:
- ❌ Single widget edits
- ❌ Simple questions or explanations
- ❌ Reading files or searching code

### Todo List Structure

Break down tasks into **atomic, actionable items**:

```markdown
1. [NOT-STARTED] Setup GraphQL client
   - Add graphql_flutter dependency to pubspec.yaml
   - Create GraphQLClientProvider in core/providers/
   - Configure HttpLink with backend API URL
   - Setup AuthLink for JWT token injection
   - Test connection with simple query

2. [IN-PROGRESS] Create authentication data layer
   - Create User model in data/models/user.dart
   - Create AuthRepository in data/repositories/auth_repository.dart
   - Implement login(), register(), refreshToken() methods
   - Add token storage with flutter_secure_storage

3. [NOT-STARTED] Implement authentication providers
   - Create authProvider in presentation/providers/auth_provider.dart
   - Add authStateProvider to track login status
   - Implement logout functionality
   - Handle token refresh on 401 errors

4. [NOT-STARTED] Build login screen UI
   - Create LoginScreen in presentation/screens/auth/login_screen.dart
   - Add email and password TextFormFields
   - Add form validation (class-validator patterns)
   - Wire up authProvider.login() method
   - Add loading state and error handling

5. [NOT-STARTED] Build register screen UI
   - Create RegisterScreen in presentation/screens/auth/register_screen.dart
   - Add email, password, confirmPassword fields
   - Implement validation according to PRD requirements
   - Wire up authProvider.register() method

6. [NOT-STARTED] Setup navigation
   - Add go_router dependency to pubspec.yaml
   - Create router configuration in core/router/app_router.dart
   - Define routes: /login, /register, /home, /tasks, etc.
   - Add authentication guard (redirect to /login if not authenticated)

7. [NOT-STARTED] Write tests
   - Widget tests: login_screen_test.dart, register_screen_test.dart
   - Integration tests: test/integration/auth_flow_test.dart
   - Run: flutter test
```

### Todo Workflow Rules

1. **Write todos FIRST** before starting work (use `manage_todo_list` with operation="write")
2. **Mark ONE todo as in-progress** before working on it
3. **Complete the work** for that specific todo
4. **Mark completed IMMEDIATELY** after finishing
5. **Move to next todo** - repeat the cycle

**CRITICAL**: Update todo status in real-time, don't batch completions.

## Explain: Communication Standards

### Before Taking Action

Always explain **what you're about to do and why**, **referencing Mobile PRD sections**:

```
I'll implement the task completion screen. According to Mobile PRD Section X.Y:

UI Specification:
- Full-screen modal with task details at top
- Optional comment TextField (max 500 characters)
- Photo upload section (up to 3 images, as per PRD requirement)
- Primary action button: "Submit for Approval" or "Mark Complete" (based on group settings)
- Cancel button in AppBar

This involves:
1. Creating TaskCompletionScreen widget
   - Display task details (title, description, points)
   - Add optional comment TextFormField with character counter
   - Add photo upload button (up to 3 images - Mobile PRD requirement)
   - Add "Submit for Approval" button (if group.requiresApproval)
   - Add "Mark Complete" button (if !requiresApproval)

2. Creating TaskCompletionProvider
   - Handle image selection with image_picker
   - Upload images to backend (via GraphQL mutation)
   - Call completeTask mutation with comment and attachments
   - Handle success/error states

3. Implementing state transitions (Mobile PRD Section X.Y):
   - IN_PROGRESS → AWAITING_APPROVAL (if approval required)
   - IN_PROGRESS → COMPLETED (if no approval required)
   - Show success snackbar with points earned
   - Navigate back to tasks list with refresh

This follows Mobile PRD Section X.Y UI specification and UX flow.
Backend API: completeTask mutation (verified in backend.docs/API_DOCUMENTATION.md).
```

### After Completing Tasks

Summarize **what was done and next steps**, **referencing Mobile PRD compliance**:

```
✅ Completed:
- Implemented TaskCompletionScreen with comment and photo upload
- Created TaskCompletionProvider with image selection logic
- Added completeTask GraphQL mutation call
- Implemented state transitions (Mobile PRD Section X.Y)
- Added validation for required fields
- Tested on Android emulator

📋 Mobile PRD Compliance:
- ✅ Up to 3 photo attachments (Mobile PRD Section X.Y)
- ✅ Optional completion comment with 500 char limit (Mobile PRD)
- ✅ Approval flow UI if required (Mobile PRD UX spec)
- ✅ Success feedback with points earned display (Mobile PRD)
- ✅ Loading states and error messages (Mobile PRD UX guidelines)

🔗 Backend Integration:
- ✅ completeTask mutation (verified in backend.docs/API_DOCUMENTATION.md)
- ✅ Error handling for network failures
- ✅ Token refresh on 401 errors

📝 Next steps:
- Test on iOS device
- Add widget tests for TaskCompletionScreen
- Implement photo preview before submission
- Add offline support (cache completion, sync later - per Mobile PRD offline requirements)
```

### Error Reporting

When encountering errors:
1. **State the error clearly** with relevant stack trace
2. **Explain what you tried** and why it failed
3. **Check Mobile PRD/Roadmap** - is this a known issue or missing feature?
4. **Check Backend API docs** - is this a missing backend feature?
5. **Propose solutions** based on Mobile PRD specifications
6. **Update todos** to reflect blocking issues

Example:
```
❌ Error encountered in step 3:

GraphQL Exception: Field 'completeTask' not found in schema

Context: Attempting to submit task completion (Mobile PRD Section X.Y)

Root cause: Backend API may not have implemented this mutation yet

Checked: 
- Mobile PRD Section X.Y - feature is specified and required
- backend.docs/API_DOCUMENTATION.md - mutation is documented
- backend.docs/DEVELOPMENT_ROADMAP.md - backend Phase 4 status

Hypothesis: Backend Phase 4 (Task Management) may not be fully deployed

Proposed solutions:
1. Verify backend is running latest version
2. Contact backend team about API readiness
3. If backend incomplete, implement UI mockup with local state
4. Add TODO comment: "Waiting for backend Phase 4 completion"
5. Update Mobile Roadmap with dependency blocker

Waiting for backend status confirmation before proceeding...
```

## Actionable: Execution Guidelines

### File Operations

**Creating Files**:
- Use absolute paths: `c:\projects\TaskFlow\mobile\lib\presentation\screens\...`
- Follow feature-first or layer-first structure conventions
- Include necessary imports and package references
- Use proper Dart/Flutter naming conventions (snake_case for files, PascalCase for classes)

**Editing Files**:
- Use `replace_string_in_file` with 3-5 lines of context
- Preserve exact whitespace and indentation
- Never use placeholders like `...existing code...`

**Example of Good Edit**:
```dart
// ✅ Good - includes context
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) => TaskListView(tasks: tasks),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorWidget(error: error.toString()),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    // TODO: Implement filter dialog
  }
}
```

### Terminal Commands

**Always use PowerShell syntax**:
```powershell
# ✅ Correct
flutter pub get
flutter run
flutter test
flutter build apk

# ❌ Wrong (bash syntax)
flutter pub get && flutter run
cd lib && ls
```

**Set isBackground=true for**:
- Development server (`flutter run`)
- Test watch mode (`flutter test --watch`)
- Long-running processes

**Set isBackground=false for**:
- Package installation (`flutter pub get`)
- One-time tests (`flutter test`)
- Build commands (`flutter build apk`)
- Code generation (`dart run build_runner build`)

### Flutter/Dart Specific Actions

#### Adding a New Screen

1. **Create screen file**:
   ```dart
   // lib/presentation/screens/tasks/tasks_screen.dart
   import 'package:flutter/material.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';

   class TasksScreen extends ConsumerWidget {
     const TasksScreen({super.key});

     @override
     Widget build(BuildContext context, WidgetRef ref) {
       return Scaffold(
         appBar: AppBar(title: const Text('Tasks')),
         body: const Center(child: Text('Tasks Screen')),
       );
     }
   }
   ```

2. **Add to router** (go_router):
   ```dart
   // lib/core/router/app_router.dart
   final appRouter = GoRouter(
     routes: [
       GoRoute(
         path: '/tasks',
         builder: (context, state) => const TasksScreen(),
       ),
       // ... other routes
     ],
   );
   ```

3. **Add navigation** (from another screen):
   ```dart
   onPressed: () => context.go('/tasks'),
   ```

#### Creating Riverpod Providers

**State Provider** (simple state):
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final counterProvider = StateProvider<int>((ref) => 0);

// Usage in widget:
final count = ref.watch(counterProvider);
ref.read(counterProvider.notifier).state++;
```

**Future Provider** (async data):
```dart
final tasksProvider = FutureProvider<List<Task>>((ref) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getMyTasks();
});

// Usage in widget:
final tasksAsync = ref.watch(tasksProvider);
tasksAsync.when(
  data: (tasks) => ListView(...),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

**StateNotifier Provider** (complex state):
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskFilterState {
  final TaskStatus? status;
  final TaskPriority? priority;

  TaskFilterState({this.status, this.priority});

  TaskFilterState copyWith({
    TaskStatus? status,
    TaskPriority? priority,
  }) {
    return TaskFilterState(
      status: status ?? this.status,
      priority: priority ?? this.priority,
    );
  }
}

class TaskFilterNotifier extends StateNotifier<TaskFilterState> {
  TaskFilterNotifier() : super(TaskFilterState());

  void setStatus(TaskStatus? status) {
    state = state.copyWith(status: status);
  }

  void setPriority(TaskPriority? priority) {
    state = state.copyWith(priority: priority);
  }

  void reset() {
    state = TaskFilterState();
  }
}

final taskFilterProvider = StateNotifierProvider<TaskFilterNotifier, TaskFilterState>(
  (ref) => TaskFilterNotifier(),
);
```

#### Implementing GraphQL Mutations

```dart
// In repository
Future<Task> completeTask(String taskId, {String? comment}) async {
  const mutation = r'''
    mutation CompleteTask($input: CompleteTaskInput!) {
      completeTask(input: $input) {
        id
        status
        completedAt
        points
      }
    }
  ''';

  final result = await client.mutate(MutationOptions(
    document: gql(mutation),
    variables: {
      'input': {
        'taskId': taskId,
        'comment': comment,
      },
    },
  ));

  if (result.hasException) {
    if (result.exception!.graphqlErrors.isNotEmpty) {
      throw result.exception!.graphqlErrors.first.message;
    }
    throw 'Failed to complete task';
  }

  return Task.fromJson(result.data!['completeTask']);
}
```

#### Working with Forms and Validation

```dart
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) {
                return 'Invalid email format';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Submit form
                final email = _emailController.text;
                final password = _passwordController.text;
                // Call login mutation
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
```

#### Image Picking and Upload

```dart
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageUploadWidget extends StatefulWidget {
  const ImageUploadWidget({super.key});

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null && _images.length < 3) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          children: _images.map((image) {
            return Stack(
              children: [
                Image.file(image, width: 100, height: 100, fit: BoxFit.cover),
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _images.remove(image);
                      });
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        if (_images.length < 3)
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Add Photo'),
          ),
      ],
    );
  }
}
```

## Realistic: Validation & Testing

### Pre-Execution Checks

Before running code:
1. **Verify imports** - Check that all packages exist in `pubspec.yaml`
2. **Check dependencies** - Run `flutter pub get` if packages changed
3. **Validate paths** - Confirm files exist at expected locations
4. **Review types** - Ensure data models match GraphQL schema
5. **Check backend API** - Verify endpoint exists in API documentation

### Post-Execution Validation

After making changes:
1. **Check for errors**: Use `get_errors` to verify no Dart analyzer errors
2. **Hot reload**: Test changes with `r` in Flutter run console
3. **Test on device**: Verify UI renders correctly on emulator/device
4. **Verify navigation**: Check routing works as expected
5. **Test API calls**: Verify GraphQL queries/mutations succeed

### Testing Strategy

For significant changes:
```powershell
# Run tests
flutter test                          # All unit/widget tests
flutter test --watch                  # Watch mode for TDD
flutter test --coverage               # With coverage report
flutter test test/specific_test.dart  # Specific test file

# Integration tests
flutter test integration_test/        # E2E tests (requires device/emulator)

# Code generation (if using freezed/json_serializable)
dart run build_runner build           # Generate code
dart run build_runner watch           # Watch mode
```

### Widget Testing Pattern

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('LoginScreen displays email and password fields', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify UI elements
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('LoginScreen shows error on invalid email', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Enter invalid email
    await tester.enterText(find.byType(TextFormField).first, 'invalid');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify error message
    expect(find.text('Invalid email format'), findsOneWidget);
  });
}
```

## Common Task Patterns

### Pattern: Adding a New Feature Screen

```
1. [Context] 
   - READ .docs/PRD.md Section X for mobile feature requirements and UI specification
   - READ backend.docs/API_DOCUMENTATION.md for GraphQL schema
   - Check if backend API endpoint exists and is ready
   - Search for similar screens (e.g., tasks_screen.dart) for patterns
   - Read existing navigation setup in app_router.dart
   - Check .docs/ROADMAP.md for feature status and dependencies
   
2. [List] Create todo list based on Mobile PRD requirements:
   - Create data model matching GraphQL schema (with freezed/json_serializable)
   - Create repository with GraphQL queries/mutations
   - Create Riverpod provider for state management
   - Create screen widget with UI layout (as per Mobile PRD design spec)
   - Create child widgets (list items, forms, dialogs, etc.)
   - Add navigation route in app_router.dart
   - Implement loading/error states (per Mobile PRD UX guidelines)
   - Add form validation matching Mobile PRD constraints
   - Write widget tests
   
3. [Explain] 
   - Describe approach: "Implementing [Feature] screen according to Mobile PRD Section X"
   - Explain UI design decisions and Mobile PRD compliance
   - Reference backend API availability
   
4. [Actionable] 
   - Follow feature-first or layer-first structure conventions
   - Use ConsumerWidget for Riverpod integration
   - Implement permission checks (hide admin features for non-admins per Mobile PRD)
   - Apply Material Design 3 theming (Mobile PRD design system)
   - Handle authentication errors (redirect to login on 401)
   - Write widget tests covering user interactions
   
5. [Realistic] 
   - Run `flutter test`
   - Test on Android emulator
   - Test on iOS simulator (if available)
   - Verify navigation flow
   - Check GraphQL API calls succeed
   - Validate against Mobile PRD UI specification
```
   - Write widget tests
   
3. [Explain] 
   - Describe approach: "Implementing [Feature] screen according to PRD Section X.Y"
   - Explain UI design decisions and PRD compliance
   
4. [Actionable] 
   - Follow feature-first or layer-first structure conventions
   - Use ConsumerWidget for Riverpod integration
   - Implement permission checks (hide admin features for non-admins)
   - Apply Material Design 3 theming
   - Handle authentication errors (redirect to login on 401)
   - Write widget tests covering user interactions
   
5. [Realistic] 
   - Run `flutter test`
   - Test on Android emulator
   - Test on iOS simulator (if available)
   - Verify navigation flow
   - Check GraphQL API calls succeed
```

### Pattern: Setting Up GraphQL Client

```
1. [Context] 
   - READ backend.docs/API_DOCUMENTATION.md for endpoint and schema
   - Check existing graphql_flutter setup
   - Understand authentication requirements (JWT tokens)
   
2. [List] Plan setup steps:
   - Add graphql_flutter dependency to pubspec.yaml
   - Create GraphQLClientProvider in core/providers/
   - Configure HttpLink with backend URL
   - Add AuthLink for JWT token injection
   - Setup cache (InMemoryCache)
   - Test with simple query
   - Add error handling and retry logic
   
3. [Explain] 
   - Document GraphQL client configuration
   - Justify cache strategy
   
4. [Actionable]
   - Run: flutter pub get
   - Create provider file
   - Configure links in chain (AuthLink → HttpLink)
   - Add token refresh interceptor
   
5. [Realistic]
   - Test connection with GraphQL playground
   - Verify authentication works
   - Check error handling (network errors, GraphQL errors)
```

### Pattern: Implementing Authentication Flow

```
1. [Context]
   - READ .docs/PRD.md Section X for mobile auth flow requirements
   - READ backend.docs/API_DOCUMENTATION.md for login/register mutations
   - Check existing token storage setup
   - Review JWT token structure and refresh mechanism
   
2. [List] Implementation steps:
   - Add flutter_secure_storage dependency
   - Create User model (freezed)
   - Create AuthRepository with login/register/refresh methods
   - Create AuthProvider (StateNotifier)
   - Create LoginScreen with form validation (per Mobile PRD)
   - Create RegisterScreen
   - Implement token storage (secure_storage)
   - Add token refresh logic
   - Setup navigation guard (redirect to /login if unauthenticated)
   - Write tests
   
3. [Explain] Document auth flow and security measures
4. [Actionable]
   - Follow Flutter secure storage best practices
   - Implement automatic token refresh
   - Handle logout and token expiration
   
5. [Realistic]
   - Test login/register flow
   - Verify token storage works
   - Test token refresh on 401 errors
   - Test logout clears tokens
```

### Pattern: Adding Offline Support

```
1. [Context]
   - Understand which data needs offline caching (Mobile PRD Section X)
   - Check existing local storage setup
   - Review Hive/Isar documentation
   - Check existing local storage setup
   - Review Hive/Isar documentation
   
2. [List] Offline support steps:
   - Add hive/isar dependency
   - Create local database models
   - Create local storage repository
   - Implement cache-first fetch policy
   - Add sync queue for offline mutations
   - Add connectivity listener
   - Implement background sync
   - Update UI to show offline indicator
   
3. [Explain] Document caching strategy and sync logic
4. [Actionable]
   - Use appropriate fetch policy (cache-first for reads)
   - Queue mutations when offline
   - Sync on connectivity restore
   
5. [Realistic]
   - Test offline mode
   - Verify data persists
   - Test sync on reconnection
```

## Error Recovery

If a task fails:
1. **Update todo status** to reflect blocker
2. **Explain what went wrong** with stack trace/error message
3. **Propose alternatives** or request guidance
4. **Don't proceed blindly** - wait for clarification if needed

Example:
```
❌ Task blocked: Cannot connect to GraphQL API

Error: 
SocketException: Failed host lookup: 'localhost:3000'

Context: Attempting to fetch tasks from backend

Root cause: Backend server may not be running, or incorrect URL

Checked: 
- Backend API URL in core/config/app_config.dart
- Backend server status (not running?)

Proposed solutions:
1. Start backend server: cd ../backend && npm run dev
2. Update API URL to correct endpoint
3. Check if backend is deployed (production URL)

Waiting for backend status confirmation before proceeding...
```

## Quick Reference

| Task Complexity | Use Todo List? | Steps |
|----------------|----------------|-------|
| Single widget edit | ❌ No | Just explain → execute → validate |
| 2-4 related changes | ✅ Yes | Full CLEAR framework |
| New feature screen | ✅ Yes | Full CLEAR + detailed todos |
| Investigation only | ❌ No | Explain findings |

### Tool Selection Guide

| Scenario | Tool to Use | Example |
|----------|-------------|---------|
| Finding widget patterns | `semantic_search` | Search for "StatelessWidget patterns" |
| Understanding file structure | `grep_search` | Search for "class.*Screen" in lib/ |
| Reading specific files | `read_file` | Review tasks_screen.dart implementation |
| Checking Dart errors | `get_errors` | Validate after editing |
| Running commands | `run_in_terminal` | Execute flutter pub get, flutter run |
| Package operations | `run_in_terminal` | `flutter pub add package_name` |

### Common Commands Reference

```powershell
# Development
flutter run                            # Start app on connected device
flutter run -d chrome                  # Run on web (debugging)
flutter run --release                  # Release build
flutter clean                          # Clean build cache

# Package Management
flutter pub get                        # Install dependencies
flutter pub add <package>              # Add new package
flutter pub upgrade                    # Upgrade packages
flutter pub outdated                   # Check for outdated packages

# Code Generation
dart run build_runner build            # Generate code (freezed, json_serializable)
dart run build_runner watch            # Watch mode
dart run build_runner build --delete-conflicting-outputs  # Force rebuild

# Testing
flutter test                           # Run all tests
flutter test --coverage                # With coverage
flutter test test/specific_test.dart   # Specific test
flutter test integration_test/         # Integration tests

# Building
flutter build apk                      # Android APK
flutter build appbundle                # Android App Bundle
flutter build ios                      # iOS build
flutter build web                      # Web build

# Code Quality
flutter analyze                        # Dart analyzer
dart format lib/                       # Format code
dart fix --apply                       # Apply lint fixes
```

### Project-Specific Conventions

1. **Requirements Validation**: Always verify changes against `.docs/PRD.md` before implementation
2. **Backend API Check**: Verify endpoint exists in `backend.docs/API_DOCUMENTATION.md`
3. **State Management**: Use Riverpod for all state (no setState for complex state)
4. **Navigation**: Use go_router for all navigation (no Navigator.push)
5. **Models**: Use freezed for immutable data models
6. **GraphQL**: Use graphql_flutter for API calls (code generation recommended)
7. **Localization**: Use flutter_localizations + intl (l10n/app_en.arb, l10n/app_ru.arb)
8. **Theming**: Use Material Design 3 (ThemeData.useMaterial3: true)
9. **Tokens**: Store JWT tokens in flutter_secure_storage (never SharedPreferences)
10. **Error Handling**: Show user-friendly error messages (not raw exceptions)
11. **Permission Checks**: Hide/disable UI elements based on user role (from authProvider)
12. **Loading States**: Always show loading indicators for async operations
13. **Offline Support**: Implement cache-first strategy for critical data
14. **Images**: Use cached_network_image for remote images, image_picker for uploads

**Known Mobile Development Priorities** (from .docs/ROADMAP.md):
- Phase 1: Authentication setup (JWT token management)
- Phase 2: Task management screens (list, detail, completion)
- Phase 3: Group management screens (list, detail, invite)
- Phase 4: Gamification screens (rewards, leaderboard, points)
- Phase 5: Notifications setup (FCM integration)
- Phase 6: Offline support (local caching)
- Phase 7: Advanced features (analytics, settings)

---

**Remember**: Quality over speed. Always:
1. **Consult `.docs/PRD.md` FIRST** for mobile app requirements and UI specifications
2. **Check `.docs/ROADMAP.md`** for current mobile development phase and status
3. **Verify `backend.docs/API_DOCUMENTATION.md`** for backend API availability
4. **Reference `backend.docs/PRD.md`** when understanding backend business logic
5. **Validate against Mobile PRD** after implementation
6. **Reference Mobile PRD sections** in all explanations and code comments

When in doubt: **Mobile PRD is the source of truth** for "what to build", **Backend API docs show "what's available"**, and **existing Flutter code shows "how we build it"**.
