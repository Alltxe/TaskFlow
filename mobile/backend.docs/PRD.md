# Product Requirements Document (PRD) - Backend Server

## 1. Introduction

### 1.1 Document Purpose

This Product Requirements Document (PRD) specifies the complete requirements for the backend server of the mobile application for automated distribution of household tasks in small groups with gamification and executor rotation system. This document contains only requirements (what the system must do) without implementation details, diagrams, or visual references that would be unusable by LLMs.

### 1.2 Product Overview

The backend server is the central component that implements all business logic for the mobile application designed to optimize the process of distributing routine household tasks in small social groups. The system solves the problem of subjective distribution of responsibilities (a source of interpersonal conflicts) through objective automation and gamification.

### 1.3 Target Audience

This PRD is designed for:
- Backend developers
- System architects
- QA engineers for test case development
- LLMs assisting with code generation and system understanding

## 2. User Roles and Access Control

### 2.1 User Roles

The system must support two primary user roles:

#### 2.1.1 Group Administrator (Parent/Organizer)
- Creates groups and manages participants
- Configures rotation parameters
- Controls reward catalog
- Has critical task approval functionality
- Has full administrative control over the group

#### 2.1.2 Group Participant (Student/Neighbor)
- Primary task executor
- Can accept assigned tasks
- Can take tasks from the Up-for-Grabs pool
- Can request exchange of accumulated points for rewards
- Has limited participant access

### 2.2 Access and Permission Matrix

The backend must enforce the following permissions:

| Functional Area | Group Administrator | Group Participant |
|-----------------|---------------------|-------------------|
| Create/Delete Group | Must be allowed | Must not be allowed (Only exit permitted) |
| Invite/Remove Participants | Must be allowed | Must not be allowed |
| Create/Edit Common Tasks | Must be allowed | Must not be allowed (Only personal/private tasks allowed) |
| Configure Rotation | Must be allowed | Must only be allowed to view schedule |
| Approve Tasks | Must be allowed (If control mode enabled) | Must not be allowed (Only complete and submit for review) |
| Manage Reward Catalog | Must be allowed | Must not be allowed |
| Exchange Points for Rewards | Must be allowed | Must be allowed |
| View Leaderboard | Must be allowed | Must be allowed |

### 2.3 User State Management

The backend must manage the following user states:
- Not Authenticated: User not logged in
- Authenticated: User logged in
- Viewing Data: User browsing information
- Editing Data: User modifying information
- Away: User marked as unavailable (must affect rotation calculations)

## 3. Functional Requirements

### 3.1 User Management

#### 3.1.1 Authentication
- The backend must provide JWT-based authentication
- The backend must support user registration with email/password
- The backend must support token refresh functionality
- Passwords must be stored using secure hashing (bcrypt)

#### 3.1.2 User Profile
- The backend must store user profile information including name, email, and status
- The backend must allow users to update their profile information
- The backend must track user activity metrics for display in participant profiles

#### 3.1.3 User Statistics
- The backend must calculate and provide current point balance for each user
- The backend must calculate and provide key performance indicators (e.g., percentage of tasks completed on time)
- The backend must determine and provide user position in the Leaderboard

### 3.2 Group Management

#### 3.2.1 Group Creation and Configuration
- The backend must allow administrators to create groups with a name
- The backend must store critical configuration settings:
  - Control Mode: Must determine if administrator approval is required for task completion
  - Rotation Mode: Must define if rotation will be strictly cyclic, randomized, or disabled
  - Gamification Integration: Must enable/disable points and rewards system

#### 3.2.2 Participant Management
- The backend must generate one-time tokens or secure links for user invitations
- The backend must enforce administrator exclusive rights to remove participants and change roles
- The backend must allow participants to exit groups
- The backend must maintain complete audit logs of all participant management actions

### 3.3 Task Management

#### 3.3.1 Task CRUD Operations
- The backend must provide the following task operations:
  - `CreateTask`: Must accept title, description, deadline, priority, points (optional), and group_id; must return task_id
  - `UpdateTask`: Must accept task_id and fields_to_update; must return success/error status (only author/admin can edit)
  - `SetTaskStatus`: Must accept task_id and new_status (Pending Review, Completed, Rejected); must return success/error status

#### 3.3.2 Task Attributes
- The backend must store the following task attributes:
  - Priority & Deadline: Must affect point calculation
  - Executor: Must be explicitly assigned or left empty for Up-for-Grabs pool or rotation
  - Score Points: Must be a configurable parameter used as base evaluation
  - Requires Approval: Must be a boolean determining if task transitions to "Pending Review" after participant completion

#### 3.3.3 Recurring Task Processing
- The backend must support flexible periodicity configuration (daily, weekly, etc.)
- The backend must support two assignment methods for recurring tasks:
  - Fixed Executor: Same person each time
  - Automatic Rotation: Cyclic assignment among participants
- The backend must generate new tasks from templates 24 hours before previous task deadline

#### 3.3.4 Task State Management
- The backend must manage the following task states:
  - Created: Task exists but not yet active
  - Assigned: Task has been assigned to a specific user
  - Pending Review: Task completed but awaiting approval
  - Completed: Task finished and approved
  - Rejected: Task completed but rejected, needs rework
  - Overdue: Task deadline passed without completion
  - Up-for-Grabs: Task available for self-assignment

### 3.4 Automated Distribution and Rotation Logic

#### 3.4.1 Executor Rotation Algorithm
- The backend must implement a Round Robin distribution algorithm among active executors
- The rotation algorithm must trigger after successful completion of previous task or upon reaching scheduled task generation date
- The algorithm must sort participants by date of their last completion of this task
- If participant is marked as "Away", the algorithm must skip them until period ends
- If no available executor, task must automatically move to Up-for-Grabs pool

#### 3.4.2 Up-for-Grabs Task Pool
- The backend must provide a `ClaimTask` function that allows Participants to assign free task to themselves
- The function must require that Executor field in task equals NULL
- Tasks taken from this pool must receive a bonus to points (e.g., +10%) compared to automatically assigned tasks

#### 3.4.3 Load Balancing
- The backend must support an extended rotation mode with Load Balancing for groups with unevenly complex tasks
- Administrators must be able to assign a "Weight" to each task
- The system must track "Accumulated Weight" of completed tasks per participant
- If cyclic assignment would cause significant imbalance, system must temporarily break cycle and assign task to participant with lowest load

### 3.5 Gamification and Motivation Subsystem

#### 3.5.1 Point Awarding Rules
- Points must be awarded only after successful task completion and mandatory administrator approval
- The backend must calculate points using the formula: Points = BaseScore × Multiplier

#### 3.5.2 Point Awarding/Deduction Rules
- For successful completion on time (task approved, completed before deadline): Must apply multiplier of 1.0 to BaseScore
- For late completion (completed after deadline but approved): Must apply multiplier of 0.5 to BaseScore
- For tasks taken from Up-for-Grabs: Must apply multiplier of 1.5 to BaseScore
- For task rejection/non-completion (task rejected or overdue): Must apply multiplier of 0.0 to BaseScore
- For redemption for reward: Must deduct points equal to reward cost

#### 3.5.3 Reward Mechanism
- The backend must allow administrators to manage reward catalog with name, description, and point cost
- The backend must maintain a transaction log that tracks all point operations for transparency

#### 3.5.4 Point Redemption Logic
- When Participant requests a reward, the system must first check current point balance
- If sufficient points, requested amount must move to "Reserved" status
- The `ApproveRewardRequest` function must only be available to Administrators
  - If approved: Reserved points must be deducted (transaction status: Spent)
  - If rejected: Points must be returned from reserve to Participant's account (transaction status: Refunded)

#### 3.5.5 Leaderboard
- The backend must provide an optional Leaderboard that ranks participants based on total points earned during a selected period

### 3.6 Verification, Control, and Notification Processes

#### 3.6.1 Task Completion Process
- When Participant marks task as complete, the backend must record completion time
- If approval not required: Status must immediately change to "Completed", triggering point award
- If approval required: Status must change to "Pending Review", sending notification to Administrator

#### 3.6.2 Task Approval Process
- The backend must display task card with "Pending Review" status to Administrator
- When Administrator clicks "Approve", the system must:
  - Initiate point calculation considering timeliness
  - Record completion
  - Award points
  - Notify Participant
- When Administrator clicks "Reject", the system must:
  - Require a rejection reason
  - Change task status to "Returned for revision"
  - Send task back to Participant
  - Reset potential points
  - Notify Participant

#### 3.6.3 Notifications and Reminders
- The backend must support instant push notifications for critical events:
  - Task assignment (including rotation)
  - Deadline approaching (24 hours, 1 hour)
  - Task status change to "Pending Review" or "Returned for revision"
  - Reward requests and their status
- If task is overdue and not completed, system must automatically change status to "Overdue", blocking full point award

#### 3.6.4 Audit Logging
- The backend must maintain complete audit logs for all critical actions:
  - Role changes
  - Task approvals/rejections
  - Point transactions
  - User status changes

## 4. Non-Functional Requirements

### 4.1 Performance Requirements
- Response time for most API endpoints must be < 500ms under normal load
- System must handle concurrent operations for groups of up to 10 users
- Task rotation calculations must complete within 200ms
- System must support up to 100 independent groups simultaneously

### 4.2 Security Requirements
- All user data must be encrypted in transit (TLS 1.2+)
- Passwords must be stored using bcrypt hashing with appropriate work factor
- JWT tokens must have reasonable expiration times (access token: 15 minutes, refresh token: 7 days)
- The application must not be classified as a personal data processing information system
- Input data must be validated to prevent injection attacks and XSS

### 4.3 Reliability Requirements
- System uptime target: 99.5% during normal operation
- All critical operations must be logged for audit purposes
- Input data must be validated to prevent errors and incorrect program behavior
- Regular virus scanning must be performed in accordance with GOST R ISO/IEC 15408

### 4.4 Scalability Requirements
- Designed for small group usage (up to 10 users per group)
- Must support multiple independent groups
- Architecture must allow for future scaling to larger user bases if needed
- Must handle peak loads of 5x normal traffic for short durations

### 4.5 Data Integrity Requirements
- All database operations affecting points or critical state must use transactions
- The system must maintain referential integrity between all related entities
- Data must be validated before storage to ensure business rule compliance

## 5. API Requirements

### 5.1 Authentication API

### 5.2 User API

### 5.3 Group API

### 5.4 Task API

### 5.5 Gamification API

### 5.6 Notification API

## 6. Data Model Requirements

### 6.1 Core Entity Requirements

#### 6.1.1 User Entity
- Must have unique identifier (UUID)
- Must store email (unique)
- Must store hashed password
- Must store display name
- Must store status (Active, Away, etc.)
- Must store creation and update timestamps

#### 6.1.2 Group Entity
- Must have unique identifier (UUID)
- Must store group name
- Must reference admin user
- Must store configuration settings (JSON)
- Must store creation and update timestamps

#### 6.1.3 GroupMember Entity
- Must have unique identifier (UUID)
- Must reference group
- Must reference user
- Must store role (Admin, Participant)
- Must store membership creation time

#### 6.1.4 Task Entity
- Must have unique identifier (UUID)
- Must reference group
- Must store title, description, deadline, priority
- Must store baseScore (integer)
- Must store requiresApproval (boolean)
- Must reference executor (nullable)
- Must store status (Created, Assigned, Pending, Completed, Rejected, Overdue)
- Must reference rotation template (nullable)
- Must store isRecurring (boolean)
- Must store recurrencePattern (JSON)
- Must store creation, completion, and approval timestamps

#### 6.1.5 Reward Entity
- Must have unique identifier (UUID)
- Must reference group
- Must store name and description
- Must store cost (integer)
- Must store creation and update timestamps

#### 6.1.6 PointTransaction Entity
- Must have unique identifier (UUID)
- Must reference user
- Must reference group
- Must store type (Earned, Spent, Refunded, Reserved)
- Must store amount (integer)
- Must reference task (optional)
- Must reference reward request (optional)
- Must store description
- Must store transaction time

#### 6.1.7 RewardRequest Entity
- Must have unique identifier (UUID)
- Must reference user
- Must reference reward
- Must store status (Requested, Reserved, Approved, Rejected, Completed)
- Must store reservedPoints (integer)
- Must store request and processing times
- Must store rejectionReason (optional)

## 7. Business Rules

### 7.1 Rotation Algorithm Rules

#### 7.1.1 Basic Round Robin Rules
- The system must get all active participants for the group
- The system must determine the next executor based on rotation history:
  - If previous task exists: Find position of last executor and select next in line (circular)
  - If no previous task: Use first participant in the list
- The system must create new task instance with next executor

#### 7.1.2 Weighted Random Distribution Rules
- For randomized distribution mode:
  - The system must calculate weights based on inverse task count (to give less busy users higher chance)
  - The system must normalize weights to probabilities
  - The system must select participant based on random probability selection

#### 7.1.3 Load Balancing Rules
- The system must calculate accumulated weight for each participant
- If imbalance exceeds threshold (e.g., 2x), the system must assign task to participant with lowest accumulated weight
- Otherwise, the system must fall back to regular rotation

### 7.2 Scoring Rules

#### 7.2.1 Point Calculation Rules
- Base score must come from task definition
- If completed on time: Must multiply base score by 1.0
- If completed late: Must multiply base score by 0.5
- If task was from Up-for-Grabs pool: Must multiply base score by 1.5
- Final points must be rounded to nearest integer

### 7.3 Reward Redemption Rules

#### 7.3.1 Request Process Rules
- The system must check user's point balance against reward cost
- If sufficient points, the system must:
  - Create reward request in "Requested" status
  - Reserve points (move to "Reserved" status)
  - Update request status to "Reserved"

#### 7.3.2 Approval Process Rules
- The system must confirm request is in "Reserved" status before approval
- On approval, the system must:
  - Deduct reserved points from user's balance
  - Update transaction status to "Spent"
  - Update request status to "Approved"
- On rejection, the system must:
  - Return points from reserve to user's balance
  - Update transaction status to "Refunded"
  - Update request status to "Rejected" with reason

### 7.4 Task Deadline Rules
- If task is overdue and not completed, the system must:
  - Automatically change status to "Overdue"
  - Apply multiplier of 0.0 to base score
  - Prevent further point award for this task instance
  - Continue rotation to next executor for recurring tasks

## 8. Additional Requirements

### 8.1 Internationalization
- The backend must support English language for all system-generated messages
- The backend must be designed to support additional languages in future

### 8.2 Error Handling
- The backend must return appropriate HTTP status codes for all responses
- The backend must provide clear, human-readable error messages for client consumption
- The backend must log detailed error information for debugging purposes while avoiding sensitive data exposure

### 8.3 Rate Limiting
- The backend must implement rate limiting on authentication endpoints
- The backend must limit excessive API requests from single users to prevent abuse
- Rate limits must be configurable per endpoint type