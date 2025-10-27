# Product Requirements Document (PRD) – Web Frontend

## 1. Introduction

### 1.1 Purpose  
This document defines the complete functional and non-functional requirements for the **web frontend** of the application “Automated Distribution of Household Tasks in Small Groups with Gamification and Executor Rotation.” It is intended to guide frontend development, UI/UX implementation, and integration with the existing GraphQL backend (NestJS). All requirements are derived from the system’s core business logic, user roles, and interaction scenarios described in the technical specification and usage model.

### 1.2 Scope  
The web frontend is a **responsive, web-application** that provides full access to all system features for both user roles:  
- **Group Administrator (Parent/Organizer)**  
- **Group Participant (Student/Neighbor)**  

It must support all core workflows: group management, task creation/assignment/completion, rotation logic visualization, gamification (points, rewards, leaderboard), and administrative controls.

### 1.3 Target Audience  
- Frontend developers  
- UI/UX designers  
- QA engineers  
- LLMs assisting with implementation or testing  

---

## 2. User Roles and Access Control

### 2.1 Supported Roles  
The frontend must enforce role-based UI rendering and navigation:

| Role | Permissions |
|------|-------------|
| **Group Administrator** | Full access to all features: create groups, manage participants, configure rotation, approve tasks, manage rewards, view all data |
| **Group Participant** | Limited access: view assigned tasks, claim Up-for-Grabs tasks, complete tasks, request rewards, view personal stats and leaderboard |

### 2.2 Role-Based UI Rules  
- UI elements (buttons, forms, menus) **must be hidden or disabled** if the current user lacks permission.  
- Navigation routes **must be protected** based on role and group context.  
- Error states **must be handled gracefully** when a user attempts unauthorized actions.

---

## 3. Functional Requirements

### 3.1 Authentication & Onboarding  
- **Login Page**: Email/password form with validation and error handling.  
- **Registration Page**: Form with email, password, name; must prevent duplicate emails.  
- **Welcome Screen**: Public landing page with app description and CTA to login/register.  
- **Session Management**: Automatically redirect unauthenticated users to login.  
- **Password Reset**: Not required in MVP (per source docs), but UI must be extensible.

### 3.2 Group Management  
- **Create Group Flow**: Multi-step form (wizard) with:  
  - Group name input  
  - Toggle for **Control Mode** (task approval required)  
  - Toggle for **Rotation Mode** (cyclic / randomized / disabled)  
  - Toggle for **Gamification** (points & rewards enabled)  
- **Group Dashboard**:  
  - List of user’s groups (cards with name, member count, last activity)  
  - “+ Create Group” button (admin only)  
  - “Leave Group” option (participants only)  
- **Invite Participants**:  
  - Generate one-time join link or token  
  - Display list of current members with roles  
  - Allow admin to remove members or change roles  

### 3.3 Task Management  
- **Task Creation Form**: Must support:  
  - Title, description, deadline (date + time), priority (Low/Medium/High)  
  - Base points (5–20, optional)  
  - Recurrence settings (None / Daily / Weekly / Monthly)  
  - Assignment mode:  
    - Fixed executor (select user)  
    - Automatic rotation (select participant list)  
    - Up-for-Grabs (no executor)  
- **Task Views**:  
  - **My Tasks**: Tasks assigned to current user  
  - **All Tasks**: Complete group task list (admin only)  
  - **Up-for-Grabs**: Tasks with no executor; include “Claim” button  
  - **Review Queue**: Tasks with “Pending Review” status (admin only)  
- **Task Actions**:  
  - **Complete Task**: Button visible only to executor; triggers status change to “Pending Review” (if approval required) or “Completed”  
  - **Approve/Reject**: Visible only to admin on review tasks; reject requires reason input  
  - **Edit/Delete**: Only for task author or admin  

### 3.4 Rotation & Distribution Logic (UI Representation)  
- **Rotation Schedule View**: Visual timeline or list showing:  
  - Upcoming task assignments  
  - Executor for each instance  
  - “Away” status indicators  
- **Load Balancing Indicator**: If enabled, show “Workload” metric per user (e.g., accumulated task weight)  
- **Auto-assignment Notifications**: Toast or banner when a new task is assigned via rotation  

### 3.5 Gamification System  
- **Points Display**: Current balance shown in header/profile  
- **Reward Catalog**:  
  - Grid/list of rewards with name, description, cost (in points)  
  - “Request Reward” button (enabled only if balance ≥ cost)  
- **Reward Request Flow**:  
  - Confirmation modal  
  - Success message: “Request sent to administrator”  
  - Admin receives notification  
- **Leaderboard**:  
  - Optional tab (visible only if enabled in group settings)  
  - Ranked list by total points (current period)  
  - Show user’s position highlighted  

### 3.6 Notifications & Alerts  
- **In-App Notification Center**:  
  - Real-time updates for:  
    - New task assignment  
    - Deadline reminders (24h, 1h)  
    - Task approval/rejection  
    - Reward request status change  
- **Visual Indicators**: Badge on notification icon for unread items  
- **Persistent Alerts**: For critical actions (e.g., “Task overdue”)  

### 3.7 User Profile & Statistics  
- **Profile Page**:  
  - Name, email, status (“Active” / “Away”)  
  - “Set as Away” toggle with date range picker  
- **Statistics Panel**:  
  - Total points  
  - % tasks completed on time  
  - Current leaderboard rank  
  - Transaction history (earned/spent points)  

### 3.8 View Modes  
The task list must support three interchangeable views:  
- **List**: Standard vertical list with filters  
- **Kanban Board**: Columns by status (To Do, In Progress, Review, Done)  
- **Calendar**: Monthly view with tasks pinned to deadline dates  

User’s preferred view must be persisted per group.

---

## 4. Non-Functional Requirements

### 4.1 Performance  
- Initial page load < 2s on 3G  
- Task list rendering < 500ms with 50 tasks  
- API responses must be cached and refetched intelligently (via React Query)

### 4.2 Responsiveness  
- Fully responsive layout for:  
  - Mobile (320px+)  
  - Tablet (768px+)  
  - Desktop (1024px+)  
- Touch-friendly controls (min 48×48px tap targets)

### 4.3 Accessibility  
- WCAG 2.1 AA compliance:  
  - Semantic HTML  
  - Keyboard navigation  
  - ARIA labels for dynamic content  
  - Sufficient color contrast  

### 4.4 Internationalization  
- All UI text must be externalized via i18n keys  
- Primary language: **Russian** (as per ТЗ)  
- Architecture must support adding English or other languages later

### 4.5 Security  
- No sensitive data stored in localStorage (use secure HTTP-only cookies for auth if needed)  
- All user inputs must be sanitized to prevent XSS  
- Role checks must be enforced on frontend **and** backend (frontend is not trusted)

### 4.6 Browser Support  
- Chrome, Firefox, Safari, Edge — latest 2 versions  
- Mobile: iOS Safari 13+, Android Chrome 8.0+

---

## 5. Integration Requirements

### 5.1 Backend API  
- Communicate exclusively via **GraphQL** (same API as mobile app)  
- Use **urql** or **Apollo Client** for data fetching and mutations  
- Handle authentication via **JWT** in Authorization header  

### 5.2 Data Synchronization  
- Real-time updates via **GraphQL Subscriptions** (if supported by backend) or polling (fallback)  
- Optimistic UI updates for task status changes and reward requests  

### 5.3 Error Handling  
- Display user-friendly messages for:  
  - Network errors  
  - Validation failures  
  - Permission denied  
  - Server errors (5xx)  
- Log detailed errors to console (dev mode only)

---

## 6. UI/UX Requirements

### 6.1 Design System  
- Built with **Material UI**  
- Use **Radix UI** or **Headless UI** for accessible primitives  
- Consistent spacing, typography, and color palette  

### 6.2 Core Pages (Routes)  
| Route | Access | Description |
|-------|--------|-------------|
| `/` | Public | Welcome / login redirect |
| `/login` | Public | Authentication |
| `/register` | Public | User registration |
| `/dashboard` | Authenticated | User’s group list |
| `/group/:id` | Group member | Main group view (default: task list) |
| `/group/:id/tasks` | Group member | Task management |
| `/group/:id/rewards` | Group member (if enabled) | Reward catalog |
| `/group/:id/leaderboard` | Group member (if enabled) | Leaderboard |
| `/group/:id/review` | Admin only | Task approval queue |
| `/group/:id/members` | Admin only | Participant management |
| `/group/:id/settings` | Admin only | Group configuration |
| `/profile` | Authenticated | User profile & stats |

### 6.3 State Management  
- Global state: **Zustand** (for UI state, modals, notifications)  
- Server state: **React Query** (for tasks, groups, users, rewards)  
- Form state: **React Hook Form** with Zod validation  

---

## 7. Out of Scope (MVP)  
- Offline mode  
- File uploads (e.g., proof of task completion)  
- Push notifications (web push)  
- Advanced analytics or reporting  
- Multi-language support beyond Russian  

---

## 8. Success Metrics  
- 100% coverage of user stories from ТЗ and Модель использования ИС  
- All role-based permissions correctly enforced in UI  
- Zero critical accessibility violations  
- Core user flows (create group, assign task, claim reward) completed in ≤ 3 clicks  
