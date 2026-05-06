# Alemprator Execution Plan

Last updated: 2026-05-04

## Goal

Produce a release-grade Alemprator integration for the target device family with:

- a coherent firmware image
- stable firstboot behavior
- a single quick-setup flow
- OTA compatibility through the existing release dashboard
- no duplicate package ownership and no hidden controller conflicts

## Verified Baseline

- Build tree already contains `alemprator-firstboot`, `luci-app-setup`, and `luci-app-alemprator-ota`.
- `scripts/alemprator-package-audit.sh` is now validated and reports concrete installed file paths.
- The audit currently reports no direct duplicate file ownership between the three packages.
- The remaining risk is logical controller overlap, not install-path collision.

## Verified Ownership Rules

### `alemprator-firstboot`

Owns temporary provisioning runtime and cleanup state:

- `/etc/config/alemprator_firstboot`
- `/etc/init.d/alemprator-firstboot`
- `/etc/uci-defaults/95-alemprator-firstboot`
- `/usr/share/ucitrack/alemprator-firstboot-*.json`

Current logical responsibilities:

- detect whether device is already configured
- create temporary provisioning network `alemprator_setup`
- create temporary provisioning SSID `alemprator_firstboot`
- track baseline config hashes and remove temporary provisioning after setup completes

### `luci-app-setup`

Owns setup UI, setup defaults, and runtime policy sync:

- `/etc/config/setup`
- `/etc/init.d/setup`
- `/etc/uci-defaults/40_luci-app-setup`
- `/etc/uci-defaults/45..49_*`
- `/www/luci-static/resources/view/setup/*`
- `/usr/share/luci/menu.d/zzz-luci-app-setup.json`
- `/usr/share/rpcd/acl.d/luci-app-setup.json`
- `/usr/share/ucitrack/luci-app-setup.json`

Current logical responsibilities:

- seed and maintain `setup.default`
- persist user-selected LAN, wireless, VLAN, and button-policy settings
- apply `network.lan` at save time
- apply and remove `wizardvlan`
- sync saved LAN values back into `network.lan` and `alemprator_firstboot.main`

### `luci-app-alemprator-ota`

Owns OTA runtime and release-facing identity:

- `/etc/config/alemprator_ota`
- `/etc/init.d/alemprator-ota`
- `/etc/alemprator/firmware-version`
- `/etc/uci-defaults/95-alemprator-ota`
- `/usr/libexec/alemprator-ota/*`
- `/www/luci-static/resources/view/system/ota*.js`

Current logical responsibilities:

- expose firmware version and OTA status
- perform check/update execution
- integrate with LuCI OTA page and release metadata

## Confirmed Logical Overlaps

These are the real stage-1 problems that still need cleanup:

1. `setup.default`
   - seeded by `luci-app-setup` uci-defaults
   - read and modified by `alemprator-firstboot`

2. `network.lan`
   - written by `alemprator-firstboot` provisioning defaults
   - written again by `luci-app-setup` during save/apply
   - synchronized again by `luci-app-setup` init service after boot

3. `wizardvlan`
   - generated and managed by `luci-app-setup`
   - interacts with firstboot provisioning assumptions and wireless state

4. setup completion state
   - `setup.default.initial_setup_complete`
   - `alemprator_firstboot.main.configured_once`
   - `/etc/configured`
   - `/etc/alemprator-firstboot-pending`

## Enforcement Decision

The intended ownership model for the next stages is:

1. `luci-app-setup` is the only source of truth for persisted user intent.
   - authoritative for `setup.default`
   - authoritative for final LAN/Wi-Fi/VLAN choices

2. `alemprator-firstboot` is only a temporary provisioning state machine.
   - may create temporary setup access
   - may detect completion and cleanup temporary resources
   - must not become a second long-term owner of saved user intent

3. `luci-app-alemprator-ota` is only the OTA owner.
   - owns firmware version identity and update runtime
   - must not own setup or firstboot behavior

## Multi-Stage Execution Plan

### Stage 0: Baseline lock

- keep current validated audit script in repo
- keep current target configs and current router behavior as baseline
- do not widen behavior changes before each slice has a direct validation step

Exit criteria:

- `sh scripts/alemprator-package-audit.sh` returns exit `0`

### Stage 1: Separate logical ownership

- reduce `alemprator-firstboot` writes to long-term setup state
- keep `luci-app-setup` as authoritative owner of `setup.default`
- document and enforce which component may write `network.lan`

Exit criteria:

- no duplicated long-term responsibility for setup completion markers
- no redundant LAN rewrites during steady-state boot

### Stage 2: Stabilize firstboot lifecycle

- verify firstboot only provisions temporary setup access when needed
- verify cleanup triggers are deterministic
- verify second boot does not recreate provisioning state after initial completion

Exit criteria:

- fresh flash creates setup access once
- after successful setup, reboot does not recreate temporary provisioning

### Stage 3: Stabilize quick-setup apply path

- verify UI save/apply persists `setup.default`
- verify `network.lan` changes remain stable after reboot
- verify `wizardvlan` creation/removal is idempotent

Exit criteria:

- apply path works on both fresh-flash and upgraded devices
- LAN access survives reboot and sysupgrade

### Stage 4: OTA alignment for target device

- verify model string, firmware version, and release metadata
- verify release dashboard can serve the correct firmware for this device class
- verify OTA client still behaves like the existing KM14 path

Exit criteria:

- device sees correct update metadata
- check-only and update flows complete successfully

### Stage 5: Image integration

- ensure final image includes required packages directly
- verify manifest contains expected Alemprator components
- keep meta-package helper optional, not the sole release mechanism

Exit criteria:

- firmware image contains the intended Alemprator stack without manual post-install steps

### Stage 6: Validation matrix

- fresh flash on test device
- reboot after setup completion
- OTA update from previous release
- post-upgrade verification of LAN, LuCI, SSH, and firmware version

Exit criteria:

- all scenarios pass on test hardware before dashboard rollout

## Multi-Device Organization Plan

This plan extends the KM12/KM14 work into a repeatable multi-device workflow. The rule is to add a new file only when it removes real duplication or prevents model identity from being mixed inside firmware, build output, or the OTA dashboard.

### Stage M1: Inventory model identity duplication

Confirmed model-specific data is currently duplicated in these places:

- OpenWrt target definitions: `target/linux/ramips/image/mt7621.mk`, `target/linux/qualcommax/image/ipq60xx.mk`
- model defaults and firstboot identity: `package/alemprator-firstboot/files/etc/uci-defaults/95-alemprator-firstboot`
- OTA runtime version mapping: `package/luci-app-alemprator-ota/files/usr/libexec/alemprator-ota/common.sh`
- OTA first-run correction: `package/luci-app-alemprator-ota/files/etc/uci-defaults/95-alemprator-ota`
- dashboard model seed data: `ota-server/scripts/seed-firmware-models.mjs`
- dashboard release seed data: `ota-server/scripts/seed-km12-release.mjs`
- test release seed data: `ota-server/scripts/seed-test-release.mjs`
- model config copies in the repository root, such as `KT-KM12-007H-01-05-2026.config` and `KT-KM14-102H-01-05-2026.config`

Exit criteria:

- every hardcoded board/model/version location is known before changing behavior
- no firmware or OTA publishing change is made during this inventory stage

### Stage M2: Create one model registry

Status: complete. The registry is `alemprator-models.json`; dashboard seed scripts now read model and release metadata from it.

Create a single project-level model registry that describes each supported model:

- short model id, for example `km12`, `km14`, `ar07`
- `board_name`, for example `kt,km12-007h`
- dashboard `modelKey` and `boardIdentifier`
- display name and dashboard slug
- OpenWrt target, subtarget, image slug, and config file
- current firmware version and version code
- release changelog defaults
- firstboot defaults that are truly model-specific, such as LAN IP and SSID prefix
- required shared packages

Exit criteria:

- KM12 and KM14 can be described from the registry without reading hardcoded values from OTA scripts
- adding a new model means adding one registry entry plus the real OpenWrt target/DTS/config work

Validation:

- `alemprator-models.json` parses successfully and exposes `km12`, `km14`, and `ar07`
- `seed-firmware-models.mjs`, `seed-km12-release.mjs`, and `seed-test-release.mjs` pass `node --check`
- registry-derived release metadata resolves the expected KM12/KM14 artifact names and AR07 smoke-test artifact path

### Stage M3: Use the registry in firmware runtime

Status: complete. OTA runtime now installs `/etc/alemprator/model-identities` and reads model/version identity from it instead of per-model version cases.

Move firmware model/version lookup away from per-model cases in OTA scripts. The firmware should install or generate a small identity file from the registry and let runtime scripts read that file.

Exit criteria:

- `common.sh` no longer needs a version case for every model
- `95-alemprator-ota` no longer rewrites KM12/KM14-specific versions from hardcoded cases
- model identity stays correct after sysupgrade with keep settings

### Stage M4: Use the registry in dashboard seeding and release publishing

Status: complete. Dashboard seed scripts read the registry, unknown models are rejected by registry lookup, and release seeding refuses overwrite unless `--allow-overwrite` or `ALEMPRATOR_ALLOW_RELEASE_OVERWRITE=1` is explicit.

Refactor OTA server seed scripts so firmware models and release artifacts come from the same registry.

Exit criteria:

- `seed-firmware-models.mjs` reads model definitions from the registry
- release seeding/publishing accepts a model id and refuses unknown models
- publishing refuses to overwrite an existing release unless explicitly allowed

### Stage M5: Add model-aware build and verification commands

Status: complete. The build command is `node scripts/alemprator-build-model.mjs <model-id>` and validates target profile, required shared packages, image path, size, and SHA256. Use `--restore-config` when the active `.config` should be preserved.

Add a single model-aware build path that applies the selected config, runs `make defconfig`, builds the image, and verifies the manifest and image hash.

Exit criteria:

- one command can build KM12 or KM14 from the registry
- post-build verification confirms target profile, required packages, image path, and SHA256
- active `.config` is restored or intentionally left with a clearly reported model

### Stage M6: Validate with a third model

Status: complete. AR07 validates from the same registry and build verification path as KM12/KM14; the AR07 config now enables the shared Alemprator packages required by the registry.

Use one additional model entry as a proof that the workflow is not hardcoded to KM12/KM14.

Exit criteria:

- a third model can be registered in the dashboard from the registry
- build/publish scripts reject missing image/config fields cleanly
- shared changes can be carried to the new model without duplicating OTA/firstboot logic

## Immediate Next Slice

The multi-device organization stages M1-M6 are complete at code/config level. Remaining validation is hardware/network validation: fresh flash, setup completion reboot, OTA from previous release, and LAN/LuCI/SSH/version checks on real devices.

## VLAN SSID IP Suffix r32 Plan

Scope: implement the requested VLAN SSID suffix once in the shared `luci-app-setup` package so KM12, KM14, AR07, and future registry models inherit the same behavior without model-specific copies.

Stages:

1. Add one persisted setup option, `wifi_ssid_vlan_ip_suffix`, defaulting off.
2. Apply the suffix in the existing VLAN SSID generation helpers only, using the last two octets of the current LAN IP.
3. Keep saved SSID fields as base names and append the suffix only to preview/applied wireless SSIDs.
4. Align post-install and uci-defaults recovery/fix scripts with the same suffix behavior.
5. Bump `luci-app-setup` to r92 and KM14 firmware metadata to `24.10.4-km14-r32`.
6. Validate syntax, model dry-runs, then build and publish one KM14 r32 image.