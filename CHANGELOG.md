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

### v1.0-r40
- **إصلاح حرج لعدم الإقلاع (boot loop):** السبب الجذري كان تشغيل `dnsmasq -k` (أمامي) داخل `uci-defaults/99-alemprator-firstboot` الذي يعيق الإقلاع المتزامن فيعطّل الجهاز.
- تعديل مؤقت: تشغيل dnsmasq خلفياً (`setsid ... &`) في uci-defaults لتمرير الإقلاع.
- أسماء الواجهات: `br_setup` (انحراف عن r12).
- بناء ناجح وصورة تقلع بنجاح على الجهاز الحي.

---

### v1.0-r41
- **إرجاع سلوك firstboot المعتمد (r12-style):**
  - تغيير أسماء الواجهات من `br_setup` إلى `alemprator_setup` في `uci-defaults` و `init.d` وملف الإعداد الافتراضي (مطابق لـ r12 ومتوافق مع `luci-app-setup` الذي يتوقع `alemprator_setup`).
  - إرجاع `USE_PROCD=1` في `init.d/alemprator-firstboot` (نمط r12).
  - **إزالة التشغيل اليدوي لـ dnsmasq من `uci-defaults`** (السبب الجذري لتعطل الإقلاع) — الاعتماد على `init.d/dnsmasq` القياسي.
  - الإبقاء على `launch_dnsmasq()` كاحتياط في `init.d` فقط (يُستدعى من captive portal / provisioning) لتغطية حالة تعطل `init.d/dnsmasq` إن وُجدت على الجهاز الحي.
- التوافق مؤكد: لا تعارض مع `luci-app-hotspot-openwrt r161` (يتوقع `alemprator_setup`) ولا مع تطبيق الجوال (يحذف `alemprator_setup` عند الإعداد النهائي).
- `alemprator-firstboot 1.0-r41`، أرشفة في `releases/v1.0-r41/km14/`.

---

### v1.0-r42 / v1.0-r43 — دعم PPPoE client في واجهة اللوسي + معالج الإعداد
- **`luci-app-hotspot-openwrt` (r162 + r163):**
  - إضافة حقول **PPPoE client** في صفحة الهوتسبوت (`hotspot-openwrt.js` مجموعة `server`): `wan_connection_type` (dhcp/pppoe)، `wan_pppoe_device` (افتراضي `eth0`)، `wan_pppoe_username`، `wan_pppoe_password`.
  - تحديث `apply` بإضافة `setup_wan_connection()` الذي يضبط `network.wan` (`proto=pppoe` + `device`/`username`/`password`) عند اختيار PPPoE، أو `proto=dhcp` افتراضياً.
  - إضافة نفس الحقول في **معالج البرمجة السريعة** (`luci-app-setup` `setup.js` → بطاقة `hotspotQuickCard`) مع إظهار/إخفاء تلقائي لحقول PPPoE حسب نوع الاتصال، وحفظها في `hotspot_openwrt.main` عند التطبيق.
  - تحديث `etc/config/hotspot_openwrt` بخيارات PPPoE الافتراضية.
- **`alemprator-android-app` (سابق r162/e99474b):** دعم PPPoE مدمج مسبقاً في `Device.kt` + `DeviceFormScreen` + `ScriptGenerator` (يضبط `network.wan` عبر SSH).
- المعمارية: MikroTik = PPPoE server + User Manager؛ كل راوتر له user/pass PPPoE خاص؛ WAN=PPPoE client عبر `eth0`؛ الهوتسبوت فوقه.
- أرشفة في `releases/v1.0-r43/km14/` (factory/sysupgrade + ipk r162).
  - SHA256 factory: `8ece1c9a7e3cefcbcdc1d205cffa682cec0408623c5047e1edaad086336f1302`

---

### v1.0-r44 — إصلاح: WAN/PPPoE مستقل عن فحص RADIUS
- **`luci-app-hotspot-openwrt` r163:** إصلاح حرج في `apply` — فحص `RADIUS secret` كان يوقف التطبيق بالكامل (`FATAL: RADIUS secret is empty`) **قبل** كتابة `network.wan`، مما منع ضبط PPPoE/WAN بمعزل عن الهوتسبوت.
  - الآن فحص RADIUS يمنع التطبيق **فقط عند تفعيل الهوتسبوت** (`enabled=1`). WAN/PPPoE يُضبط دائماً مستقلاً.
  - `enabled` الافتراضي يبقى `0` (لا يفشل عند أول إعداد).
- أرشفة في `releases/v1.0-r44/km14/`.
  - SHA256 factory: `9b2e54d2dac0081b86aa9732d43c5e69bd99386570482b985e5e3829f6fa06a8`

---

### v1.0-r45 — تعديل افتراضي واجهة PPPoE إلى `wan`
- **`luci-app-hotspot-openwrt` r164:** تغيير الافتراضي `wan_pppoe_device` من `eth0` إلى **`wan`** في:
  - `config/hotspot_openwrt` (الافتراضي)
  - `hotspot-openwrt.js` (getValue)
  - `setup.js` (المعالج: ref/قراءة/state/حفظ)
  - `apply` (احتياطي عند空空)
  - السبب: على KM14-102H الواجهة الفيزيائية `eth0` مقسّمة عبر السويتش إلى lan/wan بـ VLANs؛ ضبط PPPoE على `eth0` الخام يفصل LAN ويفقد الوصول للإدارة. الواجهة الصحيحة هي `wan` (VLAN مشتق من السويتش).
- أرشفة في `releases/v1.0-r45/km14/`.
  - SHA256 factory: `9f3ebe8f656fec414c2bdafd365be85a5f3948d824d4c8df96d841c9cb86240a`

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

