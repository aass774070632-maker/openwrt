# Alemprator Project Context

Last updated: 2026-05-05

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
- Current source version after latest full build: `24.10.4-km14-r29`
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

## Upgrade Preservation And LAN Stability On 2026-05-01

- `package/luci-app-alemprator-ota/files/usr/libexec/alemprator-ota/common.sh` now stages manual firmware uploads at `/tmp/firmware.bin` and ignores any OTA `keep_config=0` request during `sysupgrade` so device configuration is always preserved.
- `package/luci-app-alemprator-ota/files/usr/share/rpcd/acl.d/luci-app-alemprator-ota.json` now grants write access to `/tmp/firmware.bin` for the LuCI OTA workflow.
- `package/base-files/files/sbin/sysupgrade` now ignores `-n` on this firmware family when Alemprator marker files are present, forcing configuration preservation during upgrades.
- `package/alemprator-firstboot/files/etc/uci-defaults/95-alemprator-firstboot` now exits early during sysupgrade restore when `/sysupgrade.tgz` or `/tmp/sysupgrade.tar` exists, and reuses the saved LAN IP/netmask from `setup.default` instead of reapplying factory defaults.
- `package/luci-app-setup/files/etc/init.d/setup` now syncs `network.lan` and `alemprator_firstboot.main` from `setup.default.lan_ipaddr` / `lan_netmask` on boot, start, and reload, then schedules a delayed resync. This was the decisive fix for LAN IP reverting to `192.168.1.20` after upgrade.
- Result: the latest full build includes all config-preservation changes, and the published firmware artifact below was built from source version `24.10.4-km14-r29`.

## Button Policy Validation And Fixes On 2026-05-01

- `package/luci-app-setup/files/usr/libexec/alemprator-setup/reset-disabled` and `package/luci-app-setup/files/usr/libexec/alemprator-setup/wps-disabled` were rewritten with LF line endings only. The previous CRLF shebang caused `sh: /etc/rc.button/reset: not found` even when the file existed.
- Live validation was performed on router `192.168.1.20`:
  - enabling `setup.default.reset_button_disabled=1` and `setup.default.wps_button_disabled=1` replaced `/etc/rc.button/reset` and `/etc/rc.button/wps` with the Alemprator helper scripts
  - direct execution of both handlers returned `0`
  - `logread` recorded `ALemprator ignored reset button press because reset-button protection is enabled` and `ALemprator ignored WPS/Mesh button press because button protection is enabled`
  - `UPTIME_DELTA=0`, confirming no reboot or factory reset side effect during the validation path
- The router was restored after validation, and a later state check confirmed the native handlers were back in place when button protection was not enabled.

## Setup Wizard VLAN Naming Changes On 2026-05-01

- `package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js` now treats the first VLAN SSID field as the required primary VLAN name and the 5GHz VLAN field as an optional override.
- Effective behavior is now unified across the UI, post-install scripts, and recovery scripts:
  - primary VLAN name is stored in `setup.default.wifi_ssid_vlan_2g`
  - optional 5GHz override is stored in `setup.default.wifi_ssid_vlan_5g`
  - if the 5GHz field is blank, the effective SSID becomes `<primary>_5G`
- The following files were updated to use the same derivation rule:
  - `package/luci-app-setup/Makefile`
  - `package/luci-app-setup/files/etc/uci-defaults/40_luci-app-setup`
  - `package/luci-app-setup/files/etc/uci-defaults/47_luci-app-setup-fix-5g-vlan-ssid`
  - `package/luci-app-setup/files/etc/uci-defaults/48_luci-app-setup-recover-state`
- Live wizard validation on router `192.168.1.20` confirmed:
  - leaving the primary VLAN field empty blocks progress with `أدخل اسم شبكة VLAN الأساسي.`
  - using primary name `COPILOTVLAN` with blank 5GHz field produces effective SSIDs `COPILOTVLAN` and `COPILOTVLAN_5G`
  - after testing, router configuration was restored from a backup, returning the live SSIDs to `GALAL` and `GALAL_5G`

## Setup Wizard Cache-Busting And Copy Update On 2026-05-01

- Browser-side cache was still serving the older quick-setup page even after reinstalling the package, so the setup view was version-bumped from `r90` to `r91`:
  - `package/luci-app-setup/Makefile` now installs `setup_r91.js`
  - `package/luci-app-setup/files/usr/share/luci/menu.d/luci-app-setup.json` now points to `setup/setup_r91`
  - `package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js` and `landing.js` now use `WIZARD_BUILD_TAG = 'r91'`
- `package/luci-app-setup` package release is now `1.0-r91`.
- The VLAN helper text was also rewritten to avoid RTL/LTR rendering confusion in browsers. The currently intended labels are:
  - `الاسم الأساسي لشبكة VLAN`
  - `هذا الحقل مطلوب. وإذا تُرك حقل شبكة خمسة جيجاهرتز فارغًا، فسيُشتق اسمه من هذا الحقل.`
  - `الاسم الاختياري لشبكة VLAN على خمسة جيجاهرتز`
  - `هذا الحقل اختياري. وإذا تُرك فارغًا، فسيُنشأ الاسم تلقائيًا من الاسم الأساسي.`

## Latest Published Full Firmware Artifact On 2026-05-01

- `package/luci-app-alemprator-ota/files/etc/alemprator/firmware-version` was bumped from `24.10.4-km14-r21` to `24.10.4-km14-r29`.
- `package/luci-app-alemprator-ota/Makefile` package release is now `1.0-r12`.
- Full image build completed successfully with `make -j$(nproc)` and ended with the expected OpenWrt lines:

```text
make[2] json_overview_image_info
make[2] checksum
```

- Final sysupgrade artifact created locally:

```text
/home/baalwy/openwrt/bin/targets/ramips/mt7621/alemprator-km14-102h-24.10.4-km14-r29-sysupgrade.bin
```

- Published OTA file copied to:

```text
/home/baalwy/openwrt/ota-server/public/firmware/alemprator-km14-102h-24.10.4-km14-r29-sysupgrade.bin
```

- OTA dashboard/server path:

```text
/firmware/alemprator-km14-102h-24.10.4-km14-r29-sysupgrade.bin
```

- Public download URL:

```text
https://ota.kartnet.org/firmware/alemprator-km14-102h-24.10.4-km14-r29-sysupgrade.bin
```

- SHA256: `a673b073570ffcc9058858cb1fe7b1acd53fca2cca35a0b5ad3612544094b1f8`
- Size: `9933873`
- Local nginx verification passed with `HTTP/1.1 200 OK` for `http://127.0.0.1:8080/firmware/alemprator-km14-102h-24.10.4-km14-r29-sysupgrade.bin`.
- Public domain verification passed with `HTTP/2 200` for `https://ota.kartnet.org/firmware/alemprator-km14-102h-24.10.4-km14-r29-sysupgrade.bin`.
- Important note: this session published the firmware file and direct URL, but did not create or repoint an OTA database release/campaign row. Use the direct `/firmware/...` artifact path or public URL in the dashboard workflow as needed.

## Conversation Update 2026-05-03: KM12 Alemprator Platform State

This section is the current handoff point for any new conversation. The earlier context above is mostly KM14/r29 history. The active work moved to the `KT KM12-007H` / `kt,km12-007h` target, and the current release line is `24.10.4.1-km12-r3`.

### Current Canonical Target

- Active OpenWrt target in `.config`:
  - `CONFIG_TARGET_ramips=y`
  - `CONFIG_TARGET_ramips_mt7621=y`
  - `CONFIG_TARGET_ramips_mt7621_DEVICE_kt_km12-007h=y`
  - `CONFIG_TARGET_PROFILE="DEVICE_kt_km12-007h"`
- Active firmware version file:
  - `package/luci-app-alemprator-ota/files/etc/alemprator/firmware-version`
  - Current content: `24.10.4.1-km12-r3`
- Active package releases verified in the final manifest:
  - `alemprator-suite - 1.0-r1`
  - `luci-app-alemprator-ota - 1.0-r19`
  - `luci-app-setup - 1.0-r91`

### Final Built And Published KM12 Artifact

- Final local sysupgrade image:
  - `bin/targets/ramips/mt7621/openwrt-ramips-mt7621-kt_km12-007h-squashfs-sysupgrade.bin`
- Published OTA artifact:
  - `ota-server/public/firmware/openwrt-ramips-mt7621-kt_km12-007h-squashfs-sysupgrade-24.10.4.1-km12-r3.bin`
- Public URL:
  - `https://ota.kartnet.org/firmware/openwrt-ramips-mt7621-kt_km12-007h-squashfs-sysupgrade-24.10.4.1-km12-r3.bin`
- Size: `12524593`
- SHA256: `924c334e3357fb2b1cc5b0e488fb0dce642773b7affe3d940c3e74d4d6a830ba`
- Public HTTP verification passed on 2026-05-03:
  - `HTTP/2 200`
  - `content-type: application/octet-stream`
  - `content-length: 12524593`
  - `cache-control: no-store`

### Router State At End Of Conversation

- Router reachable over SSH at `192.168.1.20`.
- Router firmware version read from `/etc/alemprator/firmware-version`:
  - `24.10.4.1-km12-r3`
- Router OTA status check returned:
  - `last_result=up_to_date`
  - `update_available=false`
  - `latest_version=24.10.4-km12-r3`
- Note the minor version-string mismatch in `latest_version`: the currently published artifact and local version file use `24.10.4.1-km12-r3`, while the router status output showed `24.10.4-km12-r3`. Treat this as a release metadata normalization issue to re-check before any future production rollout.

### Major Device Support Added For KM12

Files added or updated so OpenWrt can build `kt,km12-007h`:

- `target/linux/ramips/dts/mt7621_kt_km12-007h.dts`
  - New DTS for `KT KM12-007H` with compatible string `kt,km12-007h`.
  - NAND layout includes `Bootloader`, `Config`, `Factory`, `kernel`, and `ubi` partitions.
  - Switch ports mapped as `wan`, `lan4`, `lan3`, `lan2`, `lan1`.
  - LEDs include `green:wlan` and `green:lan2`.
- `target/linux/ramips/image/mt7621.mk`
  - Added `Device/kt_km12-007h` using NAND image flow.
  - `SUPPORTED_DEVICES := kt,km12-007h`.
  - Produces `factory.bin` and sysupgrade image.
- `target/linux/ramips/mt7621/base-files/lib/upgrade/platform.sh`
  - Added `kt,km12-007h` to supported upgrade case.
- `target/linux/ramips/mt7621/base-files/etc/board.d/01_leds`
  - Added KM12 LED triggers for WLAN and LAN2.
- `target/linux/ramips/mt7621/base-files/etc/board.d/02_network`
  - Added KM12 network setup: LAN ports `lan1 lan2 lan3 lan4`, WAN port `wan`.
- `target/linux/ramips/mt7621/base-files/etc/hotplug.d/firmware/11-mt76-caldata`
  - KM12 uses same mt7915 EEPROM extraction path as KM14: `Factory` offset `0x0`, size `0xe00`.
- `target/linux/ramips/mt7621/base-files/etc/hotplug.d/ieee80211/10_fix_wifi_mac`
  - KM12 Wi-Fi MACs derived from `Config` offset `0x60004`.

### KM12 Default Image Configuration

- Old split default scripts were removed:
  - `target/linux/ramips/mt7621/base-files/etc/uci-defaults/90_network`
  - `target/linux/ramips/mt7621/base-files/etc/uci-defaults/99_wifi-name`
- New combined default script:
  - `target/linux/ramips/mt7621/base-files/etc/uci-defaults/98_custom`
- Important default behavior in `98_custom`:
  - Does not reapply factory defaults after sysupgrade with keep settings: exits if `/sysupgrade.tgz` or `/tmp/sysupgrade.tar` exists.
  - LAN IP: `192.168.1.20`.
  - Netmask: `255.255.255.0`.
  - Gateway: `192.168.1.2`.
  - DNS: `8.8.8.8` and `82.114.163.31`.
  - `network.lan.defaultroute='1'` to avoid the OTA failure observed when it was `0`.
  - WAN and WAN6 are deleted for the intended bridge/AP-style local setup.
  - DHCP LAN is disabled/ignored.
  - Wireless defaults renamed to KM12, not KM14.
  - Hostname and LLDP identity set to `KT-KM12-007H`.
  - HTTPS redirect disabled in uhttpd.

### Alemprator Suite Meta Package

- New package: `package/alemprator-suite/Makefile`.
- Purpose: a unified meta-package for the release image.
- Depends on:
  - `alemprator-firstboot`
  - `luci-app-setup`
  - `luci-app-alemprator-ota`
- It has explicit empty `Build/Prepare` and `Build/Compile` sections so `make package/alemprator-suite/compile` works for direct validation.
- `.config` has `CONFIG_PACKAGE_alemprator-suite=y`, and the final manifest includes `alemprator-suite - 1.0-r1`.

### Package Ownership Audit

- New audit script: `scripts/alemprator-package-audit.sh`.
- It checks install targets for:
  - `alemprator-firstboot`
  - `luci-app-setup`
  - `luci-app-alemprator-ota`
  - `alemprator-suite`
- It reports direct duplicate file ownership and prints logical overlap checkpoints.
- Verified result before image build:
  - duplicate file ownership: `none`.

### Firstboot And Setup Ownership Decisions

The agreed design direction is:

- `luci-app-setup` owns persisted user intent:
  - final LAN IP/netmask
  - setup completion state
  - Wi-Fi and VLAN settings
  - button policy
- `alemprator-firstboot` owns only temporary provisioning:
  - temporary setup network
  - temporary setup SSID
  - cleanup state
  - baseline/pending markers
- `luci-app-alemprator-ota` owns OTA runtime and release identity only.

Important implementation changes:

- `package/alemprator-firstboot/files/etc/init.d/alemprator-firstboot`
  - No longer writes `setup.default.initial_setup_complete=1` during cleanup.
  - No longer writes final LAN values into `setup.default` during cleanup.
  - `sync_firstboot_flags` now distinguishes disabled firstboot from setup-complete firstboot.
  - Cleans `auto_cleanup_armed` and `auto_cleanup_pending` when disabled.
- `package/alemprator-firstboot/files/etc/uci-defaults/95-alemprator-firstboot`
  - Skips during sysupgrade keep-settings mode.
  - Default SSID changed to `ALemprator-KT-KM12-007H`.
  - Uses saved `setup.default.lan_ipaddr` and `lan_netmask` when present, instead of always forcing default values.
  - No longer auto-marks setup complete for already configured devices.
- `package/alemprator-firstboot/files/etc/config/alemprator_firstboot`
  - Default SSID changed from KM14 to KM12.
- `package/luci-app-setup/files/etc/init.d/setup`
  - Added runtime LAN sync from `setup.default` after initial setup is complete.
  - Sync runs during boot/start/reload and is scheduled once after boot/start.

### LuCI Setup r91 Changes

- `package/luci-app-setup/Makefile`
  - `PKG_RELEASE` bumped to `91`.
  - Installed browser-cache-busted copy now `setup_r91.js`.
- `package/luci-app-setup/files/usr/share/luci/menu.d/luci-app-setup.json`
  - Menu path points to `setup/setup_r91`.
- `package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js`
  - `WIZARD_BUILD_TAG='r91'`.
  - VLAN secondary SSID behavior changed:
    - `wifi_ssid_vlan_2g` is the required base VLAN SSID.
    - `wifi_ssid_vlan_5g` is optional.
    - If 5GHz VLAN SSID is blank, it is derived from the 2G/base VLAN SSID with `_5G`.
  - Validation now checks effective generated names, not only manually typed names.
  - `disableFirstbootProvisioning()` no longer sets `configured_once=1`; firstboot owns that marker.
- `package/luci-app-setup/files/www/luci-static/resources/view/setup/landing.js`
  - `WIZARD_BUILD_TAG='r91'`.
- `package/luci-app-setup/files/etc/uci-defaults/40_luci-app-setup`
  - Default SSID changed to `ALemprator-KT-KM12-007H`.
  - Adds `wifi_ssid_vlan_2g` and `wifi_ssid_vlan_5g` defaults.
- `package/luci-app-setup/files/etc/uci-defaults/47_luci-app-setup-fix-5g-vlan-ssid`
  - Uses the new 2G/5G VLAN SSID fields.
- `package/luci-app-setup/files/etc/uci-defaults/48_luci-app-setup-recover-state`
  - Recovers separate custom 2G and 5G VLAN SSID values into `setup.default`.
- `package/luci-app-setup/files/usr/libexec/alemprator-setup/reset-disabled` and `wps-disabled`
  - Normalized to LF line endings.

### OTA r19 Changes

- `package/luci-app-alemprator-ota/Makefile`
  - `PKG_RELEASE:=19`.
  - Removed dependency on `coreutils-sha256sum`; BusyBox `sha256sum` is used.
  - Removed `/etc/model` from conffiles ownership.
- `package/luci-app-alemprator-ota/files/etc/alemprator/firmware-version`
  - `24.10.4.1-km12-r3`.
- `package/luci-app-alemprator-ota/files/usr/libexec/alemprator-ota/common.sh`
  - Manual image path normalized to `/tmp/alemprator-ota/manual-update.bin`.
  - Added `version_model_marker` and `should_accept_update_version`.
  - OTA can accept a cross-model marker transition, not only strict `opkg compare-versions >` ordering, which mattered when moving from KM14 version strings to KM12 version strings.
  - OTA sysupgrade now preserves configuration regardless of `KEEP_CONFIG=0`; it logs and ignores wipe mode because wiping config re-enables firstboot and resets LAN.
- `package/luci-app-alemprator-ota/files/usr/libexec/alemprator-ota/agent.sh`
  - Added explicit `check_only` handling.
  - `check-only` and `force-check` force `AUTO_UPGRADE=0`.
  - `force-check` bypasses retry/backoff.
  - Uses `should_accept_update_version` instead of only strict `compare_is_newer`.
- `package/luci-app-alemprator-ota/files/usr/libexec/alemprator-ota/run-once`
  - Supports `--check-only` flow.
- `package/luci-app-alemprator-ota/files/usr/share/rpcd/acl.d/luci-app-alemprator-ota.json`
  - Allows writing `/tmp/alemprator-ota/manual-update.bin` for manual upload flow.
- `package/luci-app-alemprator-ota/README-OTA.md`
  - Updated to document that OTA preserves config to keep LAN/device configuration intact.

### Sysupgrade Safety Change

- `package/base-files/files/sbin/sysupgrade`
  - Added `should_force_save_config()`.
  - If Alemprator markers/configs exist, `sysupgrade -n` is ignored and config is preserved.
  - The intent is to prevent future OTA or manual update flows from wiping setup state and resurrecting firstboot unexpectedly.

### OTA Server And Dashboard Changes

- `ota-server/scripts/seed-firmware-models.mjs`
  - Added firmware model:
    - `slug: km12-007h`
    - `modelKey: kt,km12-007h`
    - `displayName: KM12-007H`
    - `boardIdentifier: kt,km12-007h`
    - `artifactKind: sysupgrade`
- `ota-server/scripts/seed-km12-release.mjs`
  - New script to publish the built KM12 sysupgrade artifact into `ota-server/public/firmware`.
  - Current release values:
    - `model='kt,km12-007h'`
    - `version='24.10.4.1-km12-r3'`
    - `versionCode='24.10.4.1-km12-r3'`
    - `artifactName='openwrt-ramips-mt7621-kt_km12-007h-squashfs-sysupgrade-24.10.4.1-km12-r3.bin'`
  - Uses Prisma transaction to upsert model, remove duplicate release rows for same model/version, deactivate older active stable releases for KM12, then create active stable release and release file row.
- `ota-server/package.json`
  - Added script: `seed:km12-release`.

Commands used successfully:

```sh
cd /home/baalwy/openwrt/ota-server
npm run seed:models
npm run seed:km12-release
```

Local API validation that was done earlier in the conversation:

- `http://127.0.0.1:8080/api/health` was reachable.
- A test device with token `test-local-km12` was registered.
- `/api/update` returned an update after registration.
- Public artifact URL returned `HTTP/2 200`.

### Router Network Debugging History

The router changed IPs several times during the session:

- Earlier working address: `192.168.137.22`.
- After formatting/reset, expected and current address: `192.168.1.20`.
- First OTA failures after formatting were not package failures. Causes were:
  - no default route
  - DNS failing/refused
  - router clock reset to 2025, causing HTTPS certificate validation failure
- On `192.168.137.22`, the root cause was `network.lan.defaultroute='0'`; setting it to `1` and adding `default via 192.168.137.1 dev br-lan` fixed DNS/HTTPS.
- On `192.168.1.20`, gateway `192.168.1.2` was the only reachable gateway. Persisted on router:
  - `network.lan.gateway='192.168.1.2'`
  - `network.lan.defaultroute='1'`
  - `network.lan.dns='192.168.1.2 8.8.8.8 82.114.163.31'`
- Router clock was manually set from host UTC and `sysntpd` restarted, after which HTTPS to `ota.kartnet.org` succeeded.

### Build And Validation Commands That Passed

Use these as the known-good local validation commands:

```sh
make defconfig
make package/alemprator-firstboot/compile package/luci-app-setup/compile package/luci-app-alemprator-ota/compile package/alemprator-suite/compile V=s
scripts/alemprator-package-audit.sh
make -j$(nproc) V=s
```

The successful full image build ended with the expected OpenWrt output:

```text
make[2] json_overview_image_info
make[2] checksum
```

Final manifest verification:

```text
alemprator-suite - 1.0-r1
luci-app-alemprator-ota - 1.0-r19
luci-app-setup - 1.0-r91
```

### Current Important Config Snapshots

- `KT-KM12-007H-01-05-2026.config`
- `KT-KM12-007H-01-05-2026.config.old`
- `KT-KM12-007H-30-04-2026.config`
- `KT-KM14-102H-01-05-2026.config`

The active `.config` is KM12, not KM14. Do not switch back to KM14 unless explicitly requested.

### Known Residual Risks / Next Checks

Before declaring production rollout complete in a new conversation, verify these points:

1. Normalize OTA release metadata version strings so server `latest_version`, router `/etc/alemprator/firmware-version`, artifact name, and DB release row all agree on either `24.10.4.1-km12-r3` or another chosen canonical value.
2. Re-run an end-to-end OTA from an older KM12/KM14-marked image to `24.10.4.1-km12-r3` on hardware, not only `check-only`.
3. Confirm after OTA reboot that:
   - SSH and LuCI remain reachable on intended LAN IP.
   - firstboot does not recreate temporary provisioning if setup is complete.
   - `setup.default.initial_setup_complete` and `alemprator_firstboot.main.configured_once` are sane.
   - `status-json` returns `up_to_date` with no stale mismatch.
4. Consider linting/fixing formatting in the new KM12 DTS and board scripts before upstream-quality submission. The image builds, but some indentation in newly added blocks is rough.
5. Decide whether `98_custom` gateway `192.168.1.2` is production-specific or lab-specific. It fixed this environment, but a general release may need no hardcoded gateway or a documented customer-network assumption.

### Do Not Forget

- User prefers autonomous staged work: make a small safe change, build, deploy, verify, then continue without waiting unless manual network/UX validation is genuinely required.
- For router tests, current reachable IP is `192.168.1.20`.
- If router HTTPS/OTA fails after reset, check route, DNS, and date before changing OTA code.

## Conversation Update 2026-05-03: LuCI System Update r20

Completed the user-facing rename and redesign of the OTA LuCI page for KM12. Internal package/script names still use OTA, but the Arabic interface now presents the feature as system updates.

### Implemented Package State

- `luci-app-alemprator-ota` bumped to `1.0-r20`.
- Built artifact:
  - `bin/packages/mipsel_24kc/base/luci-app-alemprator-ota_1.0-r20_mipsel_24kc.ipk`
  - Size: `25660` bytes
  - SHA256: `68fb70d3601f428237142f084b0c55319461ed5f70796998403a239ecd97b064`
- Installed and force-reinstalled on router `192.168.1.20`.
- Router `opkg status luci-app-alemprator-ota` reports `Version: 1.0-r20`.

### UI Changes

- LuCI menu title changed from `تحديث OTA` to `تحديث النظام`.
- Active page remains `admin/system/ota-update`, view `system/ota_v2`.
- Page title is now `تحديثات النظام`.
- Active page sections:
  - `التحديث عبر الإنترنت`
  - `فحص اتصال الإنترنت`
  - `التحديث اليدوي`
  - `حالة النظام`
- Main user-facing button labels now include:
  - `فحص الإنترنت`
  - `فحص التحديث`
  - `تثبيت التحديث`
  - `رفع ملف التحديث`
  - `تثبيت الملف`
  - `حذف الملف`
  - `نسخ الأمر`
- Styling in `ota_v2.js` was updated to match the quick setup page palette and card organization.

### Internet Check / MikroTik Command

Added production helper:

```text
/usr/libexec/alemprator-ota/internet-check
```

The helper returns JSON with:

```text
status, internet_ok, server_ok, message, lan_ip, gateway, server_url, server_host, mikrotik_command
```

It checks:

1. Default route / gateway.
2. Internet reachability by pinging `1.1.1.1` or `8.8.8.8`.
3. Real OTA API reachability using the existing shared `check_update_json` helper, not only the web server root.

If the router has no internet, the UI shows a ready MikroTik command for the detected LAN IP:

```text
/ip firewall nat add chain=srcnat src-address=192.168.1.20 action=masquerade comment="Alemprator updater internet access"
```

The LuCI update check button now runs `internet-check` first. If `internet_ok` is false, it does not start the OTA check and asks the user to apply the MikroTik command first.

### Verification Performed

Local checks:

```text
sh -n package/luci-app-alemprator-ota/files/usr/libexec/alemprator-ota/internet-check
node --check package/luci-app-alemprator-ota/files/www/luci-static/resources/view/system/ota_v2.js
Node JSON.parse validation for menu and ACL JSON
make package/luci-app-alemprator-ota/compile V=s
```

Router checks after forced reinstall:

```json
{"status":"online","internet_ok":true,"server_ok":true,"message":"الإنترنت وخادم التحديثات يعملان.","lan_ip":"192.168.1.20","gateway":"192.168.1.2","server_url":"https://ota.kartnet.org","server_host":"ota.kartnet.org","mikrotik_command":"/ip firewall nat add chain=srcnat src-address=192.168.1.20 action=masquerade comment=\"Alemprator updater internet access\""}
```

Router `status-json` still reports current firmware `24.10.4.1-km12-r3`, model `kt,km12-007h`, and `last_result: up_to_date`.

### Notes

- Integrated browser reached `http://192.168.1.20/cgi-bin/luci/admin/system/ota-update`, but LuCI required login, so no authenticated visual screenshot was taken.
- A stale SSH known-host warning appeared because the router host key changed after firmware work. The deployment was still completed using explicit host-key options for this lab router.

## Conversation Update 2026-05-03: KM12 r4 Full Image Published

Built and published the full KM12 r4 sysupgrade image using the canonical version string:

```text
24.10.4.1-km12-r4
```

Important: do not use the old shortened form `24.10.4-km12-r3` for new releases. That shortened r3 row remains only as an inactive historical DB row.

### r4 Source State

- `package/luci-app-alemprator-ota/files/etc/alemprator/firmware-version` is `24.10.4.1-km12-r4`.
- `ota-server/scripts/seed-km12-release.mjs` has:
  - `version = '24.10.4.1-km12-r4'`
  - `versionCode = '24.10.4.1-km12-r4'`
  - artifact `openwrt-ramips-mt7621-kt_km12-007h-squashfs-sysupgrade-24.10.4.1-km12-r4.bin`

### Published r4 Artifact

```text
https://ota.kartnet.org/firmware/openwrt-ramips-mt7621-kt_km12-007h-squashfs-sysupgrade-24.10.4.1-km12-r4.bin
```

Details:

```text
size:   12524593
sha256: 49b878a995d92d535b8f4b91446ac193afff28dfcc21c85a68ae0aa2fe9fdade
HTTP:   200 OK
```

The active OTA DB release for model `kt,km12-007h` is now:

```json
{
  "version": "24.10.4.1-km12-r4",
  "versionCode": "24.10.4.1-km12-r4",
  "active": true,
  "channel": "stable",
  "sha256": "49b878a995d92d535b8f4b91446ac193afff28dfcc21c85a68ae0aa2fe9fdade",
  "fileSize": "12524593"
}
```

Sysupgrade metadata was verified with `fwtool -i`; the image reports `new_supported_devices: ["kt,km12-007h"]` and OpenWrt target `ramips/mt7621` board `kt_km12-007h`.

### Router Check During r4 Publish

Router `192.168.1.20` was reachable by SSH, but `internet-check` returned `no_internet` because its gateway was `192.168.1.1` at that moment:

```json
{"status":"no_internet","internet_ok":false,"server_ok":false,"lan_ip":"192.168.1.20","gateway":"192.168.1.1"}
```

This blocks the router from seeing r4 until its upstream/gateway/NAT is fixed, but does not affect the published OTA image or the active r4 release in the server database.

## Conversation Update 2026-05-03: KM14 r30 With System Update UI

Implemented the safe KM14 path requested after the KM12 r4 work. The goal was to bring these OTA improvements into `kt,km14-102h` without mixing KM12 artifacts or adding test files:

- Fix the `check update` button so it checks only and does not start an upgrade.
- Rename the LuCI update page from OTA wording to `تحديث النظام` / `تحديثات النظام`.
- Improve the update page layout to match the quick setup style.
- Add internet checking and a ready MikroTik command when the router has no upstream internet.

### Source / Config State

- Firmware identity was changed to:

```text
24.10.4-km14-r30
```

- Active `.config` was restored from `KT-KM14-102H-01-05-2026.config` and regenerated with `make defconfig`.
- Verified target selection:

```text
CONFIG_TARGET_ramips_mt7621_DEVICE_kt_km14-102h=y
# CONFIG_TARGET_ramips_mt7621_DEVICE_kt_km12-007h is not set
CONFIG_PACKAGE_luci-app-alemprator-ota=y
CONFIG_PACKAGE_luci-app-setup=y
CONFIG_PACKAGE_alemprator-firstboot=y
```

- The image manifest contains:

```text
alemprator-firstboot - 1.0-r8
luci-app-alemprator-ota - 1.0-r20
luci-app-setup - 1.0-r91
```

### Build Verification

Pre-build checks passed:

```text
sh -n package/luci-app-alemprator-ota/files/usr/libexec/alemprator-ota/agent.sh
sh -n package/luci-app-alemprator-ota/files/usr/libexec/alemprator-ota/internet-check
node --check package/luci-app-alemprator-ota/files/www/luci-static/resources/view/system/ota_v2.js
Node JSON.parse validation for menu and ACL JSON
```

Package builds passed for:

```text
package/luci-app-alemprator-ota
package/luci-app-setup
package/alemprator-firstboot
```

Full `make -j$(nproc)` build completed successfully and ended with:

```text
make[2] json_overview_image_info
make[2] checksum
```

### Published r30 Artifact

Local source build output:

```text
bin/targets/ramips/mt7621/openwrt-ramips-mt7621-kt_km14-102h-squashfs-sysupgrade.bin
```

Named r30 artifact:

```text
bin/targets/ramips/mt7621/alemprator-km14-102h-24.10.4-km14-r30-sysupgrade.bin
```

Published OTA artifact:

```text
ota-server/public/firmware/alemprator-km14-102h-24.10.4-km14-r30-sysupgrade.bin
```

Public URL:

```text
https://ota.kartnet.org/firmware/alemprator-km14-102h-24.10.4-km14-r30-sysupgrade.bin
```

Artifact details:

```text
size:   9933873
sha256: 992d3332873cf72dc0c6e14ee64f9b4b6278446f2ba22f43edee87e2f6a608ec
HTTP:   200 OK
```

Sysupgrade metadata was verified with `fwtool -i`; the image reports:

```text
new_supported_devices: ["kt,km14-102h"]
target: ramips/mt7621
board: kt_km14-102h
```

### OTA DB State

The active OTA DB release for model `kt,km14-102h` is now:

```json
{
  "version": "24.10.4-km14-r30",
  "versionCode": "24.10.4-km14-r30",
  "active": true,
  "channel": "stable",
  "downloadUrl": "https://ota.kartnet.org/firmware/alemprator-km14-102h-24.10.4-km14-r30-sysupgrade.bin",
  "sha256": "992d3332873cf72dc0c6e14ee64f9b4b6278446f2ba22f43edee87e2f6a608ec",
  "fileSize": "9933873"
}
```

The previous `24.10.4-km14-r29` release is inactive.

### Live Router Diagnosis After r30 Publish

After the first final validation, the user asked to open the live KM14 router at `192.168.1.21` with password `123456` and diagnose why r30 did not appear, without modifying the project. The check was done read-only. No source files and no router settings were changed during that diagnostic pass.

The router was reachable later and reported:

```text
current firmware: 24.10.4-km14-r29
board/model: kt,km14-102h
luci-app-alemprator-ota: 1.0-r12
/usr/libexec/alemprator-ota/internet-check: not found
br-lan IP: 192.168.1.21/24
default route: via 192.168.1.1 dev br-lan
ping 1.1.1.1: 100% packet loss
status-json last_error: update check request failed: Failed to send request: Operation not permitted
logread: alemprator-ota register failed; continuing with update check: register request failed: Failed to send request: Operation not permitted
```

Server-side checks confirmed r30 is published and active for KM14:

```text
model: kt,km14-102h
version: 24.10.4-km14-r30
active: true
channel: stable
url: https://ota.kartnet.org/firmware/alemprator-km14-102h-24.10.4-km14-r30-sysupgrade.bin
sha256: 992d3332873cf72dc0c6e14ee64f9b4b6278446f2ba22f43edee87e2f6a608ec
size: 9933873
```

The live router MAC seen during diagnosis was:

```text
0c:96:cd:65:be:bf
```

That device was not found in the OTA server device table because its `/api/register` and update-check requests do not reach the server.

Conclusion: r30 not appearing on `192.168.1.21` is not a firmware artifact problem, not a wrong link problem, and not an OTA DB activation problem. The router is still on r29 with old OTA package `1.0-r12`, and it cannot reach the internet/OTA server through gateway `192.168.1.1`. Until upstream routing/NAT is fixed, the old System Update page cannot fetch r30.

Likely MikroTik NAT command for this specific router:

```text
/ip firewall nat add chain=srcnat src-address=192.168.1.21 action=masquerade comment="Alemprator updater internet access"
```

After internet/NAT is fixed, pressing the update check button should allow the router to see `24.10.4-km14-r30`. Because the live router has OTA `1.0-r12`, it will not show the newer r20 `internet-check` explanation UI until it is upgraded.

### Final Handoff State For New Conversation

- Latest KM12 release remains `24.10.4.1-km12-r4` for model `kt,km12-007h`.
- Latest KM12 artifact remains active in OTA DB:

```text
https://ota.kartnet.org/firmware/openwrt-ramips-mt7621-kt_km12-007h-squashfs-sysupgrade-24.10.4.1-km12-r4.bin
size:   12524593
sha256: 49b878a995d92d535b8f4b91446ac193afff28dfcc21c85a68ae0aa2fe9fdade
```

- Latest KM14 release is `24.10.4-km14-r30` for model `kt,km14-102h`.
- Latest KM14 artifact remains active in OTA DB:

```text
https://ota.kartnet.org/firmware/alemprator-km14-102h-24.10.4-km14-r30-sysupgrade.bin
size:   9933873
sha256: 992d3332873cf72dc0c6e14ee64f9b4b6278446f2ba22f43edee87e2f6a608ec
```

- Current source tree build identity after latest work is KM14, not KM12:

```text
package/luci-app-alemprator-ota/files/etc/alemprator/firmware-version = 24.10.4-km14-r30
CONFIG_TARGET_ramips_mt7621_DEVICE_kt_km14-102h=y
# CONFIG_TARGET_ramips_mt7621_DEVICE_kt_km12-007h is not set
# CONFIG_PACKAGE_alemprator-suite is not set
CONFIG_PACKAGE_luci-app-alemprator-ota=y
CONFIG_PACKAGE_luci-app-setup=y
CONFIG_PACKAGE_alemprator-firstboot=y
```

- KM14 r30 image manifest includes:

```text
alemprator-firstboot - 1.0-r8
luci-app-alemprator-ota - 1.0-r20
luci-app-setup - 1.0-r91
```

- Important next-conversation warning: older sections may mention an earlier active KM12 `.config` or an earlier moment when `192.168.1.21` was unreachable. The current final state is the one in this handoff section: source `.config` is KM14 r30, and `192.168.1.21` was later reached and diagnosed as a no-internet/NAT issue.

## Conversation Update 2026-05-04: Multi-Model Setup, Firstboot, KM12 r6, KM14 r36

This is now the newest handoff section. Older sections above are historical and may mention KM14 r30, KM12 r4, or the old KM14 `192.168.1.21` firstboot/LAN behavior. The current source and published state after the 2026-05-04 work is described here.

### User Direction And Constraints

The user asked to keep Alemprator as a clean multi-device system for current and future models, with these constraints:

- Apply improvements to all models in `alemprator-models.json`, not only KM12, KM14, or AR07.
- Avoid duplicated per-model code unless a device really needs a different value.
- If a value must vary by device, store it in the central model registry first.
- Work in safe stages: small change, validate, build one model if firmware is needed, then dry-run the rest.
- Keep LAN/AP safety intact and do not add unnecessary files.

### Current Central Model Registry State

`alemprator-models.json` now has global firstboot defaults:

```json
"defaults": {
  "firstboot": {
    "lanIp": "192.168.1.20",
    "setupIp": "192.168.8.1"
  }
}
```

Current model versions in the registry:

```text
km12: 24.10.4.1-km12-r6
km14: 24.10.4-km14-r36
ar07: 1.1.0-test
```

Current per-model firstboot LAN values for KM12, KM14, and AR07 are all `192.168.1.20`. The temporary setup IP remains `192.168.8.1`.

Current active `.config` target after the latest work is KM14:

```text
CONFIG_TARGET_ramips_mt7621_DEVICE_kt_km14-102h=y
# CONFIG_TARGET_ramips_mt7621_DEVICE_kt_km12-007h is not set
CONFIG_TARGET_PROFILE="DEVICE_kt_km14-102h"
```

### Setup Wizard SSID IP Suffix Change

The setup wizard was updated so the SSID IP-suffix option appears in both the primary Wi-Fi section and the VLAN section.

- File changed: `package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js`
- The primary-section checkbox and VLAN checkbox are synchronized to the same UCI option.
- If the user toggles it from primary Wi-Fi, VLAN follows; if toggled from VLAN, primary follows.
- Validation performed:
  - `node --check package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js`
  - `make package/luci-app-setup/compile V=s`
  - dry-run passed for KM12, KM14, and AR07.

This change was included in later package builds and firmware images.

### Firstboot / Factory Default LAN Change

The user requested that after factory reset or first programming, LAN bridge must be available on `192.168.1.20`, while the temporary setup network remains available on `192.168.8.1`.

Implemented behavior:

- LAN bridge default: `192.168.1.20`
- Temporary setup network: `192.168.8.1`
- The temporary provisioning sections are deleted after the first real save from:
  - quick setup LuCI page
  - any relevant LuCI page that commits UCI changes
  - terminal scripts or manual `uci commit`
- Cleanup deletes only the temporary sections:
  - `network.alemprator_setup`
  - `dhcp.alemprator_setup`
  - `wireless.alemprator_firstboot`
  - `firewall.alemprator_setup`
- Cleanup must not delete or change the real LAN configuration chosen by the user.

Files changed:

- `alemprator-models.json`
  - Added global `defaults.firstboot.lanIp = 192.168.1.20` and `setupIp = 192.168.8.1`.
  - Normalized KM12/KM14/AR07 `firstboot.lanIp` to `192.168.1.20`.
- `package/alemprator-firstboot/Makefile`
  - `PKG_RELEASE:=10`.
  - Description now documents LAN `192.168.1.20` and temp setup `192.168.8.1`.
- `package/alemprator-firstboot/files/etc/config/alemprator_firstboot`
  - Default `option lan_ipaddr '192.168.1.20'`.
  - Default `option setup_ipaddr '192.168.8.1'` remains.
- `package/alemprator-firstboot/files/etc/uci-defaults/95-alemprator-firstboot`
  - Removed old board-specific KM14 LAN `192.168.1.21` logic.
  - Keeps board-specific SSID selection only.
  - Keeps sysupgrade keep-settings guard for `/sysupgrade.tgz` and `/tmp/sysupgrade.tar`.
- `package/alemprator-firstboot/files/etc/init.d/alemprator-firstboot`
  - Cleanup flags align to `enabled=0`, `configured_once=1`, `auto_cleanup_armed=0`, `auto_cleanup_pending=0`.
  - `monitor_once()` now schedules deferred cleanup when the baseline changes instead of waiting for an ambiguous second cycle.
- `package/luci-app-setup/Makefile`
  - `PKG_RELEASE:=94`.
- `package/luci-app-setup/files/etc/config/setup`
  - Default `option lan_ipaddr '192.168.1.20'`.
- `package/luci-app-setup/files/etc/uci-defaults/40_luci-app-setup`
  - Default setup LAN IP is `192.168.1.20`.
  - Old `192.168.1.21` and `192.168.1.22` remain only as migration cases to normalize old devices to `192.168.1.20`.
- `package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js`
  - `disableFirstbootProvisioning()` now aligns firstboot flags with the runtime cleanup state.

Validation performed for this stage:

```text
JSON.parse(alemprator-models.json): OK
sh -n firstboot/setup shell scripts: OK
node --check setup.js: OK
make package/alemprator-firstboot/compile V=s: OK
make package/luci-app-setup/compile V=s: OK
scripts/alemprator-package-audit.sh: Duplicate file ownership: none
dry-run: KM12 OK, KM14 OK, AR07 OK
```

One full firmware build was performed as the staged build test:

```text
model: km12
image: bin/targets/ramips/mt7621/openwrt-ramips-mt7621-kt_km12-007h-squashfs-sysupgrade.bin
size: 12524593
sha256: 28923df69dc4c6e57fc60631eb4a82435f8c9ef3aa74e241287749aa581f6162
```

That KM12 build was validation-only for the firstboot change and was not published as a new OTA release. The published KM12 r6 artifact listed below has a different SHA from an earlier r6 build.

### Critical KM14 Root Cause: `98_custom` Override

After KM14 r35 was built and published, the user reported that factory reset / first boot still returned to `192.168.1.21`.

Root cause found:

```text
target/linux/ramips/mt7621/base-files/etc/uci-defaults/98_custom
```

That target-level uci-defaults file had a KM14-specific override:

```sh
device_lan_ipaddr='192.168.1.21'
```

It later applied:

```sh
uci set network.lan.ipaddr="$device_lan_ipaddr"
```

This ran outside `alemprator-firstboot`, so the firstboot package changes alone could not fix KM14. The fix was to remove only the KM14 LAN override from `98_custom`; KM14 still keeps board-specific hostname and SSID logic. Current `98_custom` default is:

```sh
device_lan_ipaddr='192.168.1.20'
```

Search verification after the fix found no `192.168.1.21` remaining in `target/linux/ramips/mt7621/base-files/etc/uci-defaults/**`.

### KM14 r34, r35, r36 Release History

KM14 r34 was built and published first after setup wizard changes:

```text
version: 24.10.4-km14-r34
url: https://ota.kartnet.org/firmware/openwrt-ramips-mt7621-kt_km14-102h-squashfs-sysupgrade-24.10.4-km14-r34.bin
size: 9933873
sha256: 141493e6b4802a0bda16c823e552b33ffa153d7fe0ca9bc98c724dcbd4fd2e73
HTTP: 200 OK
```

KM14 r35 was then built and published for the firstboot/default LAN changes:

```text
version: 24.10.4-km14-r35
url: https://ota.kartnet.org/firmware/openwrt-ramips-mt7621-kt_km14-102h-squashfs-sysupgrade-24.10.4-km14-r35.bin
size: 9933873
sha256: 2698542766ac5ebe854e3c6b4f2abb75fedf1f4512a02663d490242c2b72b68d
HTTP: 200 OK
```

Important: r35 is superseded. It was built before discovering the target-level `98_custom` KM14 override, so it can still produce `192.168.1.21` after factory reset.

Current correct KM14 release is r36:

```text
version: 24.10.4-km14-r36
url: https://ota.kartnet.org/firmware/openwrt-ramips-mt7621-kt_km14-102h-squashfs-sysupgrade-24.10.4-km14-r36.bin
size: 9933873
sha256: dd6edcc8039094a9227e9194a03c4812cd0601ef5d0b63591d32c0634f79bd35
HTTP local: 200 OK
HTTP public: 200 OK
```

KM14 r36 was published as a new release, not as an overwrite. It includes:

- The firstboot/setup shared defaults.
- `alemprator-firstboot` r10.
- `luci-app-setup` r94.
- `luci-app-alemprator-ota` r28 identity metadata.
- Removal of the KM14 `192.168.1.21` override from `98_custom`.

After updating a KM14 device to r36 and doing a factory reset / first boot, expected LAN IP is `192.168.1.20`, not `192.168.1.21`. Temporary setup access should remain on `192.168.8.1` until the first real configuration save.

### KM12 r6 Release History

KM12 was bumped from r5 to r6 and published after the setup wizard primary/VLAN SSID suffix work:

```text
version: 24.10.4.1-km12-r6
url: https://ota.kartnet.org/firmware/openwrt-ramips-mt7621-kt_km12-007h-squashfs-sysupgrade-24.10.4.1-km12-r6.bin
size: 12524593
sha256: ce32f4f5bbc47d09663e3f2162fba586ae888d92da0e9399b9ec70cab9a70a78
HTTP public: 200 OK
```

Important: later in the firstboot/default LAN stage, KM12 was built again for validation and produced SHA256 `28923df69dc4c6e57fc60631eb4a82435f8c9ef3aa74e241287749aa581f6162`, but that validation image was not published. If publishing the firstboot/default LAN changes for KM12 is needed, use a new version such as r7 instead of replacing r6 content.

### Current OTA Identity Package State

`package/luci-app-alemprator-ota/Makefile`:

```text
PKG_RELEASE:=28
```

`package/luci-app-alemprator-ota/files/etc/alemprator/model-identities` currently maps:

```text
kt,km12-007h|kt,km12-007h|24.10.4.1-km12-r6|24.10.4.1-km12-r6|km12
kt,km14-102h|kt,km14-102h|24.10.4-km14-r36|24.10.4-km14-r36|km14
kt,ar07-102h|AR-07-102H|1.1.0-test|110-test|ar07
```

### OTA Server Notes

- OTA server path: `ota-server`
- Public firmware directory: `ota-server/public/firmware`
- Public base URL: `https://ota.kartnet.org`
- Local check URL: `http://127.0.0.1:8080`
- Publish script used for both KM12 and KM14:

```sh
cd /home/baalwy/openwrt/ota-server
node scripts/seed-km12-release.mjs km14
node scripts/seed-km12-release.mjs km12
```

Despite the script name, it supports a model argument and was used successfully for KM14 r35/r36 and KM12 r6.

### Known Runtime Notes

- A router-side SSL message like `SSL verify error: unknown error` was discussed. The firmware URL itself was valid; likely causes are router time, CA trust, DNS, proxy, or network reachability.
- If KM14 still shows `192.168.1.21` after testing r36, first verify the router actually installed `24.10.4-km14-r36` and that factory reset/first boot ran the new uci-defaults. Also confirm settings were not kept from an older image.
- If OTA checks time out, first re-check router route, DNS, date/time, and upstream NAT before changing OTA code.

### New-Conversation Priority

The most current practical next hardware validation is:

1. Update KM14 to `24.10.4-km14-r36`.
2. Factory reset / format without keeping old settings.
3. Confirm LAN bridge is reachable at `192.168.1.20`.
4. Confirm temporary setup network is reachable at `192.168.8.1`.
5. Make any real save from LuCI or a terminal `uci commit` flow.
6. Confirm temporary setup sections disappear and LAN remains stable.

Do not reuse r34 or r35 for new KM14 content. For any further KM14 change, bump to r37 or later. For any further KM12 change, bump to r7 or later.

## Conversation Update 2026-05-05: KM14 r37 Bridge Port Fix

This is the newest handoff update after the 2026-05-04 firstboot/LAN work. KM14 r36 fixed the factory LAN IP, but the user showed a LuCI screenshot where KM14 still displayed KM12-style bridge ports: `wan lan1 lan2 lan3 lan4`.

### Root Cause

The KM14 DTS correctly defines only these switch ports:

```text
wan
lan
```

The KM12 DTS defines:

```text
wan
lan1
lan2
lan3
lan4
```

However, `target/linux/ramips/mt7621/base-files/etc/uci-defaults/98_custom` was forcing the bridge device ports for every board to:

```text
lan1 lan2 lan3 lan4 wan
```

That made KM14 LuCI show KM12 ports even though the board is KM14.

### Fix Applied

`98_custom` now selects bridge ports based on `board_name`:

```sh
device_bridge_ports='lan1 lan2 lan3 lan4 wan'

case "$board_name" in
  kt,km14-102h)
    device_bridge_ports='lan wan'
    ;;
  kt,km12-007h|'')
    ;;
esac
```

Then it applies the selected list generically:

```sh
uci del network.cfg030f15.ports
for bridge_port in $device_bridge_ports; do
  uci add_list network.cfg030f15.ports="$bridge_port"
done
```

This keeps KM12 behavior unchanged while KM14 now uses its real `lan` / `wan` device names.

### New Firmware Release

KM14 was bumped from r36 to r37 because r36 contains the wrong bridge-port default.

Current correct KM14 release:

```text
version: 24.10.4-km14-r37
url: https://ota.kartnet.org/firmware/openwrt-ramips-mt7621-kt_km14-102h-squashfs-sysupgrade-24.10.4-km14-r37.bin
size: 9933873
sha256: 9fe7902b764e1f4d7842ab8891ca4e6dfe31329baff5f91fcd1c07745aaab64f
HTTP local: 200 OK
HTTP public: 200 OK
```

Source version state:

```text
alemprator-models.json: 24.10.4-km14-r37
package/luci-app-alemprator-ota/Makefile: PKG_RELEASE:=29
model-identities KM14 line: 24.10.4-km14-r37
```

Validation performed:

```text
JSON.parse(alemprator-models.json): OK
sh -n target/linux/ramips/mt7621/base-files/etc/uci-defaults/98_custom: OK
KM14 dry-run: OK
KM14 full build: OK
KM14 r37 OTA publish: OK, overwritten=false
KM12 dry-run after shared 98_custom change: OK
AR07 dry-run after shared change: OK
```

Important: r37 supersedes r36 for KM14. If a KM14 router still shows `lan1 lan2 lan3 lan4` in LuCI after update, first verify it actually installed `24.10.4-km14-r37` and then factory-reset or clear the old saved `network` config, because sysupgrade with keep-settings can preserve the old bridge port list.

## Conversation Update 2026-05-05: KM12 r7 And AR-07 r1 Published

Built and published full images for KM12 and AR-07 so their firmware URLs can be entered in the OTA control panel.

### KM12 r7

```text
version: 24.10.4.1-km12-r7
url: https://ota.kartnet.org/firmware/openwrt-ramips-mt7621-kt_km12-007h-squashfs-sysupgrade-24.10.4.1-km12-r7.bin
size: 12524593
sha256: e02be988031ba88439c182fbdd05c621d066f087f479758e588565c7b2ce8e67
HTTP local: 200 OK
HTTP public: 200 OK
```

### AR-07 r1

AR-07 was changed from the old test identity to a production release identity:

```text
version: 24.10.4-ar07-r1
url: https://ota.kartnet.org/firmware/openwrt-qualcommax-ipq60xx-kt_ar07-102h-squashfs-sysupgrade-24.10.4-ar07-r1.bin
size: 14766878
sha256: 63aaaaf15a004dd2e196bc24213963830747b24c5ffb2ca5a8a237553ecfe0ad
HTTP local: 200 OK
HTTP public: 200 OK
```

Publication details:

- `node scripts/seed-km12-release.mjs km12` published KM12 r7 with `overwritten=false`.
- `node scripts/seed-km12-release.mjs ar07` published AR-07 r1 with `overwritten=false`.
- `package/luci-app-alemprator-ota/Makefile` was bumped to `PKG_RELEASE:=30` for the updated model identities.
- `model-identities` now contains KM12 r7 and AR-07 r1.

For future changes, do not replace these binaries under the same version. Bump KM12 to r8 or later, and AR-07 to r2 or later.

## Conversation Update 2026-05-07: Hotspot Protection (Alemprator Guard)

Initiated the implementation of a professional licensing and protection system for the Hotspot package to prevent unauthorized copying while maintaining open SSH access.

### Protection Strategy

- **Hardware Binding**: Code is tied to the unique `device.token` from the Alemprator OTA system.
- **Licensing**: Mandatory periodic check against `https://ota.kartnet.org/api/hotspot-verify`.
- **Grace Period**: 3 days for offline operation.
- **Hardening**: Binary compilation (SHC) of sensitive shell scripts.
- **Global Design**: Integrated into the central `alemprator-models.json` registry.

### Completed Steps

- **Step 1: Central Registry Update**:
  - Added `licensing` defaults to `alemprator-models.json`.
  - Added new models: **AR06-012H** and **DV02-012H** to the registry.
  - Defined `gracePeriodDays: 3` and `verifyPath: "/api/hotspot-verify"`.
  - Validation: JSON schema verified via Node.js.

- **Step 2: Universal License Checker**:
  - Implemented `/usr/libexec/hotspot-openwrt/license-check` using UCI (`hotspot_licensing`).
  - Integrated with `common.sh` for HMAC-signed verification requests.
  - Validation: Tested 3-day grace period and server-check flow on KM14.

### Current Work: Step 3

- **Integration**: Making the main `apply` script dependent on the license check.
- **Hardening (SHC)**: Compiling sensitive shell scripts into binary executables to prevent reading/copying the logic.
