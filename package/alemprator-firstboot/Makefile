include $(TOPDIR)/rules.mk

PKG_NAME:=alemprator-firstboot
PKG_VERSION:=1.0
PKG_RELEASE:=22
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKGARCH:=all
PKG_LICENSE:=GPL-3.0-only

include $(INCLUDE_DIR)/package.mk

define Package/alemprator-firstboot
  SECTION:=utils
  CATEGORY:=Utilities
	TITLE:=ALemprator First Boot Provisioning
	DEPENDS:=+dnsmasq +firewall4 +luci-app-setup
endef

define Package/alemprator-firstboot/description
 Independent first-boot provisioning layer for ALemprator devices.
  Provides a LAN interface on 192.168.1.20 and a temporary isolated setup network on 192.168.8.1
 and lets luci-app-setup disable it safely after the first successful apply.
endef

define Package/alemprator-firstboot/conffiles
/etc/config/alemprator_firstboot
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
endef

define Package/alemprator-firstboot/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/alemprator_firstboot $(1)/etc/config/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/alemprator-firstboot $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/99-alemprator-firstboot $(1)/etc/uci-defaults/
	$(INSTALL_DIR) $(1)/usr/share/ucitrack
	$(INSTALL_DATA) ./files/usr/share/ucitrack/alemprator-firstboot-dhcp.json $(1)/usr/share/ucitrack/
	$(INSTALL_DATA) ./files/usr/share/ucitrack/alemprator-firstboot-firewall.json $(1)/usr/share/ucitrack/
	$(INSTALL_DATA) ./files/usr/share/ucitrack/alemprator-firstboot-network.json $(1)/usr/share/ucitrack/
	$(INSTALL_DATA) ./files/usr/share/ucitrack/alemprator-firstboot-setup.json $(1)/usr/share/ucitrack/
	$(INSTALL_DATA) ./files/usr/share/ucitrack/alemprator-firstboot-wireless.json $(1)/usr/share/ucitrack/
	$(INSTALL_DIR) $(1)/etc/rc.d
	$(LN) ../init.d/alemprator-firstboot $(1)/etc/rc.d/S98alemprator-firstboot
endef

$(eval $(call BuildPackage,alemprator-firstboot))