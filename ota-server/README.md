# ALemprator OTA Server

This directory contains the standalone self-hosted OTA backend scaffold created during Week 1 of the execution plan.

## What Exists In This Stage

1. NestJS-style backend structure
2. Environment configuration skeleton
3. Health module
4. OTA DTOs and controller skeleton
5. Prisma schema draft
6. Docker and Nginx deployment skeleton

## What Does Not Exist Yet

1. Installed dependencies
2. Database migrations applied
3. Real OTA business logic
4. Admin authentication
5. Admin dashboard

## Intended Commands

When Node.js and npm are available:

```bash
npm install
npm run prisma:generate
npm run build
npm run start:dev
```

## Smoke Test Release

To create a reusable OTA smoke-test release for `AR-07-102H`:

```bash
npm run seed:test-release
```

This seeds an active stable release that points to the placeholder firmware artifact at `/firmware/AR-07-102H-1.1.0-test.bin`. It is only for backend and delivery validation and must not be flashed to devices.

## Model Registry

Supported model metadata is defined once in `../alemprator-models.json`. Dashboard seed scripts read that registry instead of carrying their own KM12/KM14/AR07 tables.

```bash
npm run seed:models
npm run seed:release -- km12
npm run seed:release -- km14
npm run seed:test-release
```

Release seeding refuses to replace an existing `model` + `version` by default. To intentionally refresh an existing release and artifact metadata, pass an explicit overwrite guard:

```bash
npm run seed:release -- km12 --allow-overwrite
npm run seed:test-release -- ar07 --allow-overwrite
```

For non-interactive jobs, set `ALEMPRATOR_ALLOW_RELEASE_OVERWRITE=1` instead of passing the flag.

## One-Command OTA Smoke Test

After the API is up and the test release is seeded, run:

```bash
npm run smoke:e2e
```

This executes a full flow: health, register, update, heartbeat, and model-mismatch rejection.

## OTA Security Settings

Optional environment variables:

- `OTA_HMAC_SECRET`: when set, OTA clients must send `X-OTA-TS` and `X-OTA-Signature` headers.
- `OTA_HMAC_MAX_SKEW_SECONDS`: maximum allowed timestamp skew for HMAC validation.
- `OTA_RATE_LIMIT_WINDOW_SECONDS`: sliding window duration for OTA endpoint throttling.
- `OTA_RATE_LIMIT_MAX_REQUESTS`: max requests per token+IP+endpoint in the configured window.

## Admin Release API

The backend now exposes a small admin API protected by an admin `Bearer` access token.

Example login request:

```bash
curl -fsS -X POST http://127.0.0.1:8080/api/admin/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@example.com","password":"CHANGE_ME"}'
```

Example list request:

```bash
curl -fsS http://127.0.0.1:8080/api/admin/releases \
  -H 'Authorization: Bearer <access-token>'
```

Example create request:

```bash
curl -fsS -X POST http://127.0.0.1:8080/api/admin/releases \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <access-token>' \
  -d '{
    "model": "AR-07-102H",
    "version": "1.1.1-test",
    "artifact_path": "/firmware/AR-07-102H-1.1.0-test.bin",
    "changelog": "Created through admin API"
  }'
```

`artifact_path` must point to a file under `public/firmware`. The service computes `sha256`, file size, and the public download URL automatically.

## Admin Auth API

Before logging in for the first time, create or refresh the admin account from `.env`:

```bash
npm run seed:admin
```

Then use the auth endpoints:

```bash
curl -fsS -X POST http://127.0.0.1:8080/api/admin/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@example.com","password":"CHANGE_ME"}'
```

Get the current admin from the access token:

```bash
curl -fsS http://127.0.0.1:8080/api/admin/auth/me \
  -H 'Authorization: Bearer <access-token>'
```

Refresh the session:

```bash
curl -fsS -X POST http://127.0.0.1:8080/api/admin/auth/refresh \
  -H 'Content-Type: application/json' \
  -d '{"refresh_token":"<refresh-token>"}'
```

Logout the session:

```bash
curl -fsS -X POST http://127.0.0.1:8080/api/admin/auth/logout \
  -H 'Content-Type: application/json' \
  -d '{"refresh_token":"<refresh-token>"}'
```

## Directory Layout

```text
ota-server/
  src/
  prisma/
  docker/
  docs/
```

## Related Documents

See the weekly execution plan in:

- `../package/luci-app-alemprator-ota/SELF-HOSTED-WEEKLY-PLAN.md`
