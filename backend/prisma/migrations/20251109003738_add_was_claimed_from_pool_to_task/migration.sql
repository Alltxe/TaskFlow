-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
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
    "was_claimed_from_pool" BOOLEAN NOT NULL DEFAULT false,
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
