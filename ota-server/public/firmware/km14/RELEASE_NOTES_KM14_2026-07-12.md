# KM14 Release Notes

Release date: 2026-07-12 (updated 2026-07-13)
Target: ramips/mt7621
Device profile: kt_km14-102h

## Firmware Artifacts

- openwrt-ramips-mt7621-kt_km14-102h-squashfs-factory.bin
- openwrt-ramips-mt7621-kt_km14-102h-squashfs-sysupgrade.bin
- openwrt-ramips-mt7621-kt_km14-102h.manifest
- SHA256SUMS

## Changes in this release

### luci-app-hotspot-openwrt (r138 → r139)

**Root cause fix: removed REST API dependency in hotspot-card-info CGI**

The hotspot-card-info CGI script previously called `userman-info` in the background,
which connected to MikroTik's REST API (v7) or legacy C API (v6) to fetch balance
and profile data. This introduced:

1. Lock file race conditions (multiple concurrent requests)
2. Stale cache for up to 1 hour
3. 180-second timeout in C binary (v6 compatibility)
4. v6/v7 compatibility issues
5. Three independent failure points (shell CGI → Lua proxy → C binary)

**Solution:** Replaced all REST API / C API calls with direct reads from the local
CoovaChilli session database via `chilli_query list`. All RADIUS attributes
(Session-Timeout, input/output octets, bandwidth limits) are already stored by
CoovaChilli at authentication time — the extra API call was entirely redundant.

**Specific changes:**
- hotspot-card-info: removed 137 lines (background jobs, lock files, cache,
  userman-info calls); simplified to 108 lines — reads only from chilli_query
- status.html: reads balance fields directly from top-level response (no more
  `user_manager` sub-object)
- Makefile: removed `+curl` and `+libc` dependencies, removed C code build
  (Build/Prepare, Build/Compile), removed userman-info and mikrotik_api from install
- Eliminated 3 external dependencies (curl, mikrotik_api C binary, userman-info Lua proxy)
- Package size reduced, no external network calls during status page load

### Packages
- alemprator-firstboot_1.0-r12_mipsel_24kc.ipk
- alemprator-guard_1.0-r1_mipsel_24kc.ipk
- alemprator-mtax_1.0-r3_mipsel_24kc.ipk
- alemprator-suite_1.0-r1_mipsel_24kc.ipk
- bandix-plus_0.1.0-r1_mipsel_24kc.ipk
- luci-app-alemprator-dhcp_1.0-r1_mipsel_24kc.ipk
- luci-app-alemprator-ota_1.0-r48_mipsel_24kc.ipk
- luci-app-bandix-plus_0.1.0-r1_all.ipk
- luci-app-cpu-perf_0.6.1-r2_all.ipk
- luci-app-cpu-status_0.6.3-r1_all.ipk
- luci-app-hotspot-openwrt_1.0-r139_mipsel_24kc.ipk
- luci-app-log-viewer_1.5.0-r2_all.ipk
- luci-app-netspeedtest_26.137.52127~e1ca5a9_all.ipk
- luci-app-setup_1.0-r121_mipsel_24kc.ipk
- luci-app-temp-status_0.8.1-r1_all.ipk
- luci-app-tn-netports_2.0.7-r1_all.ipk

## Validation

- hotspot-card-info returns valid JSON without calling any external API
- status.html displays balance, profile, speed limits from RADIUS data
- No lock files, no cache files, no background processes on status page
- Package built successfully for mipsel_24kc

---

### luci-app-hotspot-openwrt (r139 → r140 — 10 fix commits)

**Root cause fixes:**
- #8 logout_ok بدون socket: حذف `[ -n "$matched_socket" ] || logout_ok='true'`، إضافة `NO_SESSION`
- #19 Speed بدون sanitize: دالة `sanitize_speed_spec()` تقبل فقط `[0-9]+[km]/[0-9]+[km]`
- #5/#6 متغيرات عالمية + No local: `local` لـ ~58 متغيراً في `apply_config`
- #14 كتابة غير ذرية /etc/hosts: `cat >` → `mv` (atomic rename)
- #13 مجلد في conffiles: حذف `/etc/hotspot-openwrt/backups/`
- #11 ملفات PID ميتة: حذفها من `status-json`
- #12 مسح WiFi عشوائي: حماية أقسام hotspot فقط
- #16 تحقق RADIUS Secret: validation + return on fail
- #20 stop_service غير كامل: تنظيف dnsmasq/nftables/hosts
- #23 lastCardInfo غير معرف: حذف كود ميت
- Syntax error hotspot-card-info line 161: `'` → `"`

---

### luci-app-hotspot-openwrt (r140 → r141 — Async RADIUS login)

**Root cause fix:** `chilli_query login` يعود فوراً (async — لا ينتظر رد RADIUS).  
**Solution:** إضافة polling loop (15 محاولة × 0.2s = حتى 3 ثوانٍ) ينتظر `state=pass` بعد إرسال الطلب.

---

### luci-app-hotspot-openwrt (r141 → r142 — Cached REST API)

**Problem:** RADIUS لا يوفر اسم الباقة، الرصيد، تاريخ الانتهاء.  
**Solution:** REST API يُستدعى **مرة واحدة** عند تسجيل الدخول، يُخزّن في `/tmp/hotspot-cache-$username`.
- إعادة `mikrotik_api` (C binary لدعم v6 عبر port 8728)
- إعادة `userman-info` (بـ `uclient-fetch` بدلاً من `curl` — لا حاجة لـ dependency إضافي)
- `hotspot-card-info` يقرأ من الكاش
- `hotspot-logout` يمسح الكاش

---

### luci-app-hotspot-openwrt (r142 → r143 — Fix round: login, block, speed, balance)

| المشكلة | الإصلاح |
|---------|---------|
| RADIUS polling 3s لا يكفي | مهلة **15s** (75×0.2s) |
| حظر MAC لا يعمل من الجدول | زر "حظر" يطرد + يضيف MAC إلى UCI + nft فوراً |
| Speed test يقيس CGI محلي (خاطئ) | يستخدم `speedtest_url` خارجي (download GET + upload POST) |
| balance_total/balance_remaining فارغان لـ v7 | userman-info يملؤهما من `transfer-limit`/`uptime-limit` |
| اسم cache قد يكون `/tmp/hotspot-cache-` (فارغ) | شرط `[ -n "$cache_username" ]` قبل بناء المسار |
| balance_remaining لا يظهر | fallback إلى `cache_balance` |

**إعدادات جديدة:** `speedtest_url` في LuCI → Services → Hotspot OpenWrt

---

## Published artifacts (current)

- `luci-app-hotspot-openwrt_1.0-r143_mipsel_24kc.ipk`
- `openwrt-ramips-mt7621-kt_km14-102h-squashfs-sysupgrade.bin`
- `SHA256SUMS` محدّث
- Manifest محدّث (r143)
