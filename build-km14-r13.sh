#!/bin/sh
# =============================================================================
# build-km14-r13.sh  —  مسودة موثّقة لبناء صورة نظام كاملة لجهاز KM14
# الجهاز: ramips/mt7621  (kt_km14-102h)
# الهدف:  تكرار بناء v1.0-r13 بشكل قابل للتحقق (مع كل إصلاحات الهوتسبوت)
#
# ⚠️ هذا السكربت "مسودة للمراجعة" — لم يُنفَّذ. راجعه قبل التشغيل.
# ⚠️ يفترض أنك داخل مجلد مصدر OpenWrt (/home/galal/openwrt).
# =============================================================================

set -e

# --- 1) اختيار ملف config أساس لـ KM14 ---------------------------------------
# أحدث config متوفر لـ KM14. عدّله حسب الحاجة.
BASE_CONFIG="KT-KM14-102H-11-05-2026.config"

# --- 2) وضع الـ config النشط ------------------------------------------------
cp "$BASE_CONFIG" .config
make defconfig

# --- 5) تفعيل الخيارات الحرجة صراحةً (لأن BASE_CONFIG لا يفعلها) ------------
#     هذه هي الخيارات التي جعلت r13 تعمل: chilli_redir + proxy + HTB shaping
sed -i 's/^# CONFIG_COOVACHILLI_REDIR is not set/CONFIG_COOVACHILLI_REDIR=y/' .config
sed -i 's/^# CONFIG_COOVACHILLI_PROXY is not set/CONFIG_COOVACHILLI_PROXY=y/' .config
sed -i 's/^# CONFIG_COOVACHILLI_NOSSL is not set/CONFIG_COOVACHILLI_NOSSL=y/'   .config

# تفعيل وحدة نواة HTB لتحديد السرعات (يجب أن تكون =y مدمجة لا module)
sed -i 's/^# CONFIG_KERNEL_NET_SCH_HTB is not set/CONFIG_KERNEL_NET_SCH_HTB=y/' .config

# التأكد من اختيار جهاز KM14 وتفعيل حزمة الهوتسبوت
sed -i 's/^# CONFIG_TARGET_ramips_mt7621_DEVICE_kt_km14-102h is not set/CONFIG_TARGET_ramips_mt7621_DEVICE_kt_km14-102h=y/' .config
sed -i 's/^# CONFIG_PACKAGE_luci-app-hotspot-openwrt is not set/CONFIG_PACKAGE_luci-app-hotspot-openwrt=y/' .config

# إعادة توليد الـ defconfig بعد التعديلات لضمان اتساق التبعيات
make defconfig

# --- 4) حفظ نسخة من الـ config الفعلي المستخدم في هذا البناء (توثيق) --------
mkdir -p releases/v1.0-r13/km14
cp .config "releases/v1.0-r13/km14/r13-km14.config"

# --- 5) البناء ---------------------------------------------------------------
#     V=s لعرض التفاصيل عند الفشل. غيّر -j حسب عدد الأنوية.
make -j"$(nproc)" V=s

# --- 6) جمع المخرجات إلى مجلد النسخة -----------------------------------------
BIN="bin/targets/ramips/mt7621"
cp "$BIN/openwrt-ramips-mt7621-kt_km14-102h-squashfs-factory.bin"   releases/v1.0-r13/km14/
cp "$BIN/openwrt-ramips-mt7621-kt_km14-102h-squashfs-sysupgrade.bin" releases/v1.0-r13/km14/
cp "$BIN/openwrt-ramips-mt7621-kt_km14-102h.manifest"               releases/v1.0-r13/km14/
cp bin/packages/mipsel_24kc/base/luci-app-hotspot-openwrt_*.ipk     releases/v1.0-r13/km14/ 2>/dev/null || \
cp bin/packages/mipsel_24kc/packages/luci-app-hotspot-openwrt_*.ipk releases/v1.0-r13/km14/ 2>/dev/null || true
cp bin/packages/mipsel_24kc/packages/coova-chilli_*.ipk             releases/v1.0-r13/km14/ 2>/dev/null || true

# --- 7) توليد sha256sums للتحقق (كان مفقوداً في r13) -------------------------
cd releases/v1.0-r13/km14 && sha256sum * > sha256sums && cd -

echo "=== تم البناء. المخرجات في releases/v1.0-r13/km14/ ==="
ls -la releases/v1.0-r13/km14/
