import { PrismaClient } from '@prisma/client';
import { firmwareModelData, getModelEntries } from './model-registry.mjs';

const prisma = new PrismaClient();

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
  const modelDefinitions = await getModelEntries();

  for (const entry of modelDefinitions) {
    const definition = firmwareModelData(entry);
    const aliases = entry.dashboard?.aliases ?? [];
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
        aliases,
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