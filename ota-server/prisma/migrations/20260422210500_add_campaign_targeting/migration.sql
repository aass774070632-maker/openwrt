-- AlterTable
ALTER TABLE "devices" ADD COLUMN "firmware_model_id" INTEGER;

-- AlterTable
ALTER TABLE "releases" ADD COLUMN "firmware_model_id" INTEGER;

-- CreateTable
CREATE TABLE "firmware_models" (
    "id" SERIAL NOT NULL,
    "slug" TEXT NOT NULL,
    "model_key" TEXT NOT NULL,
    "display_name" TEXT NOT NULL,
    "board_identifier" TEXT,
    "artifact_kind" TEXT NOT NULL DEFAULT 'sysupgrade',
    "notes" TEXT,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "firmware_models_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "device_groups" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "device_groups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "device_group_members" (
    "id" SERIAL NOT NULL,
    "device_id" INTEGER NOT NULL,
    "group_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "device_group_members_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "device_tags" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "color" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "device_tags_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "device_tag_members" (
    "id" SERIAL NOT NULL,
    "device_id" INTEGER NOT NULL,
    "tag_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "device_tag_members_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "campaigns" (
    "id" SERIAL NOT NULL,
    "release_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "channel" TEXT NOT NULL DEFAULT 'stable',
    "priority" INTEGER NOT NULL DEFAULT 100,
    "rollout_percent" INTEGER NOT NULL DEFAULT 100,
    "active" BOOLEAN NOT NULL DEFAULT false,
    "start_at" TIMESTAMP(3),
    "end_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "campaigns_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "campaign_target_rules" (
    "id" SERIAL NOT NULL,
    "campaign_id" INTEGER NOT NULL,
    "rule_type" TEXT NOT NULL,
    "operator" TEXT NOT NULL DEFAULT 'eq',
    "value_string" TEXT,
    "value_json" JSONB,
    "is_exclude" BOOLEAN NOT NULL DEFAULT false,
    "group_id" INTEGER,
    "tag_id" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "campaign_target_rules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "campaign_devices" (
    "id" SERIAL NOT NULL,
    "campaign_id" INTEGER NOT NULL,
    "device_id" INTEGER NOT NULL,
    "eligibility_status" TEXT NOT NULL DEFAULT 'pending',
    "update_status" TEXT,
    "last_evaluated_at" TIMESTAMP(3),
    "matched_at" TIMESTAMP(3),
    "delivered_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "campaign_devices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" SERIAL NOT NULL,
    "admin_user_id" INTEGER,
    "action" TEXT NOT NULL,
    "entity_type" TEXT NOT NULL,
    "entity_id" TEXT,
    "payload_json" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "firmware_models_slug_key" ON "firmware_models"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "firmware_models_model_key_key" ON "firmware_models"("model_key");

-- CreateIndex
CREATE UNIQUE INDEX "device_groups_name_key" ON "device_groups"("name");

-- CreateIndex
CREATE UNIQUE INDEX "device_group_members_device_id_group_id_key" ON "device_group_members"("device_id", "group_id");

-- CreateIndex
CREATE INDEX "device_group_members_group_id_idx" ON "device_group_members"("group_id");

-- CreateIndex
CREATE UNIQUE INDEX "device_tags_name_key" ON "device_tags"("name");

-- CreateIndex
CREATE UNIQUE INDEX "device_tag_members_device_id_tag_id_key" ON "device_tag_members"("device_id", "tag_id");

-- CreateIndex
CREATE INDEX "device_tag_members_tag_id_idx" ON "device_tag_members"("tag_id");

-- CreateIndex
CREATE INDEX "campaigns_release_id_idx" ON "campaigns"("release_id");

-- CreateIndex
CREATE INDEX "campaigns_active_channel_priority_idx" ON "campaigns"("active", "channel", "priority");

-- CreateIndex
CREATE INDEX "campaign_target_rules_campaign_id_idx" ON "campaign_target_rules"("campaign_id");

-- CreateIndex
CREATE INDEX "campaign_target_rules_group_id_idx" ON "campaign_target_rules"("group_id");

-- CreateIndex
CREATE INDEX "campaign_target_rules_tag_id_idx" ON "campaign_target_rules"("tag_id");

-- CreateIndex
CREATE UNIQUE INDEX "campaign_devices_campaign_id_device_id_key" ON "campaign_devices"("campaign_id", "device_id");

-- CreateIndex
CREATE INDEX "campaign_devices_device_id_idx" ON "campaign_devices"("device_id");

-- CreateIndex
CREATE INDEX "audit_logs_admin_user_id_idx" ON "audit_logs"("admin_user_id");

-- CreateIndex
CREATE INDEX "audit_logs_entity_type_entity_id_idx" ON "audit_logs"("entity_type", "entity_id");

-- CreateIndex
CREATE INDEX "devices_firmware_model_id_idx" ON "devices"("firmware_model_id");

-- CreateIndex
CREATE INDEX "releases_firmware_model_id_idx" ON "releases"("firmware_model_id");

-- AddForeignKey
ALTER TABLE "devices" ADD CONSTRAINT "devices_firmware_model_id_fkey" FOREIGN KEY ("firmware_model_id") REFERENCES "firmware_models"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "releases" ADD CONSTRAINT "releases_firmware_model_id_fkey" FOREIGN KEY ("firmware_model_id") REFERENCES "firmware_models"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "device_group_members" ADD CONSTRAINT "device_group_members_device_id_fkey" FOREIGN KEY ("device_id") REFERENCES "devices"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "device_group_members" ADD CONSTRAINT "device_group_members_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "device_groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "device_tag_members" ADD CONSTRAINT "device_tag_members_device_id_fkey" FOREIGN KEY ("device_id") REFERENCES "devices"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "device_tag_members" ADD CONSTRAINT "device_tag_members_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "device_tags"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "campaigns" ADD CONSTRAINT "campaigns_release_id_fkey" FOREIGN KEY ("release_id") REFERENCES "releases"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "campaign_target_rules" ADD CONSTRAINT "campaign_target_rules_campaign_id_fkey" FOREIGN KEY ("campaign_id") REFERENCES "campaigns"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "campaign_target_rules" ADD CONSTRAINT "campaign_target_rules_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "device_groups"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "campaign_target_rules" ADD CONSTRAINT "campaign_target_rules_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "device_tags"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "campaign_devices" ADD CONSTRAINT "campaign_devices_campaign_id_fkey" FOREIGN KEY ("campaign_id") REFERENCES "campaigns"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "campaign_devices" ADD CONSTRAINT "campaign_devices_device_id_fkey" FOREIGN KEY ("device_id") REFERENCES "devices"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_admin_user_id_fkey" FOREIGN KEY ("admin_user_id") REFERENCES "admin_users"("id") ON DELETE SET NULL ON UPDATE CASCADE;