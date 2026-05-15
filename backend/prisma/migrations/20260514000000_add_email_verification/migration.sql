-- AlterTable: add email_verified_at column to users
ALTER TABLE "users" ADD COLUMN "email_verified_at" TIMESTAMP(3);

-- Deduplicate usernames before adding unique constraint
-- Appends _N to duplicate usernames (keeping the first occurrence as-is)
DO $$
DECLARE
  dup_username TEXT;
  dup_id TEXT;
  cnt INT;
BEGIN
  FOR dup_username IN (SELECT username FROM users GROUP BY username HAVING COUNT(*) > 1)
  LOOP
    cnt := 0;
    FOR dup_id IN (SELECT id FROM users WHERE username = dup_username ORDER BY created_at ASC OFFSET 1)
    LOOP
      cnt := cnt + 1;
      UPDATE users SET username = dup_username || '_' || cnt WHERE id = dup_id;
    END LOOP;
  END LOOP;
END $$;

-- AlterTable: make username unique
ALTER TABLE "users" ADD CONSTRAINT "users_username_key" UNIQUE ("username");

-- CreateTable: email_verifications
CREATE TABLE "email_verifications" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "used_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "user_id" TEXT NOT NULL,

    CONSTRAINT "email_verifications_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "email_verifications_user_id_idx" ON "email_verifications"("user_id");

-- AddForeignKey
ALTER TABLE "email_verifications" ADD CONSTRAINT "email_verifications_user_id_fkey"
    FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
