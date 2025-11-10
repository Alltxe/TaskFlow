---
applyTo: '**'
---

# TaskFlow Frontend - LLM Development Instructions

## Project Overview

**TaskFlow** is a web-based task management system with gamification features for household/group task distribution and rotation. This is a **React + TypeScript + Vite** frontend that communicates with a **GraphQL backend** (NestJS).

### Core Technologies
- **Framework**: React 19 + TypeScript 5.9
- **Build Tool**: Vite 7
- **UI Library**: Material-UI (MUI) 7 + Radix UI
- **Routing**: React Router 7
- **State Management**: 
  - Server State: TanStack Query (React Query)
  - Client State: Zustand
- **GraphQL Client**: urql with GraphCache
- **Testing**: Vitest + Playwright + Testing Library
- **Styling**: Emotion (CSS-in-JS)

### Project Structure
```
src/
  ├── api/          # GraphQL client, queries, mutations
  ├── components/   # Reusable UI components
  ├── features/     # Feature-specific modules
  ├── lib/          # Utilities, router, theme
  ├── pages/        # Route pages
  ├── store/        # Zustand stores
  ├── types/        # TypeScript types
  └── locales/      # i18n translations
```

---

## Context: Understanding Before Acting

**ALWAYS** gather context before making changes:

1. **Read Related Files**: Use `read_file` or `semantic_search` to understand existing patterns
2. **Check Dependencies**: Identify component relationships and imports
3. **Review Similar Code**: Look for existing implementations to maintain consistency
4. **Understand Data Flow**: 
   - GraphQL queries/mutations → React Query hooks
   - Server state (React Query) vs Client state (Zustand)
   - Component props flow and event handlers
5. **Check PRD Requirements**: Reference `.docs/PRD.md` for feature specifications

**Never assume** - if you're unsure about existing code structure, search for it first.

### Key Patterns to Follow

#### GraphQL Integration
- **Never** write GraphQL queries inline - define them in `src/api/queries.ts`
- Use GraphQL Codegen for type-safe operations
- Authentication: JWT tokens managed by `authStore`, injected via urql `fetchOptions`
- Real-time updates: Use subscriptions via `subscriptionExchange` (WebSocket)

#### Component Patterns
- **Functional components** with hooks only (no class components)
- Use **TypeScript** for all files (`.tsx` for components)
- Props interfaces: `interface ComponentNameProps { ... }`
- Export pattern: Named exports preferred over default exports
- Location: Reusable components → `src/components/`, page-specific → `src/features/`

#### State Management Rules
- **Server data** (tasks, groups, users): React Query hooks
- **UI state** (modals, notifications): Zustand stores
- **Authentication**: `useAuthStore` (persisted)
- **Form state**: React Hook Form (not implemented yet, but planned)

#### Path Aliases (configured in vite.config.ts)
```typescript
@/          → src/
@components → src/components/
@pages      → src/pages/
@features   → src/features/
@lib        → src/lib/
@api        → src/api/
@store      → src/store/
@types      → src/types/
@locales    → src/locales/
```
Always use path aliases instead of relative imports.

---

## List: Task Decomposition Strategy

### When to Use Todo Lists

Use the `manage_todo_list` tool for ANY task that involves **2 or more distinct steps**:

- ✅ Adding a new page with components and routing
- ✅ Implementing a feature with GraphQL queries and UI
- ✅ Creating a new Zustand store with actions
- ✅ Refactoring components across multiple files
- ✅ Setting up new test suites

**DO NOT** use todo lists for:
- ❌ Single file edits
- ❌ Simple questions or explanations
- ❌ Reading files or searching code

### Todo List Structure

Break down tasks into **atomic, actionable items**:

```markdown
1. [NOT-STARTED] Define GraphQL query for fetching tasks
   - Add query to src/api/queries.ts
   - Run codegen to generate types

2. [IN-PROGRESS] Create TaskList component
   - Create src/components/tasks/TaskList.tsx
   - Implement UI with MUI DataGrid or List

3. [NOT-STARTED] Integrate React Query hook
   - Create useTasksQuery hook
   - Handle loading and error states

4. [NOT-STARTED] Add TaskList to Tasks page
   - Import component into src/pages/Tasks.tsx
   - Wire up data fetching

5. [NOT-STARTED] Test component
   - Write unit test with Testing Library
   - Verify rendering and interactions
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

Always explain **what you're about to do and why**:

```
I'll create a new custom module for managing brands. This involves:
1. Creating the data model
2. Setting up the service layer
3. Generating migrations
4. Adding API endpoints

This follows the Medusa v2 modular architecture pattern.
```

### After Completing Tasks

Summarize **what was done and next steps**:

```
✅ Completed:
- Created brand module with data model
- Generated and ran migrations
- Added admin API endpoints

📝 Next steps:
- Test the endpoints with sample data
- Add validation logic
- Create admin UI components
```

### Error Reporting

When encountering errors:
1. **State the error clearly** with relevant details
2. **Explain what you tried** and why it failed
3. **Propose solutions** or ask for clarification
4. **Update todos** to reflect blocking issues

## Explain: Communication Standards

### Before Taking Action

Always explain **what you're about to do and why**:

```
I'll create a new TaskCard component for displaying individual tasks. This involves:
1. Creating the component file in src/components/tasks/
2. Implementing the UI with MUI Card and Typography
3. Adding TypeScript props interface
4. Integrating with the TaskList parent component

This follows the atomic component design pattern used throughout the project.
```

### After Completing Tasks

Summarize **what was done and next steps**:

```
✅ Completed:
- Created TaskCard component with status badge
- Added priority color coding
- Implemented click handler for task details
- Added unit tests with 90% coverage

📝 Next steps:
- Connect TaskCard to task detail modal
- Add edit/delete actions for admin users
- Implement drag-and-drop for Kanban view
```

### Error Reporting

When encountering errors:
1. **State the error clearly** with relevant details
2. **Explain what you tried** and why it failed
3. **Propose solutions** or ask for clarification
4. **Update todos** to reflect blocking issues

---

## Actionable: Execution Guidelines

### File Operations

**Creating Files**:
- Use absolute paths: `c:\projects\TaskFlow\frontend\src\components\...`
- Follow project structure conventions (see Architecture section)
- Include necessary imports and type definitions
- Always use path aliases for imports

**Example Component Structure**:
```typescript
import { FC } from 'react'
import { Box, Typography } from '@mui/material'
import type { Task } from '@types/task'

interface TaskCardProps {
  task: Task
  onClick?: () => void
}

export const TaskCard: FC<TaskCardProps> = ({ task, onClick }) => {
  return (
    <Box onClick={onClick}>
      <Typography variant="h6">{task.title}</Typography>
    </Box>
  )
}
```

**Editing Files**:
- Use `replace_string_in_file` with 3-5 lines of context
- Preserve exact whitespace and indentation
- Never use placeholders like `...existing code...`

### Terminal Commands

**Always use PowerShell syntax**:
```powershell
# ✅ Correct
npm run dev
npm run codegen
cd src\components; ls

# ❌ Wrong (bash syntax)
npm run dev && npm run codegen
cd src/components && ls
```

**Set isBackground=true for**:
- Development server (`npm run dev`)
- GraphQL codegen watch (`npm run codegen:watch`)
- Test UI mode (`npm run test:ui`)

**Set isBackground=false for**:
- Build commands (`npm run build`)
- Running tests (`npm test`)
- GraphQL codegen (`npm run codegen`)

### React + TypeScript Specific Actions

**Adding New Pages**:
1. Create page component in `src/pages/<PageName>.tsx`
2. Add route to `src/lib/router.tsx`
3. Add navigation link if needed (in Sidebar or Header)
4. Wrap with `<ProtectedRoute>` if authentication required
5. Wrap with `<AppShell>` for layout

**Creating GraphQL Operations**:
1. Define query/mutation in `src/api/queries.ts`
2. Run `npm run codegen` to generate TypeScript types
3. Import generated types: `import { UseTasksQuery } from '@api/generated'`
4. Use with urql hooks: `useQuery(TASKS_QUERY)`

**Adding Zustand Stores**:
1. Create store file in `src/store/<storeName>.ts`
2. Define interface with state and actions
3. Use `create` from zustand
4. Add `persist` middleware if state should be saved
5. Export custom hook: `export const useMyStore = create(...)`

**Styling Components**:
- Primary: Use MUI's `sx` prop for styling
- Advanced: Use `styled` from `@emotion/styled`
- Global styles: Add to `src/lib/globalStyles.ts`
- Theme: Modify `src/lib/theme.ts` for design tokens

---

## Realistic: Validation & Testing

### Pre-Execution Checks

Before running code:
1. **Verify imports** - Check that all modules exist
2. **Check dependencies** - Ensure required packages are installed
3. **Validate paths** - Confirm files exist at expected locations
4. **Review types** - Ensure TypeScript types are correct
5. **Check GraphQL schema** - Verify query/mutation matches backend schema

### Post-Execution Validation

After making changes:
1. **Check for errors**: Use `get_errors` to verify no TypeScript/lint errors
2. **Run builds**: Execute `npm run build` to verify production build
3. **Run codegen**: If GraphQL changed, run `npm run codegen`
4. **Test in browser**: Start dev server and verify UI works

### Testing Strategy

For significant changes:
```powershell
# Run unit tests
npm run test

# Run tests with coverage
npm run test:coverage

# Run E2E tests
npm run test:e2e

# Run tests in UI mode
npm run test:ui
```

### Common Validation Commands

```powershell
# Type checking
npm run build

# Linting
npm run lint

# Formatting check
npm run format:check

# Full validation suite
npm run lint; npm run test; npm run build
```

---

## Common Task Patterns

### Pattern: Adding a New Feature

```
1. [Context] 
   - Read PRD requirements in .docs/PRD.md
   - Search for similar features in workspace
   - Check existing component patterns
2. [List] Create todo list with all steps
3. [Explain] Describe the approach
4. [Actionable] 
   - Define GraphQL queries
   - Create components
   - Add routing
   - Integrate state management
   - Write tests
5. [Realistic] Validate with tests and error checks
```

### Pattern: Creating a New Page

```
1. [Context] 
   - Check routing in src/lib/router.tsx
   - Review existing page patterns (Dashboard, Login, Groups)
   - Verify required data from backend GraphQL schema
2. [List] Break down into steps
3. [Explain] Outline page structure and purpose
4. [Actionable]
   - Create page component in src/pages/ or src/pages/[feature]/
   - Add route configuration to router.tsx
   - Implement data fetching with urql
   - Add to Sidebar navigation (if needed)
   - Apply AppShell wrapper for authenticated pages
   - Apply ProtectedRoute for auth-required pages
5. [Realistic] Test routing, rendering, and data fetching
```

### Pattern: Integrating New GraphQL Operation

```
1. [Context] 
   - Review backend GraphQL schema
   - Check existing query patterns in src/api/queries.ts
2. [List] Plan integration steps
3. [Explain] Describe query structure
4. [Actionable]
   - Add query to queries.ts
   - Run npm run codegen
   - Create React Query hook
   - Integrate into component
   - Handle loading/error states
5. [Realistic] Test query execution
```

### Pattern: Debugging an Issue

```
1. [Context] Reproduce the error, gather stack traces
2. [List] Break investigation into steps
3. [Explain] Hypothesize root cause
4. [Actionable]
   - Add console.log or debugger statements
   - Check browser DevTools
   - Verify data flow
   - Implement fix
5. [Realistic] Verify fix resolves issue without side effects
```

---

## Error Recovery

If a task fails:
1. **Update todo status** to reflect blocker
2. **Explain what went wrong** with evidence
3. **Propose alternatives** or request guidance
4. **Don't proceed blindly** - wait for clarification if needed

### Common Errors and Solutions

| Error | Likely Cause | Solution |
|-------|-------------|----------|
| `Module not found` | Wrong import path | Use path alias (@components, @api, etc.) |
| `Property does not exist` | TypeScript type mismatch | Run `npm run codegen` if GraphQL-related |
| `Cannot read property of undefined` | Missing null check | Add optional chaining `?.` |
| `Network request failed` | Backend not running | Start backend server |
| Build errors | Type errors | Check `get_errors` output |

---

## Quick Reference

| Task Complexity | Use Todo List? | Steps |
|----------------|----------------|-------|
| Single file edit | ❌ No | Just explain → execute → validate |
| 2-4 related changes | ✅ Yes | Full CLEAR framework |
| Multi-file feature | ✅ Yes | Full CLEAR + detailed todos |
| Investigation only | ❌ No | Explain findings |

### Tool Selection Guide

| Scenario | Tool to Use | Example |
|----------|-------------|---------|
| Finding project code | `semantic_search` or `grep_search` | Search for existing components |
| Reading specific files | `read_file` | Review component implementation |
| Checking errors | `get_errors` | Validate TypeScript compilation |
| Running commands | `run_in_terminal` | Execute npm scripts, tests |
| Creating components | `create_file` | New React component files |
| Editing files | `replace_string_in_file` | Update existing code |

### NPM Scripts Reference

| Script | Purpose | Background? |
|--------|---------|-------------|
| `npm run dev` | Start dev server | ✅ Yes |
| `npm run build` | Production build | ❌ No |
| `npm run codegen` | Generate GraphQL types | ❌ No |
| `npm run codegen:watch` | Watch mode for codegen | ✅ Yes |
| `npm run test` | Run unit tests | ❌ No |
| `npm run test:ui` | Test UI mode | ✅ Yes |
| `npm run test:e2e` | E2E tests with Playwright | ❌ No |
| `npm run lint` | Check code style | ❌ No |
| `npm run lint:fix` | Auto-fix lint issues | ❌ No |

---

## Architecture Guidelines

### Component Organization

```
src/components/
  ├── layout/        # AppShell, Header, Sidebar
  ├── tasks/         # Task-related components
  ├── groups/        # Group management components
  ├── rewards/       # Gamification components
  └── common/        # Shared UI primitives
```

### Page Structure

```
src/pages/
  ├── Welcome.tsx           # Public landing
  ├── Login.tsx             # Authentication
  ├── Register.tsx          # Sign up
  ├── Dashboard.tsx         # Personal task calendar view
  ├── Groups.tsx            # User's groups list
  ├── NotFound.tsx          # 404 page
  └── [feature]/            # Feature-specific pages
      ├── GroupTasks.tsx    # /group/:id/tasks
      ├── Rewards.tsx       # /group/:id/rewards
      ├── Leaderboard.tsx   # /group/:id/leaderboard
      └── ...
```

### State Management Layers

1. **URL State**: React Router params/search
2. **Server State**: React Query (for API data)
3. **Client State**: Zustand stores
   - `authStore` - Authentication (persisted)
   - `uiStore` - UI preferences
   - `notificationStore` - Toast messages

### GraphQL Code Generation

**Workflow**:
1. Define operation in `src/api/queries.ts`
2. Run `npm run codegen`
3. Import from `@api/generated` (auto-created)
4. Use type-safe hooks

**Example**:
```typescript
// src/api/queries.ts
export const TASKS_QUERY = gql`
  query Tasks($groupId: ID!) {
    tasks(groupId: $groupId) {
      id
      title
      status
    }
  }
`

// After codegen, use in component:
import { useTasksQuery } from '@api/generated'

const { data } = useTasksQuery({ variables: { groupId } })
```

---

## Role-Based Access Control

### Implementing Permission Checks

**Frontend guards** (for UI only - backend enforces security):

```typescript
// Check if user is group admin
const isAdmin = groupMember?.role === 'ADMIN'

// Conditionally render admin-only UI
{isAdmin && <AdminPanel />}

// Disable actions for non-admins
<Button disabled={!isAdmin}>Delete Group</Button>
```

### Protected Routes

```typescript
// Wrap routes requiring auth
<ProtectedRoute>
  <DashboardPage />
</ProtectedRoute>

// For role-specific routes (implement later)
<ProtectedRoute requiredRole="ADMIN">
  <GroupSettingsPage />
</ProtectedRoute>
```

---

## Best Practices

### DO ✅
- Use TypeScript strictly (no `any` types)
- Implement proper error boundaries
- Handle loading and error states in UI
- Use React.memo for expensive components
- Validate user input before submitting
- Write tests for critical business logic
- Use semantic HTML for accessibility
- Follow MUI design system patterns
- Keep components under 250 lines
- Extract reusable logic into custom hooks

### DON'T ❌
- Mutate state directly
- Use inline styles (use `sx` prop or `styled`)
- Fetch data in useEffect (use React Query)
- Store derived state (compute from source)
- Ignore TypeScript errors
- Skip error handling in mutations
- Hardcode API URLs (use env vars)
- Bypass authentication checks
- Create deeply nested component trees
- Use `console.log` in production code

---

**Remember**: Quality over speed. Take time to understand context, plan properly, and validate thoroughly. When in doubt, search the workspace first, then ask for clarification.