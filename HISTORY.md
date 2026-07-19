# التاريخ الكامل للمشروع - KM14-102H Firmware

## البداية
المشروع: بناء فيرموير لراوتر **KT-KM14-102H** يعمل بنظام OpenWrt 24.10.4.
الجهاز معالج MT7621 مع NAND 128MB.

---

## v1.0-r4 ~ r7 — الإصدارات التأسيسية
**الطلب:** بناء فيرموير أساسي للجهاز مع OpenWrt.
**الإصلاح:** بناء أولي مع البرامجيات الأساسية (alemprator-network-protection).

---

## v1.0-r9 — تطبيق الإعداد
**الطلب:** إضافة تطبيق جوال للإعداد الأولي.
**الإصلاح:** إضافة `alemprator-setup-app APK` و`luci-app-alemprator-network-protection`.

---

## v1.0-r12 — بداية الهوتسبوت
**الطلب:** إضافة hotspot للجهاز.
**الإصلاح:** إضافة `luci-app-hotspot-openwrt 1.0-r154` في الصورة.

---

## v1.0-r13 — الهوتسبوت الكامل
**الطلب:** تشغيل hotspot كامل مع:
- CoovaChilli
- إعادة توجيه NAT (chilli_redir)
- تحديد السرعة (tc + HTB)
- proxy
- صفحة تسجيل الدخول CGI

**الإصلاح:**
- تفعيل `COOVACHILLI_REDIR=y` و `COOVACHILLI_PROXY=y` و `COOVACHILLI_NOSSL=y`
- تفعيل `KERNEL_NET_SCH_HTB=y` (HTB لتحديد السرعة)
- `luci-app-hotspot-openwrt 1.0-r155`
- `coova-chilli 1.6-r12`
- أول حفظ لملف `.config` (r13-km14.config)
- أول حفظ لـ sha256sums

---

## v1.0-r14 — إصلاح sysupgrade
**الطلب:** sysupgrade يمسح الإعدادات القديمة بسبب `COMPAT_VERSION`.

**الإصلاح:** إزالة `DEVICE_COMPAT_VERSION := 1.1` من تعريف KM14.
**النتيجة:** sysupgrade لم يعد يمسح الإعدادات.

---

## v1.0-r15 — SSH key
**الطلب:** إضافة مفتاح SSH تلقائياً في الصورة.

**الإصلاح:** إضافة `authorized_keys` في `/etc/dropbear/`.
**المشكلة:** الـ `authorized_keys` منع SSH من التشغيل (dropbear.defaults يخرج إذا وجد الملف).

---

## v1.0-r16 — Boot loop
**الطلب:** الجهاز يعلق في boot loop بعد فلاش factory.bin.

**الإصلاح:** إزالة `KERNEL_SIZE := 20480k` (كانت 20MB، والصحيح 4MB من `Device/nand`).
**النتيجة:** kernel يكتب في المساحة الصحيحة (0x400000)، UBI يبدأ في المكان الصحيح.

---

## v1.0-r17 — إصلاح SSH
**الطلب:** SSH لا يشتغل (مشكلة من r15).

**الإصلاح:** إزالة ملف `authorized_keys` بالكامل من `base-files`.
**النتيجة:** SSH يشتغل طبيعي بدون مفتاح مضمن.
**الحالة:** أول إصدار مع:
- factory.bin صحيح ✅
- SSH شغال ✅
- hotspot مثبت ✅

---

## v1.0-r18 — DHCP في أول إقلاع
**الطلب:** شبكة ALemprator تظهر بعد الفرمات لكن لا توزع IP (DHCP ميت).

**الإصلاح:** تعديل `98_custom`:
- قبل: كان يوقف DHCP دائماً `dhcp.lan.ignore=1` + `dnsmasq disable` في rc.local
- بعد: يتحقق `initial_complete != 1` → يضبط IP/SSID فقط ويطلع بدون لمس DHCP

**المشكلة المتبقية:** dnsmasq لا يشتغل بسبب فشل ujail (مشكلة في البناء نفسه).

---

## v1.0-r19 — dnsmasq fallback (الحالي)
**الطلب:** dnsmasq لا يعمل حتى بعد إصلاح 98_custom.

**الإصلاح:** إضافة fallback مباشر إذا فشل تشغيل dnsmasq عبر ujail:
- `99-alemprator-firstboot`: بعد إنشاء الشبكة المؤقتة
- `alemprator-firstboot init`: في كل مكان يعيد تشغيل dnsmasq (cleanup, captive portal)
- الكود: يتحقق `pgrep -x dnsmasq` → إذا لا يوجد، يشتغل مباشرة بدون jail

**النتيجة:** dnsmasq يعمل دائماً ✅

---

## المشاكل الحالية (مفتوحة)
- **HTB/kmod-sched-core غير مفعل** في `.config` → تحديد السرعة (tc) قد لا يعمل
- **ujail لا يعمل مع dnsmasq** → تم التعامل معها بـ fallback لكن المشكلة الأصلية باقية
- **ملاحظة:** لو user غيّر الإعدادات من LuCI بعد الإعداد، الـ `98_custom` ما يرجع يشتغل (uci-defaults يحذف نفسه)

---

## ملخص الطلبات والإصلاحات

| الإصدار | الطلب | المشكلة | الإصلاح |
|---------|-------|---------|---------|
| r4-7 | بناء أساسي | — | — |
| r9 | تطبيق إعداد | — | إضافة APK |
| r12 | hotspot | — | إضافة hotspot package |
| r13 | hotspot كامل | chilli_redir, NAT, HTB, proxy غير مفعلة | تفعيلها في .config |
| r14 | sysupgrade يمسح | COMPAT_VERSION 1.1 | إزالته |
| r15 | SSH key | — | إضافة authorized_keys |
| r16 | boot loop | KERNEL_SIZE خطأ | إزالته (رجوع لـ 4MB) |
| r17 | SSH لا يعمل | authorized_keys يمنع dropbear | حذف الملف |
| r18 | DHCP ميت بعد الفرمات | 98_custom يوقف DHCP دائماً | تحقق initial_complete |
| r19 | dnsmasq لا يشتغل | ujail فاشل | fallback مباشر |
