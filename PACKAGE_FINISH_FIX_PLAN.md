# خطة تشطيب وتصحيح الحزم المخصصة

هذا الملف هو قالب تنفيذ عملي موحد لإنهاء وتصحيح كل الحزم المخصصة في المشروع.
الهدف: تحويل الشغل من إصلاحات عشوائية إلى دورة ثابتة: تحليل -> إصلاح -> تحقق -> تثبيت إصدار.

## 1) قائمة الحزم المستهدفة

1. `alemprator-ax`
2. `alemprator-firstboot`
3. `alemprator-guard`
4. `alemprator-suite`
5. `bandix-plus`
6. `luci-app-alemprator-dhcp`
7. `luci-app-alemprator-ota`
8. `luci-app-bandix-plus`
9. `luci-app-cpu-perf`
10. `luci-app-cpu-status`
11. `luci-app-hotspot-openwrt`
12. `luci-app-log-viewer`
13. `luci-app-netspeedtest`
14. `luci-app-setup`
15. `luci-app-temp-status`
16. `luci-app-tn-netports`

## 2) أفضل طريقة (Workflow موحد لكل حزمة)

1. **Baseline**: تحديد سلوك الحزمة الحالي (ما الذي يعمل/لا يعمل).
2. **Bug List**: كتابة المشاكل حسب الأولوية (Critical/High/Medium/Low).
3. **Root Cause**: تثبيت السبب الجذري لكل مشكلة قبل التعديل.
4. **Small Batch Fixes**: تنفيذ الإصلاحات على دفعات صغيرة (لا تجمع كل شيء في دفعة واحدة).
5. **Build Package Only**: بناء الحزمة منفردة بعد كل دفعة.
6. **Runtime Test**: اختبار فعلي على الجهاز/الصورة بعد التثبيت.
7. **Regression Check**: إعادة فحص النقاط الأساسية للحزمة.
8. **Release Bump**: تحديث `PKG_RELEASE` عند نجاح الإصلاحات.
9. **Changelog Note**: توثيق مختصر لما تغيّر ولماذا.
10. **Publish**: نسخ ipk الجديد إلى مجلد الإصدار العام وتحديث `SHA256SUMS`.

## 3) Definition of Done (DoD) موحد لكل حزمة

تعتبر الحزمة "مكتملة" فقط إذا تحقق التالي:

1. `make package/<name>/compile` ناجح بدون أخطاء.
2. تثبيت الحزمة على بيئة الاختبار ناجح.
3. الخدمة/الواجهة تعمل بعد `reboot`.
4. لا يوجد أخطاء Runtime حرجة في `logread`.
5. اختبار Regression الأساسي للحزمة ناجح.
6. توثيق التغييرات تم تحديثه.
7. رفع `PKG_RELEASE` تم بشكل صحيح.

## 4) بطاقة العمل القياسية لكل حزمة

انسخ هذه البطاقة واملأها لكل حزمة:

```md
## Package: <name>

### A) Scope
- الهدف الوظيفي للحزمة:
- المسارات الأساسية:

### B) Issues
1. [Severity] وصف المشكلة
2. [Severity] وصف المشكلة

### C) Root Cause
- المشكلة 1:
- المشكلة 2:

### D) Fix Plan
1. تعديل ملف X
2. تعديل ملف Y

### E) Verification
- Build command:
- Install command:
- Runtime checks:
- Reboot checks:

### F) Release
- PKG_RELEASE: rX -> rY
- Changelog summary:
- Published path:
```

## 5) Checklist فحص سريع (قبل/بعد كل إصلاح)

### قبل الإصلاح

1. تأكيد المشكلة بإعادة إنتاج واضحة.
2. حفظ لقطات أو logs للمقارنة.
3. تحديد ملفات التأثير المباشر.

### بعد الإصلاح

1. بناء الحزمة منفردة.
2. تثبيت ipk الجديد.
3. اختبار الواجهة أو الخدمة.
4. إعادة تشغيل والتحقق من الاستمرارية.
5. مقارنة logs قبل/بعد.

## 6) أوامر تشغيل قياسية

> بدّل `<pkg>` باسم الحزمة.

```bash
# Build package only
make package/<pkg>/compile V=s

# Optional clean + rebuild package
make package/<pkg>/clean
make package/<pkg>/compile V=s

# Locate generated package
find bin -type f | grep "<pkg>" | grep '\.ipk$'
```

## 7) خطة التنفيذ على دفعات (مقترح)

### الدفعة 1: حرجة (وظائف أساسية)

1. `luci-app-hotspot-openwrt`
2. `luci-app-setup`
3. `luci-app-alemprator-ota`
4. `alemprator-guard`
5. `alemprator-firstboot`

### الدفعة 2: تشغيلية / خدمات

1. `luci-app-alemprator-dhcp`
2. `alemprator-ax`
3. `alemprator-suite`
4. `bandix-plus`
5. `luci-app-bandix-plus`

### الدفعة 3: واجهات مراقبة

1. `luci-app-cpu-perf`
2. `luci-app-cpu-status`
3. `luci-app-log-viewer`
4. `luci-app-netspeedtest`
5. `luci-app-temp-status`
6. `luci-app-tn-netports`

## 8) نموذج تقرير يومي مختصر

```md
# Daily Package Fix Report - YYYY-MM-DD

## Completed
- <pkg>: fixed X, verified Y, bumped to rZ

## In Progress
- <pkg>: root cause identified, pending runtime test

## Blocked
- <pkg>: blocked by dependency <name>

## Next
- Start with <pkg>
```

## 9) قاعدة ذهبية

- لا تنتقل لحزمة جديدة قبل إغلاق الحالية بـ DoD كامل.
- أي إصلاح بدون اختبار Runtime + Reboot يعتبر غير مكتمل.
- أي نشر بدون تحديث checksums يعتبر نشر ناقص.

## 10) بطاقة عملية جاهزة: luci-app-hotspot-openwrt

## Package: luci-app-hotspot-openwrt

### A) Scope
- الهدف الوظيفي للحزمة: إدارة نظام الهوتسبوت (واجهة LuCI + سكربتات التطبيق + خدمات Chilli وRADIUS Proxy).
- المسارات الأساسية:
	- package/luci-app-hotspot-openwrt/Makefile
	- package/luci-app-hotspot-openwrt/files/usr/share/luci/menu.d/luci-app-hotspot-openwrt.json
	- package/luci-app-hotspot-openwrt/files/www/luci-static/resources/view/services/hotspot-openwrt.js
	- package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/apply

### B) Issues
1. [High] صفحة الحزمة لا تظهر في قائمة Services داخل LuCI.
2. [Medium] عدم اتساق النشر: أحيانا يتم تحديث صورة sysupgrade بدون تحديث ipk المناظر في مجلد الإصدار العام.

### C) Root Cause
- المشكلة 1: خطأ نحوي في ملف القائمة LuCI (`a{` بدل `{`) يمنع تفسير JSON.
- المشكلة 2: عملية النشر السابقة كانت تنسخ ملفات الصور فقط ولا تنسخ حزم ipk المخصصة تلقائيا.

### D) Fix Plan
1. إصلاح ملف menu JSON.
2. إعادة بناء الحزمة منفردة.
3. نشر ipk الجديد في مجلد الإصدار العام (km14/packages).
4. تحديث SHA256SUMS بعد نسخ الصور والحزم معا.
5. اختبار ظهور الصفحة من الرابط المباشر ثم من القائمة.

### E) Verification
- Build command:
	- make package/luci-app-hotspot-openwrt/compile V=s
- Install command (على الراوتر):
	- opkg install --force-reinstall /tmp/luci-app-hotspot-openwrt_*.ipk
- Runtime checks:
	- uhttpd وrpcd يعملان بدون أخطاء حرجة في logread.
	- الصفحة تفتح من:
		- /cgi-bin/luci/admin/services/hotspot-openwrt
- Reboot checks:
	- بعد إعادة التشغيل، الصفحة ما زالت ظاهرة في Services وتفتح بشكل طبيعي.

### F) Release
- PKG_RELEASE الحالي: r126.
- Changelog summary:
	- إصلاح JSON قائمة LuCI لمنع اختفاء صفحة Hotspot OpenWrt.
	- توحيد نشر الصورة + الحزمة في مجلد الإصدار العام.
- Published path:
	- ota-server/public/firmware/km14/packages/luci-app-hotspot-openwrt_1.0-r126_mipsel_24kc.ipk

### G) الحالة الحالية
1. تم الإصلاح في السورس.
2. تم رفع الإصدار إلى r126 وبناء الحزمة ونشرها في مجلد km14.
3. الصورة الكاملة KM14 أُعيد بناؤها وتتضمن الإصلاح.
4. تم التحقق الميداني: صفحة `/cgi-bin/luci/admin/services/hotspot-openwrt` تُرجع HTTP 200 بعد التثبيت.
5. الحالة: مكتملة وظيفيا (يبقى فقط متابعة UX عند الاستخدام اليومي).

## 11) بطاقة عملية جاهزة: luci-app-setup

## Package: luci-app-setup

### A) Scope
- الهدف الوظيفي للحزمة: معالج الإعداد الأولي للشبكة/الواي فاي/الهوتسبوت وربط الإعدادات مع UCI.
- المسارات الأساسية:
	- package/luci-app-setup/Makefile
	- package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js
	- package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.css
	- package/luci-app-setup/files/etc/config/setup
	- package/luci-app-setup/files/etc/uci-defaults/*

### B) Issues
1. [High] تعقيد مرتفع في setup.js (ملف كبير جدا) يزيد احتمال الانحدار عند أي تعديل صغير.
2. [High] ازدواجية القراءة بين setup.default و hotspot_openwrt.main في وضع hotspot_quick تتطلب تحقق Regression صارم.
3. [Medium] مسارات wizardvlan و managed wifi-iface حساسة وقد تؤدي إلى حذف/تكوين غير مقصود عند تغييرات لاحقة.

### C) Root Cause
- المشكلة 1: منطق متعدد الوظائف داخل ملف واحد بدون فصل كاف لطبقات القراءة/التحقق/الكتابة.
- المشكلة 2: دعم التوافق الخلفي يقرأ من مصدرين UCI في عدة حقول، ما قد يسبب التباس عند الترحيل.
- المشكلة 3: إدارة الواجهات اللاسلكية تعتمد شروطا مركبة على network/mode وتحتاج اختبارات تغطية واسعة.

### D) Fix Plan
1. تثبيت Baseline وظيفي واضح لسيناريوهات setup الأساسية (router/repeater/hotspot/hotspot_quick).
2. إضافة فحوص تحقق مركزة لحالات hotspot_quick + wizardvlan قبل أي refactor إضافي.
3. حصر أي تعديل جديد في دفعات صغيرة (validation ثم save path ثم network apply).
4. منع إدخال تغييرات هيكلية كبيرة قبل إغلاق اختبارات الانحدار.
5. بعد كل دفعة: build الحزمة منفردة + اختبار فعلي على جهاز KM14.

### E) Verification
- Build command:
	- make package/luci-app-setup/compile V=s
- Install command (على الراوتر):
	- opkg install --force-reinstall /tmp/luci-app-setup_*.ipk
- Runtime checks:
	- فتح معالج الإعداد بدون JS errors في المتصفح.
	- الانتقال بين الخطوات يعمل بدون كسر الحالة.
	- حفظ وضع hotspot_quick يكتب القيم الأساسية بشكل صحيح.
- Reboot checks:
	- الإعدادات المحفوظة تبقى مستقرة بعد إعادة التشغيل.
	- لا يوجد فقدان غير متوقع لواجهات الواي فاي.

### F) Release
- PKG_RELEASE الحالي: r120.
- Changelog summary المقترح عند الإغلاق:
	- تحسين ثبات مسارات hotspot_quick/wizardvlan.
	- تقوية تحقق الإدخال وتقليل احتمالات الانحدار.
- Published path (عند البناء):
	- ota-server/public/firmware/km14/packages/luci-app-setup_1.0-r120_mipsel_24kc.ipk

### G) الحالة الحالية
1. Baseline معروف والحزمة مبنية ضمن صورة KM14 الأخيرة.
2. تم تنفيذ Regression ميداني أعمق لمسارات الحزمة الأساسية بنجاح.
3. تم التحقق الميداني: صفحة `/cgi-bin/luci/admin/applications/alemprator` تُرجع HTTP 200.
4. تم التحقق أيضا من:
	- `/cgi-bin/luci/admin/status/overview` => HTTP 200
	- `/cgi-bin/luci/admin/status/overview-real` => HTTP 200
5. فحص محتوى HTML أكد تحميل view الصحيح `setup/setup` بدون مؤشرات كسر في الصفحة.
6. البطاقة مغلقة حاليا، وأي اختبار hotspot/hotspot_quick إضافي يصبح جزءا من Regression دوري بعد أي تعديل جديد.

## 12) بطاقة عملية جاهزة: luci-app-alemprator-ota

## Package: luci-app-alemprator-ota

### A) Scope
- الهدف الوظيفي للحزمة: عميل OTA على الراوتر (register/update/heartbeat) مع واجهة LuCI للإدارة اليدوية والحالة.
- المسارات الأساسية:
	- package/luci-app-alemprator-ota/Makefile
	- package/luci-app-alemprator-ota/files/usr/libexec/alemprator-ota/
	- package/luci-app-alemprator-ota/files/etc/init.d/alemprator-ota
	- package/luci-app-alemprator-ota/files/www/luci-static/resources/view/system/ota.js

### B) Issues
1. [High] اعتماد قوي على توفر API خارجي؛ عند فشل endpoint يجب أن يبقى سلوك العميل واضحا وآمنا.
2. [Medium] مخاطر عدم اتساق الحالة بين run-once/manual-update/status-json عند الانقطاع أو إعادة التشغيل أثناء التحديث.
3. [Medium] أي تغيير في تنسيق رد API قد يكسر التحديث دون رسائل مفهومة للمشغل.

### C) Root Cause
- المشكلة 1: مسار التحديث يعتمد على الشبكة والـ backend، ويحتاج fallback موثوق ورسائل أخطاء دقيقة.
- المشكلة 2: وجود عدة نقاط دخول لتدفق OTA يزيد احتمالية تباين الحالة إذا لم يكن lock/state موحدا.
- المشكلة 3: parser على العميل يحتاج فحصا صارما للحقول الإلزامية قبل متابعة sysupgrade.

### D) Fix Plan
1. مراجعة common.sh وagent.sh لتوحيد إدارة الحالة والـ exit codes.
2. تعزيز التحقق من JSON الاستجابة قبل أي تنزيل أو sysupgrade.
3. توحيد رسائل الفشل في status-json وواجهة ota.js.
4. إضافة اختبار انقطاع إنترنت/404/sha mismatch كجزء ثابت من Regression.
5. نشر ipk محدث فقط بعد نجاح اختبارات update-safe (بدون تنفيذ ترقية فعلية على كل دورة).

### E) Verification
- Build command:
	- make package/luci-app-alemprator-ota/compile V=s
- Install command (على الراوتر):
	- opkg install --force-reinstall /tmp/luci-app-alemprator-ota_*.ipk
- Runtime checks:
	- التحقق من /usr/libexec/alemprator-ota/manual-info وstatus-json.
	- تجربة check update مع رد صالح ورد غير صالح.
	- التأكد أن فشل الشبكة لا يدخل الجهاز في حالة update معلقة.
- Reboot checks:
	- بعد reboot تبقى حالة OTA سليمة ولا توجد مهام عالقة.

### F) Release
- PKG_RELEASE الحالي: r47.
- Changelog summary المقترح عند الإغلاق:
	- تقوية مسارات التحقق من رد API.
	- تحسين وضوح الحالة والأخطاء في الواجهة والـ scripts.
- Published path (عند البناء):
	- ota-server/public/firmware/km14/packages/luci-app-alemprator-ota_1.0-r47_mipsel_24kc.ipk

### G) الحالة الحالية
1. الحزمة مدمجة ضمن صورة KM14 الحالية وموجودة في مجلد packages.
2. البطاقة جاهزة كأولوية ثالثة بعد hotspot-openwrt وsetup.
3. تم التحقق الميداني: صفحة `/cgi-bin/luci/admin/system/ota-update` تُرجع HTTP 200.
4. المتبقي لإغلاق البطاقة بالكامل:
	- تنفيذ سيناريوهات فشل API والتحقق من ثبات status-json وواجهة ota.

## 13) بطاقة عملية جاهزة: alemprator-guard

## Package: alemprator-guard

### A) Scope
- الهدف الوظيفي للحزمة: التحقق من الترخيص/السماحية عبر هوية الجهاز مع منطق grace period قبل السماح بخدمات محددة.
- المسارات الأساسية:
	- package/alemprator-guard/Makefile
	- package/alemprator-guard/src/guard.c

### B) Issues
1. [High] حساسية عالية لأي خطأ في منطق التحقق لأنه قد يحجب الخدمة عن أجهزة سليمة.
2. [Medium] التعامل مع انقطاع الخادم يعتمد على cache/grace ويجب التحقق من كل حواف الزمن.
3. [Medium] أي تغيير في endpoint/headers قد يسبب رفضا صامتا إذا لم توجد رسائل واضحة.

### C) Root Cause
- المشكلة 1: قرار السماح/المنع مركزي داخل binary واحد وحساس لشروط متعددة (token/mac/cache/time).
- المشكلة 2: مسارات fallback تعتمد قيم UCI محلية وقد تتأثر بفساد config أو clock drift.
- المشكلة 3: اعتماد خارجي على endpoint يجعل الاختبار المحلي غير كاف دون محاكاة ردود الخادم.

### D) Fix Plan
1. تثبيت مصفوفة حالات واضحة: accepted/blocked/unreachable/expired/first-boot.
2. مراجعة مسارات cache read/write والتأكد من سلامة transitions بين الحالات.
3. إضافة اختبارات محاكاة endpoint محلي (رد true/false/timeout).
4. توحيد رسائل الخطأ لتسهيل التشخيص من logread.
5. اعتماد اختبار reboot + clock skew ضمن regression.

### E) Verification
- Build command:
	- make package/alemprator-guard/compile V=s
- Install command (على الراوتر):
	- opkg install --force-reinstall /tmp/alemprator-guard_*.ipk
- Runtime checks:
	- التحقق من سلوك guard مع server متاح/غير متاح/رفض صريح.
	- التأكد من قراءة وكتابة cache بشكل صحيح.
- Reboot checks:
	- ثبات القرار بعد reboot ضمن نفس نافذة grace.

### F) Release
- PKG_RELEASE الحالي: r1.
- Changelog summary المقترح عند الإغلاق:
	- تحسين ثبات منطق cache/grace.
	- تحسين قابلية التشخيص عبر رسائل أوضح.
- Published path (عند البناء):
	- ota-server/public/firmware/km14/packages/alemprator-guard_1.0-r1_mipsel_24kc.ipk

### G) الحالة الحالية
1. الحزمة مبنية وموجودة ضمن مخرجات KM14.
2. البطاقة جاهزة كأولوية رابعة ضمن الدفعة الحرجة.
3. تم التحقق الميداني: الحزمة مثبتة على الراوتر، وتشغيل `alemprator-guard` أعطى `exit 0` (smoke check).
4. المتبقي لإغلاق البطاقة بالكامل:
	- تشغيل اختبارات حالات الرخصة كاملة مع محاكاة endpoint وانقطاع الشبكة.

## 14) بطاقة عملية جاهزة: alemprator-firstboot

## Package: alemprator-firstboot

### A) Scope
- الهدف الوظيفي للحزمة: تهيئة إعدادات أول إقلاع (network/firewall/wireless/setup) وتطبيق fallbackات آمنة.
- المسارات الأساسية:
	- package/alemprator-firstboot/Makefile
	- package/alemprator-firstboot/files/etc/init.d/alemprator-firstboot
	- package/alemprator-firstboot/files/etc/uci-defaults/99-alemprator-firstboot
	- package/alemprator-firstboot/files/etc/uci-defaults/10-alemprator-dns-fallback
	- package/alemprator-firstboot/files/etc/config/alemprator_firstboot

### B) Issues
1. [High] حساسية عالية لترتيب التنفيذ عند أول إقلاع؛ أي خلل قد يسبب إعداد شبكة غير متوقع.
2. [Medium] تداخل محتمل مع تغييرات معالج setup أو uci-defaults الأخرى في نفس الإقلاع.
3. [Medium] صعوبة التحقق من idempotency (تشغيل السكربت مرة واحدة فقط بالشكل الصحيح).

### C) Root Cause
- المشكلة 1: سكربت أول إقلاع يلامس عدة subsystems دفعة واحدة.
- المشكلة 2: تعدد uci-defaults قد يولد سباق ترتيب إذا لم يكن التسلسل مضبوطا.
- المشكلة 3: بعض الأعطال لا تظهر إلا على جهاز نظيف (fresh flash) وليس على بيئة مطورة.

### D) Fix Plan
1. تثبيت سيناريو اختبار fresh flash كشرط أساسي قبل أي تعديل.
2. مراجعة ترتيب uci-defaults والتأكد أن fallback لا يطغى على إعدادات المستخدم.
3. إضافة فحوص safeguard داخل init script لتجنب إعادة تطبيق غير مقصودة.
4. اعتماد اختبار إعادة الإقلاع المتكرر للتحقق من عدم إعادة تهيئة غير مرغوبة.

### E) Verification
- Build command:
	- make package/alemprator-firstboot/compile V=s
- Install command (على الراوتر):
	- opkg install --force-reinstall /tmp/alemprator-firstboot_*.ipk
- Runtime checks:
	- التحقق من حالة config بعد أول إقلاع.
	- التأكد من تطبيق DNS fallback عند الحاجة فقط.
- Reboot checks:
	- لا إعادة تهيئة غير متوقعة بعد الإقلاع الثاني والثالث.

### F) Release
- PKG_RELEASE الحالي: r12.
- Changelog summary المقترح عند الإغلاق:
	- ضبط تسلسل firstboot وتحسين idempotency.
	- تقليل تعارض firstboot مع setup.
- Published path (عند البناء):
	- ota-server/public/firmware/km14/packages/alemprator-firstboot_1.0-r12_mipsel_24kc.ipk

### G) الحالة الحالية
1. الحزمة مبنية وموجودة ضمن مخرجات KM14.
2. البطاقة جاهزة كأولوية خامسة ضمن الدفعة الحرجة.
3. تم التحقق الميداني: الحزمة مثبتة وخدمة `alemprator-firstboot` مفعلة عند الإقلاع.
4. المتبقي لإغلاق البطاقة بالكامل:
	- اختبار fresh flash فعلي + reboot idempotency checks.

## 15) بطاقة عملية جاهزة: luci-app-alemprator-dhcp

## Package: luci-app-alemprator-dhcp

### A) Scope
- الهدف الوظيفي للحزمة: واجهة LuCI + خدمة sentinel لمتابعة/حماية سلوك DHCP حسب منطق Alemprator.
- المسارات الأساسية:
	- package/luci-app-alemprator-dhcp/Makefile
	- package/luci-app-alemprator-dhcp/src/dhcp-sentinel.c
	- package/luci-app-alemprator-dhcp/files/etc/init.d/alemprator-dhcp-sentinel
	- package/luci-app-alemprator-dhcp/files/www/luci-static/resources/view/alemprator-dhcp/index.js
	- package/luci-app-alemprator-dhcp/files/usr/share/luci/menu.d/luci-app-alemprator-dhcp.json

### B) Issues
1. [High] أي خلل في dhcp-sentinel قد يؤثر مباشرة على توزيع DHCP واستقرار الشبكة المحلية.
2. [Medium] احتمال عدم اتساق بين حالة الخدمة الفعلية وما يظهر في واجهة LuCI.
3. [Medium] حساسية startup order بين dnsmasq وخدمة sentinel.

### C) Root Cause
- المشكلة 1: الخدمة مرتبطة بمسار تشغيلي شبكي حرج.
- المشكلة 2: الواجهة تعتمد قراءة حالة قد لا تعكس race conditions عند startup/restart.
- المشكلة 3: ترتيب init scripts قد يختلف حسب الجهاز/الصورة.

### D) Fix Plan
1. مراجعة منطق dhcp-sentinel.c على حالات الخطأ والـ exit codes.
2. توحيد آلية فحص الحالة بين الخدمة والواجهة.
3. ضبط startup sequencing والتأكد من dependency واضحة على dnsmasq/network.
4. إضافة اختبار restart stress للخدمة مع مراقبة logread.

### E) Verification
- Build command:
	- make package/luci-app-alemprator-dhcp/compile V=s
- Install command (على الراوتر):
	- opkg install --force-reinstall /tmp/luci-app-alemprator-dhcp_*.ipk
- Runtime checks:
	- واجهة LuCI تظهر الحالة الصحيحة للخدمة.
	- لا انقطاع DHCP أثناء restart الخدمة.
- Reboot checks:
	- الخدمة تبدأ تلقائيا وتعمل بشكل مستقر بعد reboot.

### F) Release
- PKG_RELEASE الحالي: r1.
- Changelog summary المقترح عند الإغلاق:
	- تقوية استقرار dhcp-sentinel وتحسين مزامنة الحالة مع الواجهة.
- Published path (عند البناء):
	- ota-server/public/firmware/km14/packages/luci-app-alemprator-dhcp_1.0-r1_mipsel_24kc.ipk

### G) الحالة الحالية
1. تم بناء الحزمة ونشرها داخل `km14/packages`.
2. تم تثبيت الحزمة على الراوتر وظهور ملف menu الخاص بها.
3. تم التحقق الميداني: صفحة `/cgi-bin/luci/admin/network/alemprator_dhcp` تُرجع HTTP 200.
4. المتبقي لإغلاق البطاقة بالكامل:
	- تنفيذ اختبارات DHCP تحت ضغط restart + reboot على جهاز فعلي.

## 16) بطاقة عملية جاهزة: alemprator-ax

## Package: alemprator-ax

### A) Scope
- الهدف الوظيفي للحزمة: توفير أدوات/أوامر alemprator التنفيذية (CLI binaries/scripts) على النظام.
- المسارات الأساسية:
	- package/alemprator-ax/Makefile
	- package/alemprator-ax/files/usr/bin/alemprator*

### B) Issues
1. [High] كثرة الملفات التنفيذية بأسماء متقاربة ترفع احتمال سوء الربط أو صلاحيات غير صحيحة.
2. [Medium] غياب توثيق وظيفي واضح لكل binary يصعب التشخيص عند الأعطال.

### C) Root Cause
- المشكلة 1: الحزمة تعتمد نسخ عدة ملفات مباشرة إلى /usr/bin.
- المشكلة 2: لا يوجد اختبار موحد لسلوك كل أمر بعد التثبيت.

### D) Fix Plan
1. حصر دور كل ملف تنفيذي وتثبيت permissions صحيحة.
2. إضافة تحقق smoke test بسيط لكل أمر أساسي.
3. توثيق مختصر لاستخدام كل أداة في README داخلي أو changelog.

### E) Verification
- Build command:
	- make package/alemprator-ax/compile V=s
- Install command:
	- opkg install --force-reinstall /tmp/alemprator-mtax_*.ipk
- Runtime checks:
	- command -v لكل أداة + تشغيل --help إن متاح.
- Reboot checks:
	- الأدوات تبقى متاحة بعد reboot.

### F) Release
- PKG_RELEASE الحالي: r3.
- Published path (عند البناء):
	- ota-server/public/firmware/km14/packages/alemprator-mtax_1.0-r3_mipsel_24kc.ipk

### G) الحالة الحالية
1. تم بناء الحزمة (`alemprator-mtax_1.0-r3`) ونشرها داخل `km14/packages`.
2. تم تثبيتها على الراوتر بنجاح.
3. تم التحقق الميداني من وجود وصلاحية جميع الملفات التنفيذية تحت `/usr/bin`.

## 17) بطاقة عملية جاهزة: alemprator-suite

## Package: alemprator-suite

### A) Scope
- الهدف الوظيفي للحزمة: ميتا-حزمة لتجميع/ربط حزم alemprator الأساسية.
- المسارات الأساسية:
	- package/alemprator-suite/Makefile

### B) Issues
1. [High] أي خطأ في dependencies قد يمنع تثبيت أجزاء مهمة من النظام.
2. [Medium] خطر drift بين مكونات suite والإصدارات الفعلية للحزم التابعة.

### C) Root Cause
- المشكلة 1: الحزمة تعتمد على تعريف تبعيات فقط بدون منطق تنفيذي.
- المشكلة 2: تحديث الحزم التابعة بدون تحديث suite يسبب فجوة توافق.

### D) Fix Plan
1. مراجعة DEPENDS وتوحيدها مع الواقع الحالي للحزم المخصصة.
2. اختبار تثبيت suite على جهاز نظيف والتأكد من سحب كل الحزم المطلوبة.

### E) Verification
- Build command:
	- make package/alemprator-suite/compile V=s
- Install command:
	- opkg install --force-reinstall /tmp/alemprator-suite_*.ipk
- Runtime checks:
	- opkg info alemprator-suite + opkg status للحزم التابعة.
- Reboot checks:
	- استمرار تشغيل الخدمات التابعة بعد reboot.

### F) Release
- PKG_RELEASE الحالي: r1.
- Published path (عند البناء):
	- ota-server/public/firmware/km14/packages/alemprator-suite_1.0-r1_mipsel_24kc.ipk

### G) الحالة الحالية
1. تم بناء الحزمة (`alemprator-suite_1.0-r1`) ونشرها داخل `km14/packages`.
2. تم تثبيتها على الراوتر بنجاح.
3. تم التحقق أن التبعيات المعلنة موجودة في حالة الحزمة (meta-package verified).

## 18) بطاقة عملية جاهزة: bandix-plus

## Package: bandix-plus

### A) Scope
- الهدف الوظيفي للحزمة: خدمة backend لمراقبة/تجميع بيانات الشبكة لاستهلاكها في الواجهة.
- المسارات الأساسية:
	- package/bandix-plus/Makefile
	- package/bandix-plus/files/bandix-plus.init
	- package/bandix-plus/files/bandix-plus.config
	- package/bandix-plus/update.sh

### B) Issues
1. [High] أي خلل في init/config يؤثر على توافر بيانات المراقبة.
2. [Medium] مخاطر تحديث غير متوافق عبر update.sh.

### C) Root Cause
- المشكلة 1: الخدمة تعتمد startup صحيح + config صالح.
- المشكلة 2: مسار التحديث قد يغيّر حالة runtime دون rollback واضح.

### D) Fix Plan
1. مراجعة init script (start/stop/restart) ومعالجة الأخطاء.
2. توحيد default config والتحقق من القيم قبل التشغيل.
3. اختبار update.sh في بيئة اختبار قبل اعتمادها.

### E) Verification
- Build command:
	- make package/bandix-plus/compile V=s
- Install command:
	- opkg install --force-reinstall /tmp/bandix-plus_*.ipk
- Runtime checks:
	- التحقق من pid/service status ومن وجود مخرجات صالحة.
- Reboot checks:
	- الخدمة تبدأ تلقائيا بعد reboot.

### F) Release
- PKG_RELEASE الحالي: r1.
- Published path (عند البناء):
	- ota-server/public/firmware/km14/packages/bandix-plus_0.1.0-r1_mipsel_24kc.ipk

### G) الحالة الحالية
1. تم بناء الحزمة (`bandix-plus_0.1.0-r1_mipsel_24kc.ipk`) ونشرها داخل `km14/packages`.
2. تم التثبيت على الراوتر بنجاح مع إعادة تثبيت clean.
3. تم التحقق من حالة الحزمة عبر `opkg status bandix-plus` (installed + conffile present).

## 19) بطاقة عملية جاهزة: luci-app-bandix-plus

## Package: luci-app-bandix-plus

### A) Scope
- الهدف الوظيفي للحزمة: واجهة LuCI لخدمة bandix-plus.
- المسارات الأساسية:
	- package/luci-app-bandix-plus/Makefile
	- package/luci-app-bandix-plus/po/

### B) Issues
1. [Medium] احتمال عدم ظهور الصفحة إذا لم تطابق الواجهة تبعيات backend.
2. [Low] تغطية ترجمة محدودة.

### C) Root Cause
- المشكلة 1: ارتباط مباشر بحزمة bandix-plus وتبعيات LuCI.
- المشكلة 2: عناصر i18n قد لا تغطي كل النصوص.

### D) Fix Plan
1. التحقق من ظهور الصفحة وربطها مع backend.
2. مراجعة ACL/menu/view إن وجدت داخل feeds/luci أو ملفات الحزمة.
3. تحسين الترجمة الأساسية للنصوص المهمة.

### E) Verification
- Build command:
	- make package/luci-app-bandix-plus/compile V=s
- Install command:
	- opkg install --force-reinstall /tmp/luci-app-bandix-plus_*.ipk
- Runtime checks:
	- الصفحة تظهر وتسترجع بيانات bandix-plus بدون أخطاء JS.
- Reboot checks:
	- استمرار ظهور الصفحة بعد reboot.

### F) Release
- PKG_RELEASE الحالي: r1.
- Published path (عند البناء):
	- ota-server/public/firmware/km14/packages/luci-app-bandix-plus_0.1.0-r1_all.ipk

### G) الحالة الحالية
1. تم بناء الحزمة (`luci-app-bandix-plus_0.1.0-r1_all.ipk`) ونشرها داخل `km14/packages`.
2. تم التثبيت على الراوتر بنجاح مع حل التحقق على المسار الصحيح في LuCI.
3. تم التحقق الميداني: الصفحات
	- `/cgi-bin/luci/admin/network/bandix_plus` => HTTP 200
	- `/cgi-bin/luci/admin/network/bandix_plus/index` => HTTP 200
	- `/cgi-bin/luci/admin/network/bandix_plus/settings` => HTTP 200

## 20) بطاقة عملية جاهزة: luci-app-cpu-perf

## Package: luci-app-cpu-perf

### A) Scope
- الهدف الوظيفي للحزمة: إدارة/عرض إعدادات أداء المعالج عبر LuCI مع خدمة init.
- المسارات الأساسية:
	- package/luci-app-cpu-perf/Makefile
	- package/luci-app-cpu-perf/root/etc/init.d/cpu-perf
	- package/luci-app-cpu-perf/root/etc/config/cpu-perf

### B) Issues
1. [High] خطأ runtime مرصود في الواجهة (Cannot read properties...) يمنع القراءة الصحيحة للحالة.
2. [Medium] ظهور "No performance data" على بعض الأجهزة بسبب اختلاف cpufreq sysfs.

### C) Root Cause
- المشكلة 1: فرضيات غير محمية داخل JS أو backend حول وجود بيانات init/status.
- المشكلة 2: اختلاف دعم cpufreq حسب الجهاز/النواة.

### D) Fix Plan
1. حماية جميع قراءات الخصائص null/undefined في الواجهة.
2. إضافة fallback آمن عند غياب cpufreq nodes.
3. تحسين رسائل الخطأ لتكون تشخيصية بدل فشل عام.

### E) Verification
- Build command:
	- make package/luci-app-cpu-perf/compile V=s
- Install command:
	- opkg install --force-reinstall /tmp/luci-app-cpu-perf_*.ipk
- Runtime checks:
	- الصفحة تفتح بدون JS error.
	- عرض governor/frequencies عندما تكون متاحة.
- Reboot checks:
	- استمرارية الخدمة والواجهة بعد reboot.

### F) Release
- PKG_RELEASE الحالي: r2.
- Published path (عند البناء):
	- ota-server/public/firmware/km14/packages/luci-app-cpu-perf_0.6.1-r2_all.ipk

### G) الحالة الحالية
1. تم إصلاح عطل TypeError في الواجهة.
2. تم رفع الإصدار إلى r2 وبناء الحزمة ونشرها في km14.
3. الصورة الكاملة KM14 تتضمن النسخة الجديدة.
4. تم التحقق الميداني: صفحة `/cgi-bin/luci/admin/services/cpu-perf` تُرجع HTTP 200 وعلامة `Cannot read properties` غير موجودة.
5. ملاحظة: غياب بيانات الأداء متوقع على هذا الجهاز لعدم وجود `cpufreq` في sysfs.

## 21) بطاقة عملية جاهزة: luci-app-cpu-status

## Package: luci-app-cpu-status

### A) Scope
- الهدف الوظيفي للحزمة: عرض حالة المعالج وبياناته عبر LuCI.
- المسارات الأساسية:
	- package/luci-app-cpu-status/Makefile
	- package/luci-app-cpu-status/po/

### B) Issues
1. [Medium] احتمال عدم تطابق بيانات العرض مع تنوع الأجهزة.
2. [Low] تغطية ترجمة وتحسين UX.

### C) Root Cause
- المشكلة 1: الاعتماد على مصادر معلومات قد تختلف بين targetات.
- المشكلة 2: اختلافات واجهة LuCI بين الإصدارات.

### D) Fix Plan
1. اختبار الحزمة على KM14 والتأكد من القيم المعروضة.
2. تحسين التعامل مع غياب بعض الحقول (fallback values).

### E) Verification
- Build command:
	- make package/luci-app-cpu-status/compile V=s
- Install command:
	- opkg install --force-reinstall /tmp/luci-app-cpu-status_*.ipk
- Runtime checks:
	- الصفحة تعرض معلومات متسقة بدون أخطاء JS.
- Reboot checks:
	- الاستقرار بعد reboot.

### F) Release
- PKG_RELEASE الحالي: r1.
- Published path (عند البناء):
	- ota-server/public/firmware/km14/packages/luci-app-cpu-status_0.6.3-r1_all.ipk

### G) الحالة الحالية
1. تم بناء الحزمة (`luci-app-cpu-status_0.6.3-r1_all.ipk`) ونشرها داخل `km14/packages`.
2. تم التثبيت على الراوتر بنجاح والتحقق عبر `opkg status`.
3. تم التحقق الميداني: `/cgi-bin/luci/admin/status/realtime/cpu` تُرجع HTTP 200.
4. تم اجتياز اختبار ما بعد إعادة التشغيل (Reboot Regression): الحزمة ثابتة والواجهة تعمل.

## 22) بطاقة عملية جاهزة: luci-app-log-viewer

## Package: luci-app-log-viewer

### A) Scope
- الهدف الوظيفي للحزمة: عرض السجلات في LuCI مع ميزات تصفية.
- المسارات الأساسية:
	- package/luci-app-log-viewer/Makefile
	- package/luci-app-log-viewer/po/

### B) Issues
1. [Medium] مخاطر الأداء عند أحجام سجلات كبيرة.
2. [Low] تحسينات UX/ترجمة.

### C) Root Cause
- المشكلة 1: الواجهة قد تسحب كميات كبيرة من البيانات دفعة واحدة.
- المشكلة 2: عدم وجود حدود افتراضية مناسبة للعرض في بعض السيناريوهات.

### D) Fix Plan
1. اختبار الأداء على log كبير.
2. ضبط الافتراضات (عدد أسطر/تحديث) إن لزم.
3. التحقق من عدم كسر الواجهة مع log فارغ أو ضخم.

### E) Verification
- Build command:
	- make package/luci-app-log-viewer/compile V=s
- Install command:
	- opkg install --force-reinstall /tmp/luci-app-log-viewer_*.ipk
- Runtime checks:
	- عرض السجلات وتصفيتها بدون تجمد.
- Reboot checks:
	- استمرار عمل الواجهة بعد reboot.

### F) Release
- PKG_RELEASE الحالي: r2.
- Published path (عند البناء):
	- ota-server/public/firmware/km14/packages/luci-app-log-viewer_1.5.0-r2_all.ipk

### G) الحالة الحالية
1. تم بناء الحزمة (`luci-app-log-viewer_1.5.0-r2_all.ipk`) ونشرها داخل `km14/packages`.
2. تم التثبيت على الراوتر بنجاح والتحقق عبر `opkg status`.
3. تم التحقق الميداني لمسارات الواجهة:
	- `/cgi-bin/luci/admin/status/log-viewer` => HTTP 200
	- `/cgi-bin/luci/admin/status/log-viewer/syslog` => HTTP 200
	- `/cgi-bin/luci/admin/status/log-viewer/dmesg` => HTTP 200
4. تم اجتياز اختبار ما بعد إعادة التشغيل (Reboot Regression): الواجهة ما زالت تعمل بعد الإقلاع.

## 23) بطاقة عملية جاهزة: luci-app-netspeedtest

## Package: luci-app-netspeedtest

### A) Scope
- الهدف الوظيفي للحزمة: اختبار سرعة الشبكة عبر LuCI مع خدمات مساندة (iperf3/librespeed-go/mikrotik-btest).
- المسارات الأساسية:
	- package/luci-app-netspeedtest/Makefile
	- package/luci-app-netspeedtest/root/etc/init.d/netspeedtest
	- package/luci-app-netspeedtest/root/etc/config/netspeedtest

### B) Issues
1. [Medium] الاعتماد على عدة أدوات خارجية يزيد فرص فشل جزئي.
2. [Medium] حساسية الأداء/الواجهة عند انقطاع أحد backends.

### C) Root Cause
- المشكلة 1: تكامل متعدد الأدوات يتطلب اكتشاف قدرات runtime قبل العرض.
- المشكلة 2: بعض البيئات لا توفر جميع الأدوات بنفس الإعداد الافتراضي.

### D) Fix Plan
1. إضافة checks واضحة لتوفر كل backend.
2. تحسين رسائل الخطأ لكل مسار اختبار.
3. مراجعة init/config لضمان startup صحيح.

### E) Verification
- Build command:
	- make package/luci-app-netspeedtest/compile V=s
- Install command:
	- opkg install --force-reinstall /tmp/luci-app-netspeedtest_*.ipk
- Runtime checks:
	- تنفيذ اختبار واحد على الأقل بنجاح.
	- عرض فشل backend بشكل واضح بدون كسر الصفحة.
- Reboot checks:
	- الخدمة والواجهة تعملان بعد reboot.

### F) Release
- PKG_RELEASE الحالي: يعتمد على luci.mk/feeds (لا يوجد رقم ثابت معرف محليا في هذا Makefile).
- Published path (عند البناء):
	- ota-server/public/firmware/km14/packages/luci-app-netspeedtest_*.ipk

### G) الحالة الحالية
1. تم بناء الحزمة (`luci-app-netspeedtest_26.137.52127~e1ca5a9_all.ipk`) ونشرها داخل `km14/packages`.
2. تم التثبيت على الراوتر بنجاح والتحقق عبر `opkg status`.
3. تم إصلاح مشكلة صلاحيات init عبر تحديث `postinst/prerm` في `Makefile` لضمان قابلية تنفيذ `/etc/init.d/netspeedtest`.
4. تحقق فعلي بعد الإصلاح: `/etc/init.d/netspeedtest` أصبح executable (`-rwxr-xr-x`).
5. تم التحقق الميداني لمسارات الواجهة:
	- `/cgi-bin/luci/admin/network/netspeedtest` => HTTP 200
	- `/cgi-bin/luci/admin/network/netspeedtest/iperf3` => HTTP 200
	- `/cgi-bin/luci/admin/network/netspeedtest/librespeed` => HTTP 200
	- `/cgi-bin/luci/admin/network/netspeedtest/speedtest` => HTTP 200
	- `/cgi-bin/luci/admin/network/netspeedtest/webspeedtest` => HTTP 200
6. تم اجتياز اختبار ما بعد إعادة التشغيل (Reboot Regression): الصلاحيات محفوظة والواجهة تعمل.

## 24) بطاقة عملية جاهزة: luci-app-temp-status

## Package: luci-app-temp-status

### A) Scope
- الهدف الوظيفي للحزمة: عرض حالة/حرارة الحساسات ضمن LuCI.
- المسارات الأساسية:
	- package/luci-app-temp-status/Makefile
	- package/luci-app-temp-status/po/

### B) Issues
1. [Medium] تنوع أسماء/مسارات الحساسات قد ينتج عرضا فارغا على بعض الأجهزة.
2. [Low] تحسينات ترجمة وتجربة استخدام.

### C) Root Cause
- المشكلة 1: الاعتماد على توفر حساسات ومصادر بيانات قد تختلف لكل target.
- المشكلة 2: الواجهة قد لا توفر fallback واضح عند غياب القيم.

### D) Fix Plan
1. اختبار على KM14 مع التحقق من بيانات الحساسات المتاحة فعليا.
2. إضافة fallback ورسالة توضيحية عندما لا تتوفر حساسات.

### E) Verification
- Build command:
	- make package/luci-app-temp-status/compile V=s
- Install command:
	- opkg install --force-reinstall /tmp/luci-app-temp-status_*.ipk
- Runtime checks:
	- الصفحة تعرض القيم أو رسالة واضحة بدون أخطاء.
- Reboot checks:
	- الاستقرار بعد reboot.

### F) Release
- PKG_RELEASE الحالي: r1.
- Published path (عند البناء):
	- ota-server/public/firmware/km14/packages/luci-app-temp-status_0.8.1-r1_all.ipk

### G) الحالة الحالية
1. تم بناء الحزمة (`luci-app-temp-status_0.8.1-r1_all.ipk`) ونشرها داخل `km14/packages`.
2. تم التثبيت على الراوتر بنجاح والتحقق عبر `opkg status`.
3. تم التحقق الميداني: `/cgi-bin/luci/admin/status/realtime/temperature` تُرجع HTTP 200.
4. تم اجتياز اختبار ما بعد إعادة التشغيل (Reboot Regression): الصفحة متاحة بعد الإقلاع.

## 25) بطاقة عملية جاهزة: luci-app-tn-netports

## Package: luci-app-tn-netports

### A) Scope
- الهدف الوظيفي للحزمة: عرض حالة منافذ الشبكة في LuCI.
- المسارات الأساسية:
	- package/luci-app-tn-netports/Makefile
	- package/luci-app-tn-netports/htdocs/luci-static/resources/netports.js
	- package/luci-app-tn-netports/root/etc/config/luci_netports

### B) Issues
1. [Medium] اختلاف تعريف المنافذ بين الأجهزة قد يسبب عرضا غير دقيق.
2. [Low] احتمالات مشاكل i18n/UX في بعض الأنماط.

### C) Root Cause
- المشكلة 1: الاعتماد على أسماء واجهات ومخططات عتادية تختلف حسب target.
- المشكلة 2: منطق العرض يعتمد config افتراضي قد لا يلائم كل لوحة.

### D) Fix Plan
1. اختبار الحزمة على KM14 مع ضبط config الافتراضي للمنافذ.
2. مراجعة netports.js لمسارات fallback عند غياب الواجهة.
3. توثيق أي تخصيص خاص بالجهاز.

### E) Verification
- Build command:
	- make package/luci-app-tn-netports/compile V=s
- Install command:
	- opkg install --force-reinstall /tmp/luci-app-tn-netports_*.ipk
- Runtime checks:
	- الصفحة تعرض حالة المنافذ المتوقعة على KM14.
- Reboot checks:
	- بقاء الإعدادات والواجهة بعد reboot.

### F) Release
- PKG_RELEASE الحالي: يعتمد على luci.mk/feeds (PKG_VERSION=2.0.7 معرف محليا).
- Published path (عند البناء):
	- ota-server/public/firmware/km14/packages/luci-app-tn-netports_*.ipk

### G) الحالة الحالية
1. تم بناء الحزمة (`luci-app-tn-netports_2.0.7-r1_all.ipk`) ونشرها داخل `km14/packages`.
2. تم التثبيت على الراوتر بنجاح والتحقق عبر `opkg status`.
3. ملاحظة متوقعة: وجود تعارض conffile معدّل أدى إلى إنشاء `/etc/config/luci_netports-opkg` بدون فشل التثبيت.
4. تم التحقق الميداني: `/cgi-bin/luci/admin/status/tn-netports` تُرجع HTTP 200.
5. تم اجتياز اختبار ما بعد إعادة التشغيل (Reboot Regression): الحالة مستقرة والواجهة تعمل.

## 26) إغلاق رسمي: Release Freeze (KM14)

### A) الهدف
- تثبيت مسار نشر رسمي واحد لإصدار KM14 ومنع خلط الحزم في `ota-server/public`.

### B) ما تم تنفيذه
1. نقل جميع ملفات `*.ipk` من جذر `ota-server/public` إلى أرشيف آمن:
	- `ota-server/public/_archive_release_freeze_2026-07-07`
2. الإبقاء على مسار الإصدار الرسمي فقط:
	- `ota-server/public/firmware/km14`
3. تحديث `SHA256SUMS` داخل مسار KM14 الرسمي بعد التنظيف.

### C) نتيجة القياس
1. الملفات المنقولة من جذر `public`: 108 ملف ipk.
2. المتبقي في جذر `public` بعد التنظيف: 0 ملف ipk.
3. عدد الحزم الرسمية داخل `km14/packages`: 16 ملف ipk.

### D) مخرجات التوثيق
1. تقرير Freeze مفصل:
	- `ota-server/public/firmware/km14/RELEASE_FREEZE_REPORT_2026-07-07.md`
2. Release Notes نهائية:
	- `ota-server/public/firmware/km14/RELEASE_NOTES_KM14_2026-07-07.md`

### E) الحالة الحالية
1. التشطيب مغلق تنفيذيا.
2. مسار النشر الرسمي لـ KM14 نظيف وواضح.
3. التراجع ممكن عند الحاجة عبر إعادة الملفات من الأرشيف (بدون فقدان بيانات).
