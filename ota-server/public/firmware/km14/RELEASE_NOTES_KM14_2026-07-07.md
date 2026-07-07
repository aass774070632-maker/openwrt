# KM14 Release Notes

Release date: 2026-07-07
Target: ramips/mt7621
Device profile: kt_km14-102h

## Firmware Artifacts

- openwrt-ramips-mt7621-kt_km14-102h-squashfs-factory.bin
- openwrt-ramips-mt7621-kt_km14-102h-squashfs-sysupgrade.bin
- openwrt-ramips-mt7621-kt_km14-102h.manifest
- SHA256SUMS

## Included Custom Packages (official)

- alemprator-firstboot_1.0-r12_mipsel_24kc.ipk
- alemprator-guard_1.0-r1_mipsel_24kc.ipk
- alemprator-mtax_1.0-r3_mipsel_24kc.ipk
- alemprator-suite_1.0-r1_mipsel_24kc.ipk
- bandix-plus_0.1.0-r1_mipsel_24kc.ipk
- luci-app-alemprator-dhcp_1.0-r1_mipsel_24kc.ipk
- luci-app-alemprator-ota_1.0-r47_mipsel_24kc.ipk
- luci-app-bandix-plus_0.1.0-r1_all.ipk
- luci-app-cpu-perf_0.6.1-r2_all.ipk
- luci-app-cpu-status_0.6.3-r1_all.ipk
- luci-app-hotspot-openwrt_1.0-r126_mipsel_24kc.ipk
- luci-app-log-viewer_1.5.0-r2_all.ipk
- luci-app-netspeedtest_26.137.52127~e1ca5a9_all.ipk
- luci-app-setup_1.0-r120_mipsel_24kc.ipk
- luci-app-temp-status_0.8.1-r1_all.ipk
- luci-app-tn-netports_2.0.7-r1_all.ipk

## Field Validation Summary

- LuCI routes for hotspot, cpu-perf, dhcp, setup, bandix, cpu-status, log-viewer, netspeedtest, temp-status, and tn-netports verified with HTTP 200.
- Post-reboot regression passed on router 192.168.1.20.
- netspeedtest init permissions issue was fixed and verified post-reboot.

## Publication Hygiene

- Public root ipk files were archived to:
  ota-server/public/_archive_release_freeze_2026-07-07
- Official release source is now only:
  ota-server/public/firmware/km14
