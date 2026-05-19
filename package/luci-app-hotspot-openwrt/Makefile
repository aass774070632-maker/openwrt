include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-hotspot-openwrt
PKG_VERSION:=1.0
PKG_RELEASE:=r33
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
# PKGARCH:=all (Disabled to allow architecture-specific binaries)
PKG_LICENSE:=GPL-3.0-only

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-hotspot-openwrt
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI Hotspot OpenWrt wizard for CoovaChilli and MikroTik RADIUS
	DEPENDS:=+luci-base +rpcd +rpcd-mod-file +uhttpd +coova-chilli +kmod-tun +alemprator-guard
endef

define Package/luci-app-hotspot-openwrt/description
 LuCI wizard and backend engine for turning OpenWrt into a CoovaChilli
 captive portal authenticated by MikroTik User Manager through RADIUS UDP.
endef

define Package/luci-app-hotspot-openwrt/conffiles
/etc/config/hotspot_openwrt
/etc/config/hotspot_licensing
/etc/hotspot-openwrt/firewall.sh
endef

define Package/luci-app-hotspot-openwrt/postinst
#!/bin/sh
[ "$${IPKG_NO_SCRIPT}" = "1" ] && exit 0
rm -f "$${IPKG_INSTROOT}/tmp/luci-indexcache" "$${IPKG_INSTROOT}"/tmp/luci-indexcache.*.json
[ -n "$${IPKG_INSTROOT}" ] && exit 0
ln -sf /usr/libexec/hotspot-openwrt/init.d/hotspot-openwrt /etc/init.d/hotspot-openwrt
/etc/init.d/rpcd reload >/dev/null 2>&1 || true
/etc/init.d/uhttpd reload >/dev/null 2>&1 || true
filelist=/dev/null
exit 0
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
endef

define Package/luci-app-hotspot-openwrt/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/hotspot_openwrt $(1)/etc/config/
	$(INSTALL_CONF) ./files/etc/config/hotspot_licensing $(1)/etc/config/
	$(INSTALL_DIR) $(1)/etc/hotspot-openwrt
	$(INSTALL_BIN) ./files/etc/hotspot-openwrt/firewall.sh $(1)/etc/hotspot-openwrt/
	$(INSTALL_DIR) $(1)/usr/libexec/hotspot-openwrt/init.d
	$(INSTALL_BIN) ./files/etc/init.d/hotspot-openwrt $(1)/usr/libexec/hotspot-openwrt/init.d/
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
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/portal-upload $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/phase2-smoke $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/phase2-client-sim $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/phase3-rc-gate $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/presence-watchdog $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/status-json $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/kick-client $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/userman-info $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/validate $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/license-check $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_DIR) $(1)/etc/chilli
	$(INSTALL_BIN) ./files/etc/chilli/up.sh $(1)/etc/chilli/
	$(INSTALL_BIN) ./files/etc/chilli/down.sh $(1)/etc/chilli/
	$(INSTALL_BIN) ./files/etc/chilli/conup.sh $(1)/etc/chilli/
	$(INSTALL_BIN) ./files/etc/chilli/condown.sh $(1)/etc/chilli/
	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d
	$(INSTALL_DATA) ./files/usr/share/luci/menu.d/luci-app-hotspot-openwrt.json $(1)/usr/share/luci/menu.d/
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./files/usr/share/rpcd/acl.d/luci-app-hotspot-openwrt.json $(1)/usr/share/rpcd/acl.d/
	$(INSTALL_DIR) $(1)/www/luci-static/resources/view/services
	$(INSTALL_DATA) ./files/www/luci-static/resources/view/services/hotspot-openwrt.js $(1)/www/luci-static/resources/view/services/
	$(INSTALL_DIR) $(1)/www/hotspot
	$(INSTALL_DATA) ./files/www/hotspot/login.html $(1)/www/hotspot/
	$(INSTALL_DATA) ./files/www/hotspot/status.html $(1)/www/hotspot/
	$(INSTALL_DATA) ./files/www/hotspot/terms.html $(1)/www/hotspot/
	$(INSTALL_DATA) ./files/www/hotspot/style.css $(1)/www/hotspot/
	$(INSTALL_DATA) ./files/www/hotspot/settings.js $(1)/www/hotspot/
	$(INSTALL_DATA) ./files/www/hotspot/api.json $(1)/www/hotspot/
	$(INSTALL_DIR) $(1)/www/cgi-bin
	$(INSTALL_BIN) ./files/www/cgi-bin/generate_204 $(1)/www/cgi-bin/
	$(INSTALL_BIN) ./files/www/cgi-bin/hotspot-login $(1)/www/cgi-bin/
	$(INSTALL_BIN) ./files/www/cgi-bin/hotspot-card-info $(1)/www/cgi-bin/
	$(INSTALL_BIN) ./files/www/cgi-bin/hotspot-logout $(1)/www/cgi-bin/
	$(INSTALL_BIN) ./files/www/cgi-bin/hotspot-speedtest $(1)/www/cgi-bin/
	
	# Alemprator Guard: Hardening Step
	# Compiles scripts to binary to prevent theft
	# We export STAGING_DIR so the compiler can find its headers/libs
	export STAGING_DIR=$(STAGING_DIR); \
	SHC_BIN=$$(find $(STAGING_DIR_HOST)/bin -name shc | head -n 1); \
	[ -z "$$SHC_BIN" ] && SHC_BIN=$$(find $(TOPDIR)/tools/shc -name shc -type f -executable | head -n 1); \
	bash $(CURDIR)/scripts/harden.sh "$$SHC_BIN" "$(TARGET_CC)" "$(1)"
endef

$(eval $(call BuildPackage,luci-app-hotspot-openwrt))