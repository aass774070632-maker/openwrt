# خطة الإصلاح الجذري: إلغاء API Polling والاعتماد على RADIUS Protocol

## تحليل الجذر (Root Cause Analysis)

### المشكلة
النظام الحالي يفصل **المصادقة** (RADIUS UDP بين Chilli و MikroTik) عن **جلب المعلومات** (REST API / TCP 8728). هذا يخلق:

```
متصفح ← status.html ← hotspot-card-info ← userman-info ← REST API (v7) / TCP API (v6) ← سيرفر ميكروتك
                                                          ↕
                                                  lock file + cache (3600s)
```

ثلاث نقاط انكسار: `hotspot-card-info` (shell) → `userman-info` (Lua proxy) → `mikrotik_api` (C binary)

### لماذا ميكروتك الأصلي لا يعاني؟
ميكروتك الأصلي لا يستخدم API Polling للـ hotspot. آلية عمله:

```
مستخدم ← صفحة ميكروتك ← المصادقة عبر RADIUS المحلي (User Manager داخلي)
                         ↕
                 كل المعلومات تأتي من RADIUS Access-Accept
                 Session-Timeout ← الوقت المتبقي
                 Idle-Timeout ← مهلة الخمول
                 MikroTik-Rate-Limit ← السرعة
```

لا API خارجي، لا cache، لا lock files.

### ما يفعله Chilli بالفعل
CoovaChilli يخزن كل RADIUS Access-Accept attributes في session database محلياً:

| RADIUS Attribute | أين يخزنه Chilli | متاح حالياً؟ |
|-----------------|------------------|--------------|
| Session-Timeout | `sessiontimeout` في الجلسة | نعم في `chilli_query list` ($7) |
| Idle-Timeout | `idletimeout` في الجلسة | نعم في `chilli_query list` ($8) |
| Input-Octets | `input_octets` | نعم في `chilli_query list` ($9) |
| Output-Octets | `output_octets` | نعم في `chilli_query list` ($10) |
| Bandwidth-Max-Up | `bandwidthmaxup` | نعم في `chilli_query list` ($13) |
| Bandwidth-Max-Down | `bandwidthmaxdown` | نعم في `chilli_query list` ($14) |
| Max-Input-Octets | `maxinputoctets` | نعم في `chilli_query list` ($9 بعد /) |
| Max-Output-Octets | `maxoutputoctets` | نعم في `chilli_query list` ($10 بعد /) |
| Max-Total-Octets | `maxtotaloctets` | نعم في `chilli_query list` ($11) |
| Reply-Message | `redir.username` أو custom | غير مستخدم حالياً |

**كل المعلومات موجودة في Chilli بالفعل — فقط لم نستخدمها!**

---

## الحل الجذري: RADIUS-Native Session Display

### المسار الجديد
```
متصفح ← status.html ← hotspot-card-info ← chilli_query list (محلي، بدون شبكة)
                                           ↕
                                  CoovaChilli session database
                                           ↕
                                  RADIUS Access-Accept من ميكروتك
```

**لا اتصال شبكة خارجي. لا cache. لا lock files. لا C binary. لا Lua proxy.**

### ماذا يعرض للمستخدم

| الحقل | المصدر | مثال |
|-------|--------|------|
| رقم الكرت (Username) | RADIUS User-Name → Chilli session | `12345` |
| البروفايل (Profile) | RADIUS Class أو Reply-Message | `باقة 500 ميجا` |
| السرعة القصوى تحميل | MikroTik-Rate-Limit → `bandwidthmaxdown` | `2 Mbps` |
| السرعة القصوى رفع | MikroTik-Rate-Limit → `bandwidthmaxup` | `1 Mbps` |
| البيانات المستهلكة (تحميل) | `output_octets` من Chilli | `150 MB` |
| البيانات المستهلكة (رفع) | `input_octets` من Chilli | `30 MB` |
| الوقت المتبقي | RADIUS Session-Timeout | `45 دقيقة` |
| البيانات المتبقية | `maxtotaloctets - (input+output)` | `320 MB` |
| حالة الاتصال | `session_state == pass` | `متصل` |

### ماذا لو لم يرسل ميكروتك Session-Timeout؟
- **وقت مفتوح**: يعرض "غير محدود" بدلاً من الوقت المتبقي
- **بيانات مفتوحة**: يعرض "غير محدود" بدلاً من البيانات المتبقية
- **سرعة غير محدودة**: يعرض "غير محدود" بدلاً من السرعة

### ماذا لو تعطل RADIUS نفسه؟
إذا تعطل RADIUS (قطع بين Chilli وميكروتك):
- لا أحد يستطيع تسجيل الدخول أصلاً
- المشكلة موجودة سواء استخدمنا API أو RADIUS
- **لا فرق**: API polling أيضاً لن يعمل لأن السيرفر نفسه غير متاح

---

## خطة التنفيذ (مع ضمان عدم توقف الخدمة)

### المرحلة 0: تهيئة سيرفر ميكروتك (جهة السيرفر)

#### 0.1 إعداد Session-Timeout في User Manager Profiles

لكل Profile في User Manager، تأكد من وجود **Session-Timeout**:

```
/radius incoming
set [find where comment~"hotspot"] session-timeout=86400
```

أو من خلال واجهة Profiles في User Manager:
- Profile → Session Timeout: أدخل المدة بالثواني

**ماذا يعطي هذا؟** Chilli سيقرأ Session-Timeout ويخزنه. `hotspot-card-info` سيقرأه ويعرض الوقت المتبقي للمستخدم.

#### 0.2 إعداد Max-Total-Octets (اختياري — للباقات المحدودة البيانات)

إذا كانت الباقة محدودة البيانات (ليست مفتوحة)، أضف حد البيانات:

```
/user-manager/profile/set [find] max-total-octets=500000000
```

**ماذا يعطي هذا؟** Chilli سيقرأ `maxtotaloctets`. `hotspot-card-info` سيحسب `maxtotaloctets - input_octets - output_octets` ويعرض "المتبقي: 320 MB".

#### 0.3 إرسال Reply-Message مع الرصيد (اختياري متقدم)

ميكروتك User Manager يدعم إرسال ردود مخصصة:

يمكنك إنشاء سكريبت في User Manager يضبط Reply-Message:

```
:local remaining [/user-manager/user/get [find] bytes-left]
/radius incoming set reply-message="رصيدك: $remaining بايت"
```

**أو الأسهل**: استخدام حقل `Reply-Message` في إعدادات الـ Profile:
- Profile → Reply-Message: `Credit: %B` (حيث %B هو متغيّر User Manager للبايتات المتبقية)

ميكروتك يدعم المتغيرات التالية في Reply-Message:
- `%B` = bytes remaining
- `%T` = time remaining
- `%U` = username

### المرحلة 1: تحسين hotspot-card-info (خالٍ من المشاكل)

**ما يتغير**: `hotspot-card-info` يقرأ من `chilli_query` فقط. لا userman-info، لا lock، لا cache.

**ما لا يتغير**: نفس مسار الاستجابة JSON — الحقول القديمة تبقى موجودة للتوافق.

#### الهيكل الجديد

```
#!/bin/sh
chilli_query -s $socket list | awk '$2 == IP' | while read mac ip state sid _ user ...
do
  # قراءة Session-Timeout و Idle-Timeout
  session_timeout=$(echo $line | awk '{print $7}' | cut -d/ -f2)
  idle_timeout=$(echo $line | awk '{print $8}' | cut -d/ -f2)
  
  # قراءة octets
  input_octets=$(echo $line | awk '{print $9}' | cut -d/ -f1)
  output_octets=$(echo $line | awk '{print $10}' | cut -d/ -f1)
  max_input=$(echo $line | awk '{print $9}' | cut -d/ -f2)
  max_output=$(echo $line | awk '{print $10}' | cut -d/ -f2)
  max_total=$(echo $line | awk '{print $11}')
  
  # قراءة السرعات
  max_up=$(echo $line | awk '{print $13}' | sed 's/.*%//')
  max_down=$(echo $line | awk '{print $14}' | sed 's/.*%//')
  
  # حساب المتبقي
  remaining=$(( max_total - input_octets - output_octets ))
  
  # إخراج JSON مباشرة
done
```

**الضمانات**:
- لا lock files ← لا سباق ← لا توقف
- لا cache ← لا بيانات فاسدة
- لا userman-info ← لا timeout 180 ثانية
- لا curl ← لا مشاكل توافق v6/v7
- لا mikrotik_api ← لا C binary
- `chilli_query list` متاح فوراً ← لا تأخير

### المرحلة 2: تحديث status.html

**ما يتغير**: JS تقرأ `remaining_time` و `remaining_bytes` من JSON بدلاً من `user_manager.balance_*`.

**التبديل الآمن**: status.html يحاول قراءة الحقول الجديدة أولاً، فإن لم توجد يقرأ القديمة.

```javascript
// متوافق مع القديم والجديد
balanceVal.textContent = data.balance_remaining 
    || formatTime(data.session_timeout_remaining)
    || formatBytes(data.remaining_bytes)
    || 'مفتوح';
```

### المرحلة 3: إزالة الكود الميت

بعد تأكيد أن النظام الجديد يعمل (أسبوعين اختبار):

1. إزالة `userman-info` من المصدر
2. إزالة `mikrotik_api.c` و `md5.c` من المصدر
3. إزالة `src/Makefile`
4. إزالة `Build/Prepare` و `Build/Compile` من Makefile (تم)
5. إزالة `+curl` من DEPENDS (تم)
6. إزالة lock file logic من أي سكريبت متبقي

### المرحلة 4: الميزات الإضافية (اختياري)

#### 4.1 Session-Time Real-time Display
`chilli_query status ip CLIENT_IP` يعرض Session-Timeout المتبقي بالثواني. يمكن تحديثه live في status.html بدون refresh.

#### 4.2 RADIUS CoA للطرد الفوري
عندما ينتهي رصيد المستخدم، ميكروتك يرسل CoA (Change of Authorization) أو Disconnect-Request. Chilli يدعم هذا. يمكن تكوين ميكروتك لإرسال CoA عند انتهاء الرصيد.

#### 4.3 Reply-Message Parser
إذا أرسل ميكروتك Reply-Message يحتوي على رصيد، نعرضه كما هو في صفحة الحالة.

---

## ضمانات عدم توقف الخدمة

### أثناء التحديث (Upgrade)

1. **الملفات القديمة تبقى**: حتى بعد التثبيت، `userman-info` يبقى موجوداً على الجهاز (كـ dead code). لا نحذفه — نتركه.
2. **خيار UCI للعودة**: نضيف خيار UCI:
   ```
   config hotspot_openwrt
       option data_source 'radius'  # radius | api
   ```
   إذا اختار `api`، يعود النظام القديم (userman-info + cache + lock).
3. **استجابة JSON متوافقة**: الحقول الجديدة (`remaining_time`, `remaining_bytes`) تضاف بجانب الحقول القديمة (`balance_*`).

### سيناريوهات التبديل

| السيناريو | ماذا يحدث | هل يتوقف hotspot؟ |
|-----------|-----------|-------------------|
| تثبيت الحزمة الجديدة | النظام الجديد يبدأ مباشرة، القديم يبقى غير مستخدم | لا |
| UCI data_source = radius | يستخدم Chilli فقط | لا |
| UCI data_source = api | يعود للنظام القديم (إن وجد userman-info) | لا |
| userman-info غير موجود | النظام الجديد يعمل طبيعياً | لا |
| chilli_query غير موجود | JSON يعيد `ok: false` مع رسالة "Chilli غير مثبت" | لا (المستخدم يرى فقط خطأ في صفحته) |
| RADIUS لا يرسل Session-Timeout | يعرض الوقت كـ "غير محدود" | لا |
| الـ cache القديم موجود | يتجاهله النظام الجديد — لا يقرأه | لا |

### اختبار ما قبل النشر

1. **اختبار chilli_query**: تأكد من أن `chilli_query list` يعمل ويعيد session data
2. **اختبار JSON**: تشغيل `hotspot-card-info` يدوياً والتحقق من JSON
3. **اختبار status.html**: فتح الصفحة في متصفح والتحقق من ظهور الرصيد
4. **اختبار التزامن**: فتح 10 صفحات في نفس الوقت ← لا lock errors
5. **اختبار v6 و v7**: تجربة مع كلا الإصدارين من ميكروتك

---

## حالة الإصدارات

| الإصدار | التاريخ | التغييرات |
|---------|---------|-----------|
| r139 | 2026-07-12 | RADIUS-native migration: hotspot-card-info, MAC format, upload_octets/download_octets, status.html بدون sub-object, CoovaChilli patch (swap octets), Makefile (إزالة curl/userman-info) |
| r140 | 2026-07-12 | إصلاح #8 logout_ok (بدون socket), #19 speed sanitize, #5/#6 local variables, #14 atomic /etc/hosts, #13 conffiles, #11 PID files, #12 WiFi section protection, #16 RADIUS secret validation, #20 stop_service, #23 lastCardInfo. **إصلاح syntax error في hotspot-card-info (line 161)** |
| r141 | 2026-07-12 | **إصلاح #21 async RADIUS login polling**: بعد `chilli_query login`، ينتظر حتى 3 ثوانٍ (فحص كل 0.2 ثانية) حتى يصبح `state=pass`. حل مشكلة "خطأ في الاتصال بالسيرفر" مع استمرار اشتغال الإنترنت لاحقاً. |

## المشاكل المتبقية المعروفة

1. **الحقول التي لا يوفرها RADIUS**: اسم البروفايل، الرصيد، تاريخ الانتهاء — يظهر `-`
   - الحل: REST API مرة واحدة عند تسجيل الدخول → كاش محلي → قراءة من الملف بعدها (صفر API في التحديثات)

## مقارنة الحل النهائي

| المعيار | قبل (REST API polling) | بعد (RADIUS-native + cached REST) |
|---------|------------------------|-----------------------------------|
| سطور الكود في مسار الرصيد | ~541 (userman-info + hotspot-card-info) | ~80 (hotspot-card-info) |
| نقاط الفشل | 3 (shell → Lua → C) | 1 (shell → chilli_query) |
| طلبات API خارجية | طلب لكل مستخدم لكل refresh | 1 طلب لكل جلسة (عند الدخول فقط) |
| Lock files | /tmp/hotspot_balance.lock | لا يوجد |
| Cache | /tmp/hotspot_balance_cache (3600s) | /tmp/hotspot-cache-* (مدة الجلسة) |
| التواصل مع ميكروتك | RADIUS + REST/API | RADIUS (مصادقة) + REST (مرة واحدة للبروفايل) |
| دعم v6 | يحتاج C binary (قد لا يشتغل) | RADIUS protocol — يعمل |
| دعم v7 | REST API — يعمل | RADIUS protocol + REST للبروفايل فقط |
| مهلة الفشل | 180 ثانية (lock يمنع الكل) | <1 ثانية (قراءة محلية) |
| XSS عبر API | ممكن (Reply-Message غير منقى) | نحن ننشئ JSON — تحكم كامل |
| استهلاك ذاكرة C binary | 409 سطور C + 205 سطور MD5 | 0 |
| اعتماد على curl | نعم (كل طلب) | نعم (عند الدخول فقط لجلب البروفايل) |
| سرعة ظهور الرصيد | 2-10 ثوانٍ (خلفية + cache) | <0.1 ثانية (قراءة محلية) |
| سرعة تسجيل الدخول | فوري | 0.2-3 ثوانٍ (انتظار رد RADIUS) |
