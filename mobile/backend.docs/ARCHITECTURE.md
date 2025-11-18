# TaskFlow Backend - Architecture Documentation

## Overview

TaskFlow backend is a NestJS-based GraphQL API designed for managing household tasks with automated distribution, gamification, and rotation systems. This document describes the system architecture, design decisions, and development guidelines.

---

## Table of Contents

1. [System Architecture](#system-architecture)
2. [Technology Stack](#technology-stack)
3. [Module Structure](#module-structure)
4. [Design Patterns](#design-patterns)
5. [Data Flow](#data-flow)
6. [Security Architecture](#security-architecture)
7. [Performance Optimizations](#performance-optimizations)
8. [Testing Strategy](#testing-strategy)
9. [Development Workflow](#development-workflow)
10. [Design Decisions](#design-decisions)

---

## System Architecture

### High-Level Architecture

```
┌─────────────────┐
│  GraphQL Client │ (Frontend/Mobile App)
└────────┬────────┘
         │ HTTPS (JWT)
         ▼
┌─────────────────────────────────────────┐
│         NestJS Application              │
│  ┌───────────────────────────────────┐  │
│  │       GraphQL API Layer           │  │
│  │  (Apollo Server + Code First)     │  │
│  └───────────┬───────────────────────┘  │
│              │                           │
│  ┌───────────▼───────────────────────┐  │
│  │      Resolver Layer               │  │
│  │  (Auth, User, Group, Task, etc.)  │  │
│  └───────────┬───────────────────────┘  │
│              │                           │
│  ┌───────────▼───────────────────────┐  │
│  │      Service Layer                │  │
│  │  (Business Logic)                 │  │
│  └───────────┬───────────────────────┘  │
│              │                           │
│  ┌───────────▼───────────────────────┐  │
│  │      Prisma ORM Layer             │  │
│  │  (Database Abstraction)           │  │
│  └───────────┬───────────────────────┘  │
└──────────────┼───────────────────────────┘
               │
       ┌───────┴────────┬─────────────┐
       ▼                ▼             ▼
  ┌─────────┐    ┌──────────┐   ┌─────────┐
  │PostgreSQL│    │  Redis   │   │Firebase │
  │         │    │  (Cache) │   │  (Push) │
  └─────────┘    └──────────┘   └─────────┘
```

### Component Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                      Application Layer                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   Auth   │  │   User   │  │  Group   │  │   Task   │   │
│  │  Module  │  │  Module  │  │  Module  │  │  Module  │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
│       │             │              │              │          │
│  ┌────▼─────┐  ┌───▼──────┐  ┌───▼──────┐  ┌───▼──────┐   │
│  │  Reward  │  │Notification│ │AuditLog │  │ Firebase │   │
│  │  Module  │  │  Module   │  │ Module  │  │  Module  │   │
│  └──────────┘  └───────────┘  └──────────┘  └──────────┘   │
└──────────────────────────────────────────────────────────────┘
┌──────────────────────────────────────────────────────────────┐
│                      Infrastructure Layer                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Prisma   │  │  Cache   │  │ Logger   │  │Throttler │   │
│  │ Service  │  │ Manager  │  │ Winston  │  │ Guards   │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└──────────────────────────────────────────────────────────────┘
┌──────────────────────────────────────────────────────────────┐
│                         Cross-Cutting Concerns                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │Exception │  │   Auth   │  │  Validation│ │  Health  │   │
│  │ Filters  │  │  Guards  │  │   Pipes   │  │  Checks  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└──────────────────────────────────────────────────────────────┘
```

---

## Technology Stack

### Core Framework

- **NestJS 11**: Progressive Node.js framework
  - Modular architecture
  - Dependency injection
  - Decorators and metadata
  - TypeScript first-class support

### API Layer

- **GraphQL**: API query language
- **Apollo Server**: GraphQL server implementation
- **@nestjs/graphql**: NestJS GraphQL module (code-first approach)
- **graphql-query-complexity**: Query complexity limiting

### Database & ORM

- **PostgreSQL 14**: Relational database
  - ACID compliance
  - Advanced indexing
  - JSON support for metadata
- **Prisma ORM**: Modern database toolkit
  - Type-safe queries
  - Auto-generated client
  - Migration management
  - Query optimization

### Authentication & Security

- **Passport.js**: Authentication middleware
- **JWT**: JSON Web Tokens (access + refresh)
- **bcrypt**: Password hashing
- **Helmet**: Security headers
- **@nestjs/throttler**: Rate limiting
- **class-validator**: Input validation
- **class-transformer**: DTO transformation

### Caching

- **cache-manager**: Unified caching interface
- **cache-manager-redis-yet**: Redis adapter
- **In-memory cache**: Development fallback

### Push Notifications

- **firebase-admin**: Firebase Cloud Messaging SDK
- **FCM**: Push notification delivery

### Logging & Monitoring

- **Winston**: Structured logging
  - File transports (error.log, combined.log)
  - Console output
  - Log rotation
- **@nestjs/terminus**: Health checks
  - Liveness probes
  - Readiness probes
  - Custom indicators

### Task Scheduling

- **@nestjs/schedule**: CRON jobs
  - Deadline monitoring (hourly)
  - Reminder notifications (30 min intervals)

### Testing

- **Jest**: Unit and integration testing
- **Supertest**: E2E API testing
- **@nestjs/testing**: Testing utilities

### Development Tools

- **TypeScript 5.x**: Static typing
- **ESLint**: Code linting
- **Prettier**: Code formatting
- **ts-node**: TypeScript execution
- **nodemon**: Development auto-restart

---

## Module Structure

Each feature module follows a consistent structure:

```
module-name/
├── module-name.module.ts       # NestJS module definition
├── module-name.resolver.ts     # GraphQL resolver (API endpoints)
├── module-name.service.ts      # Business logic layer
├── module-name.service.spec.ts # Unit tests
├── dto/                        # Data Transfer Objects
│   └── module-name.input.ts    # GraphQL input types (with validation)
├── types/                      # GraphQL object types
│   └── module-name.type.ts     # GraphQL output types
├── guards/                     # Custom authorization guards
│   └── module-guard.ts
├── decorators/                 # Custom decorators
│   └── custom.decorator.ts
└── README.md                   # Module documentation
```

### Core Modules

#### 1. Auth Module (`src/modules/auth/`)

**Responsibilities**:
- User registration and login
- JWT token generation and validation
- Refresh token rotation
- Password hashing and verification

**Key Components**:
- `AuthService`: Authentication business logic
- `AuthResolver`: GraphQL mutations (register, login, refresh, logout)
- `JwtStrategy`: Passport JWT strategy
- `JwtAuthGuard`: Route protection
- `CurrentUser` decorator: Extract user from request

**Dependencies**: PrismaService

---

#### 2. User Module (`src/modules/user/`)

**Responsibilities**:
- User profile management
- Statistics calculation (points, completion rate, leaderboard)
- Away status management

**Key Components**:
- `UserService`: User business logic
- `UserResolver`: GraphQL queries/mutations
- Caching: 5-minute TTL for statistics

**Dependencies**: PrismaService, CacheManager

---

#### 3. Group Module (`src/modules/group/`)

**Responsibilities**:
- Group CRUD operations
- Member management (invite, join, remove)
- Role-based access control (Admin/Member)
- Invitation token generation

**Key Components**:
- `GroupService`: Group business logic
- `GroupResolver`: GraphQL API
- `GroupAdminGuard`: Admin-only operations
- Audit logging integration

**Dependencies**: PrismaService, AuditLogService

---

#### 4. Task Module (`src/modules/task/`)

**Responsibilities**:
- Task CRUD operations
- Task state machine (PENDING → AWAITING_APPROVAL → COMPLETED)
- Rotation algorithms (Round Robin, Weighted Random, Load Balancing)
- Up-for-Grabs pool management
- Point calculation with multipliers
- Deadline monitoring (CRON job)

**Key Components**:
- `TaskService`: Task business logic
- `TaskResolver`: GraphQL API
- `RotationService`: Distribution algorithms
- `DeadlineService`: Automated deadline checks

**Dependencies**: PrismaService, RotationService, AuditLogService, NotificationService, CacheManager

---

#### 5. Reward Module (`src/modules/reward/`)

**Responsibilities**:
- Reward catalog management
- Point reservation system
- Reward request approval workflow
- Point ledger (PointTransaction)
- Leaderboard calculation

**Key Components**:
- `RewardService`: Reward business logic
- `RewardResolver`: GraphQL API
- Point transaction types: EARNED, RESERVED, SPENT, REFUNDED

**Dependencies**: PrismaService, NotificationService

---

#### 6. Notification Module (`src/modules/notification/`)

**Responsibilities**:
- In-app notification creation
- Push notification delivery (FCM)
- Notification preferences (muted types, quiet hours)
- Device token management

**Key Components**:
- `NotificationService`: Notification logic
- `NotificationResolver`: GraphQL API
- `NotificationPreferenceService`: User preferences

**Dependencies**: PrismaService, FirebaseService, NotificationPreferenceService

---

#### 7. Audit Log Module (`src/modules/audit-log/`)

**Responsibilities**:
- Comprehensive audit trail
- Action logging (CRUD, approvals, role changes, points)
- Metadata storage (before/after state)
- Audit log queries with filters

**Key Components**:
- `AuditLogService`: Logging business logic
- `AuditLogResolver`: Query API

**Dependencies**: PrismaService

---

#### 8. Prisma Module (`src/modules/prisma/`)

**Responsibilities**:
- Database connection management
- Transaction handling
- Query execution
- Connection pooling

**Key Components**:
- `PrismaService`: Extends PrismaClient with NestJS lifecycle hooks

---

#### 9. GraphQL Module (`src/modules/graph-ql/`)

**Responsibilities**:
- GraphQL schema generation
- Apollo Server configuration
- Query complexity limiting
- Playground/introspection control

**Configuration**:
- Code-first approach
- Max complexity: 1000
- Playground: dev only
- Introspection: dev only

---

#### 10. Firebase Module (`src/modules/firebase/`)

**Responsibilities**:
- Firebase Admin SDK initialization
- Push notification sending (single + batch)
- Retry logic with exponential backoff
- Invalid token cleanup

**Key Components**:
- `FirebaseService`: FCM integration

---

## Design Patterns

### 1. Dependency Injection

NestJS uses constructor-based dependency injection:

```typescript
@Injectable()
export class TaskService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly rotation: RotationService,
    private readonly audit: AuditLogService,
    @Inject(CACHE_MANAGER) private cacheManager: Cache,
  ) {}
}
```

**Benefits**:
- Loose coupling
- Testability (easy mocking)
- Centralized dependency management

---

### 2. Repository Pattern (via Prisma)

Prisma acts as a repository layer:

```typescript
// No manual SQL - type-safe queries
const task = await this.prisma.task.findUnique({
  where: { id: taskId },
  include: {
    assignee: true,
    group: true,
  },
});
```

**Benefits**:
- Type safety
- Auto-completion
- Database abstraction
- Migration management

---

### 3. Guard Pattern (Authorization)

Custom guards for route protection:

```typescript
@UseGuards(JwtAuthGuard, GroupAdminGuard)
@Mutation(() => Boolean)
async deleteGroup(@Args('id') id: string, @CurrentUser() user: User) {
  return this.groupService.deleteGroup(id, user.id);
}
```

**Benefits**:
- Separation of concerns
- Reusable authorization logic
- Clear security boundaries

---

### 4. Decorator Pattern

Custom decorators for metadata extraction:

```typescript
export const CurrentUser = createParamDecorator(
  (data: unknown, context: ExecutionContext) => {
    const ctx = GqlExecutionContext.create(context);
    return ctx.getContext().req.user;
  },
);
```

**Benefits**:
- Cleaner resolver methods
- Encapsulated logic
- Type-safe parameter injection

---

### 5. Strategy Pattern (Rotation Algorithms)

Different task assignment strategies:

```typescript
class RotationService {
  async assignTask(group: Group, members: User[]): Promise<User> {
    switch (group.rotationType) {
      case 'ROUND_ROBIN':
        return this.roundRobin(members);
      case 'WEIGHTED_RANDOM':
        return this.weightedRandom(members);
      case 'LOAD_BALANCING':
        return this.loadBalancing(members);
      default:
        return null; // Up-for-Grabs
    }
  }
}
```

**Benefits**:
- Open/Closed principle
- Easy to add new algorithms
- Clear separation of strategies

---

### 6. DTO (Data Transfer Object) Pattern

Input validation and transformation:

```typescript
@InputType()
export class CreateTaskInput {
  @Field()
  @IsNotEmpty()
  @Length(1, 200)
  title: string;

  @Field({ nullable: true })
  @IsOptional()
  @Length(0, 2000)
  description?: string;

  @Field(() => TaskPriority, { defaultValue: TaskPriority.MEDIUM })
  priority: TaskPriority;
}
```

**Benefits**:
- Input validation at API boundary
- Type safety
- Self-documenting API
- Security (whitelist, forbidNonWhitelisted)

---

## Data Flow

### Authentication Flow

```
1. User submits credentials
   ↓
2. AuthResolver validates input
   ↓
3. AuthService checks credentials (bcrypt)
   ↓
4. Generate JWT tokens (access + refresh)
   ↓
5. Store refresh token in database
   ↓
6. Return tokens to client
```

### Task Creation Flow

```
1. Client sends createTask mutation (JWT in header)
   ↓
2. JwtAuthGuard validates token → extracts user
   ↓
3. TaskResolver receives input + current user
   ↓
4. GroupAdminGuard checks user is group admin
   ↓
5. TaskService.createTask(input, userId)
   ├─ Validate group membership
   ├─ Determine assignee (via RotationService or manual)
   ├─ Create task in database (Prisma transaction)
   ├─ Create audit log entry
   ├─ Send notification to assignee
   └─ Return created task
   ↓
6. TaskResolver returns task to client
```

### Point Award Flow

```
1. Admin approves task completion
   ↓
2. TaskService.approveTask(taskId, userId, approved=true)
   ↓
3. Calculate points with multipliers:
   - On-time: 1.0x
   - Late: 0.5x
   - Up-for-Grabs: 1.5x
   ↓
4. Prisma transaction:
   ├─ Update task status → COMPLETED
   ├─ Create TaskCompletionHistory record
   ├─ Create PointTransaction (type: EARNED)
   └─ Update cache (invalidate user statistics)
   ↓
5. Create audit log (action: TASK_APPROVAL, points awarded)
   ↓
6. Send notifications:
   ├─ TASK_APPROVED to assignee
   └─ POINT_AWARDED to assignee (with points amount)
   ↓
7. Return updated task
```

---

## Security Architecture

### Authentication & Authorization

#### JWT Strategy

- **Access Token**: Short-lived (15 minutes), stateless
- **Refresh Token**: Long-lived (7 days), stored in database
- **Token Rotation**: New refresh token on each refresh (invalidates old)

#### Password Security

- **Algorithm**: bcrypt with salt rounds = 10
- **Validation**: Min 8 chars, uppercase, lowercase, number, special char
- **No plaintext storage**: Passwords never logged or displayed

#### Role-Based Access Control (RBAC)

| Role | Permissions |
|------|------------|
| **Group Admin** | Create/edit/delete tasks, approve completions, manage members, create rewards |
| **Group Member** | Complete assigned tasks, claim Up-for-Grabs, view statistics, request rewards |

Guards enforce RBAC at resolver level.

---

### Input Validation

- **class-validator**: Automatic DTO validation
- **Whitelist**: Strip unknown properties
- **ForbidNonWhitelisted**: Reject extra properties
- **Transform**: Sanitize inputs (trim, lowercase)

---

### Rate Limiting

- **General API**: 100 requests/minute
- **Auth endpoints**: 5 requests/minute
- **GraphQL-aware**: Custom ThrottlerGuard for GQL context

---

### Security Headers (Helmet)

- **Content-Security-Policy**: Prevent XSS
- **X-Frame-Options**: Clickjacking protection
- **X-Content-Type-Options**: MIME sniffing prevention
- **Strict-Transport-Security**: Force HTTPS
- **X-XSS-Protection**: Legacy XSS filter

---

### Database Security

- **Prisma ORM**: SQL injection prevention (parameterized queries)
- **Connection pooling**: Prevent connection exhaustion
- **SSL/TLS**: Encrypted database connections in production
- **Least privilege**: Database user with minimal permissions

---

### Audit Trail

All critical actions logged:
- Task approvals/rejections
- Role changes
- Point transactions
- Reward redemptions
- Member additions/removals

**Audit logs include**:
- User ID (who)
- Action type (what)
- Entity ID (which resource)
- Timestamp (when)
- Metadata (before/after state)
- IP address (where - future enhancement)

---

## Performance Optimizations

### 1. Caching Strategy

- **User Statistics**: 5-minute TTL (Redis/in-memory)
- **Cache Invalidation**: On task completion, point transactions
- **Cache Keys**: `user-stats:${userId}:${groupId}`

### 2. Database Optimization

#### Indexes

```prisma
model Task {
  @@index([groupId])
  @@index([assigneeId])
  @@index([status])
  @@index([deadline])
}

model GroupMember {
  @@index([groupId, userId])
}

model PointTransaction {
  @@index([userId, groupId])
  @@index([groupId, type])
}
```

#### Connection Pooling

Prisma automatically manages connection pool:
- Min connections: 2
- Max connections: 10 (adjustable via `connection_limit`)

#### Query Optimization

- **Select only needed fields**: Use `select` instead of full models
- **Batch operations**: `findMany` with `include` instead of N+1 queries
- **Pagination**: Use `take` and `skip` for large datasets
- **Transactions**: `$transaction` for atomic operations

---

### 3. GraphQL Query Complexity

- **Max Complexity**: 1000 points
- **Complexity Calculation**: Depth × fields × multipliers
- **Prevention**: Reject overly complex queries

---

### 4. Batch Notifications

Firebase supports batch sending (up to 500 tokens):

```typescript
await this.firebase.sendBatchPushNotifications(
  tokens,
  { title, body, data },
);
```

---

## Testing Strategy

### Test Pyramid

```
        /\
       /E2E\        ← 102 tests (integration + E2E)
      /______\
     /        \
    /  Unit    \    ← 189 tests (services, resolvers)
   /____________\
```

### Unit Tests (`*.spec.ts`)

**Coverage**: 42% (target: >80% in Phase 10)

**Approach**:
- Mock all dependencies
- Test business logic in isolation
- Use Jest for assertions
- Focus on services (core logic)

**Example**:
```typescript
describe('TaskService', () => {
  let service: TaskService;
  let prisma: PrismaService;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        TaskService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: CACHE_MANAGER, useValue: mockCache },
      ],
    }).compile();

    service = module.get<TaskService>(TaskService);
  });

  it('should complete task without approval', async () => {
    mockPrisma.task.findUnique.mockResolvedValue(mockTask);
    const result = await service.completeTask('task-id', 'user-id');
    expect(result.status).toBe('COMPLETED');
  });
});
```

---

### E2E Tests (`test/*.e2e-spec.ts`)

**Coverage**: All critical user flows

**Approach**:
- Test full request/response cycle
- Use real database (test instance)
- Clean database between tests
- Use Supertest for HTTP assertions

**Example**:
```typescript
describe('Task Operations (e2e)', () => {
  let app: INestApplication;
  let accessToken: string;

  beforeAll(async () => {
    app = await createTestApp();
    accessToken = await registerAndLogin(app);
  });

  it('should create and complete task', async () => {
    const createResponse = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ query: CREATE_TASK_MUTATION });

    expect(createResponse.body.data.createTask.id).toBeDefined();

    const taskId = createResponse.body.data.createTask.id;

    const completeResponse = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ 
        query: COMPLETE_TASK_MUTATION,
        variables: { taskId },
      });

    expect(completeResponse.body.data.completeTask.status).toBe('COMPLETED');
  });
});
```

---

### Test Commands

```bash
# Unit tests
npm run test

# Unit tests with coverage
npm run test:cov

# E2E tests
npm run test:e2e

# Watch mode (TDD)
npm run test:watch

# Specific test file
npm run test -- task.service.spec.ts
```

---

## Development Workflow

### Git Branching Strategy

```
main (production)
  ├─ develop (integration)
  │    ├─ feature/task-rotation
  │    ├─ feature/gamification
  │    └─ bugfix/auth-token-refresh
  └─ hotfix/critical-bug
```

**Branch Types**:
- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/*`: New features
- `bugfix/*`: Non-critical bug fixes
- `hotfix/*`: Critical production fixes

---

### Commit Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style (formatting, missing semicolons)
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding missing tests
- `chore`: Maintenance (dependency updates, build config)

**Examples**:
```
feat(task): implement Round Robin rotation algorithm

- Sort members by last assignment date
- Skip users marked as away
- Fallback to Up-for-Grabs if no available executor

Closes #42
```

---

### Code Review Checklist

- [ ] Tests added/updated (unit + E2E)
- [ ] Documentation updated (API, README, architecture)
- [ ] Type safety maintained (no `any` types)
- [ ] Error handling implemented
- [ ] Input validation added
- [ ] Audit logging (for critical actions)
- [ ] Performance considered (queries, caching)
- [ ] Security reviewed (authentication, authorization)
- [ ] Code style consistent (ESLint + Prettier)
- [ ] No console.log (use Logger instead)

---

### Continuous Integration (CI)

**GitHub Actions Workflow** (recommended):

```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: test
          POSTGRES_DB: taskflow_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run linter
        run: npm run lint
      
      - name: Run unit tests
        run: npm run test:cov
      
      - name: Run E2E tests
        run: npm run test:e2e
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

---

## Design Decisions

### 1. Why GraphQL over REST?

**Pros**:
- Flexible queries (clients request exact data needed)
- Strong typing with schema
- Single endpoint
- Built-in documentation (introspection)
- Efficient data fetching (no over/under-fetching)

**Cons**:
- Learning curve
- Caching complexity (solved with Apollo Client)
- File uploads require multipart spec

**Decision**: GraphQL chosen for frontend flexibility and type safety.

---

### 2. Why Prisma over TypeORM?

**Pros**:
- Type-safe queries (generated client)
- Superior migration system
- Better performance (optimized SQL)
- Excellent TypeScript integration
- Active development

**Cons**:
- Less flexible for raw SQL (trade-off for safety)
- Smaller ecosystem than TypeORM

**Decision**: Prisma chosen for type safety and DX.

---

### 3. Why PostgreSQL over MongoDB?

**Pros**:
- ACID compliance (critical for financial data - points)
- Relational integrity (tasks, users, groups, points)
- Complex queries (leaderboards, statistics)
- Mature ecosystem
- Better for structured data

**Cons**:
- Schema migrations required
- Less flexible for unstructured data

**Decision**: PostgreSQL chosen for data integrity and relational queries.

---

### 4. Why JWT Refresh Tokens?

**Approach**: Short-lived access tokens (15 min) + long-lived refresh tokens (7 days)

**Pros**:
- Balance security and UX
- Refresh tokens can be revoked (logout)
- Stateless access tokens (scalable)
- Token rotation prevents reuse

**Cons**:
- Database lookup on refresh (mitigated by caching)

**Decision**: Hybrid approach chosen for security without sacrificing UX.

---

### 5. Why Redis Cache?

**Approach**: Redis in production, in-memory cache in dev

**Pros**:
- Fast (in-memory storage)
- Distributed caching (multi-instance support)
- TTL support
- Data structures (lists, sets, hashes)

**Cons**:
- Additional infrastructure
- Data volatility (cache misses)

**Decision**: Redis for production scalability, in-memory for dev simplicity.

---

### 6. Why Code-First GraphQL?

**Approach**: TypeScript classes with decorators generate schema

**Pros**:
- Single source of truth (TypeScript)
- Type safety at compile time
- Auto-completion in IDE
- DRY principle (no duplicate type definitions)

**Cons**:
- Schema changes require recompilation
- Less control over generated schema

**Decision**: Code-first for type safety and maintainability.

---

## Contributing

### Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/taskflow-backend.git`
3. Create feature branch: `git checkout -b feature/your-feature`
4. Install dependencies: `npm install`
5. Set up environment: `cp .env.example .env`
6. Run migrations: `npx prisma migrate dev`
7. Start dev server: `npm run dev`

### Development Guidelines

- **Follow NestJS conventions**: Modules, services, resolvers
- **Write tests first** (TDD encouraged)
- **Document public APIs**: JSDoc comments for services
- **Use TypeScript strictly**: No `any` types
- **Validate inputs**: Always use DTOs with validation decorators
- **Handle errors gracefully**: Use NestJS exceptions
- **Log appropriately**: Use Logger service, not console.log
- **Commit atomically**: One logical change per commit
- **Write meaningful commit messages**: Follow conventional commits

### Code Style

- **Linting**: `npm run lint` (ESLint)
- **Formatting**: `npm run format` (Prettier)
- **Type checking**: `npm run build` (tsc)

**Pre-commit hooks** (Husky + lint-staged recommended):

```json
{
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged"
    }
  },
  "lint-staged": {
    "*.ts": [
      "eslint --fix",
      "prettier --write"
    ]
  }
}
```

---

## References

### Official Documentation

- [NestJS](https://docs.nestjs.com/)
- [Prisma](https://www.prisma.io/docs/)
- [GraphQL](https://graphql.org/learn/)
- [Apollo Server](https://www.apollographql.com/docs/apollo-server/)
- [PostgreSQL](https://www.postgresql.org/docs/)
- [Redis](https://redis.io/documentation)

### Project Documentation

- [PRD (Product Requirements)](./PRD.md)
- [API Documentation](./API_DOCUMENTATION.md)
- [Deployment Guide](./DEPLOYMENT_GUIDE.md)
- [Development Roadmap](./DEVELOPMENT_ROADMAP.md)

---

**Version**: 1.0.0  
**Last Updated**: November 10, 2025  
**Maintainers**: TaskFlow Development Team
