# TaskFlow - AI Coding Instructions

## Project Overview
TaskFlow is a collaborative task management system with gamification features. Backend uses **NestJS + GraphQL (code-first) + Prisma + SQLite**, focusing on group-based task assignment with rotation algorithms, rewards, and approval workflows.

## Architecture & Key Patterns

### 1. Global Module Pattern
- `PrismaModule` marked with `@Global()` decorator (`src/modules/prisma/prisma.module.ts`)
- Automatically available to all modules without explicit import
- Other modules (e.g., `AuthModule`) must be explicitly imported where needed
- **Critical**: When creating protected resolvers, always import `AuthModule` to access `JwtAuthGuard` and `JwtStrategy`

### 2. GraphQL Code-First Approach
- Schema auto-generated in `src/schema.gql` (do NOT edit manually)
- Use `@ObjectType()` for return types, `@InputType()` for mutations/query inputs
- **All fields must have explicit types**: `@Field(() => String)` not `@Field()`
- Use `@Field(() => Type, { nullable: true })` for optional fields
- Resolver decorators: `@Resolver()` without type parameter for class-level guards to work properly

### 3. Authentication Flow
**JWT Strategy with Flexible Token Format:**
```ts
// Supports both "Bearer <token>" AND raw token in Authorization header
jwtFromRequest: ExtractJwt.fromExtractors([
  ExtractJwt.fromAuthHeaderAsBearerToken(),
  (request) => request?.headers?.authorization?.startsWith('Bearer ') ? null : request?.headers?.authorization
])
```

**Protecting Resolvers:**
```ts
@Query(() => UserType)
@UseGuards(JwtAuthGuard)  // Apply per-method, not at class level
async me(@CurrentUser() user: User) { }
```

**Custom Decorator Usage:**
- `@CurrentUser()` returns full user object from JWT payload
- `@CurrentUser('id')` extracts specific field (use with caution, prefer full object)

### 4. Prisma Domain Model
**Core Entities:** User → Group → Task → Reward
- **Groups**: Invite token-based joining, role-based access (ADMIN/MEMBER)
- **Tasks**: 4 rotation types (`ROUND_ROBIN`, `RANDOM`, `WEIGHTED_RANDOM`, `DISABLED`), approval workflows
- **Gamification**: Points awarded on task completion, redeemable for rewards
- **History Tracking**: `TaskCompletionHistory`, `AuditLog` for full audit trail

**Key Relations:**
- User creates Groups (createdGroups) and belongs to many via GroupMember
- Group has members (GroupMember[]), tasks, rewards
- Task has creator, assignee, approver, parent (for recurring tasks)

### 5. Error Handling Pattern
- `AllExceptionsFilter` removes stack traces from client responses (security)
- GraphQL errors include both `code` (string like "UNAUTHENTICATED") AND `statusCode` (number like 401)
- Custom error formatting in `GraphQlModule`:
  ```ts
  formatError: (error) => ({
    message: error.message,
    extensions: { code: errorCode, statusCode: statusCode || 500 }
  })
  ```

### 6. Validation & Transformation
- Global `ValidationPipe` in `main.ts` with `whitelist: true`, `forbidNonWhitelisted: true`
- Use `class-validator` decorators in DTOs: `@IsEmail()`, `@IsNotEmpty()`, `@MinLength(6)`
- Use `class-transformer` for automatic type conversion

## Development Workflows

### Quick Start
```bash
cd backend
npm install
npx prisma migrate dev  # Apply migrations
npm run dev             # Start with watch mode (uses SWC for fast reload)
```

### Database Operations
```bash
npx prisma studio               # Visual DB editor (http://localhost:5555)
npx prisma migrate dev --name <description>  # Create migration
npx prisma generate             # Regenerate Prisma Client after schema changes
```

### GraphQL Endpoint
- **Playground**: http://localhost:3000/graphql (GraphiQL UI)
- **CSRF**: Disabled in development (`csrfPrevention: false`)
- **Authentication**: Add `Authorization: Bearer <token>` OR just `<token>` header

### Testing
```bash
npm run test          # Unit tests
npm run test:watch    # Watch mode
npm run test:e2e      # E2E tests
```

## Common Pitfalls & Solutions

### 1. "Требуется авторизация" (401) with valid token
**Cause**: Module doesn't import `AuthModule`
**Fix**: Add `AuthModule` to module's imports:
```ts
@Module({
  imports: [PrismaModule, AuthModule],  // ← Critical
  providers: [YourService, YourResolver],
})
```

### 2. GraphQL Type Errors ("Cannot return null for non-nullable field")
**Cause**: Missing explicit type annotations or incorrect nullable settings
**Fix**: 
```ts
@Field(() => String, { nullable: true })  // For optional fields
@Field(() => [GroupType])                 // For arrays (always non-null)
```

### 3. Prisma "Expected String, provided Object"
**Cause**: Passing full object instead of ID to relation field
**Fix**: Extract ID before Prisma operation:
```ts
// ✓ Correct
createdById: user.id

// ✗ Wrong
createdById: user  // user is object, not string
```

### 4. Circular Dependency in Modules
**Cause**: Two modules import each other
**Fix**: Use `forwardRef()` or restructure to shared module pattern

## Module Creation Template

When creating new feature modules:

```ts
// 1. Generate structure
npx nest g module modules/<name> --no-spec
npx nest g service modules/<name> --no-spec
npx nest g resolver modules/<name> --no-spec

// 2. Module setup
@Module({
  imports: [PrismaModule, AuthModule],  // AuthModule if using guards
  providers: [<Name>Service, <Name>Resolver],
  exports: [<Name>Service],
})

// 3. GraphQL Types (types/<name>.type.ts)
@ObjectType()
export class <Name>Type {
  @Field(() => ID)
  id: string;
  // ... explicit type for every field
}

// 4. Input DTOs (dto/<name>.input.ts)
@InputType()
export class Create<Name>Input {
  @Field(() => String)
  @IsNotEmpty()
  name: string;
}

// 5. Service (DI Prisma, implement business logic)
@Injectable()
export class <Name>Service {
  constructor(private prisma: PrismaService) {}
}

// 6. Resolver (apply guards per-method)
@Resolver()
export class <Name>Resolver {
  @Query(() => <Name>Type)
  @UseGuards(JwtAuthGuard)
  async get<Name>(@CurrentUser() user: User) { }
}
```

## Project-Specific Conventions

### Naming
- Prisma models: `PascalCase` (User, Group, Task)
- GraphQL types: `<Name>Type` (UserType, GroupType)
- Input DTOs: `<Action><Name>Input` (CreateGroupInput, UpdateTaskInput)
- Services/Resolvers: `<Name>Service`, `<Name>Resolver`

### File Organization
```
src/modules/
  <feature>/
    dto/            # Input types with validation
    types/          # GraphQL object types
    decorators/     # Custom decorators (if needed)
    <feature>.module.ts
    <feature>.service.ts
    <feature>.resolver.ts
```

### Business Logic Location
- **Services**: Database operations, validation, business rules
- **Resolvers**: GraphQL layer, guard application, user extraction
- **Guards**: Authentication/authorization only
- **Filters**: Error formatting and logging

## Environment Setup

Required `.env` variables:
```env
DATABASE_URL="file:./dev.db"
JWT_SECRET="<change-in-production>"
JWT_EXPIRES_IN="7d"
NODE_ENV="development"
```

**When in doubt**: Check existing modules (Auth, Group) for working examples of patterns.
