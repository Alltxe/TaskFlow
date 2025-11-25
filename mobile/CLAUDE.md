# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TaskFlow Mobile is a Flutter cross-platform application for automated distribution of household tasks in small groups with gamification and executor rotation system. The app is built using Clean Architecture with Flutter 3.9.2+, Dart, and Riverpod for state management.

**Current Phase:** Phase 6 Complete (Task Management Core) → Phase 7 Next (Gamification Features)

## Core Rules

### Context Gathering (Mandatory before any changes)

**NEVER act without context. ALWAYS check:**

1. **`.docs/PRD.md` (Mobile PRD)**: The single source of truth for mobile requirements, UI/UX specs, user flows, business rules, and validations.
2. **`.docs/ROADMAP.md` (Roadmap)**: Identify the current development phase, completed features, and planned work.
3. **Backend API Documentation**: Verify the availability of required endpoints:
   - **`.docs/GRAPHQL_API_DOCUMENTATION.md`**: Complete GraphQL API documentation.
   - **`.docs/schema.gql`**: The latest GraphQL schema file. Use it to validate queries, mutations, and data structures.
4. **`backend.docs/PRD.md` (Backend PRD - Reference Only)**: Consult for understanding server-side logic, data models, and validation rules when referenced by the mobile PRD.
5. **Search and Read Code**: Use read_file or search to understand existing patterns and implementations.

### Todo Lists (Mandatory for multi-step tasks)

Use the `TodoWrite` tool for **any task with 2 or more distinct steps**, such as:
- Adding a new screen (providers + widgets + navigation).
- Setting up core infrastructure (GraphQL client, state management).
- Implementing a feature spanning multiple components.
- Debugging complex issues (investigation + fix).

**Do NOT use** for single-file edits or simple queries.

#### Todo List Guidelines
- **Write First**: Create the todo list before starting work.
- **Break Down**: Decompose tasks into small, actionable items.
- **Track Progress**: Mark one item as `[IN-PROGRESS]`, work on it, then mark it `[COMPLETED]` immediately upon finishing. Move sequentially.
- **Update in Real-Time**: Do not batch updates.
- **Use location immediately** instead of writing hardcoded values.

## Development Commands

### Build and Run
```bash
# Run the app in development mode
flutter run

# Run on specific device
flutter run -d <device-id>

# Build release APK (Android)
flutter build apk --release

# Build app bundle (Android - for Play Store)
flutter build appbundle --release

# Build iOS (macOS only)
flutter build ios --release

# Clean build artifacts
flutter clean
```

### Code Generation
```bash
# Generate code (freezed, json_serializable, etc.)
flutter pub run build_runner build

# Watch mode (auto-regenerate on changes)
flutter pub run build_runner watch

# Clean previous generated files and regenerate
flutter pub run build_runner build --delete-conflicting-outputs
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/domain/usecases/auth/login_usecase_test.dart

# Run integration tests
flutter test integration_test/app_test.dart
```

### Code Quality
```bash
# Run static analysis
flutter analyze

# Format code
flutter format lib test

# Check for outdated dependencies
flutter pub outdated
```

### Localization
```bash
# Generate localization files (from l10n.yaml)
flutter gen-l10n

# Location of translation files
# - Source: lib/l10n/app_en.arb, app_es.arb, etc.
# - Generated: lib/l10n/app_localizations.dart
```

## Architecture Overview

### Clean Architecture Layers

The codebase follows Clean Architecture with strict separation of concerns:

```
lib/
├── core/                   # Cross-cutting concerns
│   ├── config/            # App configuration (API URLs, constants)
│   ├── errors/            # Error handling (Failure, Exceptions)
│   ├── localization/      # i18n support
│   ├── router/            # Navigation (go_router)
│   └── theme/             # Design system (colors, typography, spacing)
├── data/                  # Data Layer (external)
│   ├── datasources/       # Remote (GraphQL) and Local (SecureStorage)
│   ├── models/            # DTOs with JSON serialization
│   ├── providers/         # Riverpod providers for data
│   └── repositories/      # Repository implementations
├── domain/                # Business Logic Layer
│   ├── entities/          # Pure business objects
│   └── usecases/          # Single-responsibility business logic
├── presentation/          # UI Layer
│   ├── screens/           # Full-screen widgets
│   ├── widgets/           # Reusable UI components
│   └── providers/         # Riverpod state management for UI
├── shared/                # Shared utilities
└── l10n/                  # Localization files
```

### State Management

**Riverpod 2.5+** is used for all state management:

- **Providers**: Declare dependencies and expose data to UI
- **StateNotifier**: For mutable state management (e.g., AuthNotifier)
- **FutureProvider/StreamProvider**: For async operations
- **Consumer/ConsumerWidget**: For rebuilding UI on state changes

**Example Pattern:**
```dart
// Provider declaration (in data/providers/)
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

// Usage in UI
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    // ...
  }
}
```

### GraphQL Integration

**Location:** `lib/core/config/graphql_config.dart` (if exists) or configured in providers

**Key Points:**
- All API communication uses GraphQL via `graphql_flutter` package
- Authentication via JWT tokens stored in `flutter_secure_storage`
- Access token expires in 15 minutes; refresh token expires in 7 days
- Token refresh handled automatically by auth interceptor
- GraphQL endpoint: `http://10.0.2.2:3000/graphql` (Android emulator) or configured in `AppConfig`

**Query/Mutation Pattern:**
```dart
// Define query string
const String myQuery = r'''
  query GetTasks($groupId: String!) {
    getGroupTasks(groupId: $groupId) {
      id
      title
      status
    }
  }
''';

// Execute with GraphQL client
final result = await graphQLClient.query(
  QueryOptions(
    document: gql(myQuery),
    variables: {'groupId': groupId},
  ),
);
```

### Navigation

**go_router 14.6+** with declarative routing:

- **Auth Guard**: Redirects unauthenticated users to `/login`
- **Bottom Navigation**: StatefulShellRoute with 3 tabs (Home, Groups, Profile)
- **Deep Linking**: Supported via `/join/:inviteToken` route

**Common Routes:**
- `/` - Splash screen (auth check)
- `/login` - Login screen
- `/register` - Registration screen
- `/home` - Dashboard (main tab)
- `/groups` - Groups list (main tab)
- `/profile` - User profile (main tab)
- `/groups/:groupId` - Group detail
- `/tasks/:taskId` - Task detail
- `/tasks/create?groupId=xxx` - Create task
- `/join/:inviteToken` - Join group via invite link

### Data Models

**freezed + json_serializable** for immutable data classes:

```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String username,
    String? avatarUrl,
    required bool isAway,
    DateTime? awayUntil,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

**Important:** After modifying models, run `flutter pub run build_runner build`

### Error Handling

**Pattern:** Use `Failure` objects (not exceptions) in domain/presentation layers:

```dart
// lib/core/errors/failure.dart
@freezed
class Failure with _$Failure {
  const factory Failure.server(String message) = ServerFailure;
  const factory Failure.network(String message) = NetworkFailure;
  const factory Failure.authentication(String message) = AuthenticationFailure;
  // ...
}
```

**Repository Pattern:**
```dart
// Return Either<Failure, Success> using dartz
Future<Either<Failure, User>> getCurrentUser() async {
  try {
    final user = await remoteDataSource.getCurrentUser();
    return Right(user);
  } on ServerException catch (e) {
    return Left(Failure.server(e.message));
  }
}
```

## Key Patterns and Conventions

### File Naming
- **Screens:** `*_screen.dart` (e.g., `login_screen.dart`)
- **Widgets:** `*_widget.dart` (e.g., `task_card_widget.dart`)
- **Models:** `*.dart` in `data/models/` (e.g., `user.dart`)
- **Entities:** `*.dart` in `domain/entities/` (e.g., `user_entity.dart`)
- **Use Cases:** `*_usecase.dart` (e.g., `login_usecase.dart`)
- **Repositories:** `*_repository.dart` (interface) and `*_repository_impl.dart` (implementation)
- **Providers:** `*_providers.dart` (e.g., `auth_providers.dart`)

### Code Style
- **Linting:** Configured in `analysis_options.yaml` (flutter_lints + custom rules)
- **Required trailing commas** for better formatting
- **Prefer const constructors** and **single quotes**
- **Always declare return types**
- **Use package imports** (not relative imports from `lib/`)

### Testing Strategy
- **Unit Tests:** Test repositories, use cases, and business logic
- **Widget Tests:** Test UI components in isolation
- **Integration Tests:** Test complete user flows
- **Mocking:** Use `mockito` package with code generation

**Test File Location:** Mirror the `lib/` structure in `test/`

### Localization
- **Tool:** Flutter's official `intl` package with `flutter_localizations`
- **Configuration:** `l10n.yaml` at project root
- **Source Files:** `lib/l10n/app_en.arb` (English), `app_es.arb` (Spanish), etc.
- **Usage:**
  ```dart
  import 'package:mobile/l10n/app_localizations.dart';

  Text(AppLocalizations.of(context)!.loginTitle)
  ```

## Phase-Specific Guidelines

### Current Phase: Phase 7 - Gamification Features (NEXT UP)

**Objectives:**
- Implement reward catalog management (admin and participant views)
- Build reward redemption workflow (request → approve/reject)
- Create point transaction history
- Implement leaderboard with rankings
- Add point earning animations

**GraphQL Endpoints Available:**
- `createReward`, `updateReward`, `deleteReward`
- `requestReward`, `approveRewardRequest`
- `getGroupRewards`, `getMyRewardRequests`, `getGroupRewardRequests`
- `getPointBalance`, `getPointTransactionHistory`
- `getGroupLeaderboard`

**Reference:** See ROADMAP.md Phase 7 for detailed task breakdown.

### Completed Phases (Reference Only)

**Phase 1-3:** Foundation, Design System, Authentication (JWT tokens, login/register, splash screen)
**Phase 4:** Core Navigation (bottom tabs), User Profile (statistics, settings)
**Phase 5:** Group Management (CRUD, members, roles, invite system)
**Phase 6:** Task Management Core (CRUD, status workflows, rotation algorithms, Up-for-Grabs pool)

## API Configuration

### Environment Variables
Set via `--dart-define` at build time:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:3000 --dart-define=ENVIRONMENT=development
```

**Defaults (AppConfig):**
- `API_BASE_URL`: `http://10.0.2.2:3000` (Android emulator)
- `ENVIRONMENT`: `development`

### API Endpoint Structure
- **GraphQL:** `{API_BASE_URL}/graphql`
- **WebSocket:** `ws://{host}:3000/graphql` (for subscriptions, if implemented)

## Common Workflows

### Adding a New Screen
1. Create screen file: `lib/presentation/screens/<feature>/<screen_name>_screen.dart`
2. Add route to `lib/core/router/app_router.dart`
3. Create necessary providers in `lib/data/providers/` or `lib/presentation/providers/`
4. Add localization strings to `lib/l10n/app_en.arb`
5. Run `flutter gen-l10n` to regenerate localization files

### Adding a New GraphQL Operation
1. Verify operation exists in `.docs/schema.gql`
2. Create query/mutation string in data source: `lib/data/datasources/<feature>_remote_datasource.dart`
3. Add method to repository: `lib/data/repositories/<feature>_repository_impl.dart`
4. Create use case: `lib/domain/usecases/<feature>/<operation>_usecase.dart`
5. Expose via provider: `lib/data/providers/<feature>_providers.dart`
6. Use in UI via `ref.read()` or `ref.watch()`

### Adding a New Model/Entity
1. Create freezed model: `lib/data/models/<model_name>.dart`
2. Add `@freezed` annotation and `fromJson/toJson` factories
3. Run `flutter pub run build_runner build --delete-conflicting-outputs`
4. Create corresponding entity (if needed): `lib/domain/entities/<entity_name>.dart`
5. Add mapper methods in repository if entity differs from model

### Implementing a Feature
1. **Plan:** Read PRD section, check ROADMAP phase requirements
2. **Context:** Verify GraphQL schema, check existing similar implementations
3. **Data Layer:** Create models, data sources, repository implementations
4. **Domain Layer:** Create entities (if different from models), use cases
5. **Presentation Layer:** Create providers, screens, widgets
6. **Navigation:** Add routes to app_router.dart
7. **Localization:** Add strings to .arb files
8. **Testing:** Write unit tests for use cases, widget tests for screens
9. **Verify:** Test on emulator/device, check all error states

## Important Notes

### Authentication Flow
1. User logs in → receives `accessToken` + `refreshToken`
2. `accessToken` stored in memory, `refreshToken` stored in `flutter_secure_storage`
3. All GraphQL requests include `Authorization: Bearer {accessToken}` header
4. Token refresh handled automatically when access token expires
5. On logout, clear both tokens and redirect to login

### Rotation Types (Task Assignment)
- **ROUND_ROBIN:** Cyclic assignment based on last completion time
- **RANDOM:** Random assignment among active members
- **LOAD_BALANCING:** Weight-based assignment (triggers redistribution when imbalance >= 2x)
- **DISABLED:** Manual assignment or Up-for-Grabs pool (claimed by users, 1.5x points)

### Task Status Lifecycle
- **PENDING** → **AWAITING_APPROVAL** (if `requiresApproval = true`) → **COMPLETED**
- **PENDING** → **COMPLETED** (if `requiresApproval = false`)
- **AWAITING_APPROVAL** → **PENDING** (if rejected by admin)
- **PENDING/AWAITING_APPROVAL** → **OVERDUE** (deadline passed)

### Point Multipliers
- **On-time completion:** 1.0x
- **Late completion:** 0.5x
- **Up-for-Grabs claim:** 1.5x (bonus for claiming unassigned tasks)
- **Rejected task:** 0.0x

### Secure Storage (flutter_secure_storage)
- Used for JWT tokens only
- Keys: `access_token`, `refresh_token`, `user_id`
- Platform-specific: Keychain (iOS), KeyStore (Android)

## Troubleshooting

### Code Generation Issues
```bash
# Delete generated files and rebuild
flutter pub run build_runner build --delete-conflicting-outputs

# If still failing, clean and retry
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### GraphQL Connection Issues (Android Emulator)
- Use `10.0.2.2` instead of `localhost` to access host machine
- Ensure backend is running on `http://localhost:3000`
- Check `lib/core/config/app_config.dart` for correct endpoint

### Navigation Issues
- Check auth state in `authStateProvider`
- Verify route exists in `lib/core/router/app_router.dart`
- Check redirect logic in router for auth guard

### State Not Updating
- Ensure provider is watched: `ref.watch(myProvider)` not `ref.read()`
- Check if StateNotifier is calling `state = newState`
- Verify provider scope (e.g., using `ProviderScope` at app root)

## Resources

- **PRD:** `.docs/PRD.md` - Complete product requirements
- **Roadmap:** `.docs/ROADMAP.md` - Development phases and status
- **GraphQL API:** `.docs/GRAPHQL_API_DOCUMENTATION.md` - Complete API reference
- **GraphQL Schema:** `.docs/schema.gql` - Type definitions
- **Backend PRD:** `backend.docs/PRD.md` - Server-side reference

## Contact

For issues or questions about the codebase, refer to:
- TaskFlow repository documentation
- PRD for business requirements
- ROADMAP for development status
- do not run flutter run