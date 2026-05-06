import { createHash } from 'node:crypto';
import { readFile, stat } from 'node:fs/promises';
import path from 'node:path';
import { PrismaClient } from '@prisma/client';
import {
  firmwareModelData,
  getCliTarget,
  getModelEntry,
  otaServerRoot,
  releaseOverwriteAllowed,
  trimTrailingSlash,
} from './model-registry.mjs';

const prisma = new PrismaClient();

const target = getCliTarget('ar07', 'ALEMPRATOR_TEST_RELEASE_TARGET');
const allowOverwrite = releaseOverwriteAllowed();

async function ensureFirmwareModel(tx, entry) {
  const modelData = firmwareModelData(entry);

  return tx.firmwareModel.upsert({
    where: {
      modelKey: modelData.modelKey,
    },
    update: {
      slug: modelData.slug,
      displayName: modelData.displayName,
      boardIdentifier: modelData.boardIdentifier,
      artifactKind: modelData.artifactKind,
      notes: modelData.notes,
      active: true,
    },
    create: {
      slug: modelData.slug,
      modelKey: modelData.modelKey,
      displayName: modelData.displayName,
      boardIdentifier: modelData.boardIdentifier,
      artifactKind: modelData.artifactKind,
      notes: modelData.notes,
      active: true,
    },
  });
}

async function main() {
  const entry = await getModelEntry(target);
  const testRelease = entry.testRelease;

  if (!testRelease) {
    throw new Error(`Model "${target}" does not define a test release seed.`);
  }

  const artifactPath = path.join(otaServerRoot, testRelease.artifactRelativePath);
  const artifactPublicPath = testRelease.artifactPublicPath;
  const model = entry.dashboard.modelKey;
  const version = entry.firmware.version;
  const versionCode = entry.firmware.versionCode ?? version;
  const [buffer, fileStats] = await Promise.all([readFile(artifactPath), stat(artifactPath)]);
  const sha256 = createHash('sha256').update(buffer).digest('hex');
  const publicBaseUrl = trimTrailingSlash(process.env.FIRMWARE_PUBLIC_BASE_URL ?? testRelease.publicBaseUrlDefault);
  const downloadUrl = `${publicBaseUrl}${artifactPublicPath}`;
  const channel = testRelease.channel ?? 'stable';

  const existingRelease = await prisma.release.findFirst({
    where: {
      model,
      version,
    },
    select: {
      id: true,
    },
  });

  if (existingRelease && !allowOverwrite) {
    throw new Error(
      `Release ${model} ${version} already exists. Re-run with --allow-overwrite or ALEMPRATOR_ALLOW_RELEASE_OVERWRITE=1 to replace it.`,
    );
  }

  await prisma.$transaction(async (tx) => {
    const firmwareModel = await ensureFirmwareModel(tx, entry);

    if (allowOverwrite) {
      await tx.releaseFile.deleteMany({
        where: {
          release: {
            model,
            version,
          },
        },
      });

      await tx.release.deleteMany({
        where: {
          model,
          version,
        },
      });
    }

    await tx.release.updateMany({
      where: {
        model,
        active: true,
        channel,
      },
      data: {
        active: false,
      },
    });

    await tx.release.create({
      data: {
        model,
        firmwareModelId: firmwareModel.id,
        version,
        versionCode,
        downloadUrl,
        sha256,
        changelog: testRelease.changelog,
        force: false,
        rolloutPercent: 100,
        active: true,
        channel,
        files: {
          create: [
            {
              kind: 'sysupgrade',
              url: downloadUrl,
              sha256,
              sizeBytes: BigInt(fileStats.size),
            },
          ],
        },
      },
    });
  });

  console.log(JSON.stringify({ target, model, version, downloadUrl, sha256, overwritten: Boolean(existingRelease) }, null, 2));
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });