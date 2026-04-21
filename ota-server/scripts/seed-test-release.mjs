import { createHash } from 'node:crypto';
import { readFile, stat } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const projectRoot = path.resolve(__dirname, '..');
const artifactRelativePath = 'public/firmware/AR-07-102H-1.1.0-test.bin';
const artifactPath = path.join(projectRoot, artifactRelativePath);
const artifactPublicPath = '/firmware/AR-07-102H-1.1.0-test.bin';
const model = 'AR-07-102H';
const version = '1.1.0-test';

function trimTrailingSlash(value) {
  return value.endsWith('/') ? value.slice(0, -1) : value;
}

async function main() {
  const [buffer, fileStats] = await Promise.all([readFile(artifactPath), stat(artifactPath)]);
  const sha256 = createHash('sha256').update(buffer).digest('hex');
  const publicBaseUrl = trimTrailingSlash(process.env.FIRMWARE_PUBLIC_BASE_URL ?? 'http://localhost:8080');
  const downloadUrl = `${publicBaseUrl}${artifactPublicPath}`;

  await prisma.$transaction(async (tx) => {
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

    await tx.release.updateMany({
      where: {
        model,
        active: true,
        channel: 'stable',
      },
      data: {
        active: false,
      },
    });

    await tx.release.create({
      data: {
        model,
        version,
        versionCode: '110-test',
        downloadUrl,
        sha256,
        changelog: 'Smoke-test release for OTA backend validation only.',
        force: false,
        rolloutPercent: 100,
        active: true,
        channel: 'stable',
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

  console.log(JSON.stringify({ model, version, downloadUrl, sha256 }, null, 2));
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });