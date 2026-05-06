include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-alemprator-ota
PKG_VERSION:=1.0
PKG_RELEASE:=30
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_LICENSE:=GPL-3.0-only
PKG_MAINTAINER:=ALemprator

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-alemprator-ota
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=ALemprator OTA Agent and UI
	DEPENDS:=+luci-base +rpcd +rpcd-mod-file +cgi-io +uclient-fetch +jsonfilter +libubox +ca-bundle +openssl-util
endef

define Package/luci-app-alemprator-ota/description
 Lightweight OTA identity and update system for ALemprator OpenWrt builds.
 Supports device registration, periodic update checks, staged rollout gates,
 update windows, retries, and a LuCI page under System -> System Update.
endef

define Package/luci-app-alemprator-ota/conffiles
/etc/config/alemprator_ota
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
endef

define Package/luci-app-alemprator-ota/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/alemprator_ota $(1)/etc/config/
	$(INSTALL_DIR) $(1)/etc/alemprator
	$(INSTALL_DATA) ./files/etc/alemprator/firmware-version $(1)/etc/alemprator/
	$(INSTALL_DATA) ./files/etc/alemprator/model-identities $(1)/etc/alemprator/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/alemprator-ota $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/95-alemprator-ota $(1)/etc/uci-defaults/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/etc/hotplug.d/iface/95-alemprator-ota $(1)/etc/hotplug.d/iface/
	$(INSTALL_DIR) $(1)/usr/libexec/alemprator-ota
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-ota/common.sh $(1)/usr/libexec/alemprator-ota/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-ota/agent.sh $(1)/usr/libexec/alemprator-ota/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-ota/run-once $(1)/usr/libexec/alemprator-ota/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-ota/manual-info $(1)/usr/libexec/alemprator-ota/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-ota/manual-clear $(1)/usr/libexec/alemprator-ota/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-ota/manual-update $(1)/usr/libexec/alemprator-ota/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-ota/start-check $(1)/usr/libexec/alemprator-ota/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-ota/start-manual-update $(1)/usr/libexec/alemprator-ota/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-ota/start-update $(1)/usr/libexec/alemprator-ota/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-ota/status-json $(1)/usr/libexec/alemprator-ota/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-ota/internet-check $(1)/usr/libexec/alemprator-ota/
	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d
	$(INSTALL_DATA) ./files/usr/share/luci/menu.d/luci-app-alemprator-ota.json $(1)/usr/share/luci/menu.d/
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./files/usr/share/rpcd/acl.d/luci-app-alemprator-ota.json $(1)/usr/share/rpcd/acl.d/
	$(INSTALL_DIR) $(1)/www/luci-static/resources/view/system
	$(INSTALL_DATA) ./files/www/luci-static/resources/view/system/ota.js $(1)/www/luci-static/resources/view/system/
	$(INSTALL_DATA) ./files/www/luci-static/resources/view/system/ota_v2.js $(1)/www/luci-static/resources/view/system/
	$(INSTALL_DIR) $(1)/etc/rc.d
	$(LN) ../init.d/alemprator-ota $(1)/etc/rc.d/S95alemprator-ota
endef

$(eval $(call BuildPackage,luci-app-alemprator-ota))
