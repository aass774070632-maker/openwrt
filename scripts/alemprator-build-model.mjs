#!/usr/bin/env node
import { createHash } from 'node:crypto';
import { copyFile, readFile, stat, unlink, writeFile } from 'node:fs/promises';
import { constants, existsSync } from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const scriptPath = fileURLToPath(import.meta.url);
const openwrtRoot = path.resolve(path.dirname(scriptPath), '..');
const registryPath = path.join(openwrtRoot, 'alemprator-models.json');
const activeConfigPath = path.join(openwrtRoot, '.config');

function usage() {
  console.error('Usage: node scripts/alemprator-build-model.mjs <model-id> [--no-build] [--restore-config] [--jobs N]');
}

function run(command, args) {
  const result = spawnSync(command, args, {
    cwd: openwrtRoot,
    stdio: 'inherit',
    shell: false,
  });

  if (result.status !== 0) {
    throw new Error(`${command} ${args.join(' ')} failed with exit code ${result.status}`);
  }
}

function parseArgs(argv) {
  const flags = new Set();
  let modelId;
  let jobs = String(process.env.JOBS ?? '');

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--jobs') {
      jobs = argv[index + 1] ?? '';
      index += 1;
      continue;
    }
    if (arg.startsWith('--')) {
      flags.add(arg);
      continue;
    }
    modelId = arg;
  }

  return { modelId, flags, jobs };
}

function requireConfigLine(configText, expectedLine) {
  if (!configText.includes(`${expectedLine}\n`) && !configText.endsWith(expectedLine)) {
    throw new Error(`Missing expected .config line: ${expectedLine}`);
  }
}

async function sha256File(filePath) {
  return createHash('sha256').update(await readFile(filePath)).digest('hex');
}

async function main() {
  const { modelId, flags, jobs } = parseArgs(process.argv.slice(2));

  if (!modelId) {
    usage();
    process.exitCode = 2;
    return;
  }

  const registry = JSON.parse(await readFile(registryPath, 'utf8'));
  const entry = registry.models?.[modelId];

  if (!entry) {
    throw new Error(`Unknown model "${modelId}". Expected one of: ${Object.keys(registry.models ?? {}).join(', ')}`);
  }

  const sourceConfigPath = path.join(openwrtRoot, entry.openwrt.configFile);
  if (!existsSync(sourceConfigPath)) {
    throw new Error(`Model config file does not exist: ${entry.openwrt.configFile}`);
  }

  const previousConfig = existsSync(activeConfigPath) ? await readFile(activeConfigPath) : null;
  const restoreConfig = flags.has('--restore-config');
  const buildImage = !flags.has('--no-build');

  try {
    await copyFile(sourceConfigPath, activeConfigPath, constants.COPYFILE_FICLONE_FORCE).catch(async () => {
      await copyFile(sourceConfigPath, activeConfigPath);
    });

    run('make', ['defconfig']);

    const configText = await readFile(activeConfigPath, 'utf8');
    const target = entry.openwrt.target;
    const subtarget = entry.openwrt.subtarget;
    const profile = entry.openwrt.profile;

    requireConfigLine(configText, `CONFIG_TARGET_${target}=y`);
    requireConfigLine(configText, `CONFIG_TARGET_${target}_${subtarget}=y`);
    requireConfigLine(configText, `CONFIG_TARGET_${target}_${subtarget}_${profile}=y`);
    requireConfigLine(configText, `CONFIG_TARGET_PROFILE="${profile}"`);

    const requiredPackages = registry.sharedPackages ?? [];
    for (const packageName of requiredPackages) {
      requireConfigLine(configText, `CONFIG_PACKAGE_${packageName}=y`);
    }

    if (buildImage) {
      const makeArgs = jobs ? [`-j${jobs}`] : [];
      run('make', makeArgs);
    }

    const imagePath = path.join(openwrtRoot, entry.openwrt.imagePath);
    const imageExists = existsSync(imagePath);
    let imageSha256 = null;
    let imageSize = null;

    if (buildImage || imageExists) {
      if (!imageExists) {
        throw new Error(`Expected image was not found: ${entry.openwrt.imagePath}`);
      }
      const imageStats = await stat(imagePath);
      imageSize = imageStats.size;
      imageSha256 = await sha256File(imagePath);
    }

    console.log(JSON.stringify({
      modelId,
      boardName: entry.boardName,
      profile,
      configFile: entry.openwrt.configFile,
      requiredPackages,
      buildImage,
      imagePath: entry.openwrt.imagePath,
      imageSize,
      imageSha256,
      configRestored: restoreConfig,
    }, null, 2));
  } finally {
    if (restoreConfig) {
      if (previousConfig) {
        await writeFile(activeConfigPath, previousConfig);
      } else if (existsSync(activeConfigPath)) {
        await unlink(activeConfigPath);
      }
    }
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});