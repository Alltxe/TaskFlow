## Core Rules

### Context Gathering (Mandatory before any changes)
**NEVER act without context. ALWAYS check:**

1.  **`.docs/PRD.md` (Mobile PRD)**: The single source of truth for mobile requirements, UI/UX specs, user flows, business rules, and validations.
2.  **`.docs/ROADMAP.md` (Roadmap)**: Identify the current development phase, completed features, and planned work.
3.  **Backend API Documentation**: Verify the availability of required endpoints:
    *   **`.docs/GRAPHQL_API_DOCUMENTATION.md`**: Complete GraphQL API documentation.
    *   **`.docs/schema.gql`**: The latest GraphQL schema file. Use it to validate queries, mutations, and data structures.
4.  **`backend.docs/PRD.md` (Backend PRD - Reference Only)**: Consult for understanding server-side logic, data models, and validation rules when referenced by the mobile PRD.
5.  **Search and Read Code**: Use `read_file` or `semantic_search` to understand existing patterns and implementations.

### Todo Lists (Mandatory for multi-step tasks)

Use the `manage_todo_list` tool for **any task with 2 or more distinct steps**, such as:
*   Adding a new screen (providers + widgets + navigation).
*   Setting up core infrastructure (GraphQL client, state management).
*   Implementing a feature spanning multiple components.
*   Debugging complex issues (investigation + fix).

**Do NOT use** for single-file edits or simple queries.

#### Todo List Guidelines
*   **Write First**: Create the todo list before starting work (`manage_todo_list`, operation="write").
*   **Break Down**: Decompose tasks into small, actionable items.
*   **Track Progress**: Mark one item as `[IN-PROGRESS]`, work on it, then mark it `[COMPLETED]` immediately upon finishing. Move sequentially.
*   **Update in Real-Time**: Do not batch updates.
- use the location immediately instead of writing hardcode