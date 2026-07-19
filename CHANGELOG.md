# سجل الإصدارات - KM14-102H OpenWrt Firmware

## ترتيب الإصدارات (من الأقدم للأحدث)

---

### v1.0-r4
- أول بناء لجهاز KM14-102H
- OpenWrt 24.10.4 مع Kernel 6.6.110

---

### v1.0-r5
- تحديث: `alemprator-network-protection 1.0-r5`

---

### v1.0-r6
- تحديث: `alemprator-network-protection 1.0-r6`

---

### v1.0-r7
- تحديث: `alemprator-network-protection 1.0-r7`

---

### v1.0-r9
- إضافة: `alemprator-setup-app APK`
- تحديث: `alemprator-network-protection 1.0-r8`

---

### v1.0-r10
- إضافة: `luci-app-alemprator-network-protection 1.0-r8`
- إصدار APK جديد

---

### v1.0-r11
- تحديث: `alemprator-setup-app APK`
- إضافة: `alemprator-network-protection 1.0-r10`

---

### v1.0-r12
- إضافة: `luci-app-hotspot-openwrt 1.0-r154`
- بداية دمج الهوتسبوت في الصورة الأساسية

---

### v1.0-r13
- أول إصدار كامل مع الهوتسبوت
- **الحزم الثابتة في الصورة:**
  - `luci-app-hotspot-openwrt 1.0-r155`
  - `coova-chilli 1.6-r12`
  - `luci-app-setup`
  - `alemprator-firstboot`
- تم حفظ `.config` لأول مرة (r13-km14.config)
- إصلاحات الهوتسبوت: chilli_redir, NAT redirect, iptables ACCEPT, tc HTB shaping, CGI speed-limiting

---

### v1.0-r14
- **إزالة `DEVICE_COMPAT_VERSION := 1.1`** من تعريف KM14 (sysupgrade لم يعد يمسح الإعدادات)
- إصلاح: حفظ sha256sums

---

### v1.0-r15
- **إضافة `authorized_keys`** في `/etc/dropbear/` (تسبب في تعطيل SSH)
- إضافة `device_lan_ipaddr='192.168.1.11'` في 98_custom لـ KM14
- **مشكلة:** SSH لا يشتغل بعد الفلاش

---

### v1.0-r16
- **إزالة `KERNEL_SIZE := 20480k`** (factory.bin الآن يصحح حجم kernel)
- إصلاح boot loop (كان kernel يُكتَب خارج مساحة NAND)
- **ملاحظة:** SSH ما زال معطل بسبب authorized_keys الموروث من r15

---

### v1.0-r17
- **إزالة `authorized_keys`** من `base-files` → SSH يشتغل طبيعي
- أول إصدار مع SSH عامل و factory.bin صحيح

---

### v1.0-r18
- **إصلاح `98_custom`:** لا يوقف DHCP في أول إقلاع
  - يتحقق `initial_complete != 1` → يضبط IP/SSID فقط ويطلع
  - ما يكتب rc.local مع dnsmasq disable
  - يترك DHCP شغال عشان شبكة ALemprator توزع IP
- **ملاحظة:** مشكلة dnsmasq ujail ما زالت موجودة

---

### v1.0-r19
- **إضافة fallback dnsmasq** بدون jail إذا فشل التشغيل العادي:
  - `99-alemprator-firstboot:213-216` (بعد إنشاء الشبكة المؤقتة)
  - `alemprator-firstboot init:143-151` (بعد تنظيف DHCP)
  - `alemprator-firstboot init:249-255` (في captive portal)
  - `alemprator-firstboot init:274-280` (في captive portal remove)
- **إصلاح شامل:** dnsmasq يعمل دائماً حتى لو فشل ujail

---

### v1.0-r22 (إعادة بناء نظيفة — hotspot r161, setup r124)
- إعادة بناء كاملة للـ firmware من الصفر (kernel + rootfs)
- hotspot r161, setup r124 (bump PKG_RELEASE بعد الـ build النظيف)
- initramfs مضمّن للطوارئ (TFTP recovery)
- **ملفات الإصدار في `releases/v1.0-r22/km14/`:**
  - `openwrt-ramips-mt7621-kt_km14-102h-squashfs-factory.bin` (19M)
  - `openwrt-ramips-mt7621-kt_km14-102h-squashfs-sysupgrade.bin` (17M)
  - `openwrt-ramips-mt7621-kt_km14-102h-initramfs-kernel.bin` (16M)
  - sha256sums, manifest, r22-km14.config

### v1.0-r21 (إصلاح شامل — 13 مشكلة في hotspot + setup)
- **إصلاح `luci-app-hotspot-openwrt` (r158→r160):** 8 إصلاحات
  - `enforcement-check:24`: typo `chspot-openwrt` → `hotspot-openwrt`
  - `hotspot-openwrt.js:11`: إزالة dead `LICENSE_CHECK_CMD`
  - `hotspot-openwrt.js:1439`: إزالة dead `uci.load('hotspot_licensing')`
  - `hotspot_openwrt` config: إضافة `maint_enabled`, `maint_mode`, `maint_start`, `maint_end`
  - `radius-proxy:78-82`: إفراغ `LOCAL_USERS` وقراءة `LOCAL_SECRET` من UCI
  - `apply:424-431`: fallback لـ `od -An -tx1` إن لم يكن `hexdump` موجوداً
  - `status-json:157-158`: استبدال pid_file variables بـ `pidof`
  - `hotspot-login:12`: إضافة `timeout 5` لـ `dd` لمنع التعليق
- **إصلاح `luci-app-setup` (r121→r123):** 5 إصلاحات
  - `luci-app-setup.json`: إزالة مفتاح JSON مكرر + نقل `test-radius` داخل `file`
  - `setup.js:3175,4787`: إزالة `hotspotQuickSecondaryEnabled = true` القسري
  - `Makefile`: إضافة `+watchcat +alemprator-firstboot +luci-app-alemprator-ota` إلى DEPENDS
  - `setup.js:5687-5696`: إعادة تعيين hotspot flags فقط عندما `mode != 'ap'`
  - `setup.js:3168-3179`: إضافة validation لـ `lanIpaddr`/`lanNetmask` مع fallback آمن
- **بناء firmware كامل KM14** مع جميع الإصلاحات
- sha256sums, manifest, 18 IPK في `releases/v1.0-r21/km14/`

---

### v1.0-r20 (الإصدار الموحد المكتمل)
- **إصدار التجميع الموحد المكتمل (Consolidated Master Release):**
  - دمج شامل لكافة إصلاحات الحزم الـ 16 دون استثناء.
  - دمج حزمة `alemprator-network-protection` (r3/r7) مع تقسيم كروت LAN الأربعة في الـ DTS.
  - دمج حزمة `luci-app-hotspot-openwrt` (r150) بنمط RADIUS-native وتحديد السرعة بالخلفية عبر `setsid`.
  - دمج حزم `luci-app-setup`, `luci-app-alemprator-ota`, `bandix-plus`, `luci-app-netspeedtest`.
  - توليد صور النظام `factory.bin` و `sysupgrade.bin` مع ملفات البصمة والتكوين المعتمدة في `releases/v1.0-r20/km14/` وتحديث `ota-server`.
  - **إصلاح تسريب واصفات الملفات (fd leak):** إغلاق fd 3-9 و 1000 في العمليات الخلفية لـ `alemprator-firstboot` و `alemprator-network-protection` لمنع تعليق `opkg`.
  - **إصلاح تعارض ملفات البناء:** إضافة `--force-overwrite` في `include/rootfs.mk` لتجاوز تعارض `coova-chilli` مع `luci-app-hotspot-openwrt`.

---

## ملخص التغييرات لكل ملف

| الملف | r13 | r14 | r15 | r16 | r17 | r18 | r19 | r20 |
|-------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `DEVICE_COMPAT_VERSION` | 1.1 | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| `KERNEL_SIZE (20480k)` | خطأ | خطأ | خطأ | ❌ | ❌ | ❌ | ❌ | ❌ |
| `authorized_keys` | — | — | إضافة | موروث | ❌ | ❌ | ❌ | ❌ |
| 98_custom: DHCP off | دائماً | دائماً | دائماً | دائماً | دائماً | فقط بعد إعداد | فقط بعد إعداد | فقط بعد إعداد |
| 98_custom: rc.local | يكتب | يكتب | يكتب | يكتب | يكتب | لا يكتب (أول إقلاع) | لا يكتب (أول إقلاع) | لا يكتب (أول إقلاع) |
| dnsmasq fallback | — | — | — | — | — | — | ✅ | ✅ |
| LAN Split 4-Ports (DTS) | — | — | — | — | — | — | — | ✅ |
| Network Protection (r3/r7) | — | — | — | — | — | — | — | ✅ |
| Hotspot RADIUS-native | — | — | — | — | — | — | — | ✅ |

> ❌ = تمت إزالته/إصلاحه
> ✅ = تمت إضافته

