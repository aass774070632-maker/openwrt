# توثيق نظام الإعداد الأولي والهوتسبوت

## المكونات
| الملف | رقم التنفيذ | الوظيفة |
|-------|-------------|---------|
| `40_luci-app-setup` | 40 | ينشئ `/etc/config/setup` مع `initial_setup_complete=0` |
| `98_custom` | 98 | يضبط IP والـ SSID النهائية. يوقف DHCP فقط بعد اكتمال الإعداد |
| `99-alemprator-firstboot` | 99 | ينشئ شبكة البرمجة المؤقتة (ALemprator-KT-KM14-102H) |
| `alemprator-firstboot init` | START=98 | يراقب إعدادات المستخدم وينظف الشبكة المؤقتة |

## التدفق (First Boot)

### 1. uci-defaults (ترتيب أبجدي)
```
40_luci-app-setup  →  ينشئ setup.default
98_custom          →  initial_complete=0 → يضبط IP/SSID ويطلع
99-alemprator-firstboot  →  initial_complete=0 → ينشئ:
                            • network.alemprator_setup   (192.168.8.1/24)
                            • dhcp.alemprator_setup      (pool 100-149)
                            • wireless.alemprator_firstboot  (SSID: ALemprator...)
                            • firewall.alemprator_setup  (ACCEPT)
                         →  يعطل باقي WiFi
                         →  يشغل dnsmasq (fallback مباشر إذا فشل jail)
                         →  يشغل captive portal (nftables + uhttpd)
```

### 2. Init scripts
```
/etc/init.d/alemprator-firstboot start:
  • setup_captive_portal() : dnsmasq restart + nftables redirect
  • monitor_once() : يفحص كل 5 ثواني هل تغيرت الإعدادات
```

### 3. المستخدم يتصل بـ "ALemprator-KT-KM14-102H"
```
WiFi → DHCP → 192.168.8.x → Captive Portal → LuCI Setup Wizard
```

### 4. المستخدم يكمل الإعداد ويحفظ
```
Setup Wizard Save:
  1. uci.set('setup.default.initial_setup_complete', '1')
  2. disableFirstbootProvisioning():
     • تحذف network.alemprator_setup, dhcp.alemprator_setup
     • تحذف wireless.alemprator_firstboot  (ALemprator يختفي فوراً)
     • تحذف firewall.alemprator_setup
     • توقف DHCP اللان (dhcp.lan.ignore=1)
     • توقف firstboot (enabled=0, configured_once=1)
  3. تطبق إعدادات الهوتسبوت النهائية
  4. إعادة تشغيل
```

### 5. Second Boot (بعد الإعداد)
```
98_custom: initial_complete=1 → يطبق bridge mode كامل:
  • يوقف DHCP (dhcp.lan.ignore=1)
  • يضبط bridge ports (حسب hotspot)
  • يضبط SSIDs النهائية
  • يكتب rc.local مع dnsmasq disable (if bridge mode)
  • يعطل dnsmasq, odhcpd, log, firewall

99-alemprator-firstboot: configured_once=1 → يخرج فوراً (ما يعيد الشبكة)
```

## المشاكل والحلول

### 1. DHCP لا يعمل على شبكة ALemprator
- **السبب**: dnsmasq ujail يفشل في التشغيل (مشكلة بناء)
- **الحل**: Fallback مباشر: إذا فشل dnsmasq restart، نشتغله بدون jail

### 2. 98_custom يوقف DHCP قبل الإعداد
- **السبب**: 98_custom كان يوقف DHCP دائماً حتى في أول إقلاع
- **الحل**: أضفنا تحقق `initial_complete != 1` → يضبط IP/SSID ويطلع فقط

### 3. شبكة ALemprator ترجع بعد الإعداد
- **السبب**: 99-alemprator-firstboot يعيد إنشائها إذا لم يتم تنظيف flags
- **الحل**: setup wizard ينظف كل flags + init script يراقب ويتأكد من الحذف

## التعديلات المطبقة (r19)

| التعديل | الملف |
|---------|-------|
| 98_custom لا يوقف DHCP في أول إقلاع | `98_custom:33-44` |
| Fallback dnsmasq مباشر | `99-alemprator-firstboot:213-216` |
| Fallback dnsmasq في init script | `alemprator-firstboot:143-151, 249-255, 274-280` |
