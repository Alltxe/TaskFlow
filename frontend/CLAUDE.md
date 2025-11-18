# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**TaskFlow**: React + TypeScript task management app with gamification and task rotation. Communicates with NestJS GraphQL backend on port 3000.

**Status**: Phase 2-3 complete (~30%). Auth, layout, and infrastructure done. Group management in progress.

### Tech Stack
- **Frontend**: React 19 + TypeScript 5.9 + Vite 7
- **UI**: Material-UI 7 + Radix UI + Emotion
- **Routing**: React Router 7
- **State**: Zustand (client) + urql (GraphQL)
- **Testing**: Vitest + Playwright + Testing Library
- **Language**: Russian (primary UI language)

### Project Structure
```
src/
  ├── api/          # GraphQL client, queries, generated types
  ├── components/   # Reusable UI components
  ├── features/     # Feature-specific modules
  ├── lib/          # Router, theme, utilities
  ├── pages/        # Route pages
  ├── store/        # Zustand stores (auth, ui, notifications)
  ├── types/        # TypeScript types
  └── locales/      # i18n translations
```

## Path Aliases (Always Use These)
```typescript
@/           → src/
@components/ → src/components/
@pages/      → src/pages/
@features/   → src/features/
@lib/        → src/lib/
@api/        → src/api/
@store/      → src/store/
@types/      → src/types/
@locales/    → src/locales/
```

## Essential Commands

**NEVER run `npm run dev`** - server started manually by user.

```bash
# Build & validation
npm run build            # TypeScript + Vite build (use this to check compilation)
npm run lint             # Check code style
npm run lint:fix         # Auto-fix lint issues
npm run format           # Format code with Prettier
npm run format:check     # Check code formatting

# GraphQL (requires backend on port 3000)
npm run codegen          # Generate types from GraphQL schema
npm run codegen:watch    # Generate types in watch mode

# Testing
npm test                 # Run unit tests (Vitest)
npm run test:ui          # Run tests with Vitest UI
npm run test:coverage    # Run tests with coverage report
npm run test:e2e         # E2E tests with Playwright (requires backend)
npm run test:e2e:ui      # E2E tests with Playwright UI
```

## Workflow Rules

### Before Making Changes
1. **Gather context**: Read related files, check existing patterns
2. **Check documentation**:
   - `.docs/PRD.md` - Feature specifications
   - `.docs/GRAPHQL_API_DOCUMENTATION.md` - API reference with examples
   - `.docs/schema.gql` - GraphQL schema
3. **Search for similar code**: Maintain consistency with existing implementations

### Task Management
- Use TodoWrite tool for **any task with 2+ steps**
- Break tasks into atomic, actionable items
- Mark ONE todo as in_progress before starting
- Complete and mark as done IMMEDIATELY after finishing
- **Don't batch completions** - update status in real-time

### Communication
- **Before action**: Explain what and why
- **After completion**: Summarize what was done
- **On errors**: State error clearly, explain attempts, propose solutions

## Architecture Essentials

### State Management (Zustand)
1. **authStore** (`src/store/authStore.ts`) - Auth state, persisted to localStorage as `auth-storage`
2. **uiStore** - UI state (sidebar, theme) - not persisted
3. **notificationStore** - Toast notifications - not persisted

**Auth flow**: authStore → localStorage → urql client reads token → GraphQL headers

### GraphQL Integration (urql)
- **Client**: `src/api/client.ts` (cacheExchange, fetchExchange, subscriptionExchange)
- **Queries/Mutations**: Define in `src/api/queries.ts`
- **Types**: Generated in `src/api/generated/` via `npm run codegen`
- **Cache invalidation**: Login/logout invalidates entire Query cache

**Pattern**:
```typescript
// 1. Add query to src/api/queries.ts
// 2. Run npm run codegen
// 3. Use in component:
import { useQuery, useMutation } from 'urql'
import { MY_QUERY } from '@api/queries'

const [result] = useQuery({ query: MY_QUERY })
const [, mutate] = useMutation(MY_MUTATION)
```

### Routing (React Router 7)
- **Public**: `/`, `/login`, `/register`
- **Protected**: `/dashboard`, `/groups`, `/profile`, `/join/:inviteToken`
- **Group routes**: `/group/:groupId/*` - uses `<GroupLayout>` with nested routes:
  - `/group/:groupId/tasks` - Task management
  - `/group/:groupId/members` - Member management
  - `/group/:groupId/settings` - Group settings (admin only)
  - `/group/:groupId/rotation` - Rotation schedule
  - `/group/:groupId/rewards` - Rewards catalog
  - `/group/:groupId/leaderboard` - Points leaderboard
- **Protection**: `<ProtectedRoute>` checks `authStore.isAuthenticated`
- **Layout**: `<AppShell>` wraps all authenticated pages (Header + Sidebar)

### Component Patterns
- **Functional components** with TypeScript (.tsx)
- **Props**: `interface ComponentNameProps { ... }`
- **Exports**: Named exports preferred
- **Location**: Reusable → `src/components/`, feature-specific → `src/features/`
- **Styling**: MUI `sx` prop or `styled` from Emotion

## Key Constraints

### Localization
- **Primary language: Russian** - use Russian text for all UI
- i18n infrastructure planned, use i18next when adding translations
- Never hardcode English text in components

### Role-Based Access (GroupMember.role)
- **ADMIN**: Full group management, task approval, member management
- **MEMBER**: View/complete tasks, request rewards
- **UI**: Hide/disable admin features for non-admins (frontend guards only)

### Gamification
- Points awarded for task completion
- Rewards catalog (spend points)
- Leaderboard (total points)
- Only if `group.gamificationEnabled: true`

### Task Rotation
- **CYCLIC**: Round-robin assignment
- **RANDOMIZED**: Random assignment
- **DISABLED**: Manual only

## Best Practices

### DO ✅
- Use TypeScript strictly (no `any`)
- Use path aliases (@components, @api, etc.)
- Handle loading/error states in UI
- Check `.docs/GRAPHQL_API_DOCUMENTATION.md` before implementing GraphQL features
- Run `npm run codegen` after modifying GraphQL operations
- Use Russian text for UI consistently
- Keep components under 250 lines

### DON'T ❌
- Mutate state directly
- Fetch data in useEffect (use urql hooks)
- Ignore TypeScript errors
- Use relative imports (use path aliases)
- Hardcode English text
- Run `npm run dev` (user starts server manually)

## Common Pitfalls

1. **GraphQL codegen fails**: Backend must be running on port 3000
2. **Auth token not sent**: Token read from localStorage `auth-storage` key automatically
3. **Routes not working**: Check `authStore.isAuthenticated` for protected routes
4. **Path alias errors**: Must be in both `tsconfig.app.json` and `vite.config.ts`
5. **Tests failing on Windows**: Tests run sequentially to avoid EMFILE errors. MUI icons are mocked in test environment.

## Environment Setup

Create `.env` file from `.env.example`:
```bash
VITE_API_URL=http://localhost:3000/graphql
VITE_WS_URL=ws://localhost:3000/graphql
```

Backend must be running on port 3000 for GraphQL operations and codegen.

## Documentation

- `.docs/PRD.md` - Product requirements
- `.docs/GRAPHQL_API_DOCUMENTATION.md` - API guide with examples
- `.docs/schema.gql` - GraphQL schema
- `.docs/DEVELOPMENT_ROADMAP.md` - Development phases
- `.docs/BACKEND_API_REQUIREMENTS.md` - Backend API requirements

## File Operations

**Creating files**: Use absolute paths (C:\projects\TaskFlow\frontend\src\...)
**Editing files**: Use exact context (3-5 lines), preserve whitespace, no placeholders

## Validation

After changes:
1. Run `npm run build` to check TypeScript compilation
2. Run `npm run lint` to check code style
3. Run `npm run codegen` if GraphQL changed
4. Test manually in browser (user starts dev server)

---

**Remember**: Context first, plan with todos, explain actions, validate thoroughly. Search workspace before making assumptions.
