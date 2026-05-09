import { createHash } from 'node:crypto';
import { readFile, readdir, stat } from 'node:fs/promises';
import path from 'node:path';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const publicFirmwareDir = './public/firmware';
const publicBaseUrl = 'https://ota.kartnet.org';

async function main() {
  const files = await readdir(publicFirmwareDir);
  console.log(`Found ${files.length} files in public/firmware`);

  for (const filename of files) {
    if (!filename.endsWith('.bin')) continue;

    const filePath = path.join(publicFirmwareDir, filename);
    const fileStats = await stat(filePath);
    const buffer = await readFile(filePath);
    const sha256 = createHash('sha256').update(buffer).digest('hex');
    
    // Extract model and version from filename
    // Example: openwrt-ramips-mt7621-kt_km12-007h-squashfs-sysupgrade-24.10.4.1-km12-r7.bin
    // We'll try to be smart or just use the filename parts
    
    let model = 'unknown';
    let version = 'unknown';
    
    if (filename.includes('km12')) model = 'kt,km12-007h';
    else if (filename.includes('km14')) model = 'kt,km14-102h';
    else if (filename.includes('ar07')) model = 'AR-07-102H';
    else if (filename.includes('ar06')) model = 'AR-06-012H';
    else if (filename.includes('dv02')) model = 'DV-02-012H';
    else if (filename.includes('gapd')) model = 'LG-GAPD-7500';
    
    // Try to extract version from end of name before .bin
    const parts = filename.replace('.bin', '').split('-');
    version = parts[parts.length - 1];
    
    const downloadUrl = `${publicBaseUrl}/firmware/${filename}`;

    const existing = await prisma.release.findFirst({
      where: { model, version }
    });

    if (existing) {
      console.log(`Skipping ${filename} (already exists)`);
      continue;
    }

    // Find or create FirmwareModel
    let firmwareModel = await prisma.firmwareModel.findUnique({
      where: { modelKey: model }
    });

    if (!firmwareModel) {
       // Create dummy if missing (though they should be there from previous seeds)
       firmwareModel = await prisma.firmwareModel.create({
         data: {
           slug: model.replace(/[^a-z0-9]/gi, '-').toLowerCase(),
           modelKey: model,
           displayName: model,
           active: true
         }
       });
    }

    await prisma.release.create({
      data: {
        model,
        firmwareModelId: firmwareModel.id,
        version,
        versionCode: version,
        downloadUrl,
        sha256,
        changelog: `Restored from file: ${filename}`,
        active: false, // Default to inactive so user can choose
        channel: 'stable',
        files: {
          create: [
            {
              kind: 'sysupgrade',
              url: downloadUrl,
              sha256,
              sizeBytes: BigInt(fileStats.size)
            }
          ]
        }
      }
    });

    console.log(`Seeded ${filename} for model ${model}`);
  }
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
