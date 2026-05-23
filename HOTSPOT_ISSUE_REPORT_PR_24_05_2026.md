# Hotspot Settings Persistence Issue (Root Cause & Fix)

## Issue Description
Users reported that after disabling Hotspot in the initial setup screen and moving to configure a different mode (like AP or Mesh), the original Hotspot settings would stubbornly persist in the Web UI. Users experienced a "ghost" Hotspot wireless interface that refused to go away or was immediately recreated upon hitting `Save & Apply`.

## Root Cause Analysis
The issue was tracked down to a race condition between the backend shell scripts and the frontend JavaScript state machine (`setup.js`):

1. **Backend Cleanup Was Working:** `cleanup-hotspot` genuinely deleted the `wizard_hotspot` network and `hotspot_openwrt` data when the feature was disabled.
2. **Frontend UI Desync:** The frontend `setup.js` determined whether to rebuild the Hotspot configuration by looking at:
   `uci.get('hotspot_openwrt', 'main', 'enabled') === '1'`
3. **The Catch-22:** Because `cleanup-hotspot` aggressively deleted the `hotspot_openwrt.main` section entirely, `uci.get()` in JS didn't return `'0'`. Furthermore, there was another fallback state taking cues from memory. So when the JS `applyHotspotSettings` method ran upon `Save & Apply`, it erroneously believed Hotspot *should* be enabled, implicitly recreating the OpenWrt configurations that `cleanup` had just deleted.

Additionally, `cleanup-hotspot`'s `grep` matching string to find unused interfaces was too vague (e.g., `*hotspot*`), risking false-positive deletions of user configuration in Edge cases.

## Resolution
1. **Frontend Fix (`package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js`):**
   - Transferred the UI's source of truth from checking `hotspot_openwrt.main.enabled` to checking `setup.default.hotspot_enabled_from_wizard` directly. Since `setup.default` persists until we explicitly wipe it in a controlled fashion, this perfectly tracks the user's intent.
2. **Backend Safety (`package/luci-app-setup/files/usr/libexec/alemprator-setup/cleanup-hotspot`):**
   - Restricted wildcard matching to exact phrase bounds in the `case $networks` block. E.g., `*" hotspot "*` and `*" hotspot_openwrt "*` instead of `*hotspot*` to safeguard network arrays.

## Testing Status
* Verified locally on `KT-KM12` hardware (`192.168.1.20`).
* Confirmed that updating the mode now correctly shifts state and cleans out lingering Hotspot UI modules without regenerating ghost artifacts.

## Next Steps (Cloud Actions)
1. Build the updated `.ipk` variations for `luci-app-setup`.
2. Repack `.bin` firmware bundles via OTA CI/CD pipelines.
3. Validate OTA updates against DV-02 hardware.
