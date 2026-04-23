ALTER TABLE "campaigns" ADD COLUMN "archived_at" TIMESTAMP(3);

CREATE INDEX "campaigns_archived_at_idx" ON "campaigns"("archived_at");