# TaskFlow Backend - AI Coding Agent Instructions

## Project Overview

TaskFlow is a **NestJS + GraphQL + Prisma** backend for automated task distribution with gamification and rotation algorithms. The system manages household tasks for small groups (up to 10 users) with role-based access control, recurring tasks, point-based rewards, and multiple rotation strategies (Round Robin, Weighted Random, Load Balancing).

**Key Documents:**
- `.docs/PRD.md` - Complete product requirements (authoritative source)
- `.docs/DEVELOPMENT_ROADMAP.md` - Development phases and checklist
- `prisma/schema.prisma` - Database schema (11 models, 9 enums)

## Architecture & Design Patterns

### Module Structure
- **GraphQL-First API**: All resolvers use `@nestjs/graphql` with code-first approach
- **Module Organization**: Each feature is a self-contained NestJS module (`auth/`, `user/`, `group/`, `task/`, `prisma/`)
- **Service Layer Pattern**: Business logic lives in `*.service.ts`, resolvers are thin controllers
- **Prisma ORM**: Database access exclusively through `PrismaService` (no raw SQL)

### Core Services
```
PrismaService (singleton) → Injected into all feature services
AuthService → JWT generation, bcrypt hashing, user validation
TaskService → Rotation algorithms (selectAssignee), task lifecycle, approval workflow
GroupService → Membership management, invitation tokens
```

### Critical Data Flow: Task Assignment
1. Admin creates task via `createTask` mutation
2. If no `assigneeId` provided → `TaskService.selectAssignee()` applies rotation algorithm
3. Rotation types: `ROUND_ROBIN` (cyclic), `RANDOM`, `WEIGHTED_RANDOM` (inverse task count), `DISABLED` (Up-for-Grabs)
4. Algorithm respects `User.isAway` flag (filters members before selection)
5. Returns `null` if no available members → task becomes Up-for-Grabs

## Authentication & Authorization

### GraphQL Context Pattern
```typescript
// All protected resolvers use @UseGuards(JwtAuthGuard)
// Access current user via @CurrentUser() decorator
@UseGuards(JwtAuthGuard)
async myProfile(@CurrentUser() user: User) {
  // user is auto-populated from JWT payload (type from @prisma/client)
}
```

### Custom Guards
- `JwtAuthGuard` - Validates JWT, extracts user from `GqlExecutionContext` (not HTTP request)
- `GroupAdminGuard` - Checks `GroupMember.role === 'ADMIN'` from args.groupId
- Both guards use `GqlExecutionContext.create(context)` to access GraphQL-specific context

### JWT Configuration (PRD 4.2)
- **Current**: Access token = 7 days (`JWT_EXPIRES_IN` in `.env`)
- **PRD Requirement**: Access token = 15 minutes, Refresh token = 7 days
- **Missing**: Refresh token mechanism (not yet implemented - see ROADMAP Phase 2)
- Secret: `process.env.JWT_SECRET` (must be strong in production)
- Payload: `{ id, email, username }` (see `auth.service.ts:JwtPayload`)

## Database & Prisma Conventions

### Schema Patterns
- IDs: `@default(cuid())` for all primary keys
- Timestamps: `createdAt @default(now())`, `updatedAt @updatedAt`
- Soft deletes: **Not implemented** (use hard deletes)
- Column naming: Snake_case via `@map("column_name")`, camelCase in TypeScript models
- SQLite for development, PostgreSQL recommended for production

### Critical Relations (11 models, 9 enums)
```prisma
User → GroupMember → Group (many-to-many with role metadata)
Task → User (assignee, createdBy, approvedBy), Group
TaskCompletionHistory → Task, User (user, approvedBy) + attachments
RewardTransaction → User (userId, approvedById), Reward
Notification → User (userId, sentById)
AuditLog → User (optional, for system actions)
```

### Multi-Tenancy Pattern
- All queries **must** filter by `groupId` to isolate group data
- Always verify user membership before granting access:
  ```typescript
  const member = await prisma.groupMember.findFirst({
    where: { groupId, userId }
  });
  if (!member) throw new ForbiddenException(...);
  ```
- Indexes exist for: `[groupId, status]`, `[assigneeId, status]`, `[userId, isRead]`

## Business Logic Implementation (PRD Section 7)

### Task Status State Machine (PRD 3.3.4)
```
PENDING → IN_PROGRESS → AWAITING_APPROVAL → COMPLETED
                      ↘ OVERDUE (auto-triggered by deadline, not yet implemented)
AWAITING_APPROVAL → CANCELLED (on admin rejection with reason)
```
**Implemented**: PENDING, IN_PROGRESS, AWAITING_APPROVAL, COMPLETED, CANCELLED  
**Not implemented**: Auto-overdue monitoring (requires cron job - ROADMAP Phase 7)

### Point Calculation Formula (PRD 3.5.1, 7.2.1)
```
Points = task.points (baseScore) × multiplier

Multipliers (PRD 3.5.2):
- On-time completion: 1.0
- Late completion (after deadline): 0.5
- Up-for-Grabs bonus: 1.5
- Overdue/Rejected: 0.0
```
**Current state**: `completeTask` and `approveTask` implemented in `task.service.ts`  
**Missing**: Point calculation not yet connected to `TaskCompletionHistory` (ROADMAP Phase 6)

### Rotation Algorithms (PRD 3.4.1, 7.1)

**Implemented** (in `task.service.ts`):
1. **ROUND_ROBIN**: Finds last assigned task in group, selects next member cyclically
2. **RANDOM**: `Math.random()` selection from available members
3. **WEIGHTED_RANDOM**: Inverse of active task count (fewer tasks = higher probability)

**Not Implemented**:
- **Load Balancing**: Track accumulated task weight per user (ROADMAP Phase 5.3)
- **ClaimTask** mutation: Allow users to self-assign Up-for-Grabs tasks with 1.5x bonus (ROADMAP Phase 5.4)

**Edge cases handled**:
- Filters out `User.isAway === true` members before selection
- Returns `null` if no members available → task.assigneeId stays null (Up-for-Grabs)

### Reward Redemption Workflow (PRD 3.5.4, 7.3)
**Status**: Not implemented (ROADMAP Phase 6.4)  
**Required flow**:
1. User requests reward → Check balance → Reserve points (status: PENDING)
2. Admin approves → Deduct points (status: APPROVED) OR reject → Refund (status: REJECTED)
3. `RewardTransaction` model tracks all state changes

## Development Workflows

### Setup & Running (PowerShell)
```powershell
npm install
npx prisma generate              # Generate Prisma Client after schema changes
npx prisma migrate dev           # Apply migrations (creates SQLite dev.db)
npm run dev                      # Start with hot-reload (port 3000)
```

### Database Operations
```powershell
npx prisma studio                # Visual DB browser at localhost:5555
npx prisma migrate dev --name feature_name  # Create new migration
npx prisma db push               # Push schema without migration (dev only)
```

### Testing (Jest + testSprite MCP integration)
```powershell
npm test                         # Unit tests
npm run test:e2e                 # E2E tests (GraphQL mutations/queries)
npm run test:cov                 # Coverage report
npm run test:watch               # Watch mode for TDD
```

### GraphQL Playground
- URL: `http://localhost:3000/graphql`
- Schema: Auto-generated at `src/schema.gql` on server start
- Auth header: `{ "Authorization": "Bearer <JWT_TOKEN>" }`
- Introspection enabled (disable in production via `graph-ql.module.ts`)

## Code Patterns & Conventions

### Resolver → Service → Prisma Flow
```typescript
// Resolver: Thin controller, handles auth/guards
@Mutation(() => TaskType)
@UseGuards(JwtAuthGuard, GroupAdminGuard)
async createTask(@CurrentUser() user: User, @Args('input') input: CreateTaskInput) {
  return this.taskService.createTask(user.id, input);
}

// Service: Business logic, data validation
async createTask(userId: string, input: CreateTaskInput) {
  // 1. Verify admin role (or delegate to guard)
  // 2. Select assignee if not provided
  // 3. Create task via Prisma
  return this.prisma.task.create({ data: {...}, include: {...} });
}
```

### GraphQL Type Definitions
- **Types**: `types/*.type.ts` with `@ObjectType()` → Maps Prisma models to GraphQL
- **Inputs**: `dto/*.input.ts` with `@InputType()` → Mutation/query arguments
- **Validation**: Use `class-validator` decorators (`@IsNotEmpty()`, `@IsEmail()`, `@MinLength()`)
- Global pipe in `main.ts` auto-validates all inputs (whitelist, transform enabled)

### Error Handling
- Throw NestJS exceptions: `NotFoundException`, `ForbiddenException`, `BadRequestException`
- GraphQL formatting: `graph-ql.module.ts:formatError()` removes stack traces, maps status codes
- Production filter: `AllExceptionsFilter` in `main.ts` ensures no sensitive data leaks

### Common Pitfalls
1. **GraphQL Context**: Use `GqlExecutionContext.create(context)`, not `@Req()` decorator
2. **Prisma Dates**: Always `new Date(isoString)` when accepting date inputs
3. **Role Verification**: Check `GroupMember.role` in service layer, don't trust client
4. **Null Assignees**: `assigneeId: null` means Up-for-Grabs (valid state per PRD 3.4.2)
5. **Transaction Safety**: Wrap point operations in `prisma.$transaction()` (PRD 4.5)

## Current Implementation Status

### ✅ Completed (Phase 1-2)
- NestJS + GraphQL + Prisma setup with code-first schema generation
- JWT authentication (register, login) with bcrypt hashing
- User CRUD with `@CurrentUser()` decorator and `JwtAuthGuard`
- Group management (create, invite tokens, membership, `GroupAdminGuard`)
- Task CRUD with 3 rotation modes (Round Robin, Random, Weighted Random)
- Task completion and approval workflow (`completeTask`, `approveTask` mutations)
- Database schema: 11 models (User, Group, GroupMember, Task, Reward, etc.), 9 enums
- Global validation pipe and exception filter

### ❌ Not Implemented (Per PRD & ROADMAP)
- **Auth**: Refresh token mechanism (PRD 4.2 requires 15m access + 7d refresh)
- **Tasks**: Recurring task scheduler/cron (PRD 3.3.3 - generate 24h before deadline)
- **Tasks**: Auto-overdue status updates (PRD 3.6.3 - deadline monitoring)
- **Tasks**: ClaimTask mutation for Up-for-Grabs pool (PRD 3.4.2)
- **Rotation**: Load Balancing mode with task weights (PRD 3.4.3, 7.1.3)
- **Gamification**: Point transaction system with TaskCompletionHistory (PRD 3.5.1)
- **Rewards**: Full redemption workflow with point reservation (PRD 3.5.4, 7.3)
- **Rewards**: Leaderboard calculation (PRD 3.5.5)
- **Notifications**: Push notification system for events (PRD 3.6.3)
- **Audit**: AuditLog creation for critical actions (PRD 3.6.4)
- **Performance**: Rate limiting (PRD 8.3), caching for leaderboard/stats
- **Security**: CSRF protection, input sanitization beyond validation

## Environment Variables

Required in `.env` (see `.env.example`):
```bash
DATABASE_URL="file:./dev.db"           # SQLite for dev, postgresql:// for prod
JWT_SECRET="your-secret-key"           # MUST change in production
JWT_EXPIRES_IN="7d"                    # PRD requires "15m" (after refresh tokens)
PORT=3000                               # Optional, defaults to 3000
NODE_ENV="development"                  # Controls stack traces in errors
```

## Quick Reference

### Key Files
- **Auth patterns**: `auth/decorators/current-user.decorator.ts`, `auth/auth.guard.ts`
- **Custom guard**: `group/guards/group-admin.guard.ts` (check admin role)
- **Rotation logic**: `task/task.service.ts` (selectAssignee, roundRobinSelection, etc.)
- **GraphQL config**: `graph-ql/graph-ql.module.ts` (error formatting, introspection)
- **Validation examples**: `auth/dto/auth.input.ts`, `task/dto/task.input.ts`

### NestJS CLI Commands
```powershell
nest g module modules/feature      # Generate new module
nest g service modules/feature     # Generate service
nest g resolver modules/feature    # Generate GraphQL resolver
```

### PRD Cross-Reference
When implementing features, cite specific PRD sections:
- **Rotation**: PRD 3.4.1 (Round Robin), 7.1.1-7.1.3 (Algorithm rules)
- **Points**: PRD 3.5.2 (Multipliers), 7.2.1 (Calculation formula)
- **Rewards**: PRD 3.5.4 (Redemption), 7.3 (Request/approval rules)
- **Task States**: PRD 3.3.4 (State machine), 7.4 (Deadline rules)
- **Permissions**: PRD 2.2 (Access matrix for admin vs. participant)

---

**Remember**: This is a gamified task automation system with objective rotation to prevent interpersonal conflicts (PRD 1.2). Always verify PRD requirements before implementing features, update ROADMAP checklist after completion, and respect phase dependencies (e.g., points system depends on completion history).

