import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const modelDefinitions = [
  {
    slug: 'km14-102h',
    modelKey: 'kt,km14-102h',
    displayName: 'KM14-102H',
    boardIdentifier: 'kt,km14-102h',
    artifactKind: 'sysupgrade',
    notes: 'Primary ramips production model.',
    aliases: ['KM14-102H'],
  },
  {
    slug: 'ar-07-102h',
    modelKey: 'AR-07-102H',
    displayName: 'AR-07-102H',
    boardIdentifier: 'kt,ar07-102h',
    artifactKind: 'sysupgrade',
    notes: 'Qualcommax AP profile backed by board kt,ar07-102h.',
    aliases: ['AR07-102H'],
  },
];

async function backfillFirmwareModel(tx, modelId, modelKey, boardIdentifier, aliases) {
  const deviceAliases = Array.from(new Set([modelKey, ...(aliases ?? [])]));

  const linkedDevices = await tx.device.updateMany({
    where: {
      firmwareModelId: null,
      OR: [
        {
          model: {
            in: deviceAliases,
          },
        },
        ...(boardIdentifier ? [{ board: boardIdentifier }] : []),
      ],
    },
    data: {
      firmwareModelId: modelId,
    },
  });

  const linkedReleases = await tx.release.updateMany({
    where: {
      firmwareModelId: null,
      model: {
        in: deviceAliases,
      },
    },
    data: {
      firmwareModelId: modelId,
    },
  });

  return {
    linkedDevices: linkedDevices.count,
    linkedReleases: linkedReleases.count,
  };
}

async function main() {
  const results = [];

  for (const definition of modelDefinitions) {
    const result = await prisma.$transaction(async (tx) => {
      const model = await tx.firmwareModel.upsert({
        where: {
          modelKey: definition.modelKey,
        },
        update: {
          slug: definition.slug,
          displayName: definition.displayName,
          boardIdentifier: definition.boardIdentifier,
          artifactKind: definition.artifactKind,
          notes: definition.notes,
          active: true,
        },
        create: {
          slug: definition.slug,
          modelKey: definition.modelKey,
          displayName: definition.displayName,
          boardIdentifier: definition.boardIdentifier,
          artifactKind: definition.artifactKind,
          notes: definition.notes,
          active: true,
        },
      });

      const counts = await backfillFirmwareModel(
        tx,
        model.id,
        definition.modelKey,
        definition.boardIdentifier,
        definition.aliases,
      );

      return {
        id: model.id,
        model_key: model.modelKey,
        display_name: model.displayName,
        board_identifier: model.boardIdentifier,
        linked_devices: counts.linkedDevices,
        linked_releases: counts.linkedReleases,
      };
    });

    results.push(result);
  }

  console.log(JSON.stringify(results, null, 2));
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });