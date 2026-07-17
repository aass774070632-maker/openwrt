include $(TOPDIR)/rules.mk

PKG_NAME:=alemprator-suite
PKG_VERSION:=1.0
PKG_RELEASE:=2
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKGARCH:=all
PKG_LICENSE:=GPL-3.0-only

include $(INCLUDE_DIR)/package.mk

define Package/alemprator-suite
  SECTION:=base
  CATEGORY:=Base system
  TITLE:=Unified Alemprator Suite (firstboot, setup, OTA)
  DEPENDS:=+alemprator-firstboot +luci-app-setup +luci-app-alemprator-ota +alemprator-network-protection +luci-app-alemprator-network-protection +luci-app-alemprator-dhcp +luci-app-hotspot-openwrt +alemprator-mtax
endef

define Package/alemprator-suite/description
 Unified package: firstboot, LuCI setup, and OTA agent for supported Alemprator devices.
endef

define Build/Prepare
endef

define Build/Compile
endef

define Package/alemprator-suite/install
	# No direct install, meta-package only
endef

$(eval $(call BuildPackage,alemprator-suite))
