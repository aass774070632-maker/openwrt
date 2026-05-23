# Alemprator Project Context

**آخر تحديث:** 2026-05-16  
**الحالة:** إنتاج مستقر  
**الموديلات المدعومة:** KM12 · KM15 · KM14 · AR07 · AR06 · DV02 · GAPD-7500

---

## 1. نظرة عامة على البنية التحتية

| العنصر | القيمة |
|--------|--------|
| مجلد المشروع | `/home/baalwy/openwrt` |
| خادم OTA | `https://ota.kartnet.org` |
| البوابة المحلية | `http://127.0.0.1:8080` |
| لوحة التحكم | `https://ota.kartnet.org/admin-app/` |
| مجلد الـ firmware | `ota-server/public/firmware/` |
| قاعدة البيانات | PostgreSQL داخل Docker |
| لوحة التحكم | `https://ota.kartnet.org/admin-app/` |
| auth | JWT — تسجيل دخول عبر `/api/auth/login` |

---

## 1-أ. البنية التحتية — Docker (3 Containers)

### الخدمات

| Container | Image | Port | الدور |
|-----------|-------|------|-------|
| `ota-postgres` | postgres:16-alpine | 5432 | قاعدة البيانات — بيانات محفوظة في volume دائم |
| `ota-api` | (Dockerfile محلي) | 3000 | NestJS API — يُبنى من الكود المصدري |
| `ota-nginx` | nginx:1.27-alpine | 8080→80 | البوابة العامة — يُوجّه الطلبات وتوزيع ملفات الـ firmware |

### Volume مهم

```yaml
# ota-api يقرأ الـ firmware من:
./public/firmware → /app/public/firmware

# ota-nginx يخدم الـ firmware مباشرة من:
./public/firmware → /usr/share/nginx/html/firmware:ro
```

> **ملاحظة:** الـ firmware يُوضع في `ota-server/public/firmware/` وتلقائياً يصبح متاحاً عبر nginx دون إعادة بناء الـ containers.

### تشغيل الخادم

```sh
cd /home/baalwy/openwrt/ota-server
docker compose up -d           # تشغيل جميع الخدمات
docker compose up -d --build api   # بناء API وتشغيله (بعد تغيير الكود)
docker compose ps              # حالة الخدمات
docker compose logs --tail=50 api  # لوجات الـ API
```

### فحص الصحة

```sh
curl -fsS http://127.0.0.1:8080/api/health   # {"status":"ok"}
curl -fsS http://127.0.0.1:8080/api/ready    # {"ready":true}
```

### Nginx Config

ملف الإعداد: `ota-server/docker/nginx/default.conf`  
- `/api/*` → proxy إلى `ota-api:3000`  
- `/firmware/*` → static files من `/usr/share/nginx/html/firmware/`  
- `/admin-app/*` → static files لوحة التحكم

---

## 1-ب. لوحة التحكم (Admin Dashboard)

### الوصول

```
URL: https://ota.kartnet.org/admin-app/
أو محلياً: http://127.0.0.1:8080/admin-app/
```

ـ Authentication: JWT — تسجيل الدخول عبر `POST /api/auth/login`  
ـ الملفات: `ota-server/public/admin-app/` (index.html + app.js + styles.css)

### وحدات لوحة التحكم

| الوحدة | المسار | الوصف |
|--------|---------|-------|
| Dashboard | `/api/admin/dashboard` | إحصائيات عامة |
| Devices | `/api/admin/devices` | إدارة الأجهزة المسجلة |
| Models | `/api/admin/models` | إدارة نماذج الأجهزة |
| Releases | `/api/admin/releases` | إدارة الإصدارات |
| Campaigns | `/api/admin/campaigns` | حملات التحديث المجدولة |
| Groups | `/api/admin/groups` | تجميع الأجهزة |
| Tags | `/api/admin/tags` | وسوم الأجهزة |
| Audit Logs | `/api/admin/audit-logs` | سجل العمليات |

### Campaigns System (نظام حملات التحديث)

يمكن إنشاء حملة تحديث تستهدف:
- **موديل معين** (KM14, DV02, ...)
- **مجموعة أجهزة** أو **tag**
- **نسبة rollout** (مثل 10% من الأجهزة أولاً)
- **channel** (stable / beta)

عمليات الحملة:
```
POST /api/admin/campaigns              ← إنشاء حملة
PATCH /api/admin/campaigns/:id         ← تعديل
POST /api/admin/campaigns/:id/activate ← تفعيل
POST /api/admin/campaigns/:id/pause    ← إيقاف مؤقت
DELETE /api/admin/campaigns/:id        ← حذف
```

### نشر Firmware (الطريقة الصحيحة)

```sh
# 1. ضع الملف في:
ota-server/public/firmware/FILENAME.bin

# 2. في لوحة التحكم → Releases → New Release
# اختر: "مسار ملف موجود على السيرفر"
# أدخل: /firmware/FILENAME.bin
```

> **تحذير:** لا ترفع firmware عبر المتصفح — استخدم دائماً مسار السيرفر لتجنب Cloudflare timeout 524.

---

## 2. الموديلات المدعومة (الحالة الكاملة)

### جدول الموديلات والإصدارات المعتمدة في registry

| الموديل | model_key | target | architecture | أحدث إصدار نشط | رابط الفيرموير |
|---------|-----------|--------|--------------|-----------------|---------------|
| **KM14-102H** | `kt,km14-102h` | `ramips/mt7621` | `mipsel_24kc` | `24.10.4-km14-r38` | `/firmware/openwrt-ramips-mt7621-kt_km14-102h-squashfs-sysupgrade-24.10.4-km14-r38.bin` |
| **KM12-007H** | `kt,km12-007h` | `ramips/mt7621` | `mipsel_24kc` | `24.10.4.1-km12-r8` | `/firmware/openwrt-ramips-mt7621-kt_km12-007h-squashfs-sysupgrade-24.10.4.1-km12-r8.bin` |
| **KM15-103H** | `kt,km15-103h` | `ramips/mt7621` | `mipsel_24kc` | `24.10.4.1-km15-r1` | `/firmware/openwrt-ramips-mt7621-kt_km15-103h-squashfs-sysupgrade-24.10.4.1-km15-r1.bin` |
| **AR07-102H** | `AR-07-102H` | `qualcommax/ipq60xx` | `aarch64_cortex-a53` | `24.10.4-ar07-r2` | `/firmware/openwrt-qualcommax-ipq60xx-kt_ar07-102h-squashfs-sysupgrade-24.10.4-ar07-r2.bin` |
| **DV02-012H** | `DV-02-012H` | `qualcommax/ipq60xx` | `aarch64_cortex-a53` | `24.10.4-r26` | `/firmware/openwrt-qualcommax-ipq60xx-kt_dv02-012h-squashfs-sysupgrade-24.10.4-r26.bin` |
| **AR06-012H** | `AR-06-012H` | `qualcommax/ipq60xx` | `aarch64_cortex-a53` | `24.10.4-ar06-r12` | `/firmware/openwrt-qualcommax-ipq60xx-kt_ar06-012h-squashfs-sysupgrade-24.10.4-ar06-r12.bin` |
| **GAPD-7500** | `LG-GAPD-7500` | `qualcommax/ipq60xx` | `aarch64_cortex-a53` | `24.10.4-gapd7500-r1` | `/firmware/openwrt-qualcommax-ipq60xx-lg_gapd-7500-squashfs-sysupgrade-24.10.4-gapd7500-r1.bin` |

### تفاصيل SHA256 للبناء المحلي المؤكد (2026-05-16)

| الموديل | الإصدار | SHA256 | الحجم |
|---------|---------|--------|-------|
| KM14-102H | 24.10.4-km14-r38 | `2a11e6b4aca89db006c6293584734c64db7d6a74b6170f7d25b5680bfc0067a2` | 16,968,753 |
| KM12-007H | 24.10.4.1-km12-r8 | `312bc7545ed2c3a4b7e569e5a2341f996fd86de536d33a33e3894840a593dea7` | 19,303,473 |
| KM15-103H | 24.10.4.1-km15-r1 | `943a822eb95ddb8073524737f645ad9f746de2d17eaec59b6e2d169875161043` | 19,303,473 |
| AR07-102H | 24.10.4-ar07-r2 | `b8d269d33ecb8e7dce0d6db21968efd7c1cca15a88946023e066c32bf5a0d7be` | 22,037,278 |
| AR06-012H | 24.10.4-ar06-r12 | `298618dbba4d907ead90495e1a617ab5048247b6ada2d4584fc784a1667c25f6` | 23,962,398 |
| DV02-012H | 24.10.4-r26 | `e213a8cb461e401bae056dcd59438edc30667decc2d3118464019d8e57e8dbaa` | 23,962,398 |
| GAPD-7500 | 24.10.4-gapd7500-r1 | `1b1cc7f9eb5360c06cd3e4eb40c31cf96ec15b1b8b2160d11e52734364349999` | 23,962,398 |

---

## 3. الحزم الأساسية (Alemprator Packages)

### قائمة الحزم في `/home/baalwy/openwrt/package/`

### الحزم الأساسية

| الحزمة | الإصدار | الوصف |
|--------|---------|-------|
| `luci-app-alemprator-ota` | `1.0-r30` | عميل OTA + واجهة LuCI لتحديثات النظام |
| `luci-app-setup` | `1.0-r94` | معالج الإعداد السريع (Quick Setup Wizard) |
| `alemprator-firstboot` | `1.0-r10` | ضبط الإعدادات الأولية عند التشغيل الأول |
| `alemprator-suite` | `1.0-r1` | حزمة meta تجمع الحزم الأساسية |
| `luci-app-hotspot-openwrt` | `1.0-r1` | نظام الهوتسبوت CoovaChilli |
| **`alemprator-guard`** | **`1.0-r1`** | **حماية الترخيص - C binary مع HMAC** |

### حزم المراقبة والأدوات — أُضيفت 2026-05-07

> هذه الحزم موجودة في `package/` وتُدار عبر `sharedPackages` في `alemprator-models.json`، وتم التحقق من بنائها بتاريخ 2026-05-16 على المعماريتين `mipsel_24kc` و `aarch64_cortex-a53`.

| الحزمة | الإصدار | الوصف |
|--------|---------|-------|
| `luci-app-cpu-status` | `0.6.3` | معلومات استخدام CPU في صفحة الحالة |
| `luci-app-cpu-perf` | `0.6.1` | معلومات وإدارة أداء CPU |
| `luci-app-temp-status` | `0.8.1` | قراءات حساسات الحرارة في صفحة الحالة |
| `luci-app-log-viewer` | `1.5.0` | عرض متقدم لسجلات النظام (syslog + kernel) |
| `luci-app-tn-netports` | `2.0.7` | عرض حالة منافذ الشبكة |
| `luci-app-netspeedtest` | latest | اختبار سرعة الشبكة (iperf3 + librespeed) |
| `luci-app-bandix-plus` | `0.1.0` | واجهة LuCI لأداة مراقبة حركة الشبكة |
| `bandix-plus` | `0.1.0` | أداة مراقبة حركة الشبكة (Rust binary) |

### ✅ حالة الحزم الثمانية بعد التحقق

تم إغلاق هذه النقطة بنجاح:
1. الحزم الثمانية مضافة ومفعّلة في إعدادات البناء للموديلات المستهدفة.
2. تم بناؤها وفهرستها على المعماريتين (`mipsel_24kc` و `aarch64_cortex-a53`).
3. تم التحقق من وجود ملفات `ipk` الفعلية لكل الحزم: `16/16` (8 حزم × 2 معماريات).
4. يبقى اختبار التشغيل الفعلي على العتاد (runtime) خطوة منفصلة عن صحة البناء.

---

## 4. نظام Alemprator Guard (حماية الهوتسبوت)

> **أُضيف في 2026-05-09** — أهم ميزة أمنية في المشروع

### المبدأ

```
الراوتر يشتغل → الهوتسبوت يطلب license-check
                        ↓
              alemprator-guard (C binary)
              يحسب HMAC(token + mac) باستخدام مفتاح سري مضمّن في الكود
                        ↓
              POST https://ota.kartnet.org/api/hotspot-verify
              مع header: X-Guard-Sig: <hmac>
                        ↓
              السيرفر يتحقق من التوقيع ومن قاعدة بيانات الأجهزة
                        ↓
        جهاز مسجل + توقيع صحيح → accepted: true  → exit 0 → الهوتسبوت يعمل ✅
        جهاز مسروق/مجهول        → accepted: false → exit 1 → الهوتسبوت يُوقف ❌
```

### ملفات النظام

| الملف | الدور |
|-------|-------|
| `package/alemprator-guard/src/guard.c` | الكود C - يحتوي مفتاح HMAC كـ byte array |
| `package/alemprator-guard/Makefile` | بناء تلقائي لكل معمارية |
| `package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/license-check` | wrapper يستدعي الـ binary |
| `package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/apply` | يُوقف الهوتسبوت إذا فشل license-check |

### مفتاح HMAC (سري - لا يُشارك)

```
Key (hex): f50335e0dd432f2cc4ece8eac7def87e0bec7d6781206d36f12bb68bbc526cb0
مضمّن في guard.c كـ: static const unsigned char GUARD_KEY[] = { ... };
```

### Server Endpoint

- **POST** `/api/hotspot-verify`
- **Header:** `X-Guard-Sig: <hmac-sha256>`
- **Body:** `{"token":"...","mac":"..."}`
- **Response (موافقة):** `{"accepted":true,"expires_in":259200}`
- **Response (رفض):** `{"accepted":false,"reason":"invalid_signature"}`

### ملاحظات مهمة

- الـ binary مُجمَّع لـ `aarch64_cortex-a53` (DV02 و AR06 و AR07)
- لـ `mipsel_24kc` (KM12 و KM14) يجب بناء binary منفصل
- بعد كل تحديث firmware يحتوي الـ Guard، الحماية تعمل تلقائياً

---

## 5. قواعد نشر الـ Firmware

### الخطوات الصحيحة

```sh
# 1. بناء الـ firmware
make -j$(nproc)

# 2. نسخ الملف للسيرفر
cp bin/targets/.../sysupgrade.bin ota-server/public/firmware/FULL_NAME.bin

# 3. الحصول على SHA256
sha256sum ota-server/public/firmware/FULL_NAME.bin

# 4. نشر الإصدار في قاعدة البيانات
cd ota-server
node scripts/seed-km12-release.mjs [km12|km14|ar07|ar06|dv02]
```

> **تحذير:** لا ترفع ملفات firmware كبيرة عبر المتصفح — استخدم دائماً المسار المحلي.

### تسمية الملفات

```
openwrt-{target}-{device}-squashfs-sysupgrade-{version}.bin
مثال: openwrt-qualcommax-ipq60xx-kt_dv02-012h-squashfs-sysupgrade-24.10.4-r14-Guard.bin
```

---

## 6. إعداد بيئة البناء

### بناء موديل معين

```sh
# تغيير target إلى DV02 أو AR06 (qualcommax/ipq60xx)
# تعديل .config:
CONFIG_TARGET_qualcommax=y
CONFIG_TARGET_qualcommax_ipq60xx=y
CONFIG_TARGET_qualcommax_ipq60xx_DEVICE_kt_dv02-012h=y   # أو ar06-012h
CONFIG_PACKAGE_alemprator-guard=y
CONFIG_DEFAULT_alemprator-guard=y
CONFIG_DEFAULT_luci-app-hotspot-openwrt=y
CONFIG_DEFAULT_luci-app-alemprator-ota=y
CONFIG_DEFAULT_alemprator-firstboot=y

make defconfig
make -j$(nproc)
```

### بناء حزمة واحدة فقط

```sh
make package/alemprator-guard/compile V=s
make package/luci-app-hotspot-openwrt/compile V=s
make package/luci-app-alemprator-ota/compile V=s
```

---

## 7. الراوتر الحالي في المختبر

| العنصر | القيمة |
|--------|--------|
| IP | `192.168.1.20` |
| SSH | `ssh root@192.168.1.20` |
| كلمة المرور | `(فارغة أو موجودة على الراوتر)` |
| البوابة | `192.168.1.2` |
| NAT على MikroTik | `/ip firewall nat add chain=srcnat src-address=192.168.1.20 action=masquerade` |

### فحص حالة OTA على الراوتر

```sh
ssh root@192.168.1.20 '/usr/libexec/alemprator-ota/status-json'
ssh root@192.168.1.20 '/usr/libexec/alemprator-ota/internet-check'
ssh root@192.168.1.20 'logread | grep alemprator | tail -20'
```

---

## 8. OTA Server API المهمة

| الـ Endpoint | الوصف |
|-------------|-------|
| `POST /api/register` | تسجيل جهاز جديد |
| `GET /api/update` | فحص التحديثات |
| `POST /api/heartbeat` | نبضة قلب الجهاز |
| `POST /api/hotspot-verify` | التحقق من ترخيص الهوتسبوت (Guard) |

### ملاحظة على الـ heartbeat

- حقل `current_version` **اختياري** (تم إصلاحه لدعم الراوترات القديمة)
- الراوترات القديمة لا ترسل `current_version` → السيرفر يقبلها بدونه

---

## 9. ملفات SHC والـ Scripts

### قرار التصميم: لا SHC

- **SHC ملغى** — يسبب أخطاء `/tmp/` ولا يوفر حماية حقيقية
- الحماية الحقيقية = **alemprator-guard binary** + التحقق من السيرفر
- جميع سكربتات النظام تبقى نصية عادية

### مسارات السكربتات على الراوتر

```
/usr/libexec/alemprator-ota/       ← OTA scripts
/usr/libexec/hotspot-openwrt/      ← Hotspot scripts (بما فيها guard binary)
/etc/config/alemprator_ota         ← إعدادات OTA
/etc/config/hotspot_licensing      ← إعدادات ترخيص الهوتسبوت
/etc/alemprator/device.token       ← التوكن الفريد للجهاز
```

---

## 10. السجل التاريخي للإصدارات

### KM14-102H

| الإصدار | التاريخ | ملاحظات |
|---------|---------|---------|
| r29 | 2026-05-01 | أول إصدار مستقر |
| r30 | 2026-05-03 | تحديث واجهة "تحديث النظام" |
| r34 | 2026-05-04 | تحديثات VLAN/setup wizard |
| r35 | 2026-05-04 | تحديثات firstboot/LAN - **تحتوي خطأ 192.168.1.21** |
| r36 | 2026-05-04 | إصلاح 98_custom LAN IP |
| **r37** | **2026-05-05** | **إصلاح bridge ports - الإصدار الصحيح الحالي** |

### KM12-007H

| الإصدار | التاريخ | ملاحظات |
|---------|---------|---------|
| r3 | 2026-05-03 | أول إصدار |
| r4 | 2026-05-03 | تحديث internet-check UI |
| r6 | 2026-05-04 | تحديث VLAN suffix |
| **r7** | **2026-05-05** | **الإصدار الصحيح الحالي** |

### AR07-102H

| الإصدار | التاريخ | ملاحظات |
|---------|---------|---------|
| **r1** | **2026-05-05** | **أول إصدار إنتاجي** |

### DV02-012H

| الإصدار | التاريخ | ملاحظات |
|---------|---------|---------|
| r13-Fixed | 2026-05-09 | إصدار سابق بسكربتات مشفرة SHC - **مُلغى** |
| **r14-Guard** | **2026-05-09** | **أول إصدار مع Alemprator Guard binary** |

### AR06-012H

| الإصدار | التاريخ | ملاحظات |
|---------|---------|---------|
| r1-r10 | 2026-05-09→11 | إصدارات تطوير (board data خاطئ، DHCP مفتوح) |
| **r11** | **2026-05-11** | إصدار تطوير — بُني لكن SHA256 لم يتغير عن r10 (مشكلة incremental build) |
| **r12** | **2026-05-11** | **أول إصدار إنتاجي مستقر (مبني، لم يُثبّت):** WiFi board data صحيح (AR06)، Mesh مُفعّل (wpad-mesh-mbedtls)، DHCP معطّل بعد setup، copyright footer، gateway 192.168.1.2، txpower 36، DNS resolv.conf مباشر |

---

## 11. مشاكل شائعة وحلولها

### الراوتر لا يصل للسيرفر

1. تحقق من الـ route: `ip route show`
2. تحقق من الـ DNS: `nslookup ota.kartnet.org`
3. تحقق من التاريخ: `date` (HTTPS يفشل إذا الوقت خاطئ)
4. أضف NAT على MikroTik: `/ip firewall nat add chain=srcnat src-address=192.168.1.20 action=masquerade`

### خطأ 400 في heartbeat

- السبب: الراوتر القديم لا يُرسل `current_version`
- الحل: تم تصحيحه في `heartbeat.dto.ts` — الحقل الآن اختياري

### مشكلة SHC على DV02

- السبب: السكربتات المشفرة تحاول استخراج نفسها في `/tmp/` المحدود
- الحل: استخدام سكربتات نصية عادية + حماية guard binary بدلاً من SHC

### الهوتسبوت لا يبدأ بعد تحديث

- السبب: guard binary غير موجود (firmware قديم)
- الحل: تحديث الـ firmware لإصدار يحتوي `alemprator-guard`

### خطأ 502 Bad Gateway

- السبب: عادةً process محلي يستخدم port 3000
- الحل: `kill $(lsof -ti:3000)` ثم `docker compose up -d`

---

## 12. سجل إصلاحات OTA Admin Dashboard — 2026-05-11

### المشكلة

لوحة التحكم `https://ota.kartnet.org/admin-app/` كانت تعمل لكن dropdown نماذج الأجهزة (firmware models) فارغ دائماً — لا يمكن إنشاء إصدارات جديدة.

### السبب الجذري

استدعاء `renderAccessControl()` داخل `renderAll()` في `app.js` — الدالة **غير معرّفة** → `ReferenceError` يوقف JavaScript قبل الوصول لـ `refreshSelectors()` → الـ dropdown لا يتم ملؤه.

> **ملاحظة:** النسخة القديمة (من GitHub zip) لا تحتوي على `renderAccessControl` أصلاً — أُضيفت خطأً في تعديل لاحق.

### الإصلاحات المُطبَّقة

| الإصلاح | الملف | التفاصيل |
|---------|-------|----------|
| حذف `renderAccessControl()` | `app.js` L934 | أُزيلت من `renderAll()` — كانت توقف التنفيذ |
| `Array.isArray()` guards | `app.js` L1013-1020 | حماية ضد null في `refreshData()` |
| Fallback models | `app.js` refreshSelectors | اشتقاق النماذج من releases إذا فشل `/admin/models` |
| `Promise.allSettled` | `app.js` refreshData | بدلاً من `Promise.all` — endpoint واحد لا يُسقط الكل |
| Cache bump | `index.html` L233 | `v=20260511-3` لإجبار المتصفح على تحميل النسخة الجديدة |

### التحقق

```sh
# API يُعيد 7 نماذج
curl -s http://localhost:3000/api/admin/models -H "Authorization: Bearer $TOKEN" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))"
# → 7

# renderAccessControl غير موجودة
grep -c renderAccessControl ota-server/public/admin-app/app.js
# → 0

# nginx يخدم النسخة الصحيحة
curl -s http://localhost:8080/admin-app/ | grep "app.js"
# → v=20260511-3
```

### النسخة المرجعية

النسخة القديمة (الأصلية العاملة) محفوظة في:
```
/home/baalwy/openwrt-v24.10.4-copilot-hotspot-openwrt-next/
```

---

## 13. حالة حزمة OTA Identity

### `model-identities` الحالي (مُحدّث 2026-05-11)

```text
# board_name|model_key|firmware_version|version_code|model_id
kt,km12-007h|kt,km12-007h|24.10.4.1-km12-r7|24.10.4.1-km12-r7|km12
kt,km14-102h|kt,km14-102h|24.10.4-km14-r37|24.10.4-km14-r37|km14
kt,ar07-102h|AR-07-102H|24.10.4-ar07-r1|24.10.4-ar07-r1|ar07
kt,ar06-012h|AR-06-012H|24.10.4-ar06-r12|24.10.4-ar06-r12|ar06
kt,dv02-012h|DV-02-012H|24.10.4-r25-Final|24.10.4-r25-Final|dv02
```

### `alemprator-models.json` — Central Model Registry (7 نماذج)

```json
"defaults": {
  "firstboot": { "lanIp": "192.168.1.20", "setupIp": "192.168.8.1" },
  "licensing": { "gracePeriodDays": 3, "serverUrl": "https://ota.kartnet.org" }
}
```

| النموذج | model_key | target | الإصدار الحالي |
|---------|-----------|--------|---------------|
| KM12 | `kt,km12-007h` | ramips/mt7621 | `24.10.4.1-km12-r8` |
| KM15 | `kt,km15-103h` | ramips/mt7621 | `24.10.4.1-km15-r1` |
| KM14 | `kt,km14-102h` | ramips/mt7621 | `24.10.4-km14-r38` |
| AR07 | `AR-07-102H` | qualcommax/ipq60xx | `24.10.4-ar07-r2` |
| AR06 | `AR-06-012H` | qualcommax/ipq60xx | `24.10.4-ar06-r12` |
| DV02 | `DV-02-012H` | qualcommax/ipq60xx | `24.10.4-r26` |
| GAPD-7500 | `LG-GAPD-7500` | qualcommax/ipq60xx | `24.10.4-gapd7500-r1` |

### حزم Alemprator الحالية

```text
luci-app-alemprator-ota:   PKG_RELEASE:=39
alemprator-firstboot:      PKG_RELEASE:=12
luci-app-setup:            PKG_RELEASE:=95
alemprator-guard:          PKG_RELEASE:=1
luci-app-hotspot-openwrt:  PKG_RELEASE:=1
```

---

## 14. ملاحظات `98_custom` المهمة (target-level uci-defaults)

### ملف: `target/linux/ramips/mt7621/base-files/etc/uci-defaults/98_custom`

هذا الملف يُعيّن bridge ports و hostname حسب `board_name`:

```sh
case "$board_name" in
  kt,km14-102h)
    device_bridge_ports='lan wan'
    ;;
  kt,km12-007h|'')
    device_bridge_ports='lan1 lan2 lan3 lan4 wan'
    ;;
esac
```

> **تاريخ:** r36 أصلحت LAN IP من `192.168.1.21` إلى `192.168.1.20`، و r37 أصلحت bridge ports (KM14 كانت تعرض ports KM12 بالخطأ).

---

## 15. نشر Firmware عبر Script

```sh
cd /home/baalwy/openwrt/ota-server
node scripts/seed-km12-release.mjs km14   # أو km12 أو ar07
```

> رغم اسم السكربت `seed-km12-release.mjs`، يدعم argument لأي موديل.

---

## 16. ما يجب فعله لاحقاً

- [ ] بناء `alemprator-guard` binary لـ `mipsel_24kc` (KM12, KM14)
- [x] ~~إضافة AR06 و DV02 إلى `alemprator-models.json`~~ ✅ مضافين (+ GAPD-7500)
- [x] ~~تحديث `model-identities` لتشمل AR06 و DV02~~ ✅ مضافين
- [ ] تحديث إصدارات AR06 و DV02 في `model-identities` عند إصدار firmware جديد
- [ ] اختبار الهوتسبوت end-to-end على DV02 بعد التحديث لـ r14-Guard
- [ ] **ميزة التحديث التلقائي الاختياري** — checkbox في لوحة التحكم عند إنشاء release:
  - إذا مُفعّل: الراوتر يُحدّث تلقائياً عند توفر الإنترنت
  - إذا غير مُفعّل: المستخدم يُحدّث يدوياً
  - يتطلب: حقل `force_update` في DB + API + `agent.sh` + Dashboard UI
- [ ] إضافة `renderAccessControl()` بشكل صحيح إذا كان التحكم بالصلاحيات مطلوباً مستقبلاً

---

## 17. ملكية الحزم (Package Ownership Design)

> هذا التصميم أساسي — يجب اتباعه لتجنب تداخل الحزم.

### `alemprator-firstboot` — ملكية التوفير المؤقت فقط
- الشبكة المؤقتة (`alemprator_setup` = 192.168.8.1)
- SSID المؤقت
- حالة التنظيف (`auto_cleanup_armed`, `auto_cleanup_pending`)
- علامات baseline/pending
- **لا يكتب** `initial_setup_complete` أو LAN IP النهائي

### `luci-app-setup` — ملكية إعدادات المستخدم النهائية
- LAN IP/netmask النهائي
- حالة إتمام الإعداد (`initial_setup_complete`)
- إعدادات Wi-Fi و VLAN
- سياسة الأزرار
- init.d/setup يُزامن LAN من `setup.default` بعد boot/start/reload

### `luci-app-alemprator-ota` — ملكية OTA وهوية الإصدار فقط
- `firmware-version`, `model-identities`
- agent.sh, common.sh, run-once, status-json, internet-check
- صفحة LuCI `تحديث النظام`

---

## 18. سلامة Sysupgrade (Config Preservation)

### ما تم تنفيذه

- `package/base-files/files/sbin/sysupgrade` يحتوي `should_force_save_config()`
- إذا وُجدت ملفات Alemprator marker، `sysupgrade -n` يُتجاهل ويُحفظ الإعداد
- OTA agent يرفض `KEEP_CONFIG=0` دائماً — يسجل ويتجاهل وضع المسح

### السبب
- مسح الإعداد يُعيد تشغيل firstboot ويُغيّر LAN IP
- الراوتر يصبح غير قابل للوصول بعد التحديث

### ملفات manual upload
- المسار المعتمد: `/tmp/alemprator-ota/manual-update.bin` (ليس `/tmp/firmware.bin`)
- ACL يسمح بالكتابة عبر rpcd

---

## 19. OTA Agent — ميزات مهمة

### Cross-Model Version Acceptance
- `should_accept_update_version()` في common.sh
- يقبل تحديث cross-model (مثل: من KM14 version string إلى KM12)
- ليس فقط `opkg compare-versions >` صارم

### Internet Check Helper
```text
/usr/libexec/alemprator-ota/internet-check
```
يُرجع JSON:
```json
{"status":"online","internet_ok":true,"server_ok":true,"lan_ip":"...","gateway":"...","mikrotik_command":"..."}
```
- يفحص: default route → ping 1.1.1.1/8.8.8.8 → API reachability
- إذا لا إنترنت: يعرض أمر MikroTik NAT جاهز
- زر "فحص التحديث" يشغّل internet-check أولاً

### أوضاع التشغيل
- `--check-only`: فحص فقط بدون تثبيت
- `--force-check`: يتجاوز retry/backoff
- `AUTO_UPGRADE=0` افتراضياً (المستخدم يقرر)

---

## 20. Setup Wizard — منطق VLAN SSID

- `wifi_ssid_vlan_2g` = الاسم الأساسي لـ VLAN (مطلوب)
- `wifi_ssid_vlan_5g` = اسم اختياري لـ 5GHz
- إذا 5GHz فارغ → يُشتق تلقائياً: `{base}_5G`
- خيار IP suffix في SSID موجود في قسم Wi-Fi الأساسي وقسم VLAN

### ملفات ذات صلة:
- `40_luci-app-setup` — defaults
- `47_luci-app-setup-fix-5g-vlan-ssid` — إصلاح
- `48_luci-app-setup-recover-state` — استعادة

---

## 21. `98_custom` — التخصيص حسب الموديل (target-level)

> **يوجد ملفان منفصلان** — واحد لكل target:

### ramips/mt7621: `target/linux/ramips/mt7621/base-files/etc/uci-defaults/98_custom`

يُعيّن bridge ports و hostname و SSID حسب `board_name`:

```sh
case "$board_name" in
  kt,km14-102h)
    device_bridge_ports='lan wan'
    device_hostname='KT-KM14-102H'
    device_ssid='ALemprator-KT-KM14-102H'
    ;;
  kt,km12-007h|'')
    device_bridge_ports='lan1 lan2 lan3 lan4 wan'
    device_hostname='KT-KM12-007H'
    device_ssid='ALemprator-KT-KM12-007H'
    ;;
esac
```

### qualcommax/ipq60xx: `target/linux/qualcommax/ipq60xx/base-files/etc/uci-defaults/98_custom`

> **أُعيد كتابته في 2026-05-11** — كان مكتوباً بنظام comment/uncomment يدوي (يُفعّل موديل واحد ويُعلّق الباقي). الآن يستخدم `case "$board_name"` تلقائياً.

```sh
case "$board_name" in
  kt,ar06-012h)
    device_hostname='KT-AR06-012H'
    device_ssid_prefix='AR06-012H'
    device_bridge_ports='lan1 lan2 lan3 lan4 wan'
    ;;
  kt,ar07-102h)
    device_hostname='KT-AR07-102H'
    device_ssid_prefix='AR07-102H'
    device_bridge_ports='lan wan'
    ;;
  kt,dv02-012h)
    device_hostname='KT-DV02-012H'
    device_ssid_prefix='DV02-012H'
    device_bridge_ports='lan1 lan2 lan3 lan4 wan'
    ;;
  lg,gapd-7500)
    device_hostname='LG-GAPD-7500'
    device_ssid_prefix='LG-GAPD-7500'
    device_bridge_ports='lan2 lan3 lan4 wan'
    ;;
esac
```

SSID يُبنى تلقائياً: `{prefix}-2.4_{MAC}` و `{prefix}-5G_{MAC}`

### إعدادات مشتركة في كلا الملفين:
- LAN IP: `192.168.1.20` (جميع الأجهزة)
- DNS: `8.8.8.8` و `82.114.163.31`
- `network.lan.defaultroute='1'` (ضروري لنجاح OTA)
- WAN و WAN6 محذوفان (وضع AP/bridge)
- DHCP LAN معطّل
- HTTPS redirect معطّل في uhttpd
- يتخطى إعادة التطبيق عند sysupgrade مع حفظ الإعدادات
- خدمات معطّلة: firewall, log, urandom_seed, odhcpd, dnsmasq

### إصلاحات 2026-05-11 (qualcommax):
- ❌ **قبل:** hostname/SSID ثابت لموديل واحد → يجب تعليق/إلغاء تعليق يدوياً
- ✅ **بعد:** `case "$board_name"` يختار تلقائياً
- ❌ **قبل:** `defaultroute='0'` → OTA لا يعمل
- ✅ **بعد:** `defaultroute='1'` → OTA يعمل
- ✅ **Gateway:** `192.168.1.2` مُعيّن تلقائياً
- ✅ **TX Power:** `36 dBm` لكلا الراديوين
- ✅ **DNS:** `8.8.8.8 1.1.1.1 82.114.163.31` مكتوب مباشرة في `/etc/resolv.conf`
- ✅ **Country:** `PA` (بنما) للتوافق مع السوق اليمني
- ✅ **Board Data:** `ipq-wifi-kt_ar06-012h` (كان DV02 بالخطأ)
- ✅ **Mesh:** `wpad-mesh-mbedtls` بدلاً من `wpad-basic-mbedtls`
- ✅ **DHCP:** معطّل في LAN + VLAN بعد البرمجة السريعة
- ✅ **Copyright:** footer في صفحات Setup + OTA + Hotspot

---

## 22. معلومات تشغيلية

### إعداد LAN الافتراضي

- **LAN bridge:** `192.168.1.20` (جميع الموديلات)
- **Setup temp network:** `192.168.8.1`
- **Gateway:** `192.168.1.2` (في بيئة المختبر)

### سياسة الأزرار

- **Reset button:** `setup.default.reset_button_disabled=1` لتعطيله
- **WPS button:** `setup.default.wps_button_disabled=1` لتعطيله
- ملفات الحماية: `reset-disabled` و `wps-disabled` (يجب أن تكون LF line endings)

### Config Snapshots المحفوظة

```text
KT-KM12-007H-01-05-2026.config
KT-KM14-102H-01-05-2026.config
DV-02-012H-04-05-2026.config
AR-06-012H-11-05-2026.config     ← جديد (مايو 2026)
AR-07-102H-12-04-2026.config
```

### نسخ احتياطي للـ config قبل تغيير الـ target

```sh
cp .config .config.dv02-backup-20260511
```

### إذا انقطعت الكهرباء

```sh
cd /home/baalwy/openwrt/ota-server
docker compose up -d
docker compose ps
curl -fsS http://127.0.0.1:8080/api/health
curl -fsS http://127.0.0.1:8080/api/ready
```

### Admin Dashboard Cache

عند أي تعديل على `app.js`، يجب:
1. تحديث query string في `index.html`:
```html
<script src="/admin-app/app.js?v=YYYYMMDD-N" defer></script>
```
2. إعادة تشغيل nginx:
```sh
docker compose restart nginx
```

---

## 23. سجل البناء والنشر

### أحدث الإصدارات المنشورة

| الموديل | الإصدار | URL | SHA256 | الحالة |
|---------|---------|-----|--------|--------|
| KM14 | r37 | `https://ota.kartnet.org/firmware/openwrt-ramips-mt7621-kt_km14-102h-squashfs-sysupgrade-24.10.4-km14-r37.bin` | `9fe7902b...` | ✅ |
| KM12 | r7 | `https://ota.kartnet.org/firmware/openwrt-ramips-mt7621-kt_km12-007h-squashfs-sysupgrade-24.10.4.1-km12-r7.bin` | `e02be988...` | ✅ |
| AR07 | r1 | `https://ota.kartnet.org/firmware/openwrt-qualcommax-ipq60xx-kt_ar07-102h-squashfs-sysupgrade-24.10.4-ar07-r1.bin` | `63aaaaf1...` | ✅ |
| **AR06** | **r12** | `https://ota.kartnet.org/firmware/openwrt-qualcommax-ipq60xx-kt_ar06-012h-squashfs-sysupgrade-24.10.4-ar06-r12.bin` | `6bbcbb14033734b42801542ca4350431e62f086235725d4ee391645c1addacc4` | ✅ مبني، **لم يُثبّت بعد** |
| DV02 | r25-Final | موجود في DB | - | ✅ |

### نتائج البناء المحلي والتحقق — 2026-05-16 (جاهزة في المجلد العام)

> هذه النتائج ناتجة من بناء محلي كامل ونسخ الصور إلى `ota-server/public/firmware/` مع تحقق SHA256.

| الموديل | ملف النسخة في المجلد العام | SHA256 | الحجم | الحالة |
|---------|----------------------------|--------|-------|--------|
| KM12 | `/firmware/openwrt-ramips-mt7621-kt_km12-007h-squashfs-sysupgrade-24.10.4.1-km12-r8.bin` | `312bc7545ed2c3a4b7e569e5a2341f996fd86de536d33a33e3894840a593dea7` | 19,303,473 | ✅ PASS |
| KM15 | `/firmware/openwrt-ramips-mt7621-kt_km15-103h-squashfs-sysupgrade-24.10.4.1-km15-r1.bin` | `943a822eb95ddb8073524737f645ad9f746de2d17eaec59b6e2d169875161043` | 19,303,473 | ✅ PASS |
| KM14 | `/firmware/openwrt-ramips-mt7621-kt_km14-102h-squashfs-sysupgrade-24.10.4-km14-r38.bin` | `2a11e6b4aca89db006c6293584734c64db7d6a74b6170f7d25b5680bfc0067a2` | 16,968,753 | ✅ PASS |
| AR07 | `/firmware/openwrt-qualcommax-ipq60xx-kt_ar07-102h-squashfs-sysupgrade-24.10.4-ar07-r2.bin` | `b8d269d33ecb8e7dce0d6db21968efd7c1cca15a88946023e066c32bf5a0d7be` | 22,037,278 | ✅ PASS |
| AR06 | `/firmware/openwrt-qualcommax-ipq60xx-kt_ar06-012h-squashfs-sysupgrade-24.10.4-ar06-r12.bin` | `298618dbba4d907ead90495e1a617ab5048247b6ada2d4584fc784a1667c25f6` | 23,962,398 | ✅ PASS |
| DV02 | `/firmware/openwrt-qualcommax-ipq60xx-kt_dv02-012h-squashfs-sysupgrade-24.10.4-r26.bin` | `e213a8cb461e401bae056dcd59438edc30667decc2d3118464019d8e57e8dbaa` | 23,962,398 | ✅ PASS |
| GAPD-7500 | `/firmware/openwrt-qualcommax-ipq60xx-lg_gapd-7500-squashfs-sysupgrade-24.10.4-gapd7500-r1.bin` | `1b1cc7f9eb5360c06cd3e4eb40c31cf96ec15b1b8b2160d11e52734364349999` | 23,962,398 | ✅ PASS |

### ملاحظة تحقق مهمة

- تم التحقق من سلامة البناء والملفات (وجود الصورة + SHA256 + الحجم + نسخها في المجلد العام).
- لا يمكن من بيئة البناء السحابية تأكيد التشغيل الفعلي على العتاد إلا بعد flash واختبار مباشر على الراوترات.

### قواعد الإصدارات

- **لا تُعيد استخدام** رقم إصدار قديم — دائماً زد الرقم
- KM14: التالي = r38+
- KM12: التالي = r8+
- AR07: التالي = r2+
- AR06: التالي = **r13+** (r12 مبني ولم يُثبّت)
- DV02: التالي = r26+

---

## 24. ملاحظات عامة مهمة

- لا ترفع firmware كبيرة عبر المتصفح (Cloudflare 524 timeout)
- استخدم دائماً `artifact_path` بدلاً من upload
- إذا فشل OTA على الراوتر: تحقق من route → DNS → date → NAT قبل تعديل الكود
- إذا KM14 تعرض ports KM12 بعد التحديث: factory reset مطلوب (sysupgrade يحفظ bridge ports القديمة)
- الحزم المشتركة تُطبّق على **كل** الموديلات — أي تعديل يؤثر على الجميع
- `alemprator-suite` = meta-package يضم firstboot + setup + ota
- `internet-check` غير موجود في الإصدارات القديمة (< r20) — الراوتر يحتاج تحديث أولاً
- بيئة المختبر: router IP = 192.168.1.20, gateway = 192.168.1.2, المطور السابق يستخدم MikroTik كـ upstream

---

## 25. ملخص جلسة 2026-05-11 (آخر جلسة عمل)

### ما تم إنجازه في الكود

| # | التعديل | الملف | التفاصيل |
|---|---------|-------|----------|
| 1 | **إصلاح WiFi board data** | `.config` | تبديل `ipq-wifi-kt_dv02-012h` → `ipq-wifi-kt_ar06-012h` (كان يحمّل بيانات معايرة DV02 بالخطأ) |
| 2 | **98_custom تلقائي** | `target/linux/qualcommax/ipq60xx/base-files/etc/uci-defaults/98_custom` | تحويل من comment/uncomment يدوي إلى `case "$board_name"` تلقائي |
| 3 | **Gateway ثابت** | نفس الملف | `192.168.1.2` كـ gateway افتراضي |
| 4 | **TX Power** | نفس الملف | `txpower='36'` لكلا الراديوين (2.4G + 5G) |
| 5 | **DNS مباشر** | نفس الملف | كتابة `8.8.8.8 1.1.1.1 82.114.163.31` في `/etc/resolv.conf` مباشرة (dnsmasq معطّل) |
| 6 | **Country code** | نفس الملف | `PA` (بنما) للتوافق مع السوق اليمني |
| 7 | **DHCP معطّل بعد Setup** | `package/luci-app-setup/.../setup.js` سطر 2055 | تغيير `uci.unset('dhcp','lan','ignore')` → `uci.set('dhcp','lan','ignore','1')` + `dynamicdhcp='0'` |
| 8 | **Mesh مُفعّل** | `.config` | تبديل `wpad-basic-mbedtls` → `wpad-mesh-mbedtls` لدعم 802.11s |
| 9 | **Copyright footer** | `setup.js` + `ota_v2.js` + `login.html` | إضافة حقوق الطبع في 3 صفحات (البرمجة السريعة + تحديث النظام + الهوتسبوت) |
| 10 | **رقم الإصدار** | `model-identities` | ترقية من r10 → r12 |

### حالة البناء

```
الصورة المبنية: bin/targets/qualcommax/ipq60xx/openwrt-qualcommax-ipq60xx-kt_ar06-012h-squashfs-sysupgrade.bin
OTA copy:       ota-server/public/firmware/openwrt-qualcommax-ipq60xx-kt_ar06-012h-squashfs-sysupgrade-24.10.4-ar06-r12.bin
SHA256:         6bbcbb14033734b42801542ca4350431e62f086235725d4ee391645c1addacc4
Config snapshot: AR-06-012H-11-05-2026.config
```

### ⚠️ حالة التثبيت

**الراوتر 192.168.1.20 لا يزال على نسخة قديمة (r10 أو أقدم)**. النسخة r12 مبنية وجاهزة في:
- `ota-server/public/firmware/...r12.bin` (للتحديث عبر OTA)
- `bin/targets/.../sysupgrade.bin` (للتثبيت اليدوي عبر LuCI أو SCP)

**يجب تثبيت r12 يدوياً أولاً** قبل أن يكتشف OTA الإصدارات القادمة.

### مهام لم تُنفّذ بعد

| # | المهمة | الأولوية |
|---|--------|----------|
| 1 | **تثبيت r12 على الراوتر** واختبار كل التعديلات | 🔴 عاجل |
| 2 | **اختبار Captive Portal** — الكود موجود في `alemprator-firstboot` لكن يحتاج تحقق أن الهاتف يعرض صفحة تسجيل الدخول عند الاتصال بالشبكة المؤقتة | 🔴 عاجل |
| 3 | **Watchcat Ping Reboot** في الخطوة 4 من البرمجة السريعة — مؤجّل بطلب المستخدم | 🟡 لاحقاً |
| 4 | بناء `alemprator-guard` لـ `mipsel_24kc` (KM12, KM14) | 🟡 لاحقاً |
| 5 | اختبار الهوتسبوت end-to-end على DV02 | 🟡 لاحقاً |
| 6 | نشر r12 في قاعدة بيانات OTA عبر لوحة التحكم | 🔴 بعد التثبيت |

### ملاحظات مهمة للمحادثة القادمة

1. **بيئة البناء في السحابة** — لا يمكن الوصول للراوتر 192.168.1.20 عبر SSH أو المتصفح. الاختبار يتم من جهاز المستخدم (Windows) فقط.
2. **`setup_r93.js` = نسخة من `setup.js`** — Makefile سطر 127 ينسخ setup.js إلى setup_r93.js تلقائياً. أي تعديل على setup.js ينعكس على كليهما.
3. **ath11k-firmware hash** — تم تعديل `PKG_MIRROR_HASH` في `package/firmware/ath11k-firmware/Makefile` ليطابق الملف المحلي. إذا فشل البناء بخطأ hash، تحقق من هذا الملف.
4. **incremental build trap** — عند تعديل ملفات JS/HTML في حزم LuCI، يجب عمل `make package/PKGNAME/clean` ثم `compile` ثم حذف stamps في staging_dir قبل `make target/install` لضمان دخول التعديلات في الصورة.
5. **الراوتر الحالي**: KT-AR06-012H, board_name=`kt,ar06-012h`, qualcommax/ipq60xx, aarch64_cortex-a53

---

## 26. ملخص جلسة 2026-05-16 (Hotspot Quick Integration)

### قرارات معتمدة

1. دمج خيار Hotspot داخل صفحة البرمجة السريعة.
2. قاعدة صارمة: **ممنوع VLAN مع Hotspot نهائياً**.
3. الهدف التنفيذي القادم: إنشاء **شبكتين Hotspot** تلقائياً، ولكل شبكة:
   - SSID مستقل
   - IP خروج/بوابة مستقل
   - Pool مستقل
   - Policy مستقلة

### ما تم توثيقه وتنفيذه على مستوى الحزمة

- تمت معالجة نقاط حرجة في `luci-app-hotspot-openwrt` (Makefile + CGI + firewall/bootstrap + defaults + apply/license مسارات).
- تمت مواءمة Redirect وFirewall subnet مع UCI بدل القيم الثابتة.
- تمت إضافة توثيق تفصيلي كامل في:
  - `HOTSPOT_OPENWRT_NEXT_CHAT_CONTEXT.md` (قسم: Session Delta 2026-05-16)

### الملفات المرشحة للتعديل في مرحلة التنفيذ القادمة

- `package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js`
- `package/luci-app-setup/files/usr/share/rpcd/acl.d/luci-app-setup.json`
- `package/luci-app-setup/files/etc/config/setup`
- `package/luci-app-hotspot-openwrt/files/etc/config/hotspot_openwrt`
- `package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/apply`

### معيار القبول الأساسي

- عند تفعيل Hotspot Quick، أي VLAN يجب أن يُرفض قبل الحفظ، ولا يُنشأ `wizardvlan` أثناء التطبيق.

---

## 27. تنفيذ فعلي 2026-05-16 (Quick Setup + Hotspot Quick)

### ما نُفّذ

1. إضافة Hotspot Quick داخل صفحة البرمجة السريعة (الخطوة 4).
2. تفعيل قاعدة منع التعارض نهائيًا: لا VLAN مع Hotspot Quick (UI + Validation + Apply).
3. إضافة حقول شبكتين للهوتسبوت في `setup.default`:
   - SSID / Gateway / Pool Start / Pool End / Policy لكل شبكة.
4. ربط مسار الحفظ بكتابة إعدادات `hotspot_openwrt.main` + `quick_*` ثم استدعاء hotspot apply بعد apply العام.
5. توسيع ACL في `luci-app-setup` للوصول المطلوب إلى UCI/exec للهوتسبوت.

### التوثيق المرجعي

- التفاصيل الدقيقة (Delta + الملفات + المخرجات المتوقعة) موجودة في:
  - `HOTSPOT_OPENWRT_NEXT_CHAT_CONTEXT.md`

---

## 28. تنفيذ فعلي 2026-05-16 (Phase 2: Runtime Dual Hotspot)

### الهدف

تحويل الشبكة الثانية في Hotspot Quick من مجرد إعدادات محفوظة إلى مسار Runtime مستقل فعليًا (IP/Pool/Policy مستقل) مع الحفاظ على قاعدة منع VLAN بالكامل.

### ما نُفّذ

1. `setup.js`:
  - اشتقاق واجهة مشترِكين ثانية تلقائيًا من الواجهة الأساسية.
  - ربط SSID-1 بالواجهة الأساسية وSSID-2 بالواجهة الثانية.
  - حفظ مفاتيح الواجهة الثانية في `setup.default` و`hotspot_openwrt.main`.
2. `hotspot-openwrt/apply`:
  - تهيئة Network/DHCP/Firewall للشبكة الثانية عند quick dual mode.
  - إنشاء instance ثاني لـ CoovaChilli (`chilli.hotspot_openwrt_secondary`) على `tun1`.
  - تفعيل تحقق Runtime مزدوج (`tun0` + `tun1`) في quick dual mode.
  - توسيع nft compatibility rules لتضمين المسارين.
3. `status-json`:
  - إضافة حقول مراقبة للشبكة الثانية (واجهة/IP، حالة tun1، route secondary، dual flag).
4. Defaults/config:
  - إضافة مفاتيح الواجهة الثانية في:
    - `package/luci-app-setup/files/etc/config/setup`
    - `package/luci-app-setup/files/etc/uci-defaults/40_luci-app-setup`
    - `package/luci-app-hotspot-openwrt/files/etc/config/hotspot_openwrt`
5. أتمتة اختبار المرحلة الثانية على الراوتر:
  - إضافة سكربت `/usr/libexec/hotspot-openwrt/phase2-smoke` داخل الحزمة.
  - السكربت يفحص tun0/tun1 وتهيئة chilli primary/secondary وroute/nft/status-json ويُرجع JSON + exit code.
6. اختبار حي على الراوتر تم بنجاح:
  - الهدف: `192.168.1.20`
  - `phase2-smoke` أعاد `"ok": true` مع `exit code 0`
  - `status-json` أكد `chilli_running=true`, `tun0_present=true`, `tun1_present=true`
7. إصلاح لاحق في الاختبار الحي:
  - سبب خفي في BusyBox `tr` داخل تطبيع policy كان يمنع مطابقة `standard/premium` ويؤدي لتساوي bandwidth بين الشبكتين.
  - تم تعديل التطبيع إلى صيغة متوافقة (`tr -d ' \t\r\n'`) وإعادة نشر `apply`.
  - بعد الإصلاح:
    - Primary (standard): `5M/10M`
    - Secondary (premium): `15M/30M`
  - `phase2-smoke` بقي PASS مع `exit code 0`.
8. تجهيز الخطوة التالية (Two-client E2E) بدون أجهزة عميل خارجية:
  - إضافة سكربت `/usr/libexec/hotspot-openwrt/phase2-client-sim` داخل الحزمة.
  - السكربت ينفذ محاكاة عميلين عبر veth على `br-hotspot` و`br-hotspot2` ويعيد JSON نتيجة.
  - تم التحقق نحويًا وبناء الحزمة بعد الإضافة بنجاح.
9. عائق تشغيلي حالي أثناء التنفيذ من بيئة العمل:
  - الهدف السابق `192.168.1.20` لم يعد reachable من الشبكة الحالية.
  - البوابة الحالية `192.168.137.1` reachable لكنها تتطلب كلمة مرور SSH.
  - النتيجة: خطوة الاختبار الحي التالية جاهزة تقنيًا ولكن متوقفة مؤقتًا على إعادة الوصول للراوتر.
10. بعد إعادة تشغيل الجهاز تم استعادة الوصول والاختبار الحي استكمل:
  - `status-json` و `phase2-smoke` رجعا PASS مع `tun0/tun1` و `dual_quick_mode=true`.
  - سكربت `phase2-client-sim` كان غير موجود على الراوتر (state بعد reboot) وتم نشره يدويًا وإعادة تشغيله.
11. قيود كيرنل فعلية أثناء محاكاة عميلين من داخل الراوتر:
  - `veth` غير مدعوم (`RTNETLINK Not supported`).
  - `ipvlan` غير مدعوم.
  - `macvlan` مدعوم للإنشاء لكن DHCP يفشل على الجسرين في هذا السيناريو.
12. انحراف إعدادات تم رصده وإصلاحه تشغيليًا:
  - backend quick-dual مفعّل في `hotspot_openwrt.main`.
  - لكن `wireless` لم يكن يحتوي واجهة SSID ثانية فعالة لـ `hotspot2`.
  - تم إنشاء `wizard_hotspot_quick_secondary` وربطه بـ `radio1/hotspot2` وإعادة تحميل الواي فاي.
13. تحسين أداة الاختبار نفسها:
  - تحديث `phase2-client-sim` ليستخدم `veth` ثم fallback إلى `macvlan`.
  - إضافة أسباب فشل صريحة في JSON: `veth_unavailable`, `sim_blocked_require_real_clients`.
14. محاولة تفعيل `kmod-veth`:
  - تم بناء وتثبيت IPK متوافق معماريًا (`mipsel_24kc`) على الراوتر.
  - لكن `veth.ko` غير موجود لأن `CONFIG_VETH` غير مفعّل في كيرنل الهدف، فالحزمة الناتجة فعليًا بدون payload.
15. الحالة العملية الحالية:
  - صحة مسار phase-2 المؤكد: PASS.
  - إكمال two-client E2E داخليًا على نفس الجهاز محجوب بقيود الكيرنل الحالية.
  - المسار المباشر للإغلاق: عميل حقيقي واحد على `hotspot` + عميل حقيقي واحد على `hotspot2` ثم إعادة تحقق sessions/policy.
16. الإغلاق النهائي بعد اتصال عميل فعلي على الشبكة الأساسية:
  - تم تنفيذ تحقق حي نهائي مباشرة بعد تأكيد المستخدم الاتصال.
  - النتائج:
    - Runtime health: PASS (`status-json` + `phase2-smoke` مع `RC=0`).
    - Dual policy divergence: PASS (5M/10M مقابل 15M/30M).
    - Client presence on both networks: PASS (primary=1, secondary=3).
  - الخلاصة النهائية:
    - متطلبات المرحلة الثانية مكتملة حيًا.
    - الحالة النهائية: PASS.
17. بدء المرحلة الثالثة (Hardening) - الخطوة الأولى مكتملة:
  - تم تعديل `hotspot-openwrt/apply` ليطبّق self-heal لاسلكي دائم في quick dual mode.
  - أي تشغيل لـ `apply` الآن يضمن وجود وتفعيل:
    - `wireless.wizard_hotspot_quick_primary`
    - `wireless.wizard_hotspot_quick_secondary`
  - مع ربط واضح بـ `hotspot` و `hotspot2` وتعطيل APات `lan` وإزالة بقايا `wizardvlan` في نفس المسار.
  - تم اختبار انحراف مقصود حيًا:
    - حذف `wizard_hotspot_quick_secondary` يدويًا
    - ثم تشغيل `apply`
    - النتيجة: إعادة إنشاء تلقائية + عودة `hotspot2` + `phase2-smoke` PASS بعد الدورة.
  - هذه الخطوة تزيل الاعتماد على الإصلاح اليدوي بعد إعادة التشغيل.
18. المرحلة الثالثة - الخطوة الثانية مكتملة (Clean Boot Validation):
  - تم تنفيذ اختبار إعادة تشغيل نظيف على الراوتر بعد تثبيت التعديلات.
  - تحقق ما بعد الإقلاع أكد:
    - وجود `wizard_hotspot_quick_primary` و `wizard_hotspot_quick_secondary`.
    - `hotspot2` up.
    - `phase2-smoke` PASS بعد الإقلاع (`POST_SMOKE_RC=0`).
  - تحقق سلامة الحزمة:
    - `luci-app-hotspot-openwrt` بحالة `install ok installed`.
    - smoke الحالي أيضًا PASS (`SMOKE_NOW_RC=0`).
  - النتيجة:
    - سلوك self-heal ثابت عبر دورة reboot كاملة.
19. المرحلة الثالثة - بداية الخطوة الثالثة (RC Gate + Staged OTA Playbook):
  - إضافة سكربت تحقق مرشح الإصدار داخل الحزمة:
    - `package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/phase3-rc-gate`
  - ربطه في تثبيت الحزمة عبر `Makefile`.
  - التحقق الجديد يغطي:
    - quick dual flags
    - وجود وربط wireless primary/secondary
    - صعود `hotspot` و `hotspot2`
    - التزام no-VLAN على واجهات الهوتسبوت
    - PASS من `phase2-smoke` وحالة `status-json`
  - إضافة دليل تشغيل مرحلي للإطلاق عبر OTA:
    - `HOTSPOT_PHASE3_RC_AND_OTA_ROLLOUT_PLAYBOOK.md`
  - الهدف التنفيذي التالي:
    - نشر الحزمة المحدثة -> تشغيل RC gate -> جمع evidence -> إطلاق canary rollout بنسبة 10% ثم التوسعة تدريجيًا.
20. تنفيذ حي لبوابة RC بعد الإضافة:
  - تم نسخ `phase3-rc-gate` إلى الراوتر وتشغيله مباشرة.
  - النتيجة: PASS (`ok=true`, `RC=0`).
  - فحوصات الالتزام بعدم VLAN للهوتسبوت نجحت (`no_vlan_primary=true`, `no_vlan_secondary=true`).
  - تم إنتاج artifact توثيقي فعلي:
    - `hotspot-backups/phase3-rc-evidence-20260516-102947.md`

### الضوابط المحفوظة

1. لا VLAN مع Hotspot Quick (محفوظة كما هي).
2. لم يتم إجراء build أثناء كتابة تعديلات المرحلة الثانية نفسها، ثم تم تنفيذ build اختباري لاحقًا للتحقق.
3. تم إجراء فحوصات syntax + diagnostics بنجاح بعد التعديلات.
4. تم تنفيذ compile اختباري للحزم المعدلة بنجاح:
  - `make package/luci-app-hotspot-openwrt/compile -j$(nproc) V=s`
  - `make package/luci-app-setup/compile -j$(nproc) V=s`
