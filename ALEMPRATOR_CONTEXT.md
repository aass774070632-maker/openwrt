# ملف سياق مشروع الإمبراطور (Alemprator Project Context)

هذا الملف يمثل مرجعاً شاملاً وسياقاً كاملاً لكود ومشروع الإمبراطور (Alemprator) لإدارة شبكات الهوتسبوت وأنظمة الترقية التلقائية والتراخيص على نظام OpenWrt.

---

## 1. الهيكل العام والمكونات الأساسية

ينقسم مشروع الإمبراطور إلى ثلاثة أجزاء متكاملة:

1. **معالج الإعداد الأولي (`luci-app-setup`):**
   * **المسار:** [`package/luci-app-setup`](file:///home/galal/openwrt/package/luci-app-setup)
   * **الوظيفة:** معالج ذكي لتسهيل إعداد الهوتسبوت والواي فاي والشبكات والربط الأولي من خلال واجهة جافاسكربت مخصصة.
   * **الملف الرئيسي:** [`setup.js`](file:///home/galal/openwrt/package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js) (يحتوي على خطوات التهيئة والتحقق).

2. **تطبيق الهوتسبوت (`luci-app-hotspot-openwrt`):**
   * **المسار:** [`package/luci-app-hotspot-openwrt`](file:///home/galal/openwrt/package/luci-app-hotspot-openwrt)
   * **الوظيفة:** يدمج بوابة مصادقة CoovaChilli المحلية مع توجيه الميكروتك راديوس (MikroTik RADIUS over UDP).
   * **ملف الإعدادات الأساسي:** [`apply`](file:///home/galal/openwrt/package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/apply) (يقوم بتوليد إعدادات chilli والجدار الناري).

3. **عميل الترقية التلقائية والتراخيص (`luci-app-alemprator-ota` & `alemprator-guard`):**
   * **المسارات:** [`package/luci-app-alemprator-ota`](file:///home/galal/openwrt/package/luci-app-alemprator-ota) و [`package/alemprator-guard`](file:///home/galal/openwrt/package/alemprator-guard)
   * **الوظيفة:** تتبع التراخيص وتأمين الاتصال بخادم التحديثات من خلال معرفات فريدة مولدة من الماك أدرس والمعالج.

---

## 2. سياق التطوير الأخير وتحديثات وسيط الراديوس (يوليو 2026)

خلال الأيام الأخيرة، تم العمل على حل مشكلة توجيه الراديوس لبطاقات الـ 11 خانة على أجهزة `KM14` (`kt,km14-102h`) وتفادي سقوط شبكة الهوتسبوت بعد إعادة التشغيل:

### أ. تصميم وسيط الراديوس الذكي (RADIUS Proxy)
* **المسار:** [`package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/radius-proxy`](file:///home/galal/openwrt/package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/radius-proxy)
* **الوظيفة:** استقبال طلبات المصادقة والمحاسبة من CoovaChilli على منفذ `127.0.0.1:1812/1813` وتوجيهها ديناميكياً إلى خادم الراديوس الأول `server1` (الافتراضي للبطاقات العادية) أو خادم الراديوس الثاني `server2` (للبطاقات المكونة من 11 خانة) بناءً على طول الكارت وقواعد التوجيه (مثل `11:userman2`).
* **منع التصادم:** يتم تتبع الجلسات بمفتاح يجمع بين معرّف الحزمة وآيبي السيرفر (`id_serverIP`) لمنع تصادم الحزم بين الخادمين.

### ب. قائمة الأخطاء والمشاكل الهيكلية التي تم إصلاحها بالكامل:
1. **عطل nixio.poll_flags:** استبدال نداءات `poll_flags` الرقمية الخاطئة بقناع بتات صحيح وعملي لمنع تعطل تشغيل الخدمة خلفياً.
2. **الاعتمادات المفقودة في بيئة daemon:** إزالة الاعتماد على مكتبات LuCI (مثل `luci.model.uci` و `nixio.bit`) واستبدالها بأوامر uci عبر نظام التشغيل والتحقق البسيط لضمان عمل الخدمة بثبات واستقلالية تامة.
3. **مشكلة تعطيل الهوتسبوت الدائم عند الإقلاع (Boot-time permanent disable):** تعديل سكريبت `apply` لمنع تعطيل الهوتسبوت والوسيط بشكل دائم إن تأخرت كروت الشبكة والـ IP المؤقت عن العمل أثناء إقلاع الراوتر (`mode=start`).
4. **مشكلة الرفض من الميكروتك بسبب لاحقة الدومين (`@userman2`):** تعديل سكريبت [`hotspot-login`](file:///home/galal/openwrt/package/luci-app-hotspot-openwrt/files/www/cgi-bin/hotspot-login) ليقوم بحذف أي لاحقة دومين من الكارت قبل تمريره لبرنامج CoovaChilli، لكي يرسله للأخير بشكل نظيف ومطابق لما هو مخزن بقاعدة بيانات الميكروتك، مع الحفاظ على التوجيه الذكي للوسيط بناءً على طول الكارت.

---

## 3. التجميع والترقية والأوامر

* **هدف البناء:** جهاز `KT-KM14-102H` بـ target `ramips/mt7621` ومعمارية `mipsel_24kc`.
* **أمر التجميع:**
  ```bash
  make package/luci-app-hotspot-openwrt/compile V=s
  make -j$(nproc)
  ```
* **ملف الترقية الناتج:**
  `bin/targets/ramips/mt7621/openwrt-ramips-mt7621-kt_km14-102h-squashfs-sysupgrade.bin`
