include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-alemprator-dhcp
PKG_VERSION:=1.0
PKG_RELEASE:=2
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

PKG_LICENSE:=Proprietary
PKG_MAINTAINER:=ALEMPRATOR

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-alemprator-dhcp
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Alemprator Advanced DHCP Server & Sentinel
  DEPENDS:=+luci-base +libuci +libopenssl +rpcd-mod-file +rpcd-mod-iwinfo
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)/src
	$(CP) ./src/* $(PKG_BUILD_DIR)/src/
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/src \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -Wall" \
		LDFLAGS="$(TARGET_LDFLAGS) -lcrypto -luci" \
		all
endef

define Package/luci-app-alemprator-dhcp/install
	$(INSTALL_DIR) $(1)/usr/libexec/alemprator-dhcp
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/dhcp-sentinel $(1)/usr/libexec/alemprator-dhcp/
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,luci-app-alemprator-dhcp))
