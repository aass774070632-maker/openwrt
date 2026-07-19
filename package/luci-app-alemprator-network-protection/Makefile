include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-alemprator-network-protection
PKG_VERSION:=1.0
PKG_RELEASE:=8
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_LICENSE:=GPL-3.0-only
PKG_MAINTAINER:=ALemprator

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-alemprator-network-protection
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Alemprator Network Protection - Layer 2 Security UI
  DEPENDS:=+luci-base +alemprator-network-protection
  PKGARCH:=all
endef

define Package/luci-app-alemprator-network-protection/description
  Web interface for Alemprator Network Protection.
  Provides management of loop protection, broadcast/ARP storm detection,
  DHCP rogue detection, MAC flapping, port isolation, and RSTP.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
endef

define Package/luci-app-alemprator-network-protection/install
	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d
	$(INSTALL_DATA) ./files/usr/share/luci/menu.d/luci-app-alemprator-network-protection.json $(1)/usr/share/luci/menu.d/
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./files/usr/share/rpcd/acl.d/luci-app-alemprator-network-protection.json $(1)/usr/share/rpcd/acl.d/
	$(INSTALL_DIR) $(1)/www/luci-static/resources/view/network-protection
	$(INSTALL_DATA) ./htdocs/luci-static/resources/view/network-protection/overview.js $(1)/www/luci-static/resources/view/network-protection/
	$(INSTALL_DATA) ./htdocs/luci-static/resources/view/network-protection/loop.js $(1)/www/luci-static/resources/view/network-protection/
	$(INSTALL_DATA) ./htdocs/luci-static/resources/view/network-protection/broadcast.js $(1)/www/luci-static/resources/view/network-protection/
	$(INSTALL_DATA) ./htdocs/luci-static/resources/view/network-protection/arp.js $(1)/www/luci-static/resources/view/network-protection/
	$(INSTALL_DATA) ./htdocs/luci-static/resources/view/network-protection/dhcp-rogue.js $(1)/www/luci-static/resources/view/network-protection/
	$(INSTALL_DATA) ./htdocs/luci-static/resources/view/network-protection/mac-flapping.js $(1)/www/luci-static/resources/view/network-protection/
	$(INSTALL_DATA) ./htdocs/luci-static/resources/view/network-protection/port-isolation.js $(1)/www/luci-static/resources/view/network-protection/
	$(INSTALL_DATA) ./htdocs/luci-static/resources/view/network-protection/rstp.js $(1)/www/luci-static/resources/view/network-protection/
	$(INSTALL_DATA) ./htdocs/luci-static/resources/view/network-protection/logs.js $(1)/www/luci-static/resources/view/network-protection/
	$(INSTALL_DATA) ./htdocs/luci-static/resources/view/network-protection/statistics.js $(1)/www/luci-static/resources/view/network-protection/
	$(INSTALL_DATA) ./htdocs/luci-static/resources/view/network-protection/advanced.js $(1)/www/luci-static/resources/view/network-protection/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./uci-defaults/luci-app-alemprator-network-protection $(1)/etc/uci-defaults/90_luci-app-alemprator-network-protection
endef

$(eval $(call BuildPackage,luci-app-alemprator-network-protection))
