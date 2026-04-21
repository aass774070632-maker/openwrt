# ALemprator OTA System Design and API Example

This package provides a complete OTA pipeline for OpenWrt devices with per-device identity.

For a production backend/server execution plan tied to the current KartNet deployment, see `BACKEND-EXECUTION-PLAN.md` in this package directory.
For a standalone self-hosted OTA platform plan built from scratch, see `SELF-HOSTED-SERVER-PLAN.md` in this package directory.
For a highly execution-oriented weekly delivery plan with roles and deliverables, see `SELF-HOSTED-WEEKLY-PLAN.md` in this package directory.

## 1) Identity and First Boot

- On first boot, `/usr/libexec/alemprator-ota/common.sh` ensures:
  - `/etc/model` exists (board/model based default)
  - `/etc/alemprator/device.token` exists
- Token generation is deterministic and unique per device:
  - `sha256(board_name | mac | token_salt)`
- If factory reset deletes token, it is regenerated to the same value (same hardware + same salt).

## 2) Register Endpoint

Router sends JSON POST to:
- `POST /api/register`

Payload example:

```json
{
  "token": "8f...",
  "model": "kt,km14-102h",
  "version": "24.10.4 (r28959-29397011cc)",
  "mac": "12:34:56:78:9a:bc",
  "board": "kt,km14-102h"
}
```

Response example:

```json
{
  "accepted": true,
  "device_id": 120031
}
```

## 3) Update Check Endpoint

Router requests:
- `GET /api/update?token=...&model=...&version=...&mac=...&board=...`

Response if update exists:

```json
{
  "update_available": true,
  "version": "24.10.5-r1",
  "download_url": "https://cdn.example.com/fw/kt-km14-r1.bin",
  "download_urls": [
    "https://cdn1.example.com/fw/kt-km14-r1.bin",
    "https://cdn2.example.com/fw/kt-km14-r1.bin"
  ],
  "sha256": "ab...",
  "changelog": "Security fixes and driver updates",
  "force": false,
  "rollout_percent": 30
}
```

Response if no update:

```json
{
  "update_available": false
}
```

## 4) Router-side Update Flow

1. Register device if needed
2. Check `/api/update`
3. Verify rollout bucket (< rollout_percent)
4. Validate update window (`window_start` to `window_end`)
5. Download image from primary URL or fallback URLs
6. Verify `sha256`
7. Validate image with `sysupgrade -T`
8. Execute `sysupgrade` with policy:
   - preserve config by default
   - optional wipe (`keep_config=0`)
   - optional force if server marks force and `allow_force=1`

## 5) Scalable Rollout Controls

Implemented client-side:

- Random start jitter:
  - `random_delay_max` (default 3600 sec)
- Batch gating:
  - deterministic token bucket `0..99`
  - apply only when `bucket < rollout_percent`
- Time window:
  - defaults to 02:00-06:00
- Retry backoff:
  - exponential from `retry_base` up to `retry_max`

Server-side recommendation:

- Keep a per-model rollout policy table:
  - `model`, `target_version`, `rollout_percent`, `force`, `window`, `sha256`, `urls`
- Move from 10% -> 30% -> 100% by increasing `rollout_percent`

## 6) Example Server Pseudocode (FastAPI style)

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

DEVICES = {}  # token -> metadata
UPDATES = {
    "kt,km14-102h": {
        "version": "24.10.5-r1",
        "sha256": "ab...",
        "urls": [
            "https://cdn1.example.com/fw/kt-km14-r1.bin",
            "https://cdn2.example.com/fw/kt-km14-r1.bin"
        ],
        "changelog": "Security and Wi-Fi fixes",
        "force": False,
        "rollout_percent": 30,
    }
}

class RegisterBody(BaseModel):
    token: str
    model: str
    version: str
    mac: str
    board: str

@app.post("/api/register")
def register(body: RegisterBody):
    DEVICES[body.token] = body.dict()
    return {"accepted": True}

@app.get("/api/update")
def update(token: str, model: str, version: str, mac: str = "", board: str = ""):
    if token not in DEVICES:
        raise HTTPException(status_code=403, detail="unknown token")

    update = UPDATES.get(model)
    if not update:
        return {"update_available": False}

    if version == update["version"]:
        return {"update_available": False}

    return {
        "update_available": True,
        "version": update["version"],
        "download_url": update["urls"][0],
        "download_urls": update["urls"],
        "sha256": update["sha256"],
        "changelog": update["changelog"],
        "force": update["force"],
        "rollout_percent": update["rollout_percent"],
    }
```

## 7) Build System Integration

To include this OTA system in firmware builds:

1. Enable package in `.config`:
   - `CONFIG_PACKAGE_luci-app-alemprator-ota=y`
2. Build image as usual:
   - `make -j$(nproc)`

## 8) Security Notes

- Use HTTPS only for server URL
- Change `token_salt` per product line
- Reject unknown tokens on server
- Always verify SHA256 before sysupgrade
- Optionally add signed metadata with server-side JWT/HMAC
