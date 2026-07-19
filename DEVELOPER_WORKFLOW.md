# دليل المطور الإلزامي — مشروع الإمبراطور (Alemprator)
# Developer Mandatory Workflow — Preventing Regression Forever

> **هذا الملف ليس اختيارياً. أي إصلاح أو تعديل لا يتبع هذه الخطوات يُعتبر غير مقبول ولن يُعتمد.**

---

## لماذا هذا الدليل موجود؟

في الإصدارات السابقة (r4 إلى r19) حدثت مشاكل متكررة:
- إصلاح في إصدار يختفي في الإصدار التالي
- ميزة تعمل ثم تتعطل بعد بناء جديد
- SSH يشتغل ثم يتوقف، DHCP يعمل ثم يموت

**السبب الجذري**: غياب منهجية عمل ثابتة. هذا الدليل يمنع تكرار ذلك نهائياً.

---

## القسم الأول: القواعد الذهبية (لا يُسمح بكسرها أبداً)

### القاعدة 1: لا تعدّل أبداً داخل `build_dir/`
```
❌ ممنوع:  vim build_dir/target-.../luci-app-hotspot-openwrt/...
✅ صحيح:   vim package/luci-app-hotspot-openwrt/files/...
```
**السبب**: مجلد `build_dir/` مؤقت — يُمسح ويُعاد نسخه من `package/` عند كل `make clean` أو بناء جديد. أي تعديل فيه سيختفي.

### القاعدة 2: لا تنسخ ملف `.config` قديم فوق الحالي
```
❌ ممنوع:  cp KT-KM14-102H-13-11-2025.config .config
✅ صحيح:   استخدم .config الحالي دائماً + make defconfig
```
**السبب**: نسخ config قديم يُلغي كل الخيارات والحزم التي أُضيفت في الإصدارات الأخيرة.

### القاعدة 3: كل تعديل يُحفظ في Git فوراً
```
❌ ممنوع:  تعديل الكود → بناء الصورة → إرسالها للعميل (بدون commit)
✅ صحيح:   تعديل الكود → git add → git commit → بناء الصورة → إرسالها
```
**السبب**: بدون commit، التعديل موجود فقط في ملفاتك المحلية ويمكن أن يضيع بأي لحظة.

### القاعدة 4: لا تنتقل لحزمة جديدة قبل إغلاق الحالية
```
❌ ممنوع:  إصلاح نصف مشكلة في الهوتسبوت → الانتقال لإصلاح OTA → العودة للهوتسبوت
✅ صحيح:   إصلاح الهوتسبوت كاملاً → اختبار → commit → ثم الانتقال لـ OTA
```

---

## القسم الثاني: دورة العمل لكل إصلاح (خطوة بخطوة)

### الخطوة 1: فهم المشكلة وتوثيقها
```bash
# قبل لمس أي كود:
# 1. اكتب وصف المشكلة بوضوح
# 2. حدد الملفات المتأثرة
# 3. سجل الحالة الحالية (logs/screenshots)
```

### الخطوة 2: إنشاء فرع Git مخصص
```bash
# أنشئ فرعاً باسم واضح للإصلاح
git checkout -b fix/hotspot-radius-timeout

# تأكد أنك على الفرع الصحيح
git branch
```

### الخطوة 3: التعديل في المكان الصحيح فقط
```bash
# المكان الوحيد المسموح للتعديل:
package/<اسم-الحزمة>/

# أمثلة صحيحة:
vim package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/apply
vim package/alemprator-network-protection/files/etc/init.d/alemprator-network-protection

# تأكد من صحة السكربت بعد التعديل:
bash -n package/<اسم-الحزمة>/files/path/to/script.sh
```

### الخطوة 4: رفع رقم الإصدار
```bash
# افتح Makefile الحزمة وارفع PKG_RELEASE بواحد
vim package/<اسم-الحزمة>/Makefile

# مثال: غيّر من
PKG_RELEASE:=155
# إلى
PKG_RELEASE:=156
```

### الخطوة 5: بناء الحزمة منفردة أولاً
```bash
# لا تبني الصورة كاملة! ابنِ الحزمة فقط أولاً
make package/<اسم-الحزمة>/compile V=s

# تحقق من نجاح البناء
echo $?  # يجب أن يكون 0

# تأكد من وجود ملف ipk الجديد
find bin -name "<اسم-الحزمة>_*.ipk" -newer Makefile
```

### الخطوة 6: حفظ التعديل في Git
```bash
# أضف الملفات المعدلة
git add package/<اسم-الحزمة>/

# اكتب رسالة commit واضحة ومفصلة
git commit -m "fix(<اسم-الحزمة>): وصف مختصر للإصلاح

- تفاصيل ما تم تعديله
- سبب التعديل
- PKG_RELEASE: rXX -> rYY"
```

### الخطوة 7: اختبار على الراوتر (إلزامي)
```bash
# ارفع الحزمة للراوتر
scp bin/packages/mipsel_24kc/base/<اسم-الحزمة>_*.ipk root@192.168.1.20:/tmp/

# ثبّتها
ssh root@192.168.1.20 "opkg install --force-reinstall /tmp/<اسم-الحزمة>_*.ipk"

# اختبر الخدمة/الواجهة يدوياً
# ... (حسب نوع الحزمة)
```

### الخطوة 8: اختبار إعادة التشغيل (إلزامي — لا يُتجاوز أبداً)
```bash
# أعد تشغيل الراوتر
ssh root@192.168.1.20 "reboot"

# انتظر 60 ثانية ثم تحقق:
# 1. هل الراوتر يرد على ping؟
ping 192.168.1.20

# 2. هل الخدمة تعمل؟
ssh root@192.168.1.20 "logread | grep -i error | tail -20"

# 3. هل الواجهة تفتح؟
curl -s -o /dev/null -w "%{http_code}" http://192.168.1.20/cgi-bin/luci/
```

### الخطوة 9: دمج الفرع في main
```bash
# بعد نجاح كل الاختبارات فقط:
git checkout main
git merge fix/hotspot-radius-timeout
git push
```

---

## القسم الثالث: بناء صورة نظام كاملة (إصدار جديد)

### متى تبني صورة كاملة؟
- فقط عندما تكون جميع الحزم المطلوب تعديلها مكتملة ومختبرة
- لا تبني صورة كاملة لاختبار إصلاح واحد (استخدم ipk بدلاً منها)

### خطوات بناء إصدار رسمي
```bash
# 1. تأكد أنك على فرع main وكل شيء محفوظ
git status  # يجب أن يكون نظيفاً
git log --oneline -5  # راجع آخر 5 commits

# 2. تحقق من .config الحالي (لا تنسخ config قديم!)
make defconfig

# 3. تحقق أن كل الحزم المطلوبة مفعلة
grep -E "CONFIG_PACKAGE_(luci-app-hotspot|alemprator|bandix)" .config | head -20

# 4. ابنِ الصورة
make -j$(nproc) V=s 2>&1 | tee build_r<XX>.log

# 5. تحقق من نجاح البناء
ls -la bin/targets/ramips/mt7621/openwrt-ramips-mt7621-kt_km14-102h-squashfs-sysupgrade.bin

# 6. أرشف الإصدار
VERSION="v1.0-r<XX>"
mkdir -p releases/$VERSION/km14
cp .config releases/$VERSION/km14/r<XX>-km14.config
cp bin/targets/ramips/mt7621/openwrt-ramips-mt7621-kt_km14-102h-squashfs-*.bin releases/$VERSION/km14/
cp bin/targets/ramips/mt7621/openwrt-ramips-mt7621-kt_km14-102h.manifest releases/$VERSION/km14/
cd releases/$VERSION/km14 && sha256sum * > sha256sums && cd -

# 7. تحقق من البصمات
cd releases/$VERSION/km14 && sha256sum -c sha256sums && cd -

# 8. حفظ في Git
git add releases/$VERSION/
git commit -m "release($VERSION): بناء صورة km14 موحدة"

# 9. تحديث CHANGELOG.md
```

---

## القسم الرابع: شروط الإغلاق الإلزامية (Definition of Done)

**لا يُعتبر أي إصلاح مكتملاً إلا إذا تحققت جميع الشروط التالية:**

- [ ] التعديل تم في `package/` وليس في `build_dir/`
- [ ] تم رفع `PKG_RELEASE` في Makefile
- [ ] `bash -n` نجح على كل السكربتات المعدلة
- [ ] `make package/<name>/compile V=s` نجح بدون أخطاء
- [ ] تم تثبيت الحزمة على الراوتر واختبارها
- [ ] تم إعادة تشغيل الراوتر والتحقق من استمرار العمل
- [ ] لا توجد أخطاء Runtime حرجة في `logread`
- [ ] تم عمل `git commit` برسالة واضحة
- [ ] تم تحديث التوثيق (CHANGELOG.md أو PACKAGE_FINISH_FIX_PLAN.md)

---

## القسم الخامس: قائمة الأخطاء القاتلة (ممنوع منعاً باتاً)

| # | الخطأ | لماذا قاتل؟ | ماذا تفعل بدلاً منه |
|---|-------|-------------|---------------------|
| 1 | التعديل داخل `build_dir/` | يختفي عند أي clean/rebuild | عدّل في `package/` فقط |
| 2 | نسخ `.config` قديم | يُلغي حزم وخيارات مضافة لاحقاً | استخدم `.config` الحالي + `make defconfig` |
| 3 | بناء بدون `git commit` | الكود يضيع ولا يمكن تتبعه | احفظ كل تعديل في Git فوراً |
| 4 | إرسال صورة بدون اختبار reboot | مشاكل الإقلاع لا تظهر إلا بعد restart | أعد تشغيل الراوتر واختبر كل مرة |
| 5 | تعديل `DEVICE_COMPAT_VERSION` | يمسح إعدادات المستخدم عند الترقية | لا تلمسه إلا بإذن صريح |
| 6 | تعديل `KERNEL_SIZE` | يسبب boot loop | لا تلمسه أبداً |
| 7 | إضافة ملفات في `/etc/dropbear/` | قد يعطل SSH | اختبر SSH بعد كل تعديل |
| 8 | العمل على فرعين بدون merge | إصلاحات فرع تختفي في الآخر | ادمج الفرع في main فوراً بعد الاختبار |
| 9 | بناء صورة كاملة لاختبار حزمة واحدة | مضيعة وقت وخطر regression | ابنِ الحزمة منفردة وثبّتها بـ opkg |
| 10 | نشر بدون تحديث `SHA256SUMS` | الترقية التلقائية تفشل | ولّد البصمات بعد كل نشر |

---

## القسم السادس: قائمة فحص سريعة (استخدمها قبل إرسال أي إصدار)

### قبل إرسال حزمة ipk
```
□ التعديل في package/ وليس build_dir/
□ PKG_RELEASE مرفوع
□ bash -n على كل السكربتات
□ make package/<name>/compile نجح
□ git commit تم
□ اختبار على الراوتر نجح
□ اختبار بعد reboot نجح
```

### قبل إرسال صورة نظام كاملة
```
□ كل الفحوصات أعلاه لكل حزمة معدلة
□ git status نظيف (لا ملفات معلقة)
□ .config لم يُنسخ من ملف قديم
□ make defconfig تم تشغيله
□ الصورة تم بناؤها بنجاح
□ sha256sums تم توليدها
□ الصورة تم أرشفتها في releases/
□ CHANGELOG.md تم تحديثه
□ اختبار fresh flash نجح (إذا أمكن)
□ اختبار sysupgrade نجح
□ SSH يعمل بعد التثبيت
□ DHCP يوزع IP بعد التثبيت
□ الهوتسبوت يعمل (إذا كان مفعلاً)
□ logread نظيف من أخطاء حرجة
```

---

## القسم السابع: أوامر مرجعية سريعة

```bash
# === Git ===
git status                          # حالة الملفات
git diff                            # ما الذي تغير؟
git add package/<name>/             # إضافة التعديلات
git commit -m "fix(<name>): ..."    # حفظ التعديل
git log --oneline -10               # آخر 10 commits
git checkout main                   # العودة للفرع الرئيسي
git merge fix/<branch>              # دمج فرع الإصلاح

# === البناء ===
make package/<name>/compile V=s     # بناء حزمة واحدة
make package/<name>/clean           # تنظيف حزمة واحدة
make -j$(nproc) V=s                 # بناء صورة كاملة
make defconfig                      # تحديث .config

# === الاختبار ===
bash -n <script.sh>                 # فحص syntax للسكربت
scp <file> root@192.168.1.20:/tmp/  # رفع ملف للراوتر
ssh root@192.168.1.20 "..."         # تنفيذ أمر على الراوتر
curl -I http://192.168.1.20/...     # فحص صفحة ويب

# === الأرشفة ===
sha256sum * > sha256sums            # توليد بصمات
sha256sum -c sha256sums             # التحقق من البصمات
```

---

> **تذكّر دائماً**: الهدف ليس السرعة، بل الثبات. إصلاح واحد مكتمل ومختبر أفضل من 10 إصلاحات سريعة تكسر بعضها.
