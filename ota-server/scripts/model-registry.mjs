import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const otaServerRoot = path.resolve(__dirname, '..');
export const openwrtRoot = path.resolve(otaServerRoot, '..');
export const registryPath = path.join(openwrtRoot, 'alemprator-models.json');

let registryCache;

export async function loadModelRegistry() {
  if (!registryCache) {
    registryCache = JSON.parse(await readFile(registryPath, 'utf8'));
  }

  return registryCache;
}

export async function getModelEntries() {
  const registry = await loadModelRegistry();
  return Object.values(registry.models ?? {});
}

export async function getModelEntry(modelId) {
  const registry = await loadModelRegistry();
  const entry = registry.models?.[modelId];

  if (!entry) {
    throw new Error(`Unknown model "${modelId}". Expected one of: ${Object.keys(registry.models ?? {}).join(', ')}`);
  }

  return entry;
}

export function firmwareModelData(entry) {
  const dashboard = entry.dashboard ?? {};

  return {
    slug: dashboard.slug,
    modelKey: dashboard.modelKey,
    displayName: dashboard.displayName,
    boardIdentifier: dashboard.boardIdentifier ?? entry.boardName,
    artifactKind: dashboard.artifactKind ?? 'sysupgrade',
    notes: dashboard.notes,
  };
}

export function formatTemplate(template, values) {
  return template.replace(/\{([a-zA-Z0-9_]+)\}/g, (match, key) => {
    if (values[key] == null) {
      throw new Error(`Missing template value "${key}" for "${template}"`);
    }

    return values[key];
  });
}

export function trimTrailingSlash(value) {
  return value.endsWith('/') ? value.slice(0, -1) : value;
}

export function getCliTarget(defaultTarget, envName) {
  return process.argv.slice(2).find((arg) => !arg.startsWith('--')) ?? process.env[envName] ?? defaultTarget;
}

export function releaseOverwriteAllowed() {
  const envValue = process.env.ALEMPRATOR_ALLOW_RELEASE_OVERWRITE ?? '';
  return process.argv.includes('--allow-overwrite') || /^(1|true|yes)$/i.test(envValue);
}