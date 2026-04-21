function getRequired(name: string, fallback?: string): string {
  const value = process.env[name] ?? fallback;

  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }

  return value;
}

function getNumber(name: string, fallback: number): number {
  const raw = process.env[name];

  if (!raw) {
    return fallback;
  }

  const parsed = Number(raw);

  if (Number.isNaN(parsed)) {
    throw new Error(`Invalid numeric environment variable: ${name}`);
  }

  return parsed;
}

export const env = {
  NODE_ENV: process.env.NODE_ENV ?? 'development',
  PORT: getNumber('PORT', 3000),
  API_PREFIX: getRequired('API_PREFIX', 'api'),
  DATABASE_URL: getRequired('DATABASE_URL', 'postgresql://postgres:postgres@localhost:5432/ota?schema=public'),
  ADMIN_EMAIL: getRequired('ADMIN_EMAIL', 'admin@example.com'),
  ADMIN_PASSWORD: getRequired('ADMIN_PASSWORD', 'CHANGE_ME'),
  PUBLIC_BASE_URL: getRequired('PUBLIC_BASE_URL', 'https://api.example.com'),
  FIRMWARE_PUBLIC_BASE_URL: getRequired('FIRMWARE_PUBLIC_BASE_URL', 'https://dl.example.com'),
  JWT_SECRET: getRequired('JWT_SECRET', 'CHANGE_ME_32_BYTES_MINIMUM'),
  JWT_ACCESS_SECRET: getRequired('JWT_ACCESS_SECRET', process.env.JWT_SECRET ?? 'CHANGE_ME_32_BYTES_MINIMUM'),
  JWT_ACCESS_TTL_SECONDS: getNumber('JWT_ACCESS_TTL_SECONDS', 900),
  REFRESH_TOKEN_TTL_SECONDS: getNumber('REFRESH_TOKEN_TTL_SECONDS', 604800),
};
