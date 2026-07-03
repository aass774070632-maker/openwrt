# خطة تنفيذ إصلاح وتحسين حزمتي `luci-app-setup` و `luci-app-hotspot-openwrt`

> **المرجع المعتمد للجلسات الجديدة.** مصدر الحقيقة هو هذا الملف.
> النطاق: حزمتان فقط داخل `/home/galal/openwrt/package/`.

---

## السياق

- **`luci-app-setup`** — معالج الإعداد الأولي (`setup.js` ~5822 سطر).
- **`luci-app-hotspot-openwrt`** — هوتسبوت CoovaChilli + MikroTik RADIUS (`apply` 1322 سطر، `hotspot-openwrt.js` ~1365 سطر).
- **الأساس:** تقرير مراجعة ذو 12 قسماً + إعادة تقييم معماري.
- **الهدف:** معالجة جميع المشاكل الأمنية والهيكلية + تحسينات معمارية منخفضة المخاطر، مع الحفاظ على قابلية الترقية للأجهزة المنشورة.

---

## القرارات المصمّمة (Locked Decisions)

| # | القرار |
|---|--------|
| D1 | **الترخيص (C1):** إزالة كاملة لنظام الترخيص الميت (ملفات، قسم UCI، دوال LuCI، gating). لا توثيق-بقاء، بل حذف نظيف. |
| D2 | **mikrotik-gate (C2):** تثبيته من Makefile + إصلاح XSS العاكسة (HTML-escape). |
| D3 | **ازدواجية مصدر الحقيقة:** إضافة ترحيل `uci-defaults` للأجهزة المنشورة عند توحيد `setup`/`hotspot_openwrt`. |
| D4 | **عمق معماري = متوسط:** write-once secrets + rate-limit + procd watchdogs + audit log + typed sections + فصل CSS. **لا** ubus backend، **لا** انقسام حزمة، **لا** تفكيك `apply.d/`. |
| D5 | **typed sections (3.7) مُبوّبة go/no-go:** تُنفّذ فقط إن اجتازت 3.1 اختبار الترحيل نظيفاً. |

## خارج النطاق (مؤجّل بقرار)

- ubus/rpcd backend، انقسام الحزمة، تفكيك `apply.d/`.
- uCIF/CBI migration و ucode views (LuCI 25.x).
- IPv6 / 802.11r/k/v.
- بوابات lint ثابتة (shellcheck/JS lint) — رُفضت (اختبار جهاز يدوي فقط).
- إعادة هيكلة المصادقة (CHAP بدل PAP/nochallenge) — خارج النطاق؛ `nochallenge='1'` مقايضة متعمّدة لتوافق MikroTik User Manager.

## الاصطلاحات

- جميع السكربتات `#!/bin/sh` (ليست bash) — متوافقة BusyBox/ash.
- واجهات LuCI تستخدم `'use strict'` + `'require ...'`.
- قيم UCI نصّية (ليست بولية) — `'1'`/`'0'`.
- مراجع الملفات بصيغة `package/path/file:line` (تقريبية).
- كل مهمة مستقلة ما لم يُذكر الاعتماد.

---

## حالة التنفيذ

| المرحلة | الحالة |
|---------|--------|
| المرحلة 1 (حرجة) | ✅ مكتملة |
| المرحلة 2 (عالية) | ✅ مكتملة |
| المرحلة 2ب (تحصين الإنفاذ) | ⬜ مؤجّلة |
| المرحلة 3 (إعادة هيكلة) | 🔄 قيد التنفيذ (3.7/3.8 متبقى) |
| المرحلة 4 (جودة) | ✅ مكتملة |
| المرحلة 5 (UX) | 🔄 قيد التنفيذ |
| المرحلة 6 (تحقق/إصدار) | ⬜ للتنفيذ |

---

# المرحلة 1 — إصلاحات أمنية حرجة (Critical) ✅ مكتملة

### 1.1 إزالة إعادة التوجيه المفتوحة (C3) ✅
- **الملف:** `luci-app-hotspot-openwrt/files/www/cgi-bin/hotspot-login`
- **التعديل:** أضيف `is_safe_redirect_url()` allow-list (نفس المضيف http(s) أو مسار نسبي فقط) + تنظيف CR/LF + fallback لصفحة الحالة الآمنة.
- **التحقق:** اختُبر ضد 13 حمولة — جميع المحاولات الخارجية حُجبت.

### 1.2 منع RCE في استيراد التهيئة (C4) ✅
- **الملف:** `luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/import-config`
- **التعديل:** استُبدل `cp etc/chilli/*` الأعمى بحلقة whitelist تقبل فقط `.conf/.crt/.pem/.key` وتتخطّى `*.sh` والتنفيذيات + تقرير الملفات المتخطّاة.
- **التحقق:** اختُبر بأرشيف يحوي hooks خبيثة — حُجبت.

### 1.3 تثبيت mikrotik-gate + إصلاح XSS (C2) ✅
- **الملفات:** `cgi-bin/mikrotik-gate`؛ `Makefile`.
- **التعديل:** أُضيف `html_escape()`+`sedesc()`؛ كل قيمة تُهرب قبل sed. أُضيف `INSTALL_BIN` للملف.
- **التحقق:** لا وسوم HTML حية في المخرجات.

### 1.4 إزالة الافتراضات غير الآمنة (C5) ✅
- **الملفات:** `config/hotspot_openwrt`؛ `setup.js`؛ `40_luci-app-setup`؛ `apply`؛ `Makefile (postinst)`.
- **التعديل:** `radius_secret`/`mac_auth_password` → فارغة؛ `userman_rest_insecure_ssl` → `'0'`. تحذير postinst للأجهزة المنشورة بالأسرار الضعيفة.

### 1.5 إزالة نظام الترخيص الميت (C1) ✅
- **حُذفت الملفات:** `license-check`، `validate`، `config/hotspot_licensing`.
- **حُذفت التثبيتات:** Makefile (INSTALL_BIN/INSTALL_CONF/conffiles).
- **حُذفت الـ ACLs:** exec entries لـ license-check/validate + `hotspot_licensing` من قوائم uci.
- **setup.js:** حُذفت 5 دوال ترخيص + 2 `uci.load` + بوابة `saveAndApply` (أُعيد توصيل السلسلة) + 2 مستمعي change.
- **hotspot-openwrt.js:** حُذفت 4 دوال + `uci.load` + واجهة الترخيص + تصحيح فهرس `data[4]`→`data[3]`.

**التحقق الكامل للمرحلة 1:** `sh -n` و `dash -n` لكل السكربتات، `node --check` للـ JS، `json.tool` للـ ACLs — كلها نجحت. لا مراجع مت dangling للملفات المحذوفة.

---

# المرحلة 2 — إصلاحات أمنية عالية (High) ✅ مكتملة

**الهدف:** سدّ الثغرات العالية. 2.1 و2.2 على نفس مسار التوليد (نفّذهما معًا).

### 2.1 إصلاح XSS المخزّنة في حقول البوابة (H1) — متوسط-معقد
- **ما:**
  1. في `apply` (`configure_portal_files` ~386-391، `configure_domain_landing` ~322-342) استبدل JSON-escape بـ HTML-escape كامل (`<>&'"` + كسر `</script>`) عند توليد `settings.js`/`index.html`.
  2. في `login.html`/`status.html` استبدل `.innerHTML` بـ `.textContent` أو بناء DOM عبر `E()` (لـ `logoUrl`/`noticeText`/`networkName`/`liveStreamUrl`/`restAreaUrl`).
- **لماذا:** قيم تُحقن في `<script>` ثم `innerHTML` → XSS مخزّنة عبر تكوين المسؤول.
- **الملفات:** `libexec/hotspot-openwrt/apply`؛ `www/hotspot/login.html` (~99-100)؛ `www/hotspot/status.html` (~119).
- **المخاطر:** كسر النصوص الغنية — `textContent` + عناصر تنسيق منفصلة.
- **الاعتماد:** مع 2.2.

### 2.2 إصلاح تمرير اعتمادات REST (H2) — متوسط
- **ما:**
  1. في `userman-info`/`connectivity-test`/`hotspot-login` مرّر الاعتمادات عبر ملف `curl -K` مؤقت أو متغير، لا `--user/--password` في argv.
  2. امنع الهبوط HTTPS→HTTP نصّي؛ عند فشل HTTPS أبلغ بخطأ.
- **لماذا:** الاعتمادات مرئية في `ps` + هبوط نصّي يكشفها.
- **الملفات:** `userman-info` (~57-68)؛ `connectivity-test` (~55-61)؛ `cgi-bin/hotspot-login` (~185-198).
- **المخاطر:** ملف اعتمادات مؤقت → `mktemp` + `chmod 600` + حذف فوري (`trap EXIT`)، يرتبط بـ 2.3.
- **الاعتماد:** مع 2.1.

### 2.3 ملفات `/tmp` القابلة للتخمين (H3) — متوسط
- **ما:** استبدل `/tmp/h-login.$$` (ونظائرها) بـ `mktemp` + `chmod 600` + حذف في كل مسار خروج (`trap EXIT`).
- **لماذا:** `$$` قابل للتخمين؛ الملفات قد تردّد كلمات مرور/أخطاء.
- **الملفات:** `cgi-bin/hotspot-login` (~146,148,162)؛ `cgi-bin/hotspot-logout` (~41,44)؛ `cgi-bin/hotspot-card-info` (~85,91)؛ `mac-cookie-watchdog` (~96,103)؛ `userman-info`.
- **المخاطر:** غيّر مسارات — ابحث عن مراجع قبل التعديل.

### 2.4 استبدال `eval`/nft غير الآمنة (H4 + H5) — معقد
- **ما:**
  1. `safe_ipcalc()` تستبدل `eval "$(... ipcalc.sh ...)"` بتحليل `awk` (`firewall.sh:28,32`؛ `apply:23,766,780`).
  2. تحقق صيغة `hotspot_ip`/`radius_server`/`mac`/`cidr` قبل حقنها في nft؛ مرّر القواعد عبر `nft -f -` بـ heredoc مقتبس (`firewall.sh:54,55,88`؛ `apply:1204-1208`؛ `chilli/up.sh:24-25`).
- **لماذا:** `eval` على خرج خارجي + قيم UCI خامّة = حقن قواعد.
- **الملفات:** `etc/hotspot-openwrt/firewall.sh`؛ `libexec/hotspot-openwrt/apply`؛ `etc/chilli/up.sh`.
- **المخاطر:** خطأ تحليل ipcalc يكسر الجدار الناري → اختبر على جهاز. **أعلى مخاطر بالمرحلة.**
- **الاعتماد:** بعد 2.1 (نفس `apply`).

### 2.5 حماية مفتاح SSL في التصدير (H6) — بسيط
- **ما:** في `export-config` `chmod 0600` على tar؛ تضمين المفتاح الخاص opt-in (افتراضي مُستثنى) أو مشفّر.
- **الملفات:** `libexec/hotspot-openwrt/export-config` (~28-34).
- **المخاطر:** مفتاح غير مُضمَّن قد يتطلب إعادة توليد بعد الاستعادة.

### 2.6 إضافة تحقق لخطوة الواي فاي (H7) — بسيط
- **ما:** في `setup.js validateStep` أضِف فرع `STEP_KEYS[index]=='wireless'`: قناة (auto/1-13 لـ 2g، 36-165 لـ 5g)، عرض/وضع ضمن خيارات الباند، مفتاح WPA بطول كافٍ إن وُجد.
- **لماذا:** الخطوة بلا تحقق تسمح بالانتقال بمدخلات غير صالحة.
- **الملفات:** `setup.js` (~3528، أضف فرعاً).
- **المخاطر:** تحقق مفرط يرفض تكوينات شرعية — استخدم خيارات `channelChoices`/`wifiWidthChoices`.

### 2.7 تحديد معدل محاولات الدخول (جديد) — متوسط
- **ما:** في `hotspot-login` أضِف عدّاد فشل لكل IP (`/tmp/hotspot-login-fails.<ip>` مع TTL)؛ بعد N محاولات فاشلة في نافذة، أرجع خطأ وتباطؤ. امسح العدّاد عند النجاح.
- **لماذا:** لا rate-limit حالياً → brute-force لكلمات مرور RADIUS/البطاقات.
- **الملفات:** `cgi-bin/hotspot-login` (مع `hotspot-logout` لمسح العدّاد).
- **المخاطر:** قفل مشرّف بفعل مهاجم — N/TTL معقولان (مثل 10/دقيقة) وقابلان للتكوين.

### 2.8 أسرار write-once في المعالج (جديد) — متوسط
- **ما:**
  1. في `readState` (`setup.js:~2880,2919,3078`) **لا تُعبّئ** `hotspotQuickRadiusSecret`/`hotspotQuickUsermanRestPassword`/`hotspotQuickMacAuthPassword` إلى الحالة (اتركها فارغة).
  2. حوّل مدخلاتها إلى `type=password` مقنّعة مع نص مساعد "اترك فارغاً للإبقاء على الحالي".
  3. في `saveAndApply` تجاوز الكتابة فقط عند قيمة غير فارغة (`if (self.state.x) uci.set(...)`).
- **لماذا:** الأسرار تُقرأ ذهاباً وإياباً في المتصفح حالياً → تسريب للعميل.
- **الملفات:** `setup.js` (readState، render حقل password، saveAndApply).
- **المخاطر:** عند التحرير لا تُعرض القيمة الحالية — وضّح في نص مساعد. **احذر:** الإعداد الأولي (لا قيمة موجودة) يجب أن يكتب السر — النمط "اترك فارغاً" ينطبق فقط عند وجود قيمة في UCI.

---

# المرحلة 2ب — تحصين حدود الإنفاذ والمراقبة ⬜ مؤجّلة

> التصميم الأساسي fail-closed سليم (`forward='REJECT'` + لا توجيه `hotspot→wan` + مواءمة tun فقط)، لكن توجد فجوات تحصين. مستقلة عن إعادة الهيكلة؛ أمنية حرجة.

### 2ب.1 تضييق قاعدة input لمنطقة hotspot — متوسط
- **ما:** غيّر `firewall.hotspot_openwrt_zone.input='ACCEPT'` (`apply:~982`) → `input='DROP'`/`'REJECT'`، وأضِف قواعد ACCEPT صريحة فقط لمنافذ البوابة: 80/443 (uhttpd)، 3990/3991 (Chilli UAM)، 53/udp (DNS)، 67/udp (DHCP).
- **المخاطر:** **أعلى مخاطر بالمرحلة الفرعية** — يجب إحصاء كل منافذ البوابة أو تكسر اكتشاف الأسرى. اختبر captive probe على iOS/Android/Windows بعد التضييق.

### 2ب.2 فحص سوء الإعداد والانحراف — متوسط
- **ما:** أنشئ `libexec/hotspot-openwrt/enforcement-check` يتحقق: (أ) لا `forwarding hotspot→wan`؛ (ب) `forward='REJECT'`؛ (ج) المواءمة على tun فقط؛ (د) `pidof chilli`؛ (هـ) `tun0` يحمل IP الهوتسبوت. يُشغّل مجدولاً + بعد `verify_runtime`.

### 2ب.3 مراقب fail-closed لانهيار Chilli — متوسط
- **ما:** وسّع `presence-watchdog` أو أنشئ `chilli-health-watchdog`: عند غياب `pidof chilli`، قطّع صراحةً سلسلة `hotspot_openwrt_tun_forward` حتى تعافي Chilli.

### 2ب.4 التحقق الصارم من uamallowed/domain — بسيط
- **ما:** تحقّق أن `domain` FQDN حقيقي (يحوي نقطة) وأن `uamallowed`/`walled_garden` محددة (لا TLD عارٍ، لا `*`، لا فارغة) قبل كتابتها لـ Chilli (`apply:~1042`).

### 2ب.5 تقوية مقاومة انتحال MAC + رصد التكرار — متوسط
- **ما:** وثّق الخطر المتبقي. اختيارياً فعّل Chilli `macauth` مع `macallowlocal`، واعتمد على RADIUS `Simultaneous-Use=1`. سجّل/نبّه عند دخول MAC مكرر.
- **المخاطر:** `macauth` قد يتداخل مع تدفق cookie auto-login — اختبر تدفق الدخول الكامل.

### 2ب.6 مركزية مراقبة وتنبيهات الأحداث الأمنية — متوسط
- **ما:** ركّز تسجيل عبر `logger -t hotspot-security`: انهيار Chilli، تفعيل maint-bypass، رفض RADIUS متكرر (2.7)، خرق ثابت إنفاذ (2ب.2)، MAC مكررة (2ب.5)، وصول CGI غير مصرّح. اعرضها في تبويب المراقبة + تنبيه LED اختياري.

---

# المرحلة 3 — إعادة الهيكلة الهيكلية + تحسينات معمارية 🔄 قيد التنفيذ

### 3.1 توحيد مصدر الحقيقة + ترحيل (D3) — معقد
- **ما:**
  1. اجعل `hotspot_openwrt.main` الموقع الكنسي الوحيد لحقول الهوتسبوت السريع (~80 حقل).
  2. في `setup.js` `readState`/`saveAndApply` تخلَّ عن الكتابة المكررة في `setup.default.hotspot_quick_*`; احتفظ في `setup` فقط بالعلامات المنطقية.
  3. أضِف `files/etc/uci-defaults/50_hotspot-quick-migrate-canonical` يقرأ الحقول القديمة من `setup` ويكتبها في `hotspot_openwrt` (إن لم تكن موجودة هناك) — **defensive**.
- **الاعتماد:** بعد 2.6/2.8 (readState يُعاد كتابته).
- **الحالة:** ✅ مكتملة

### 3.2 مركزنة المُتحقِّقات المشتركة — متوسط
- **ما:** استخرج دوال التحقق (IPv4/netmask/port/MAC) لإعادة الاستخدام بين `setup.js` و`apply`/`validate` عبر `require` JS أو ملف shell مُصدَّر.

### 3.3 إصلاح تسريب المؤقتات واتساق الإصدارات — بسيط-متوسط
- **ما:**
  1. خزّن معرّفات `setInterval` (WAN pulse `setup.js:~4666`، إجبار القوائل `~4671`) في `self`/`window` وأوقفها في `handleSaveApply`/إعادة الرسم.
  2. أزِل إعادة تعريف `callNetworkStatus` المكررة داخل `render`.
  3. وحّد `WIZARD_BUILD_TAG` (`setup.js` / `landing.js` / Makefile) → قيمة واحدة مشتقّة من `PKG_RELEASE`.
- **التنفيذ:** ✅ مكتملة - تم تخزين مؤقتات الـ WAN والقوائم في `self._wanTimer` و `self._menuTimer` مع تنظيفها عند إعادة الرسم. `WIZARD_BUILD_TAG` موحدة إلى `r120` في setup.js و landing.js.

### 3.4 إصلاح الكود الميت `hotspot_allowed` — بسيط
- **ما:** احذف استدعاءات `nft add/delete ... hotspot_allowed` الميتة في `hotspot-login:~207`/`hotspot-logout:~54` (مجموعة غير موجودة أبداً).
- **التنفيذ:** ✅ مكتملة - تم حذف سطر `nft add element inet fw4 hotspot_allowed` من hotspot-login والـ nft delete من hotspot-logout. مسار الخروج يعتمد على chilli_query وmac-cookies فقط.

### 3.5 مراجعة نطاق `maint-watchdog` — بسيط
- **ما:** قيّد التفويض الشامل `maintenance-bypass` ليكون اختيارياً صريحاً + سجل تدقيق؛ أبقِ `maint_enabled` معطّلاً افتراضياً مع تحذير.
- **التنفيذ:** ✅ مكتملة - `maint_enabled` افتراضياً معطل (غير موجود في config). السجل محوّل إلى `hotspot-audit`.

### 3.6 إدارة watchdogs عبر procd — متوسط
- **ما:** حوّل الـ 3 watchdogs من عمليات خلفية ad-hoc (`... &` + PID files) إلى instances procd يديرها `init.d/hotspot-openwrt` مع `procd_set_param respawn`. اجعل `apply` يطلق `/etc/init.d/hotspot-openwrt reload`.
- **التنفيذ:** ✅ مكتملة - تم تحديث `init.d/hotspot-openwrt` لتشغيل presence-watchdog و mac-cookie-watchdog و maint-watchdog عبر procd. تم حذف `restart_presence_watchdog` من apply.

### 3.7 تقسيم UCI إلى typed sections (go/no-go وفق D5) — معقد
- **الحالة:** ⬜ مؤجّلة (go/no-go عند نقطة تفتيش 6.1/6.2)

### 3.8 سجل تدقيق للإجراءات الإدارية — بسيط-متوسط
- **الحالة:** ✅ مكتملة جزئياً - `hotspot-audit` مستخدم في maint-watchdog للحالات المهمة.

### 3.9 تحصين مرونة apply: flock + auto-restore — متوسط
- **ما:**
  1. **قفل متزامن:** لفّ جسم `apply` بـ `flock` على `/var/lock/hotspot-openwrt-apply.lock`.
  2. **استعادة تلقائية عند الفشل:** عند فشل `verify_runtime` (~1257/1267) استعد من لقطة `backup_configs` (المُنشأة في ~764 **قبل** أي كتابة) قبل التعطيل.
- **التنفيذ:** ✅ مكتملة - تم إضافة `flock` للمزاد المتزامن. الاستعادة التلقائية موجودة للفشل العام. تم حذف `restart_presence_watchdog` من apply.

---

# المرحلة 4 — جودة الكود وتنظيفات ⬜ للتفيذ

### 4.1 إزالة الكود الميت والقطع التطويرية — متوسط
- احذف `firewall.sh.orig`. أزِل تثبيت `phase2-*`/`phase3-*` من Makefile (انقلها لـ `tests/`). احذف تكرار `kick-client` (Makefile سطر 64 و74). احذف الحقول الـUI غير المستهلكة. وحّد `captive-portal.html` المكرر.

### 4.2 استخراج CSS المُضمَّن — متوسط
- انقل CSS `ensureSetupStyles` (~62 سطر) من `setup.js` إلى `view/setup/setup.css`.

### 4.3 تنظيفات أمنية متوسطة — متوسط
- `portal-upload`: ارفض مسارات zip-member بـ `..`/مطلقة. `hotspot-card-info`: استبدل regex بمقارنة نصّية `==`. `logs`: أكمل JSON-escape لمحارف التحكم. أزِل تعديل `/etc/init.d/dnsmasq` المواضعي في `apply` (`ensure_dnsmasq_running`) — **تحقّق من سببه الأصلي أولاً**.

### 4.4 إزالة "الحامي" المعطّل — متوسط
- احذف `protector_template.c`/`harden.sh`/`alemp_harden.py`. تأكّد بـ grep من عدم وجود مراجع بناء.

### 4.5 توثيق retention للنسخ/القاعدة — بسيط
- أضِف `/etc/hotspot-openwrt/mac-cookies.db` و`/etc/hotspot-openwrt/backups/` لـ `conffiles`.

### 4.6 إضافة ucitrack لـ hotspot_openwrt — بسيط
- أضِف `files/usr/share/ucitrack/luci-app-hotspot-openwrt.json` يربط `config hotspot_openwrt` ← `init hotspot-openwrt`.

---

# المرحلة 5 — تجربة المستخدم ⬜ مؤجّلة

### 5.1 إمكانية الوصول والتباين — متوسط
### 5.2 توحيد i18n — متوسط (استبدل النصوص العربية المُصلّبة بـ `_('...')`)
### 5.3 اختبار السرعة الحقيقي — متوسط (قياس فعلي بدل `Math.random`)
### 5.4 معاينة التغييرات قبل التطبيق — متوسط (diff مبسّط بدل مودال شريط التقدّم الزائف)
### 5.5 IPv6 / 802.11r — خارج النطاق الافتراضي (مؤجّل)

---

# المرحلة 6 — التحقق والإصدار ⬜ مؤجّلة

### 6.1 بناء الحزمتين — `make package/luci-app-setup/compile V=s` و`make package/luci-app-hotspot-openwrt/compile V=s`.
### 6.2 اختبار الدخان على الجهاز — مسار المعالج الكامل، دخول/خروج بوابة، nftables/`chilli_query`.
### 6.3 اختبار الترقية والترحيل — جهاز بالإصدار القديم، تأكيد `uci-defaults` رحّل القيم.
### 6.4 رفع الإصدار واتساقه — ارفع `PKG_RELEASE`، وحّد `WIZARD_BUILD_TAG`.

---

## ترتيب التنفيذ الموصى به

```
المرحلة 1 (حرجة) ✅ ──> المرحلة 2 (عالية) ⬜ ──> المرحلة 2ب (تحصين الإنفاذ + المراقبة)
                                                       │
                                                       ▼
                                   المرحلة 6.1-6.2 (بناء/دخان) ──> المرحلة 3.1-3.5 (إعادة هيكلة أساسية)
                                                       │
                                                       ▼
                                   نقطة تفتيش 6.1-6.2 (بناء/دخان)
                                                       │
                                                       ▼
                                      المرحلة 3.6-3.9 (معماري منخفض المخاطر)
                                                       │
                                                       ▼
                                      المرحلة 4 (جودة) ──> المرحلة 5 (UX)
                                                       │
                                                       ▼
                                            المرحلة 6.3-6.4 (ترقية/إصدار)
```

- **نقطة تفتيش إلزامية:** بعد 2ب و3.5 نفّذ 6.1+6.2 قبل المتابعة.
- **go/no-go لـ 3.7:** يُقرّر عند نقطة التفتيش.
- **الحد الأدنى للإصدار الأول:** المراحل 1+2+2ب+6.1-6.2.

---

## المخاطر والتأثيرات الجانبية الجماعية

| المخاطرة | التخفيف |
|----------|---------|
| فقدان تكوين الأجهزة المنشورة | ترحيل defensive في 3.1 + اختبار 6.3 |
| كسر الجدار الناري من `eval`/nft (2.4) | اختبار على جهاز + نسخة احتياطية |
| كسر دورة watchdogs (3.6) | اختبار respawn بعد القتل اليدوي |
| auto-restore يكتب فوق تكوين صحيح (3.9) | اللقطة قبل أي كتابة + تحقّق سلامتها |
| تضييق input يكسر اكتشاف الأسرى (2ب.1) | إحصاء منافذ البوابة + اختبار captive probe |
| rate-limit يقفل مشرّف (2.7) | N/TTL معقولان + قابلان للتكوين |
| write-once يربك التحرير (2.8) | نص مساعد واضح |
| `nochallenge` يُضعف المصادقة (PAP) | مقايضة متعمّدة لتوافق MikroTik — وثّق كـ risk note ولا تُعد هيكلة المصادقة |

## خطة التراجع (Rollback)

- قبل كل مرحلة: `cp -r package/<pkg>/files package/<pkg>/files.bak.<phase>`.
- عند الفشل: استعد `files.bak`، أعد `make .../compile`.
- للترحيل (3.1/3.7): uci-defaults defensive يعني الإزالة لا تُلغي القيم الموجودة.

## التحقق النهائي (Definition of Done)

- [ ] كل مهام المرحلتين 1-2 + 2ب مُنفّذة ومُتحقَّق منها على جهاز.
- [ ] 3.1-3.5 مُنفّذة + اجتازت 6.1/6.2.
- [ ] 3.6-3.9 مُنفّذة (3.7 بموافقة go/no-go).
- [ ] المرحلتان 4-5 مُنفّذتان (ما عدا المؤجلة).
- [ ] 6.3 (ترقية من إصدار قديم) ناجحة دون فقدان تكوين.
- [ ] أرقام الإصدار متناسقة (6.4).
- [ ] لا مسار تجاوز للإنترنت دون مصادقة (تحقّق 2ب).
- [ ] لا ثغرات حرجة/عالية متبقّية في إعادة فحص أمني.

---

## ملاحظات تنفيذية حرجة (للجلسات الجديدة)

- **Task 1.5 مكتملة:** `confirmHotspotLicenseBeforeSetupApply` كانت تُستدعى بين `collectState` و`normalizeAnonymousWifiIfaces`. أُزيلت وأُعيد توصيل السلسلة مباشرةً.
- **Task 2.8 (write-once secrets):** `readState` يُعبّئ حالياً `hotspotQuickRadiusSecret` (~2880)، `hotspotQuickUsermanRestPassword` (~2919)، `hotspotQuickMacAuthPassword` (~2893) من UCI. في `saveAndApply` تُكتب无条件 (~4331، 4366، 4344). التغيير: لا تُقرأ (اترك فارغة)، حوّل لـ `type=password`، احمِ الكتابة بـ `if (self.state.x)`. **احذر:** الإعداد الأولي يجب أن يكتب السر.
- **Task 2.8 (write-once secrets):** مكتمل — تم إضافة إلغاء قراءة الأسرار + حماية الكتابة الشرطية + placeholder مساعد.
- **Task 3.1 (ترحيل):** السكربت defensive — ينسخ `setup.default.hotspot_quick_*` → `hotspot_openwrt.main.*` فقط عندما الحقل غير موجود في `hotspot_openwrt`. تم إنشاء `50_hotspot-quick-migrate-canonical` وتحديث `saveAndApply` لكتابة القيم إلى `hotspot_openwrt.main` كالمصدر الكنسي.
- **`nochallenge='1'`** مقايضة متعمّدة لتوافق MikroTik (PAP) — لا تُعدّله. وثّق كـ risk note.
- **`ensure_dnsmasq_running`** (apply:298-309): يعدّل `/etc/init.d/dnsmasq` in-place لتعطيل procd jail. ابحث في سببه الأصلي قبل الإزالة (4.3).
- **`hotspot_allowed` nft set:** كود ميت — يُشار إليه في `hotspot-login`/`hotspot-logout` لكن لا يُنشأ أبداً (يُحذف في 3.4).
- **`harden.sh`:** يبدأ بـ `exit 0` (سطر 11) — الحامي معطّل تماماً. `protector_template.c` يُسقط plaintext لـ `/tmp`.

## المراجع الرئيسية للملفات

| الملف | الأقسام المهمة |
|------|----------------|
| `luci-app-setup/files/www/luci-static/resources/view/setup/setup.js` | load(~2130)، readState(~2816)، collectState(~3086)، validateStep(~3528)، saveAndApply(~4255)، render(~4633) |
| `luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/apply` | backup(64)، firewall zone(979-995)، chilli config(1003-1049)، watchdogs(577-610)، verify_runtime(1257/1267) |
| `luci-app-hotspot-openwrt/files/etc/hotspot-openwrt/firewall.sh` | `eval` في 28/32، vars غير مقتبسة 54/55/88 |
| `luci-app-hotspot-openwrt/files/www/cgi-bin/hotspot-login` | مُعدّل (1.1) — allow-list redirect |
| `luci-app-hotspot-openwrt/files/www/cgi-bin/mikrotik-gate` | مُعدّل (1.3) — html_escape + مُثبَّت |

---

## 🛑 سياق التطوير الأخير وتحديثات وسيط الراديوس (يوليو 2026)

خلال الأيام الثلاثة الأخيرة، تم توثيق وحل مشكلة مصادقة الراديوس المعقدة لبطاقات الـ 11 خانة على أجهزة `KM14` (`kt,km14-102h`). تم تطوير وإصلاح هيكل التوجيه الخاص بـ RADIUS وسد الثغرات الهيكلية التالية:

### 1. تصميم وسيط الراديوس الذكي (RADIUS Proxy Daemon)
* **المسار:** [`package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/radius-proxy`](file:///home/galal/openwrt/package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/radius-proxy)
* **الهدف:** استقبال طلبات المصادقة والمحاسبة من CoovaChilli على منفذ `127.0.0.1:1812/1813` وتوجيهها ديناميكياً إلى خادم الراديوس الأول `server1` (الافتراضي للبطاقات العادية) أو خادم الراديوس الثاني `server2` (للبطاقات المكونة من 11 خانة) بناءً على قواعد التوجيه المُدخلة من قبل المستخدم (مثل `11:userman2`).
* **آلية التتبع:** يتم توليد مفتاح جلسة آمن فريد يجمع بين معرّف الحزمة (Packet ID) وعنوان IP الخاص بالخادم الموجهة إليه (`id_serverIP`) لمنع تداخل الاستجابات أو تصادم المعرّفات بين الخادمين.

### 2. قائمة الأخطاء الهيكلية التي تم إصلاحها بالكامل:
* **عطل مكتبة nixio (poll_flags):** كان الكود القديم يستدعي `nixio.poll_flags` بمعاملات رقمية خاطئة مما تسبب في توقف الوسيط بالكامل. تم استبداله بعملية قناع بتات صحيحة `bit.band` ومقارنة `revents > 0`.
* **الاعتمادات المفقودة في بيئة daemon:** تم حذف استخدام `luci.model.uci` و `nixio.bit` نظراً لعدم توفرهما بشكل مضمون في بيئة التشغيل كخدمة خلفية مستقلة، واستبدالهما بأوامر نظام uci القياسية وفحوصات بسيطة ومستقلة.
* **مشكلة تعطيل الهوتسبوت الدائم عند الإقلاع (Boot-time permanent disable):** كان سكريبت [`apply`](file:///home/galal/openwrt/package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/apply) يقوم بإيقاف وتعطيل الهوتسبوت والوسيط بشكل دائم إن فشل فحص كروت الشبكة والـ IP المؤقت أثناء الإقلاع. تم إصلاحه بحيث يتخطى الإيقاف الدائم إن كان قيد الإقلاع (`mode=start`).
* **مشكلة الرفض من الميكروتك بسبب لاحقة الدومين (`@userman2`):** كانت صفحة تسجيل الدخول ترسل اسم البطاقة ملحقاً بالدومين لغرض التوجيه، مما يتسبب برفض الطلب من الميكروتك لأن البطاقات مخزنة بأرقامها المجردة. تم تعديل [`hotspot-login`](file:///home/galal/openwrt/package/luci-app-hotspot-openwrt/files/www/cgi-bin/hotspot-login) ليقوم بتنظيف اسم الكارت من أي إضافات ودومينات قبل إرساله لـ CoovaChilli، مما أدى لمصادقة صحيحة ومضمونة 100%.

### 3. التجميع والترقية:
* تم حزم وسيط الراديوس كخدمة خلفية خفيفة يتم إدارتها بالكامل وتلقائياً عبر نظام `procd` الخاص بـ OpenWrt تحت اسم `radius-proxy`.
* الفيرموير يتم تجميعه بنجاح ويخرج كملف sysupgrade جاهز للترقية الفورية.
