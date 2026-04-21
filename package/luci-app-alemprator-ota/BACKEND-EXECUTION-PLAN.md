# ALemprator OTA Backend Execution Plan

This document defines the backend/server work needed to make the existing OpenWrt OTA client operate against the KartNet backend.

## 1) Goal

The router-side OTA client is already implemented and deployed.
The missing part is the backend API and release management workflow.

The current router expects:

- Base URL: `https://api.kartnet.org`
- Register endpoint: `POST /api/register`
- Update endpoint: `GET /api/update`
- Heartbeat endpoint: `POST /api/heartbeat`

At the time of writing, these OTA endpoints do not exist on the backend yet.

## 2) Current Router Contract

The OpenWrt OTA client already performs the following steps:

1. Generate a deterministic per-device token
2. Register the router if not yet registered
3. Check for available firmware updates
4. Apply rollout and update-window policy on the router side
5. Download firmware image
6. Verify `sha256`
7. Validate image using `sysupgrade -T`
8. Execute `sysupgrade`

This means the backend is not responsible for flashing devices.
The backend only provides identity handling, release metadata, and state tracking.

## 3) Recommended Backend Topology

Recommended production topology:

1. `api.kartnet.org` as the public API hostname
2. Cloudflare optional, acting only as DNS / TLS / edge protection
3. KartNet backend as the real API origin
4. Firmware files served from either:
   - the same backend domain
   - object storage
   - a CDN/static file origin

Cloudflare is not the OTA logic itself.
Cloudflare may sit in front of the API, but the backend must still implement the OTA routes and release logic.

## 4) Minimum API Surface

The minimum viable API is exactly three endpoints.

### 4.1 `POST /api/register`

Purpose:
- Create or update a device record

Expected request body:

```json
{
  "token": "8f2d3a...",
  "model": "kt,km14-102h",
  "version": "24.10.4 (r28959-29397011cc)",
  "mac": "0c:96:cd:52:1d:f1",
  "board": "kt,km14-102h"
}
```

Expected response:

```json
{
  "accepted": true,
  "device_id": 123
}
```

Server behavior:

1. Look up device by `token`
2. If not found, create it
3. If found, update metadata
4. Store `last_seen_at`
5. Optionally store source IP / user-agent

### 4.2 `GET /api/update`

Purpose:
- Return firmware metadata for the device model if a newer release exists

Expected query parameters:

- `token`
- `model`
- `version`
- `mac`
- `board`

Example request:

```text
GET /api/update?token=8f2d3a...&model=kt,km14-102h&version=24.10.4%20(r28959-29397011cc)&mac=0c:96:cd:52:1d:f1&board=kt,km14-102h
```

If no update exists:

```json
{
  "update_available": false
}
```

If update exists:

```json
{
  "update_available": true,
  "version": "24.10.5-r1",
  "download_url": "https://api.kartnet.org/files/fw/km14-102h-24.10.5-r1.bin",
  "download_urls": [
    "https://api.kartnet.org/files/fw/km14-102h-24.10.5-r1.bin"
  ],
  "sha256": "abc123...",
  "changelog": "Fix wireless and stability issues",
  "force": false,
  "rollout_percent": 100
}
```

Server behavior:

1. Validate device token exists
2. Identify device model
3. Find the newest active release for that model
4. Compare current version with release version
5. Return either `update_available: false` or the full metadata block

### 4.3 `POST /api/heartbeat`

Purpose:
- Track device health and OTA state

Suggested request body:

```json
{
  "token": "8f2d3a...",
  "status": "idle",
  "current_version": "24.10.4 (r28959-29397011cc)",
  "last_result": "up_to_date",
  "last_error": ""
}
```

Expected response:

```json
{
  "ok": true
}
```

Server behavior:

1. Find device by token
2. Update `last_seen_at`
3. Store current status fields
4. Optionally append to an OTA event log table

## 5) Database Design

Minimum database design requires two primary tables.

### 5.1 `ota_devices`

Required columns:

- `id`
- `token` unique
- `model`
- `mac`
- `board`
- `current_version`
- `last_seen_at`
- `last_ip` nullable
- `last_result` nullable
- `last_error` nullable
- `created_at`
- `updated_at`

Optional useful columns:

- `serial_number`
- `customer_id`
- `site_id`
- `notes`
- `first_registered_at`
- `disabled`

### 5.2 `ota_releases`

Required columns:

- `id`
- `model`
- `version`
- `download_url`
- `sha256`
- `changelog`
- `force` boolean
- `rollout_percent` integer
- `active` boolean
- `created_at`
- `updated_at`

Optional useful columns:

- `min_version`
- `channel` (stable / beta / internal)
- `window_start`
- `window_end`
- `file_size`
- `build_id`
- `factory_url`
- `sysupgrade_url`

### 5.3 Optional `ota_events`

Useful for audit and troubleshooting.

Suggested columns:

- `id`
- `device_id`
- `event_type`
- `status`
- `message`
- `payload_json`
- `created_at`

## 6) Firmware Publishing Workflow

Recommended release workflow:

1. Build firmware in OpenWrt
2. Produce final `.bin` image
3. Compute `sha256`
4. Upload image to a stable HTTPS location
5. Insert or update a release entry in `ota_releases`
6. Mark that release as `active`
7. Start with `rollout_percent = 10`
8. Increase rollout gradually after validation

The router only needs a direct HTTPS file URL and matching `sha256`.

## 7) Backend Admin Requirements

The KartNet backend should expose internal admin capabilities for operators.

Minimum admin operations:

1. View all OTA devices
2. Search device by token, MAC, model, version
3. View last seen / last result / last error
4. Create release for a model
5. Activate or deactivate a release
6. Change rollout percentage
7. View release history

Recommended later:

1. Per-customer release targeting
2. Per-site rollout targeting
3. Channel support (`stable`, `beta`)
4. Device quarantine / blocklist
5. Download counters and rollout analytics

## 8) Version Comparison Rules

The backend should not rely on simple lexicographic sorting when possible.

Recommended approach:

1. Store a normalized `version_code` or semantic release rank
2. Keep raw OpenWrt version string for display only
3. Compare normalized sortable versions in the backend

If initial implementation is simple, the backend may still return the newest active release for a model and let the router decide if it is newer.
That matches the current router behavior and is acceptable for phase one.

## 9) Security Requirements

Minimum security requirements:

1. HTTPS only
2. Reject unknown tokens on `/api/update` and `/api/heartbeat`
3. Validate payload fields
4. Rate-limit the OTA routes
5. Log failed registration/update requests
6. Use direct file URLs that are not HTML pages

Recommended later:

1. HMAC-signed metadata
2. Signed release manifests
3. Admin-only release publishing APIs
4. Device allowlist or enrollment rules
5. Per-brand or per-product `token_salt`

## 10) Deployment Notes For KartNet

Recommended deployment layout:

1. Keep OTA routes in the existing KartNet backend
2. Put them under the existing `/api` prefix
3. Keep OTA files under either:
   - `/files/fw/...`
   - a storage domain such as `https://dl.kartnet.org/...`
4. Ensure public file URLs return binary data with HTTP 200
5. Ensure the API routes return JSON only, never HTML

Important:

- `https://api.kartnet.org/api/register` must exist
- `https://api.kartnet.org/api/update` must exist
- `https://api.kartnet.org/api/heartbeat` must exist

At the moment, these routes return `404`, so the backend implementation is still missing.

## 11) Recommended Implementation Order

### Phase 1

Implement:

1. `POST /api/register`
2. `GET /api/update`
3. `ota_devices` table
4. `ota_releases` table

Use:

- single model support
- one release
- one direct download URL
- `rollout_percent = 100`

### Phase 2

Implement:

1. `POST /api/heartbeat`
2. event logging
3. operator page for releases
4. operator page for devices

### Phase 3

Implement:

1. staged rollout controls
2. per-customer targeting
3. signed metadata
4. monitoring and alerting

## 12) Backend Acceptance Tests

These tests should pass before router validation.

### Register test

```bash
curl -X POST https://api.kartnet.org/api/register \
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
- not HTML

### Update test

```bash
curl "https://api.kartnet.org/api/update?token=test-token&model=kt,km14-102h&version=24.10.4&mac=00:11:22:33:44:55&board=kt,km14-102h"
```

Expected:

- HTTP 200
- JSON response
- either `update_available: false` or a full update payload

### Heartbeat test

```bash
curl -X POST https://api.kartnet.org/api/heartbeat \
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

## 13) Router Validation After Backend Is Ready

Once the backend routes exist, validate from the router:

1. Run manual register
2. Run `Check Update` from LuCI
3. Confirm `register_failed` disappears
4. Confirm `up_to_date` or `available` appears instead
5. If a release is active, validate download + `sysupgrade -T`

## 14) Summary

The OTA client side is already in place.
The KartNet backend now needs only a focused OTA module that:

1. stores devices
2. stores releases
3. returns JSON metadata
4. serves a valid firmware download URL

No further router redesign is required before the backend routes are implemented.