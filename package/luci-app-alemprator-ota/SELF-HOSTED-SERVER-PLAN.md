# ALemprator OTA Self-Hosted Server Plan

This document defines a complete plan to build the OTA server and backend from scratch for the existing OpenWrt OTA client.

This plan does not depend on KartNet or any existing backend.
It assumes we will create a dedicated OTA platform as a standalone service.

## 1) Objective

Build a production-ready OTA platform that can:

1. register OpenWrt devices
2. store per-device identity and state
3. publish firmware releases per model
4. let devices check for updates
5. support staged rollout and release policies
6. serve firmware binaries over HTTPS
7. expose an operator/admin interface

The router-side OTA client already exists in this package.
The missing piece is the standalone backend and release platform.

## 2) Scope

The self-hosted OTA platform should include five major parts:

1. OTA API service
2. database
3. firmware file storage
4. admin/operator panel
5. deployment and observability layer

This plan is intentionally backend-first and infra-aware, not just an endpoint list.

## 3) Recommended Technology Stack

Recommended default stack:

1. API backend: NestJS
2. Database: PostgreSQL
3. ORM: Prisma or TypeORM
4. Object/file storage: S3-compatible storage or local Nginx-served storage
5. Reverse proxy: Nginx
6. Containerization: Docker + Docker Compose initially
7. Admin UI: small React or Next.js panel, or a server-rendered admin if speed matters more than polish
8. Metrics/logging: Prometheus + Grafana + Loki, or simpler file logging in phase one

Why this stack:

- NestJS is suitable for structured API modules and validation
- PostgreSQL is reliable for device/release tracking
- object storage is better than storing firmware blobs directly in the database
- Nginx gives stable TLS termination and static file delivery

## 4) High-Level Architecture

Recommended production topology:

1. `api.example.com` for JSON API
2. `dl.example.com` or a storage path for firmware binaries
3. PostgreSQL as the primary data store
4. API service responsible for device registration, release lookup, and state tracking
5. admin panel for operators to publish releases and inspect device state

Logical flow:

1. Device boots and generates token
2. Device calls `POST /api/register`
3. Device periodically calls `GET /api/update`
4. API checks release policy and returns metadata
5. Device downloads firmware from file storage
6. Device validates `sha256` and applies update locally
7. Device sends `POST /api/heartbeat`
8. Admin panel shows fleet and release state

## 5) Required API Surface

Minimum API endpoints:

1. `POST /api/register`
2. `GET /api/update`
3. `POST /api/heartbeat`

Recommended operator/admin endpoints:

1. `POST /api/admin/releases`
2. `GET /api/admin/releases`
3. `PATCH /api/admin/releases/:id`
4. `GET /api/admin/devices`
5. `GET /api/admin/devices/:id`
6. `POST /api/admin/releases/:id/activate`

Recommended health/ops endpoints:

1. `GET /health`
2. `GET /ready`
3. `GET /metrics`

## 6) Router-Facing Contract

### 6.1 Register

Endpoint:

```text
POST /api/register
```

Request body:

```json
{
  "token": "8f2d3a...",
  "model": "kt,km14-102h",
  "version": "24.10.4 (r28959-29397011cc)",
  "mac": "0c:96:cd:52:1d:f1",
  "board": "kt,km14-102h"
}
```

Response:

```json
{
  "accepted": true,
  "device_id": 123
}
```

### 6.2 Update Check

Endpoint:

```text
GET /api/update
```

Query parameters:

- `token`
- `model`
- `version`
- `mac`
- `board`

No update response:

```json
{
  "update_available": false
}
```

Update available response:

```json
{
  "update_available": true,
  "version": "24.10.5-r1",
  "download_url": "https://dl.example.com/fw/km14-102h-24.10.5-r1.bin",
  "download_urls": [
    "https://dl.example.com/fw/km14-102h-24.10.5-r1.bin"
  ],
  "sha256": "abc123...",
  "changelog": "Fix wireless and stability issues",
  "force": false,
  "rollout_percent": 100
}
```

### 6.3 Heartbeat

Endpoint:

```text
POST /api/heartbeat
```

Request body:

```json
{
  "token": "8f2d3a...",
  "status": "idle",
  "current_version": "24.10.4 (r28959-29397011cc)",
  "last_result": "up_to_date",
  "last_error": ""
}
```

Response:

```json
{
  "ok": true
}
```

## 7) Data Model

### 7.1 `devices`

Purpose:
- store current device identity and latest state

Required fields:

- `id`
- `token` unique
- `model`
- `mac`
- `board`
- `current_version`
- `first_registered_at`
- `last_seen_at`
- `last_ip`
- `last_result`
- `last_error`
- `status`
- `created_at`
- `updated_at`

### 7.2 `releases`

Purpose:
- represent publishable firmware releases per device model

Required fields:

- `id`
- `model`
- `version`
- `version_code` sortable
- `download_url`
- `sha256`
- `changelog`
- `force` boolean
- `rollout_percent` integer
- `active` boolean
- `channel` default `stable`
- `created_at`
- `updated_at`

### 7.3 `release_files`

Purpose:
- support multiple URLs or file variants if needed later

Suggested fields:

- `id`
- `release_id`
- `kind` (`sysupgrade`, `factory`)
- `url`
- `sha256`
- `size_bytes`

### 7.4 `device_events`

Purpose:
- keep audit trail and troubleshooting history

Suggested fields:

- `id`
- `device_id`
- `event_type`
- `status`
- `message`
- `payload_json`
- `created_at`

### 7.5 `admin_users`

Purpose:
- operator access for the control panel

Required fields:

- `id`
- `email`
- `password_hash`
- `role`
- `created_at`
- `updated_at`

## 8) Release Publishing Workflow

Publishing a release should follow this order:

1. Build firmware image in OpenWrt
2. Produce final `.bin`
3. Compute `sha256`
4. Upload binary to storage
5. Create a release record in backend
6. Mark release as active for the target model
7. Set `rollout_percent`
8. Monitor device results

Important:

- firmware files should never be stored in PostgreSQL
- binary download URLs must return the real file, not HTML

## 9) Operator Panel Requirements

The admin UI should support:

1. device list
2. device detail page
3. release list
4. create release form
5. activate/deactivate release
6. change rollout percentage
7. view last error and last seen for devices

Phase one can be a minimal panel.
It does not need customer billing or multi-tenant complexity initially.

## 10) Security Requirements

Minimum security rules:

1. HTTPS only
2. JSON APIs only
3. no redirects on OTA endpoints
4. no browser session or CSRF dependency for device APIs
5. validate all payload fields
6. rate-limit public OTA routes
7. log invalid token access attempts

Recommended later:

1. HMAC-signed update metadata
2. signed release manifests
3. per-product token salts
4. allowlist / enrollment rules
5. admin audit log

## 11) Deployment Model

### Phase 1 deployment

Single VPS is acceptable.

Recommended services on one host:

1. `nginx`
2. `ota-api`
3. `postgres`
4. `admin-ui`
5. storage path or local object storage

Directory approach if using local storage:

```text
/srv/ota/files/fw/
```

### Phase 2 deployment

Split services if scale grows:

1. API service container
2. PostgreSQL managed or isolated
3. object storage externalized
4. CDN in front of firmware downloads

## 12) Recommended Project Structure

If using NestJS, recommended repository structure:

```text
ota-server/
  src/
    modules/
      auth/
      devices/
      releases/
      ota/
      heartbeat/
      admin/
    common/
    config/
  prisma/
  storage/
  docker/
  docs/
```

Suggested module responsibilities:

- `ota`: public device-facing endpoints
- `devices`: device queries and persistence
- `releases`: release publishing and lookup
- `heartbeat`: event/state ingestion
- `admin`: operator APIs
- `auth`: admin authentication only

## 13) Step-by-Step Build Plan

### Stage 1: Foundation

1. Create new backend repository
2. Initialize NestJS project
3. Add PostgreSQL connection
4. Add migrations
5. Add environment config
6. Add health endpoints

Deliverable:
- API boots successfully with DB connection

### Stage 2: Device APIs

1. Implement `POST /api/register`
2. Implement `GET /api/update`
3. Implement `POST /api/heartbeat`
4. Add DTO validation
5. Add database entities/models

Deliverable:
- routers can register, check update, and send heartbeat

### Stage 3: Release Management

1. Add release creation API
2. Add release listing API
3. Add release activation API
4. Add changelog and rollout controls

Deliverable:
- operators can publish releases without direct DB edits

### Stage 4: Admin Panel

1. Build login page
2. Build device list page
3. Build release list page
4. Build release creation form
5. Build release activation controls

Deliverable:
- usable operator control plane

### Stage 5: Hardening

1. Add structured logging
2. Add metrics
3. Add rate limiting
4. Add request tracing
5. Add signed metadata or HMAC
6. Add audit trail

Deliverable:
- production-hardening baseline

## 14) Initial Acceptance Tests

### Register

```bash
curl -X POST https://api.example.com/api/register \
  -H 'Content-Type: application/json' \
  -d '{
    "token":"test-token",
    "model":"kt,km14-102h",
    "version":"24.10.4 (r28959-29397011cc)",
    "mac":"00:11:22:33:44:55",
    "board":"kt,km14-102h"
  }'
```

Expected:

- HTTP 200 or 201
- JSON response

### Update

```bash
curl "https://api.example.com/api/update?token=test-token&model=kt,km14-102h&version=24.10.4&mac=00:11:22:33:44:55&board=kt,km14-102h"
```

Expected:

- HTTP 200
- JSON response

### Heartbeat

```bash
curl -X POST https://api.example.com/api/heartbeat \
  -H 'Content-Type: application/json' \
  -d '{
    "token":"test-token",
    "status":"idle",
    "current_version":"24.10.4",
    "last_result":"up_to_date",
    "last_error":""
  }'
```

Expected:

- HTTP 200
- JSON response

## 15) OpenWrt Integration Notes

The current router-side client already expects:

- `/api/register`
- `/api/update`
- `/api/heartbeat`

So the fastest path is to build the server to match the existing client contract, not to redesign the router protocol.

## 16) Recommended First Milestone

The first milestone should be deliberately small:

1. one device model
2. one active release
3. one public firmware file URL
4. no multi-tenant features
5. no advanced targeting
6. no signed metadata yet

Success definition for milestone one:

1. router registers successfully
2. `Check Update` returns `up_to_date` or `available`
3. release metadata is served correctly
4. firmware binary is downloadable by the router

## 17) Summary

To build the OTA server from scratch, create a standalone backend with:

1. public device APIs
2. PostgreSQL-backed device/release models
3. firmware storage over HTTPS
4. admin release management
5. staged production hardening

The router-side implementation is already in place.
The next major engineering task is now the self-hosted server.