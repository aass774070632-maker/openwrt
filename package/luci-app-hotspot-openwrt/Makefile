include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-hotspot-openwrt
PKG_VERSION:=1.0
PKG_RELEASE:=163
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKGARCH:=all
PKG_LICENSE:=GPL-3.0-only

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp ./src/mikrotik_api.c $(PKG_BUILD_DIR)/
	cp ./src/md5.c $(PKG_BUILD_DIR)/
	cp ./src/md5.h $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) -o $(PKG_BUILD_DIR)/mikrotik_api \
		$(PKG_BUILD_DIR)/mikrotik_api.c $(PKG_BUILD_DIR)/md5.c
endef

define Package/luci-app-hotspot-openwrt
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI Hotspot OpenWrt wizard for CoovaChilli and MikroTik RADIUS
  DEPENDS:=+luci-base +rpcd +rpcd-mod-file +uhttpd +coova-chilli +kmod-tun +ip-full +jsonfilter +unzip
endef

define Package/luci-app-hotspot-openwrt/description
 LuCI wizard and backend engine for turning OpenWrt into a CoovaChilli
 captive portal authenticated by MikroTik User Manager through RADIUS UDP.
endef

define Package/luci-app-hotspot-openwrt/conffiles
/etc/config/hotspot_openwrt
/etc/hotspot-openwrt/firewall.sh
/etc/hotspot-openwrt/mac-cookies.db
endef

define Package/luci-app-hotspot-openwrt/postinst
#!/bin/sh
[ "$${IPKG_NO_SCRIPT}" = "1" ] && exit 0
rm -f "$${IPKG_INSTROOT}/tmp/luci-indexcache" "$${IPKG_INSTROOT}"/tmp/luci-indexcache.*.json
[ -n "$${IPKG_INSTROOT}" ] && exit 0
/etc/init.d/uhttpd reload >/dev/null 2>&1 || true
# Warn if a deployed device still uses a known-weak default secret so the admin
# changes it (1.4 only changed defaults for new installs; existing values are
# preserved to avoid breaking auth).
_sec="$$(uci -q get hotspot_openwrt.main.radius_secret 2>/dev/null)"
_macpw="$$(uci -q get hotspot_openwrt.main.mac_auth_password 2>/dev/null)"
[ "$_sec" = '123456' ] && logger -t hotspot-openwrt 'WARNING: radius_secret is still the weak default "123456". Set a strong RADIUS shared secret.'
[ "$_macpw" = 'mac' ] && logger -t hotspot-openwrt 'WARNING: mac_auth_password is still the weak default "mac". Set a strong password or disable MAC auth.'
filelist=/dev/null
# Hotspot يعتمد على RADIUS attributes (Session-Timeout, Max-Total-Octets) للوقت المتبقي والبيانات المتبقية.
# REST API يُستدعى مرة واحدة عند تسجيل الدخول لجلب اسم البروفايل والرصيد وتاريخ الانتهاء.
# تأكد من إعداد User Manager:
# 1. /user-manager/profile/set [find] session-timeout=86400
# 2. /user-manager/profile/set [find] max-total-octets=БАЙТ
# تأكد من إعدادات REST API في Hotspot OpenWrt (إعدادات → REST API).
exit 0
endef

define Package/luci-app-hotspot-openwrt/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/hotspot_openwrt $(1)/etc/config/
	$(INSTALL_DIR) $(1)/etc/hotspot-openwrt
	$(INSTALL_BIN) ./files/etc/hotspot-openwrt/firewall.sh $(1)/etc/hotspot-openwrt/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/hotspot-openwrt $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/etc/init.d/chilli $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/etc/init.d/radius-proxy $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/99_hotspot-openwrt-firewall $(1)/etc/uci-defaults/
	$(INSTALL_DIR) $(1)/usr/libexec/hotspot-openwrt
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/apply $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/export-config $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/gen-ssl $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/import-config $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/kick-client $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/logs $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/mac-cookies $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/mac-cookie-watchdog $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/maint-watchdog $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/portal-upload $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/presence-watchdog $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/status-json $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/test-radius $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/connectivity-test $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/enforcement-check $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/radius-proxy $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/userman-info $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mikrotik_api $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_DIR) $(1)/www/cgi-bin
	$(INSTALL_BIN) ./files/www/cgi-bin/generate_204 $(1)/www/cgi-bin/
	$(INSTALL_BIN) ./files/www/cgi-bin/hotspot-card-info $(1)/www/cgi-bin/
	$(INSTALL_BIN) ./files/www/cgi-bin/hotspot-login $(1)/www/cgi-bin/
	$(INSTALL_BIN) ./files/www/cgi-bin/hotspot-logout $(1)/www/cgi-bin/
	$(INSTALL_BIN) ./files/www/cgi-bin/mikrotik-gate $(1)/www/cgi-bin/
	$(INSTALL_DIR) $(1)/etc/chilli
	$(INSTALL_BIN) ./files/etc/chilli/up.sh $(1)/etc/chilli/
	$(INSTALL_BIN) ./files/etc/chilli/down.sh $(1)/etc/chilli/
	$(INSTALL_BIN) ./files/etc/chilli/conup.sh $(1)/etc/chilli/
	$(INSTALL_BIN) ./files/etc/chilli/condown.sh $(1)/etc/chilli/
	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d
	$(INSTALL_DATA) ./files/usr/share/luci/menu.d/luci-app-hotspot-openwrt.json $(1)/usr/share/luci/menu.d/
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./files/usr/share/rpcd/acl.d/luci-app-hotspot-openwrt.json $(1)/usr/share/rpcd/acl.d/
	$(INSTALL_DIR) $(1)/usr/share/ucitrack
	$(INSTALL_DATA) ./files/usr/share/ucitrack/luci-app-hotspot-openwrt.json $(1)/usr/share/ucitrack/
	$(INSTALL_DIR) $(1)/www/luci-static/resources/view/services
	$(INSTALL_DATA) ./files/www/luci-static/resources/view/services/hotspot-openwrt.js $(1)/www/luci-static/resources/view/services/
	$(INSTALL_DATA) ./files/www/luci-static/resources/view/services/hotspot-openwrt.css $(1)/www/luci-static/resources/view/services/
	$(INSTALL_DIR) $(1)/www/luci-static/resources
	$(INSTALL_DATA) ./files/www/luci-static/resources/hotspot-openwrt.css $(1)/www/luci-static/resources/
	$(INSTALL_DIR) $(1)/www/hotspot
	$(INSTALL_DATA) ./files/www/hotspot/login.html $(1)/www/hotspot/
	$(INSTALL_DATA) ./files/www/hotspot/status.html $(1)/www/hotspot/
	$(INSTALL_DATA) ./files/www/hotspot/terms.html $(1)/www/hotspot/
	$(INSTALL_DATA) ./files/www/hotspot/style.css $(1)/www/hotspot/
	$(INSTALL_DATA) ./files/www/hotspot/settings.js $(1)/www/hotspot/
	$(INSTALL_DATA) ./files/www/hotspot/api.json $(1)/www/hotspot/
endef

$(eval $(call BuildPackage,luci-app-hotspot-openwrt))
