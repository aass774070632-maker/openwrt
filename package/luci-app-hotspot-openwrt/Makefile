include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-hotspot-openwrt
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKGARCH:=all
PKG_LICENSE:=GPL-3.0-only

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-hotspot-openwrt
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI Hotspot OpenWrt wizard for CoovaChilli and MikroTik RADIUS
  DEPENDS:=+luci-base +rpcd +rpcd-mod-file +uhttpd +coova-chilli +kmod-tun +iptables-nft
endef

define Package/luci-app-hotspot-openwrt/description
 LuCI wizard and backend engine for turning OpenWrt into a CoovaChilli
 captive portal authenticated by MikroTik User Manager through RADIUS UDP.
endef

define Package/luci-app-hotspot-openwrt/conffiles
/etc/config/hotspot_openwrt
endef

define Package/luci-app-hotspot-openwrt/postinst
#!/bin/sh
[ "$${IPKG_NO_SCRIPT}" = "1" ] && exit 0
rm -f "$${IPKG_INSTROOT}/tmp/luci-indexcache" "$${IPKG_INSTROOT}"/tmp/luci-indexcache.*.json
[ -n "$${IPKG_INSTROOT}" ] && exit 0
/etc/init.d/rpcd reload >/dev/null 2>&1 || true
/etc/init.d/uhttpd reload >/dev/null 2>&1 || true
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
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/hotspot-openwrt $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/usr/libexec/hotspot-openwrt
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/apply $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/mac-cookies $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/portal-upload $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/presence-watchdog $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/status-json $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/userman-info $(1)/usr/libexec/hotspot-openwrt/
	$(INSTALL_BIN) ./files/usr/libexec/hotspot-openwrt/validate $(1)/usr/libexec/hotspot-openwrt/
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
	$(INSTALL_BIN) ./files/www/cgi-bin/hotspot-login $(1)/www/cgi-bin/
	$(INSTALL_BIN) ./files/www/cgi-bin/hotspot-card-info $(1)/www/cgi-bin/
	$(INSTALL_BIN) ./files/www/cgi-bin/hotspot-logout $(1)/www/cgi-bin/
endef

$(eval $(call BuildPackage,luci-app-hotspot-openwrt))