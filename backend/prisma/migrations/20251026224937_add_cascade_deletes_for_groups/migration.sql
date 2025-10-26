-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_group_members" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "user_id" TEXT NOT NULL,
    "group_id" TEXT NOT NULL,
    "role" TEXT NOT NULL,
    "joined_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "role_changed_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "group_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "group_members_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "groups" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO "new_group_members" ("group_id", "id", "joined_at", "role", "role_changed_at", "user_id") SELECT "group_id", "id", "joined_at", "role", "role_changed_at", "user_id" FROM "group_members";
DROP TABLE "group_members";
ALTER TABLE "new_group_members" RENAME TO "group_members";
CREATE UNIQUE INDEX "group_members_user_id_group_id_key" ON "group_members"("user_id", "group_id");
CREATE TABLE "new_reward_transactions" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "points_spent" INTEGER NOT NULL,
    "status" TEXT NOT NULL,
    "requested_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "approved_at" DATETIME,
    "rejected_at" DATETIME,
    "user_id" TEXT NOT NULL,
    "reward_id" TEXT NOT NULL,
    "approved_by" TEXT,
    CONSTRAINT "reward_transactions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "reward_transactions_reward_id_fkey" FOREIGN KEY ("reward_id") REFERENCES "rewards" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "reward_transactions_approved_by_fkey" FOREIGN KEY ("approved_by") REFERENCES "users" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_reward_transactions" ("approved_at", "approved_by", "id", "points_spent", "rejected_at", "requested_at", "reward_id", "status", "user_id") SELECT "approved_at", "approved_by", "id", "points_spent", "rejected_at", "requested_at", "reward_id", "status", "user_id" FROM "reward_transactions";
DROP TABLE "reward_transactions";
ALTER TABLE "new_reward_transactions" RENAME TO "reward_transactions";
CREATE TABLE "new_rewards" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "cost" INTEGER NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "image_url" TEXT,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "group_id" TEXT NOT NULL,
    "created_by" TEXT NOT NULL,
    CONSTRAINT "rewards_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "groups" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "rewards_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_rewards" ("cost", "created_at", "created_by", "description", "group_id", "id", "image_url", "is_active", "name") SELECT "cost", "created_at", "created_by", "description", "group_id", "id", "image_url", "is_active", "name" FROM "rewards";
DROP TABLE "rewards";
ALTER TABLE "new_rewards" RENAME TO "rewards";
CREATE TABLE "new_task_attachments" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "url" TEXT NOT NULL,
    "filename" TEXT NOT NULL,
    "file_size" INTEGER NOT NULL,
    "mime_type" TEXT NOT NULL,
    "uploaded_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "task_id" TEXT NOT NULL,
    "group_id" TEXT NOT NULL,
    "uploaded_by" TEXT NOT NULL,
    CONSTRAINT "task_attachments_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "tasks" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "task_attachments_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "groups" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "task_attachments_uploaded_by_fkey" FOREIGN KEY ("uploaded_by") REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_task_attachments" ("file_size", "filename", "group_id", "id", "mime_type", "task_id", "uploaded_at", "uploaded_by", "url") SELECT "file_size", "filename", "group_id", "id", "mime_type", "task_id", "uploaded_at", "uploaded_by", "url" FROM "task_attachments";
DROP TABLE "task_attachments";
ALTER TABLE "new_task_attachments" RENAME TO "task_attachments";
CREATE INDEX "task_attachments_task_id_idx" ON "task_attachments"("task_id");
CREATE TABLE "new_task_completion_attachments" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "url" TEXT NOT NULL,
    "filename" TEXT NOT NULL,
    "file_size" INTEGER NOT NULL,
    "mime_type" TEXT NOT NULL,
    "uploaded_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completion_id" TEXT NOT NULL,
    "uploaded_by" TEXT NOT NULL,
    CONSTRAINT "task_completion_attachments_completion_id_fkey" FOREIGN KEY ("completion_id") REFERENCES "task_completion_history" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "task_completion_attachments_uploaded_by_fkey" FOREIGN KEY ("uploaded_by") REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_task_completion_attachments" ("completion_id", "file_size", "filename", "id", "mime_type", "uploaded_at", "uploaded_by", "url") SELECT "completion_id", "file_size", "filename", "id", "mime_type", "uploaded_at", "uploaded_by", "url" FROM "task_completion_attachments";
DROP TABLE "task_completion_attachments";
ALTER TABLE "new_task_completion_attachments" RENAME TO "task_completion_attachments";
CREATE TABLE "new_task_completion_history" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "points_awarded" INTEGER NOT NULL,
    "completed_at" DATETIME NOT NULL,
    "approved_at" DATETIME,
    "was_up_for_grabs" BOOLEAN NOT NULL DEFAULT false,
    "was_on_time" BOOLEAN NOT NULL DEFAULT false,
    "task_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "approved_by" TEXT,
    CONSTRAINT "task_completion_history_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "tasks" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "task_completion_history_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "task_completion_history_approved_by_fkey" FOREIGN KEY ("approved_by") REFERENCES "users" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_task_completion_history" ("approved_at", "approved_by", "completed_at", "id", "points_awarded", "task_id", "user_id", "was_on_time", "was_up_for_grabs") SELECT "approved_at", "approved_by", "completed_at", "id", "points_awarded", "task_id", "user_id", "was_on_time", "was_up_for_grabs" FROM "task_completion_history";
DROP TABLE "task_completion_history";
ALTER TABLE "new_task_completion_history" RENAME TO "task_completion_history";
CREATE INDEX "task_completion_history_user_id_completed_at_idx" ON "task_completion_history"("user_id", "completed_at");
CREATE UNIQUE INDEX "task_completion_history_task_id_user_id_completed_at_key" ON "task_completion_history"("task_id", "user_id", "completed_at");
CREATE TABLE "new_tasks" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "deadline" DATETIME NOT NULL,
    "priority" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "points" INTEGER NOT NULL,
    "requires_approval" BOOLEAN NOT NULL DEFAULT true,
    "is_recurring" BOOLEAN NOT NULL DEFAULT false,
    "recurrence_rule" TEXT,
    "rotation_type" TEXT,
    "weight" INTEGER NOT NULL DEFAULT 1,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completed_at" DATETIME,
    "group_id" TEXT NOT NULL,
    "created_by" TEXT NOT NULL,
    "assignee_id" TEXT,
    "approved_by" TEXT,
    "parent_task_id" TEXT,
    CONSTRAINT "tasks_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "groups" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "tasks_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "tasks_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "users" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "tasks_approved_by_fkey" FOREIGN KEY ("approved_by") REFERENCES "users" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "tasks_parent_task_id_fkey" FOREIGN KEY ("parent_task_id") REFERENCES "tasks" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_tasks" ("approved_by", "assignee_id", "completed_at", "created_at", "created_by", "deadline", "description", "group_id", "id", "is_recurring", "parent_task_id", "points", "priority", "recurrence_rule", "requires_approval", "rotation_type", "status", "title", "weight") SELECT "approved_by", "assignee_id", "completed_at", "created_at", "created_by", "deadline", "description", "group_id", "id", "is_recurring", "parent_task_id", "points", "priority", "recurrence_rule", "requires_approval", "rotation_type", "status", "title", "weight" FROM "tasks";
DROP TABLE "tasks";
ALTER TABLE "new_tasks" RENAME TO "tasks";
CREATE INDEX "tasks_group_id_status_idx" ON "tasks"("group_id", "status");
CREATE INDEX "tasks_assignee_id_status_idx" ON "tasks"("assignee_id", "status");
CREATE INDEX "tasks_deadline_idx" ON "tasks"("deadline");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
