# KartNet OTA Backend Handoff

This is the concise handoff version for the backend engineer.

## Goal

Implement OTA API support inside the existing KartNet backend so OpenWrt routers can:

1. register themselves
2. check whether a newer firmware exists
3. send periodic heartbeat/status data

The OpenWrt client is already implemented and deployed.
The missing part is the backend API.

## Current Router Base URL

Routers are currently configured to use:

- `https://api.kartnet.org`

And they expect these exact endpoints:

- `POST /api/register`
- `GET /api/update`
- `POST /api/heartbeat`

These routes do not exist yet and currently return `404`.

## Required Endpoints

### 1) Register Device

Endpoint:

```text
POST /api/register
```

Example request body:

```json
{
  "token": "8f2d3a...",
  "model": "kt,km14-102h",
  "version": "24.10.4 (r28959-29397011cc)",
  "mac": "0c:96:cd:52:1d:f1",
  "board": "kt,km14-102h"
}
```

Required behavior:

1. Find device by `token`
2. If device does not exist, create it
3. If it exists, update metadata
4. Save `last_seen_at`
5. Return JSON success response

Expected response:

```json
{
  "accepted": true,
  "device_id": 123
}
```

### 2) Check Update

Endpoint:

```text
GET /api/update
```

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

Required behavior:

1. Validate the device exists by `token`
2. Find active release for the same `model`
3. If no release or no newer release exists, return `update_available: false`
4. Otherwise return firmware metadata JSON

### 3) Heartbeat

Endpoint:

```text
POST /api/heartbeat
```

Example request body:

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

Required behavior:

1. Find device by token
2. Update `last_seen_at`
3. Update current device state fields

## Required Database Tables

### `ota_devices`

Minimum fields:

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

### `ota_releases`

Minimum fields:

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

## Firmware File Requirements

Firmware download URLs must:

1. be public HTTPS URLs
2. return a real binary file
3. not return HTML
4. match the `sha256` returned by `/api/update`

## Minimum Implementation Order

Implement in this order:

1. `POST /api/register`
2. `GET /api/update`
3. `ota_devices` table
4. `ota_releases` table
5. `POST /api/heartbeat`

## Minimum Acceptance Tests

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

## Important Notes

1. These OTA endpoints must return JSON only
2. They must not redirect to frontend pages
3. They must not return SPA HTML
4. They must not require browser cookies or CSRF tokens

## Current Failure Seen From Router

The router currently reaches the backend but fails with:

- `register_failed`
- `register request failed`

Root cause:

- `POST /api/register` is not implemented yet

## Full Detailed Reference

If more detail is needed, see:

- `package/luci-app-alemprator-ota/BACKEND-EXECUTION-PLAN.md`