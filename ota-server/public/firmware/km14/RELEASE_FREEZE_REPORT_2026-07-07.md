# KM14 Release Freeze Report

Date: 2026-07-07
Scope: Release hygiene and publication lock for KM14 artifacts.

## Actions Performed

1. Archived all top-level package files from ota-server/public to an archive folder.
2. Kept the official release source under ota-server/public/firmware/km14 only.
3. Re-generated checksums for the official KM14 release folder.
4. Preserved all archived artifacts without deletion.

## Cleanup Results

- Moved from ota-server/public root: 108 ipk files
- Remaining in ota-server/public root: 0 ipk files
- Archived location: ota-server/public/_archive_release_freeze_2026-07-07
- Archived total: 108 ipk files

## Official Release Path (Locked)

- ota-server/public/firmware/km14/openwrt-ramips-mt7621-kt_km14-102h-squashfs-factory.bin
- ota-server/public/firmware/km14/openwrt-ramips-mt7621-kt_km14-102h-squashfs-sysupgrade.bin
- ota-server/public/firmware/km14/openwrt-ramips-mt7621-kt_km14-102h.manifest
- ota-server/public/firmware/km14/SHA256SUMS
- ota-server/public/firmware/km14/packages/*.ipk

## Verification Snapshot

- KM14 package count in official path: 16 ipk files
- Public root package count after cleanup: 0 ipk files

## Notes

- This was a safe move operation (archive), not deletion.
- Rollback is possible by moving files back from the archive directory.
