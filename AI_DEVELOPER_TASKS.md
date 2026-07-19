# تعليمات المطور (AI) — المهام المطلوبة

> ⚠️ **قبل أي شيء**: اقرأ ملف `/home/galal/openwrt/DEVELOPER_WORKFLOW.md` كاملاً والتزم بكل قواعده.
> ⚠️ **لا تعدّل أبداً داخل `build_dir/`**. عدّل فقط في `package/`.
> ⚠️ **اعمل `git commit` قبل أي بناء.**
> ⚠️ **اقرأ ملف `/home/galal/openwrt/PACKAGE_FINISH_FIX_PLAN.md` لفهم سياق كل حزمة بالكامل قبل لمس أي كود.**

---

## المشاكل المتبقية — مرتبة حسب الأولوية

---

### 🔴 الأولوية الأولى: مشاكل حرجة (يجب إصلاحها أولاً)

---

#### المشكلة 1: `alemprator-network-protection` — اختبار Loop فيزيائي لم يتم
- **الحالة**: الحزمة مبنية (r10) وتعمل، لكن لم يتم اختبار كشف Loop الفيزيائي بعد تقسيم المنافذ (LAN Split)
- **الملفات**:
  - `package/alemprator-network-protection/files/usr/libexec/alemprator-network-protection/monitor`
  - `package/alemprator-network-protection/files/usr/libexec/alemprator-network-protection/modules/`
- **المطلوب**:
  1. راجع كود `monitor` وتأكد أن `monitor_kernel_loops()` تكتشف رسائل bridge loop على المنافذ المفصلة (`lan1`, `lan2`, `lan3`, `lan4`)
  2. تأكد أن `event-dispatcher` يعالج event `kernel_loop:` بشكل صحيح
  3. تأكد أن `action-manager` ينفذ الإجراء التصحيحي (عزل المنفذ)
- **التحقق**:
  ```bash
  make package/alemprator-network-protection/compile V=s
  # على الراوتر:
  ubus call alemprator-network-protection getStatus
  logread | grep -E "np|kernel_loop" | tail -20
  ```

---

#### المشكلة 2: `alemprator-guard` — اختبار حالات الرخصة غير مكتمل
- **الحالة**: الحزمة مبنية (r1) وتعمل (exit 0)، لكن لم يتم اختبار كل حالات الرخصة
- **الملفات**:
  - `package/alemprator-guard/src/guard.c`
- **المطلوب**:
  1. راجع كود `guard.c` وتأكد من تغطية جميع الحالات: `accepted` / `blocked` / `unreachable` / `expired` / `first-boot`
  2. تأكد أن مسار cache read/write سليم
  3. تأكد أن grace period يعمل عند انقطاع الخادم
  4. تأكد أن رسائل الخطأ في `logread` واضحة وتشخيصية
- **التحقق**:
  ```bash
  make package/alemprator-guard/compile V=s
  # على الراوتر:
  /usr/bin/alemprator-guard; echo $?
  logread | grep guard | tail -10
  ```

---

#### المشكلة 3: `alemprator-firstboot` — اختبار fresh flash غير مكتمل
- **الحالة**: الحزمة مبنية (r12) والخدمة مفعلة، لكن لم يتم اختبار fresh flash + reboot idempotency
- **الملفات**:
  - `package/alemprator-firstboot/files/etc/init.d/alemprator-firstboot`
  - `package/alemprator-firstboot/files/etc/uci-defaults/99-alemprator-firstboot`
  - `package/alemprator-firstboot/files/etc/uci-defaults/10-alemprator-dns-fallback`
- **المطلوب**:
  1. راجع `99-alemprator-firstboot` وتأكد أنه يُنفذ مرة واحدة فقط (idempotent)
  2. تأكد أن `10-alemprator-dns-fallback` لا يطغى على إعدادات DNS التي ضبطها المستخدم
  3. تأكد من ترتيب التنفيذ (لا يتعارض مع uci-defaults من حزم أخرى)
  4. تأكد أن `init.d/alemprator-firstboot` لا يعيد التهيئة بعد الإقلاع الثاني
- **التحقق**:
  ```bash
  make package/alemprator-firstboot/compile V=s
  bash -n package/alemprator-firstboot/files/etc/init.d/alemprator-firstboot
  bash -n package/alemprator-firstboot/files/etc/uci-defaults/99-alemprator-firstboot
  ```

---

### 🟡 الأولوية الثانية: مشاكل متوسطة

---

#### المشكلة 4: `luci-app-alemprator-dhcp` — استقرار dhcp-sentinel
- **الحالة**: الحزمة مبنية والواجهة تعمل (HTTP 200)، لكن لم يتم اختبار DHCP تحت ضغط
- **الملفات**:
  - `package/luci-app-alemprator-dhcp/src/dhcp-sentinel.c`
  - `package/luci-app-alemprator-dhcp/files/etc/init.d/alemprator-dhcp-sentinel`
- **المطلوب**:
  1. راجع `dhcp-sentinel.c` — تأكد من معالجة الأخطاء وexit codes
  2. تأكد أن startup sequence صحيح (الخدمة تبدأ بعد dnsmasq)
  3. تأكد أن restart الخدمة لا يقطع DHCP
- **التحقق**:
  ```bash
  make package/luci-app-alemprator-dhcp/compile V=s
  ```

---

#### المشكلة 5: `luci-app-alemprator-ota` — تقوية مسار التحقق من API
- **الحالة**: الحزمة مبنية (r55) وتعمل، لكن يحتاج تقوية ضد فشل الشبكة
- **الملفات**:
  - `package/luci-app-alemprator-ota/files/usr/libexec/alemprator-ota/`
- **المطلوب**:
  1. راجع `common.sh` و `agent.sh` — تأكد من توحيد إدارة الحالة وexit codes
  2. تأكد أن فشل الشبكة/404/sha mismatch لا يدخل الجهاز في حالة update معلقة
  3. تأكد أن رسائل الفشل واضحة في `status-json` وواجهة `ota.js`
- **التحقق**:
  ```bash
  make package/luci-app-alemprator-ota/compile V=s
  bash -n package/luci-app-alemprator-ota/files/usr/libexec/alemprator-ota/*.sh
  ```

---

#### المشكلة 6: `luci-app-setup` — تحسين ثبات مسارات hotspot_quick/wizardvlan
- **الحالة**: الحزمة مبنية (r120) والواجهة تعمل
- **الملفات**:
  - `package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js`
- **المطلوب**:
  1. راجع `setup.js` — ملف كبير ومعقد، ركز على مسارات `hotspot_quick` و `wizardvlan`
  2. تأكد أن حفظ وضع hotspot_quick يكتب القيم الأساسية بشكل صحيح
  3. تأكد أن لا يوجد حذف/تكوين غير مقصود لواجهات WiFi
- **التحقق**:
  ```bash
  make package/luci-app-setup/compile V=s
  ```

---

#### المشكلة 7: `alemprator-suite` — مراجعة التبعيات
- **الحالة**: الحزمة مبنية (r1) — ميتا-حزمة
- **الملفات**:
  - `package/alemprator-suite/Makefile`
- **المطلوب**:
  1. راجع `DEPENDS` في Makefile وتأكد أنها تطابق الحزم المخصصة الموجودة فعلاً
  2. تأكد أن كل الحزم التابعة موجودة بأسمائها الصحيحة
- **التحقق**:
  ```bash
  make package/alemprator-suite/compile V=s
  grep "DEPENDS" package/alemprator-suite/Makefile
  ```

---

### 🟢 الأولوية الثالثة: تحسينات وصيانة

---

#### المشكلة 8: `luci-app-hotspot-openwrt` — مسافة بادئة (#22)
- **الحالة**: آخر مشكلة مفتوحة من أصل 27
- **المطلوب**: تصحيح المسافة البادئة (indentation) في الملفات المتأثرة
- **التحقق**:
  ```bash
  make package/luci-app-hotspot-openwrt/compile V=s
  ```

---

#### المشكلة 9: `luci-app-hotspot-openwrt` — Cached REST API (#7 في Fix Plan)
- **الحالة**: مقترح — جلب اسم البروفايل/الرصيد/تاريخ الانتهاء
- **المطلوب**: التحقق من عمل الكاش الحالي (`/tmp/hotspot-cache-$username`) بشكل صحيح
- **الملفات**:
  - `package/luci-app-hotspot-openwrt/files/www/cgi-bin/hotspot-card-info`
  - `package/luci-app-hotspot-openwrt/files/www/cgi-bin/hotspot-login`

---

#### المشكلة 10: `alemprator-ax` — توثيق الأدوات التنفيذية
- **الحالة**: الحزمة مبنية (r3) والأدوات تعمل
- **الملفات**:
  - `package/alemprator-ax/files/usr/bin/`
- **المطلوب**: إضافة توثيق مختصر لكل أداة تنفيذية (README أو --help)

---

## قواعد العمل الصارمة

1. **ابدأ بقراءة** `DEVELOPER_WORKFLOW.md` و `PACKAGE_FINISH_FIX_PLAN.md`
2. **أصلح مشكلة واحدة في كل مرة** — لا تخلط إصلاحات حزم مختلفة
3. **اعمل `git commit` بعد كل إصلاح** قبل الانتقال للمشكلة التالية
4. **ارفع `PKG_RELEASE`** عند أي تعديل في كود الحزمة
5. **ابنِ الحزمة منفردة** (`make package/<name>/compile V=s`) — لا تبني صورة كاملة
6. **افحص السكربتات** بـ `bash -n` قبل البناء
7. **لا تعدّل** ملفات `DEVICE_COMPAT_VERSION` أو `KERNEL_SIZE` أو DTS بدون إذن صريح
8. **وثّق كل تعديل** برسالة commit واضحة تشرح ماذا ولماذا

## ترتيب العمل المقترح

```
المشكلة 1 (network-protection) → المشكلة 2 (guard) → المشكلة 3 (firstboot)
→ المشكلة 4 (dhcp) → المشكلة 5 (ota) → المشكلة 6 (setup)
→ المشكلة 7 (suite) → المشكلة 8 (hotspot indentation) → البقية
```
