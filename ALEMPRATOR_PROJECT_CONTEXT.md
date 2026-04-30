# Alemprator Project Context

Last updated: 2026-04-30

## Workspace

- Root: `/home/baalwy/openwrt`
- OpenWrt target used for KM14: `ramips/mt7621`
- Device profile: `kt_km14-102h`
- Router currently tested: `192.168.1.20`
- Router board/model reported by OTA: `kt,km14-102h`
- OTA public domain: `https://ota.kartnet.org`
- OTA local nginx port: `http://127.0.0.1:8080`

## Important Packages

- Quick setup wizard: `package/luci-app-setup`
- OTA agent and LuCI page: `package/luci-app-alemprator-ota`
- OTA server: `ota-server`

## Current Firmware Release

- Current firmware version file: `package/luci-app-alemprator-ota/files/etc/alemprator/firmware-version`
- Current source version after preparing test build: `24.10.4-km14-r21`
- Active OTA release ID: `66`
- Active model: `kt,km14-102h`
- Active firmware URL: `https://ota.kartnet.org/firmware/alemprator-km14-102h-24.10.4-km14-r18-sysupgrade.bin`
- SHA256: `301d5e00fec63941f161a27890b5beac0c335b0c1a7888cc0d242fb5df4f1d65`
- Bad duplicate release found and disabled: ID `67`, version had leading spaces before `24.10.4-km14-r18`.

## Prepared Test Artifact r21

- This file is uploaded to `/firmware/`, but no OTA release was created for it automatically.
- Version to enter in admin panel: `24.10.4-km14-r21`
- Artifact path to enter in admin panel: `/firmware/alemprator-km14-102h-24.10.4-km14-r21-sysupgrade.bin`
- Public URL: `https://ota.kartnet.org/firmware/alemprator-km14-102h-24.10.4-km14-r21-sysupgrade.bin`
- SHA256: `d2d44dfbaf2f997f214dc0f430666b54a74d476fbc2fdc2b2f0b5ca8abc9e070`
- Size: `9923633`

## OTA Server Containers

Run from `ota-server`:

```sh
docker compose ps
docker compose up -d --build api nginx
docker compose logs --tail=120 nginx
docker compose logs --tail=120 api
```

Expected services:

- `ota-postgres`: PostgreSQL database, healthy
- `ota-api`: NestJS API, port `3000`
- `ota-nginx`: nginx public gateway, port `8080`

Health checks:

```sh
curl -fsS http://127.0.0.1:8080/api/health
curl -fsS http://127.0.0.1:8080/api/ready
```

Expected:

```json
{"status":"ok"}
{"ready":true}
```

## Creating OTA Releases Safely

Do not upload large firmware files through the browser via Cloudflare. This can cause Cloudflare `524` timeout.

Use this safe flow:

1. Put the firmware file in `ota-server/public/firmware/`.
2. In the admin panel, use **مسار ملف موجود على السيرفر**.
3. Path must start with `/firmware/`, for example:

```text
/firmware/alemprator-km14-102h-24.10.4-km14-r18-sysupgrade.bin
```

The admin UI now blocks large browser uploads and shows a clear Arabic message.

## Root Cause Fixed On 2026-04-29

Symptoms on router LuCI OTA page:

- `Status: error`
- `Last Error: Invalid status JSON`
- Or `window_wait` even though router was already on r18.

Actual causes:

- A duplicate release was created from the admin panel with leading spaces in `version`.
- Server returned version as `       24.10.4-km14-r18`.
- Router compared it as a newer version than current `24.10.4-km14-r18`.
- Heartbeat requests returned HTTP `400` because router signed heartbeat as if `last_result` and `last_error` were empty while not sending these fields.

Fixes applied:

- Disabled bad release ID `67` and reactivated clean release ID `66`.
- `ota-server/src/modules/admin/admin.service.ts` now trims `version`, `version_code`, `channel`, and `changelog` before storing releases.
- `package/luci-app-alemprator-ota/files/usr/libexec/alemprator-ota/agent.sh` now trims version/hash/rollout fields from server JSON before comparing.
- `package/luci-app-alemprator-ota/files/usr/libexec/alemprator-ota/common.sh` now sends `last_result` and `last_error` in heartbeat and signs the exact same action fields.
- The fixed `common.sh` and `agent.sh` were deployed manually to router `192.168.1.20` for immediate validation.

## Router Validation Commands

Run from the OpenWrt workspace:

```sh
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/tmp/openwrt-known-hosts root@192.168.1.20 '/usr/libexec/alemprator-ota/status-json'
```

Expected after r18 is installed:

```json
{
  "status": "idle",
  "update_available": false,
  "last_result": "up_to_date",
  "current_version": "24.10.4-km14-r18"
}
```

Force a check without applying upgrade:

```sh
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/tmp/openwrt-known-hosts root@192.168.1.20 'rm -f /tmp/alemprator-ota/manual-check.pid; /usr/libexec/alemprator-ota/run-once --check-only; /usr/libexec/alemprator-ota/status-json'
```

Check active releases in database:

```sh
cd /home/baalwy/openwrt/ota-server
docker compose exec -T postgres sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "select id, model, quote_literal(version) as version_literal, active from releases where model = '\''kt,km14-102h'\'' order by active desc, created_at desc, id desc limit 5;"'
```

Expected active row:

```text
66 | kt,km14-102h | '24.10.4-km14-r18' | t
```

## Rebuild Firmware

From workspace root:

```sh
make -j$(nproc)
```

Known note: VS Code terminal notifications may falsely report this command as waiting for input. Trust final OpenWrt lines such as `json_overview_image_info` and `checksum`, plus exit code `0`.

## Current Verification Results

- OTA API health: OK
- OTA API ready: OK
- Active release: clean r18 release ID `66`
- Router OTA state: `idle`, `update_available=false`, `last_result=up_to_date`
- Recent nginx logs after fix: no new `heartbeat` or HTTP `400` entries in the checked window

## r20 Build And Live Validation On 2026-04-29

- Full firmware build completed successfully with `make -j$(nproc)`.
- Final sysupgrade artifact:

```text
/firmware/alemprator-km14-102h-24.10.4-km14-r20-sysupgrade.bin
```

- Final public URL:

```text
https://ota.kartnet.org/firmware/alemprator-km14-102h-24.10.4-km14-r20-sysupgrade.bin
```

- Final SHA256: `7cface1d2f9c6211b07575af1ce38b8eb4324601fb7b764133387b49411f12d1`
- Router manually updated and now reports `current_version=24.10.4-km14-r20`.
- Live LuCI OTA page on router `192.168.1.21` confirms the new Arabic/manual-update UI is active.
- Manual update flow validated end-to-end without flashing again:
  - uploaded `openwrt-ramips-mt7621-kt_km14-102h-squashfs-sysupgrade.bin` to `/tmp/alemprator-ota/manual-update.bin`
  - `/usr/libexec/alemprator-ota/manual-info` returned `valid=true`
  - LuCI page showed the uploaded image as ready to install
  - LuCI `حذف الملف اليدوي` removed the staged file successfully
- Cache-busting follow-up deployed on router `192.168.1.20`:
  - installed `luci-app-alemprator-ota_1.0-r11_mipsel_24kc.ipk`
  - LuCI menu entry now points to `system/ota_v2`
  - router serves `/luci-static/resources/view/system/ota_v2.js`
  - authenticated browser validation confirms the OTA page now loads `ota_v2.js` and renders the Arabic UI correctly on `192.168.1.20`
- Remaining runtime issue is not in the OTA package/UI itself:
  - router OTA checks fail with `update check request failed: Failed to send request: Operation not permitted`
  - router cannot currently reach gateway `192.168.1.1`
  - `nslookup ota.kartnet.org` times out and raw pings to `8.8.8.8` / `1.1.1.1` fail
  - therefore server-based OTA check/apply remains blocked by network reachability, not by the new OTA implementation

## r21 Setup Wizard Copy Simplification And Publish Prep On 2026-04-30

- `package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js` was shortened across hero text, status text, mode summaries, Wi-Fi summaries, VLAN summaries, maintenance cards, and reconnect/apply messages so the wizard reads cleaner and more modern.
- Local validation passed with `node --check package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js`.
- `luci-app-setup_1.0-r90_mipsel_24kc.ipk` was rebuilt and reinstalled on router `192.168.1.20`.
- Live router verification confirmed the served `/www/luci-static/resources/view/setup/setup_r90.js` contains the shortened markers:
  - `ملخص سريع قبل الحفظ.`
  - `اضبط LAN ووضع التشغيل والواي فاي وVLAN ثم احفظ.`
  - `جاهز لتنزيل نسخة احتياطية.`
  - `ملخص الواي فاي`
  - `ملخص VLAN الثانوية`
- `opkg` preserved the modified router config as `/etc/config/setup` and placed the package conffile as `/etc/config/setup-opkg`; no config merge was performed because this stage only changed LuCI copy.
- Full firmware build completed successfully with `make -j$(nproc)` after bumping `package/luci-app-alemprator-ota/files/etc/alemprator/firmware-version` to `24.10.4-km14-r21`.
- Final r21 sysupgrade artifact was created locally as:

```text
/home/baalwy/openwrt/bin/targets/ramips/mt7621/alemprator-km14-102h-24.10.4-km14-r21-sysupgrade.bin
```

- Published OTA file path:

```text
/firmware/alemprator-km14-102h-24.10.4-km14-r21-sysupgrade.bin
```

- Expected public URL:

```text
https://ota.kartnet.org/firmware/alemprator-km14-102h-24.10.4-km14-r21-sysupgrade.bin
```

- Final SHA256: `d2d44dfbaf2f997f214dc0f430666b54a74d476fbc2fdc2b2f0b5ca8abc9e070`
- Final size: `9923633`
- Local OTA gateway verification passed with HTTP `200` from `http://127.0.0.1:8080/firmware/alemprator-km14-102h-24.10.4-km14-r21-sysupgrade.bin`.
- Public DNS resolution for `ota.kartnet.org` failed from this workspace at the time of packaging, so the dashboard should use the server path `/firmware/alemprator-km14-102h-24.10.4-km14-r21-sysupgrade.bin`; the public URL above remains the expected external link when DNS/routing is normal.

## If Server Powers Off

After power returns:

1. Start containers:

```sh
cd /home/baalwy/openwrt/ota-server
docker compose up -d
```

2. Confirm services:

```sh
docker compose ps
curl -fsS http://127.0.0.1:8080/api/health
curl -fsS http://127.0.0.1:8080/api/ready
```

3. Confirm active release is still ID `66` and clean version without leading spaces.
4. Confirm router status with `/usr/libexec/alemprator-ota/status-json`.

Do not recreate r18 manually unless needed. If a new release is needed, use the server-side `/firmware/...` path and make sure version text has no leading/trailing spaces.
