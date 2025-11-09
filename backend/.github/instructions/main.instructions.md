---
applyTo: '**'
---

# LLM Development Instructions - CLEAR Framework (TaskFlow)

## Context: Understanding Before Acting

**ALWAYS** gather context before making changes:

1. **Consult PRD First**: Check `.docs/PRD.md` for requirements, business rules, and constraints
2. **Review Roadmap**: Check `.docs/DEVELOPMENT_ROADMAP.md` for current phase, completed features, and planned architecture
3. **Read Related Files**: Use `read_file` or `semantic_search` to understand existing patterns
4. **Check Dependencies**: Identify module relationships, imports, and Prisma relations
5. **Review Similar Code**: Look for existing implementations to maintain consistency
6. **Understand Data Flow**: Trace how data moves through resolvers → services → Prisma
7. **Consult NestJS/Prisma Documentation**: When unsure about NestJS APIs, GraphQL patterns, or Prisma queries

**Never assume** - if you're unsure about existing code structure, search for it first.

### Critical Documentation Files

**MUST READ** before making changes to core functionality:

- **`.docs/PRD.md`** (Product Requirements Document)
  - Source of truth for business logic and requirements
  - Defines user roles, permissions, and access control (Section 2)
  - Specifies functional requirements for all features (Section 3)
  - Contains API requirements and data models (Sections 5-6)
  - Non-functional requirements (performance, security, reliability)
  - **Use this to validate**: "Does this change align with PRD requirements?"

- **`.docs/DEVELOPMENT_ROADMAP.md`** (Development Roadmap)
  - Current project phase and completion status
  - Recently completed features and known issues
  - Planned features and their implementation order
  - Testing status and technical debt tracking
  - **Use this to understand**: "Is this feature completed, in progress, or planned?"

- **`.docs/REFRESH_TOKEN_GUIDE.md`** (if working with auth)
  - Detailed guide for JWT refresh token implementation
  - Token rotation strategy and security best practices

**Never assume** - if you're unsure about existing code structure, search for it first.

### Project Architecture Overview

This is a **NestJS GraphQL backend** with the following structure:

```
src/
├── modules/
│   ├── auth/          # JWT authentication with refresh tokens (✅ Phase 2 Complete)
│   ├── user/          # User management and statistics (✅ Phase 2 Complete)
│   ├── group/         # Group management with roles (✅ Phase 3 Complete)
│   ├── task/          # Task management with rotation (✅ Phase 4 Complete - 80%)
│   ├── prisma/        # Database ORM layer (✅ Phase 1 Complete)
│   └── graph-ql/      # GraphQL module configuration (✅ Phase 1 Complete)
├── common/
│   └── filters/       # Global exception filters (✅ Phase 1 Complete)
├── app.module.ts      # Root application module
└── schema.gql         # Auto-generated GraphQL schema
```

**⚠️ IMPORTANT**: This structure represents the **current state** (Phase 4 of 12). 

**Planned but NOT YET IMPLEMENTED** (according to `.docs/DEVELOPMENT_ROADMAP.md`):
- ⏳ **Rotation Service** (Phase 5) - Round Robin, Weighted Random, Load Balancing algorithms
- ⏳ **Gamification Service** (Phase 6) - Points calculation, rewards, leaderboard
- ⏳ **Notification Service** (Phase 7) - Push notifications, reminders, real-time updates
- ⏳ **Audit Logging** (Phase 8) - Complete audit trail for critical actions
- ⏳ **Task Scheduler** (Phase 9) - Recurring task automation, deadline reminders
- ⏳ **Analytics Service** (Phase 10) - Advanced statistics and reporting

**Before adding new features**:
1. Check `.docs/DEVELOPMENT_ROADMAP.md` for current phase
2. Verify feature is not already planned in a later phase
3. Consult `.docs/PRD.md` for requirements
4. Discuss with team if adding features out of roadmap order

### Complete System Architecture (from PRD Section 6)

The backend manages the following entities (defined in Prisma schema):

**Core Entities**:
- **User** - User accounts with authentication, profile, and status
- **Group** - Task groups with configuration (rotation mode, gamification, approval)
- **GroupMember** - Junction table for user-group relationships with roles (ADMIN/MEMBER)
- **Task** - Tasks with priority, deadline, points, recurrence, and status
- **TaskCompletionHistory** - Audit trail of task completions with point awards

**Gamification Entities** (Schema ready, service logic pending Phase 6):
- **Reward** - Reward catalog items with name, description, point cost
- **RewardTransaction** - Point redemption requests with approval workflow
- **PointTransaction** - Complete history of all point movements (planned - not in current schema)

**Supporting Entities**:
- **TaskAttachment** - File attachments for tasks (schema ready, upload logic pending)
- **TaskCompletionAttachment** - Proof of completion attachments (schema ready)
- **Notification** - Push notifications for events (schema ready, service pending Phase 7)
- **AuditLog** - Complete audit trail for critical actions (schema ready, logging pending Phase 8)
- **RefreshToken** - JWT refresh token storage with rotation (✅ implemented)

**Key Relationships** (enforce in Prisma queries):
- Group → Members (1:N via GroupMember)
- Group → Tasks (1:N)
- Task → Assignee/Creator (N:1 to User)
- User → Rewards Requested/Approved (1:N to RewardTransaction)
- User → Task Completions (1:N to TaskCompletionHistory)

**Critical Business Rules** (from PRD Section 7):
1. **Point Calculation** (PRD 7.2.1):
   - `Points = BaseScore × Multiplier`
   - On-time: 1.0x, Late: 0.5x, Up-for-Grabs: 1.5x, Rejected/Overdue: 0.0x
   
2. **Task State Transitions** (PRD 3.3.4):
   - Created → Assigned → In Progress → Awaiting Approval → Completed/Rejected
   - Any state → Overdue (if deadline passed)
   
3. **Rotation Priority** (PRD 7.1.1):
   - Sort by last completion date (oldest first)
   - Skip users with `isAway = true`
   - Fallback to Up-for-Grabs if no available executor
   
4. **Permission Enforcement** (PRD 2.2):
   - Only Group Admins can create/edit/delete group tasks
   - Only Group Admins can approve task completions (if requiresApproval = true)
   - Participants can only create personal tasks and complete assigned tasks

### Key Technologies & Patterns

- **Framework**: NestJS 11 (modular architecture)
- **Database**: SQLite with Prisma ORM
- **API**: GraphQL (code-first with `@nestjs/graphql`)
- **Auth**: JWT (access: 15min, refresh: 7 days) + Passport
- **Validation**: `class-validator` + `class-transformer`
- **Testing**: Jest (unit) + Supertest (e2e)

### Common Patterns in This Project

#### Module Structure
Each feature module follows this structure:
```
module-name/
├── module-name.module.ts       # NestJS module definition
├── module-name.resolver.ts     # GraphQL resolver
├── module-name.service.ts      # Business logic
├── module-name.service.spec.ts # Unit tests
├── dto/
│   └── module-name.input.ts    # GraphQL input DTOs (with validation)
├── types/
│   └── module-name.type.ts     # GraphQL object types
├── guards/                      # Custom guards (if needed)
├── decorators/                  # Custom decorators (if needed)
```

#### Resolver Pattern
```typescript
@Resolver()
export class FeatureResolver {
  constructor(private featureService: FeatureService) {}

  @Query(() => ReturnType, { description: 'Clear description from PRD' })
  @UseGuards(JwtAuthGuard)
  async queryName(@CurrentUser() user: User, @Args('input') input: InputDTO) {
    return this.featureService.methodName(user.id, input);
  }

  @Mutation(() => ReturnType, { description: 'Clear description from PRD' })
  @UseGuards(JwtAuthGuard, CustomGuard)
  async mutationName(@CurrentUser() user: User, @Args('input') input: InputDTO) {
    return this.featureService.methodName(user.id, input);
  }
}
```

#### Service Pattern (Business Logic Layer)
```typescript
@Injectable()
export class FeatureService {
  constructor(private prisma: PrismaService) {}

  async methodName(userId: string, data: InputDTO) {
    // 1. Validate permissions/access (according to PRD Section 2.2)
    // 2. Validate business rules (according to PRD Section 3)
    // 3. Perform business logic
    // 4. Use Prisma for database operations
    // 5. Return appropriate GraphQL type
    
    return await this.prisma.model.create({ ... });
  }
}
```

**CRITICAL**: Always implement permission checks according to **PRD Section 2.2 Access Matrix**:
- Group Administrators have full control over group settings and tasks
- Group Participants can only modify their own data and self-assigned tasks
- Use guards (`JwtAuthGuard`, `GroupAdminGuard`) to enforce access control

### When to Consult Documentation

**PRD Documentation** (`.docs/PRD.md`):
- ✅ **Business rules validation** - "Does this logic match PRD Section 3.X requirements?"
- ✅ **Permission matrix** - PRD Section 2.2 defines what each role can do
- ✅ **API contracts** - PRD Section 5 specifies exact API signatures
- ✅ **Data models** - PRD Section 6 defines entity relationships
- ✅ **Formulas and calculations** - e.g., PRD 3.5.1 defines point calculation formula
- ✅ **State machines** - PRD 3.3.4 defines valid task state transitions
- ✅ **Non-functional requirements** - PRD Section 4 (performance, security, reliability)

**Roadmap Documentation** (`.docs/DEVELOPMENT_ROADMAP.md`):
- ✅ **Current phase understanding** - What's completed, in-progress, or planned?
- ✅ **Known issues** - Don't fix what's already documented as technical debt
- ✅ **Feature dependencies** - Some features require others to be completed first
- ✅ **Testing status** - What test coverage exists for each module?
- ✅ **Recent changes** - What was fixed/added recently?

**NestJS/Prisma/GraphQL Official Docs**:
- ✅ Module registration and dependency injection
- ✅ Guard/interceptor/decorator implementation
- ✅ GraphQL schema generation configuration
- ✅ Prisma relation queries and `include`/`select` syntax
- ✅ Migration generation and execution
- ✅ Transaction handling with `$transaction`
- ✅ Type safety with generated Prisma types

**Example Workflow**:
```
User asks: "Add a feature to let users exchange points for rewards"

1. CHECK PRD: Section 3.5.4 already defines this requirement!
   - Must check point balance first
   - Points move to "Reserved" status
   - Admin approval required (ApproveRewardRequest function)
   - If approved: deduct points; if rejected: refund

2. CHECK ROADMAP: Phase 6 (Gamification) - not yet implemented
   - Reward model exists in schema (Phase 1)
   - RewardTransaction model exists
   - Service logic NOT implemented yet

3. PLAN: Implement according to PRD specification
   - Create RewardService with requestReward() method
   - Create admin mutation approveRewardRequest()
   - Follow PRD 3.5.4 state machine exactly
```

## List: Task Decomposition Strategy

### When to Use Todo Lists

Use the `manage_todo_list` tool for ANY task that involves **2 or more distinct steps**:

- ✅ Adding a new feature with resolver + service + DTOs
- ✅ Refactoring code across multiple modules
- ✅ Implementing new Prisma models + migrations + services
- ✅ Debugging issues requiring investigation + fix
- ✅ Setting up new guards, decorators, or filters

**DO NOT** use todo lists for:
- ❌ Single file edits
- ❌ Simple questions or explanations
- ❌ Reading files or searching code

### Todo List Structure

Break down tasks into **atomic, actionable items**:

```markdown
1. [NOT-STARTED] Analyze existing reward system implementation
   - Read src/modules/group/types/group.type.ts for Reward model
   - Check Prisma schema for Reward relations
   - Review similar service patterns

2. [IN-PROGRESS] Create reward DTOs
   - Create src/modules/reward/dto/reward.input.ts
   - Define CreateRewardInput, UpdateRewardInput classes
   - Add validation decorators (@IsNotEmpty, @IsString, etc.)

3. [NOT-STARTED] Implement reward service
   - Create src/modules/reward/reward.service.ts
   - Add CRUD methods using PrismaService
   - Include permission checks (group admin only)

4. [NOT-STARTED] Create reward resolver
   - Create src/modules/reward/reward.resolver.ts
   - Add queries: getReward, getGroupRewards
   - Add mutations: createReward, updateReward, deleteReward
   - Apply JwtAuthGuard and GroupAdminGuard

5. [NOT-STARTED] Define GraphQL types
   - Create src/modules/reward/types/reward.type.ts
   - Use @ObjectType and @Field decorators
   - Match Prisma model structure

6. [NOT-STARTED] Register reward module
   - Create src/modules/reward/reward.module.ts
   - Import in app.module.ts
   - Verify GraphQL schema regeneration

7. [NOT-STARTED] Write tests
   - Unit tests: reward.service.spec.ts
   - E2e tests: test/reward-operations.e2e-spec.ts
   - Run: npm run test:cov
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

Always explain **what you're about to do and why**, **referencing PRD sections**:

```
I'll implement the reward redemption workflow. According to PRD Section 3.5.4:

This involves:
1. Creating RewardService.requestReward() method
   - Check user point balance (PRD requirement)
   - Reserve points if sufficient (move to "Reserved" status)
   - Create RewardTransaction with "Requested" status

2. Creating RewardService.approveRewardRequest() (admin only)
   - Validate request is in "Reserved" status
   - If approved: deduct points, update status to "Approved"
   - If rejected: refund points, update status to "Rejected" with reason

3. Adding GraphQL mutations:
   - requestReward(rewardId: ID!): RewardTransaction
   - approveRewardRequest(requestId: ID!, approved: Boolean!, reason: String): RewardTransaction

This follows PRD Section 3.5.4 state machine and permission matrix (Section 2.2).
Phase 6 in Roadmap - Gamification system (planned but not yet implemented).
```

### After Completing Tasks

Summarize **what was done and next steps**, **referencing PRD compliance**:

```
✅ Completed:
- Implemented RewardService with requestReward() and approveRewardRequest() methods
- Added point reservation logic (PRD 3.5.4 requirement)
- Created GraphQL mutations with proper guards (admin approval - PRD 2.2)
- Added validation for point balance checks
- Wrote e2e tests validating PRD 3.5.4 state transitions

📋 PRD Compliance:
- ✅ Point balance check before reservation (PRD 3.5.4)
- ✅ Admin-only approval (PRD 2.2 permission matrix)
- ✅ Point refund on rejection (PRD 3.5.3)
- ✅ Transaction logging (PRD 3.5.3 requirement)

📝 Next steps:
- Update Roadmap to mark Phase 6 reward redemption as complete
- Add notification for reward request status changes (Phase 7 dependency)
- Consider adding reward request expiration (not in PRD - discuss with team)
```
- Generated and applied migration
- Implemented NotificationService with CRUD operations
- Added GraphQL resolver with @Query and @Mutation
- Registered NotificationModule in AppModule

📝 Next steps:
- Test notification creation in task assignment flow
- Add e2e tests for notification queries
- Consider adding GraphQL subscriptions for real-time updates
```

### Error Reporting

When encountering errors:
1. **State the error clearly** with relevant stack trace
2. **Explain what you tried** and why it failed
3. **Check PRD/Roadmap** - is this a known issue or conflicting requirement?
4. **Propose solutions** based on PRD specifications
5. **Update todos** to reflect blocking issues

Example:
```
❌ Error encountered in step 3:

PrismaClientKnownRequestError: Foreign key constraint failed on the field: `assigneeId`

Context: Attempting to assign task to user during Round Robin rotation (PRD 3.4.1)

Root cause: User is marked as "Away" (isAway=true), but rotation algorithm didn't skip them

PRD Requirement (Section 3.4.1): "If participant is marked as 'Away', the algorithm 
must skip them until period ends"

Proposed fix: 
1. Update rotation algorithm to filter users where isAway=false OR awayUntil < now()
2. Add validation in TaskService.assignTask() to prevent manual assignment to away users
3. Add e2e test case for this scenario

This aligns with PRD 3.4.1 requirement. Proceeding with fix...
``` 
database constraints?
```

## Actionable: Execution Guidelines

### File Operations

**Creating Files**:
- Use absolute paths: `c:\projects\TaskFlow\backend\src\modules\...`
- Follow module structure conventions (see Architecture section)
- Include necessary imports and decorators
- Use TypeScript types from Prisma client: `import type { User, Group } from '@prisma/client'`

**Editing Files**:
- Use `replace_string_in_file` with 3-5 lines of context
- Preserve exact whitespace and indentation
- Never use placeholders like `...existing code...`

**Example of Good Edit**:
```typescript
// ✅ Good - includes context
@Mutation(() => Boolean)
@UseGuards(JwtAuthGuard)
async deleteTask(
  @CurrentUser() user: User,
  @Args('taskId') taskId: string,
) {
  return this.taskService.deleteTask(taskId, user.id);
}

// Added new mutation below
@Mutation(() => TaskType)
@UseGuards(JwtAuthGuard)
async archiveTask(
  @CurrentUser() user: User,
  @Args('taskId') taskId: string,
) {
  return this.taskService.archiveTask(taskId, user.id);
}
```

### Terminal Commands

**Always use PowerShell syntax**:
```powershell
# ✅ Correct
npm run dev
npm run test:e2e
npx prisma migrate dev --name add_notifications

# ❌ Wrong (bash syntax)
npm run dev && npm run test
cd src/modules && ls
```

**Set isBackground=true for**:
- Development server (`npm run dev`)
- Test watch mode (`npm run test:watch`)
- Long-running processes

**Set isBackground=false for**:
- Migrations (`npx prisma migrate dev`)
- One-time tests (`npm run test:e2e`)
- Build commands (`npm run build`)

### NestJS/Prisma/GraphQL Specific Actions

#### Adding a New Module

1. **Create module structure**:
   ```
   src/modules/feature/
   ├── feature.module.ts
   ├── feature.resolver.ts
   ├── feature.service.ts
   ├── dto/feature.input.ts
   └── types/feature.type.ts
   ```

2. **Register in AppModule**:
   ```typescript
   @Module({
     imports: [
       PrismaModule,
       GraphQlModule,
       // ... existing modules
       FeatureModule, // Add here
     ],
   })
   ```

3. **Update Prisma schema** (if needed):
   ```prisma
   model Feature {
     id        String   @id @default(cuid())
     name      String
     createdAt DateTime @default(now())
     // ... relations
   }
   ```

4. **Generate and run migration**:
   ```powershell
   npx prisma migrate dev --name add_feature_model
   ```

#### Creating GraphQL DTOs

**Input Types** (for mutations/arguments):
```typescript
import { InputType, Field } from '@nestjs/graphql';
import { IsNotEmpty, IsString, IsOptional } from 'class-validator';

@InputType()
export class CreateFeatureInput {
  @Field()
  @IsString()
  @IsNotEmpty()
  name: string;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  description?: string;
}
```

**Object Types** (for query/mutation returns):
```typescript
import { ObjectType, Field, ID } from '@nestjs/graphql';

@ObjectType()
export class FeatureType {
  @Field(() => ID)
  id: string;

  @Field()
  name: string;

  @Field({ nullable: true })
  description?: string;

  @Field()
  createdAt: Date;
}
```

#### Implementing Guards

```typescript
import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { GqlExecutionContext } from '@nestjs/graphql';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class CustomGuard implements CanActivate {
  constructor(private prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const ctx = GqlExecutionContext.create(context);
    const request = ctx.getContext().req;
    const user = request.user; // From JwtAuthGuard
    const args = ctx.getArgs();

    // Implement your authorization logic
    // Return true to allow, false/throw to deny
  }
}
```

#### Working with Prisma

**Include Relations**:
```typescript
const group = await this.prisma.group.findUnique({
  where: { id: groupId },
  include: {
    members: {
      include: {
        user: true,
      },
    },
    tasks: true,
  },
});
```

**Transactions**:
```typescript
await this.prisma.$transaction(async (tx) => {
  const task = await tx.task.create({ data: taskData });
  await tx.notification.create({ 
    data: { taskId: task.id, userId: assigneeId } 
  });
});
```

**Select Specific Fields**:
```typescript
const user = await this.prisma.user.findUnique({
  where: { id: userId },
  select: {
    id: true,
    email: true,
    username: true,
    // Exclude passwordHash
  },
});
```

## Realistic: Validation & Testing

### Pre-Execution Checks

Before running code:
1. **Verify imports** - Check that all modules exist
2. **Check dependencies** - Ensure packages are installed (`package.json`)
3. **Validate paths** - Confirm files exist at expected locations
4. **Review types** - Ensure TypeScript types match Prisma schema
5. **Check Prisma client** - Run `npx prisma generate` if schema changed

### Post-Execution Validation

After making changes:
1. **Check for errors**: Use `get_errors` to verify no TypeScript/lint errors
2. **Regenerate schema**: GraphQL schema should auto-update (`schema.gql`)
3. **Test resolvers**: Use GraphQL playground or e2e tests
4. **Verify database**: Check migrations applied with `npx prisma studio`

### Testing Strategy

For significant changes:
```powershell
# Run specific test suite
npm run test                      # All unit tests
npm run test:watch                # Watch mode for TDD
npm run test:cov                  # With coverage report
npm run test:e2e                  # End-to-end tests

# Test specific file
npm run test -- auth.service.spec.ts
npm run test:e2e -- test/auth-refresh.e2e-spec.ts
```

### E2E Testing Pattern

This project uses Supertest for GraphQL e2e tests:

```typescript
describe('Feature Operations (e2e)', () => {
  let app: INestApplication;
  let accessToken: string;

  beforeAll(async () => {
    const moduleFixture = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();

    // Setup: register user and get token
    const registerResponse = await request(app.getHttpServer())
      .post('/graphql')
      .send({
        query: `mutation { register(input: {...}) { accessToken } }`,
      });
    
    accessToken = registerResponse.body.data.register.accessToken;
  });

  it('should perform feature action', async () => {
    const response = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        query: `mutation { performAction(input: {...}) { id } }`,
      });

    expect(response.status).toBe(200);
    expect(response.body.data.performAction.id).toBeDefined();
  });
});
```

## Common Task Patterns

### Pattern: Adding a New Feature Module

```
1. [Context] 
   - READ .docs/PRD.md Section 3.X for feature requirements
   - READ .docs/DEVELOPMENT_ROADMAP.md to verify feature phase
   - Search for similar modules (e.g., user/group) for patterns
   - Read Prisma schema to understand relations
   - Check existing GraphQL patterns
   
2. [List] Create todo list based on PRD requirements:
   - Verify Prisma schema matches PRD Section 6 data model
   - Update schema if needed + generate migration
   - Create DTOs and types matching PRD Section 5 API spec
   - Implement service with business logic from PRD Section 3
   - Implement permission checks from PRD Section 2.2
   - Create resolver with queries/mutations from PRD Section 5
   - Register module
   - Write tests covering PRD functional requirements
   
3. [Explain] 
   - Describe approach: "Implementing [Feature] according to PRD Section X.Y"
   - Explain architectural decisions and PRD compliance
   
4. [Actionable] 
   - Follow module structure conventions
   - Use @UseGuards according to PRD permission matrix
   - Apply validation decorators matching PRD constraints
   - Implement exact formulas/logic from PRD
   - Write e2e tests validating PRD requirements
   
5. [Realistic] 
   - Run `npm run test:e2e`
   - Verify GraphQL schema matches PRD API specification
   - Check no TypeScript errors
   - Validate business rules against PRD
```

### Pattern: Modifying Prisma Schema

```
1. [Context] 
   - READ .docs/PRD.md Section 6 for data model specification
   - Read existing schema.prisma
   - Understand relation constraints and referential integrity
   - Check if migration affects existing data (consult Roadmap for current data state)
   
2. [List] Plan migration steps:
   - Verify change matches PRD Section 6 data model
   - Update model in schema.prisma
   - Generate migration with descriptive name
   - Review generated SQL for data safety
   - Run migration
   - Update Prisma client usage in services
   - Update GraphQL types if API changed
   
3. [Explain] 
   - Document schema changes
   - Justify based on PRD requirements
   - Explain impact on existing data
   
4. [Actionable]
   - Run: npx prisma migrate dev --name descriptive_name
   - Update services using changed models
   - Regenerate Prisma client if needed
   - Update affected GraphQL types
   
5. [Realistic]
   - Test with `npx prisma studio`
   - Run affected tests
   - Check for type errors
   - Verify data integrity after migration
```

### Pattern: Debugging GraphQL Resolver

```
1. [Context] 
   - Reproduce error in GraphQL playground
   - Check resolver implementation
   - Verify guard behavior
   - Review service logic
2. [List] Investigation steps:
   - Add console.log in resolver
   - Check JWT token validity
   - Verify Prisma query syntax
   - Test service method in isolation
3. [Explain] Hypothesize root cause
4. [Actionable]
   - Fix identified issue
   - Add validation/error handling
   - Write regression test
5. [Realistic]
   - Run e2e test to confirm fix
   - Verify no side effects
```

### Pattern: Adding Authorization Guard

```
1. [Context]
   - Read existing guards (e.g., GroupAdminGuard)
   - Understand GqlExecutionContext usage
   - Check Prisma relations for access control
2. [List] Implementation steps:
   - Create guard class in guards/
   - Implement CanActivate interface
   - Extract context and user from GqlExecutionContext
   - Query Prisma for authorization check
   - Apply to resolver with @UseGuards
   - Write unit tests
3. [Explain] Document guard purpose and logic
4. [Actionable]
   - Follow existing guard patterns
   - Throw ForbiddenException on failure
   - Test with different user roles
5. [Realistic]
   - Write e2e tests for authorized/unauthorized cases
   - Verify guard execution order (JwtAuthGuard first)
```

## Error Recovery

If a task fails:
1. **Update todo status** to reflect blocker
2. **Explain what went wrong** with stack trace/error message
3. **Propose alternatives** or request guidance
4. **Don't proceed blindly** - wait for clarification if needed

Example:
```
❌ Task blocked: Cannot generate migration

Error: Prisma schema validation failed:
  - Error: Field `groupId` references unknown model `Groups`

Root cause: Typo in relation field - should be `Group` not `Groups`

Proposed fix: Update schema.prisma line 45 to reference correct model name

Waiting for confirmation before proceeding with fix.
```

## Quick Reference

| Task Complexity | Use Todo List? | Steps |
|----------------|----------------|-------|
| Single file edit | ❌ No | Just explain → execute → validate |
| 2-4 related changes | ✅ Yes | Full CLEAR framework |
| Multi-module feature | ✅ Yes | Full CLEAR + detailed todos |
| Investigation only | ❌ No | Explain findings |

### Tool Selection Guide

| Scenario | Tool to Use | Example |
|----------|-------------|---------|
| Finding module patterns | `semantic_search` | Search for "GraphQL resolver patterns" |
| Understanding file structure | `grep_search` | Search for "@Resolver()" in src/modules |
| Reading specific files | `read_file` | Review auth.service.ts implementation |
| Checking TypeScript errors | `get_errors` | Validate after editing |
| Running commands | `run_in_terminal` | Execute migrations, tests |
| Prisma operations | `run_in_terminal` | `npx prisma migrate dev`, `npx prisma studio` |

### Common Commands Reference

```powershell
# Development
npm run dev                            # Start dev server (watch mode)
npm run build                          # Production build

# Database
npx prisma generate                    # Regenerate Prisma client
npx prisma migrate dev --name <name>   # Create and apply migration
npx prisma migrate reset               # Reset database (warning: deletes data)
npx prisma studio                      # Open database GUI
npx prisma db push                     # Push schema without migration (dev only)

# Testing
npm run test                           # Run unit tests
npm run test:watch                     # Unit tests in watch mode
npm run test:cov                       # Tests with coverage report
npm run test:e2e                       # Run e2e tests
npm run test -- <file>                 # Test specific file

# Code Quality
npm run lint                           # Run ESLint
npm run format                         # Run Prettier
```

### Project-Specific Conventions

1. **Requirements Validation**: Always verify changes against `.docs/PRD.md` before implementation
2. **Roadmap Awareness**: Check `.docs/DEVELOPMENT_ROADMAP.md` for feature status and dependencies
3. **Authentication**: Always use `@UseGuards(JwtAuthGuard)` for protected routes
4. **Current User**: Access via `@CurrentUser() user: User` decorator
5. **Group Admin**: Add `@UseGuards(JwtAuthGuard, GroupAdminGuard)` for admin-only operations
6. **Validation**: Use class-validator decorators in DTOs (`@IsNotEmpty`, `@IsEmail`, etc.)
7. **Error Handling**: Use NestJS built-in exceptions (`ForbiddenException`, `NotFoundException`)
8. **Prisma Relations**: Always use `include` for relations, `select` for specific fields
9. **GraphQL Descriptions**: Add `{ description: '...' }` to queries/mutations (copy from PRD)
10. **Permission Matrix**: Implement exactly as specified in PRD Section 2.2
11. **State Machines**: Follow PRD-defined state transitions (e.g., PRD 3.3.4 for task states)
12. **Formulas**: Use exact formulas from PRD (e.g., PRD 3.5.1 for point calculation)
13. **Audit Logging**: Log critical actions as specified in PRD 3.6.4 (when implemented in Phase 8)
14. **Testing**: E2E tests should validate PRD functional requirements, not just code behavior

**Known Technical Debt** (from Roadmap):
- User statistics calculation not fully implemented (Phase 2 - partial)
- Audit logging system incomplete (Phase 8 - pending)
- Recurring task scheduler not implemented (Phase 9 - pending)
- Notification system not started (Phase 7 - pending)

**Don't reimplement** features marked as technical debt - consult Roadmap first!

---

**Remember**: Quality over speed. Always:
1. **Consult `.docs/PRD.md` FIRST** for requirements and business rules
2. **Check `.docs/DEVELOPMENT_ROADMAP.md`** for current phase and dependencies  
3. **Validate against PRD** after implementation
4. **Reference PRD sections** in all explanations and code comments
5. **Update Roadmap** when completing features or discovering issues

When in doubt: **PRD is the source of truth** for "what to build", **Roadmap shows "when and what's done"**, and **existing code shows "how we build it"**.
