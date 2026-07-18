include $(TOPDIR)/rules.mk

PKG_NAME:=alemprator-guard
PKG_VERSION:=1.0
PKG_RELEASE:=2
PKG_LICENSE:=Proprietary

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/alemprator-guard
  SECTION:=base
  CATEGORY:=Alemprator
  TITLE:=Alemprator Guard - Hardware License Validator
  DEPENDS:=+libopenssl
endef

define Package/alemprator-guard/description
  Compiled binary that validates hardware authorization for
  the Alemprator Hotspot system. Contacts the Alemprator
  licensing server using HMAC-signed requests.
  Exit 0 = Authorized, Exit 1 = Not authorized.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-O2 -s \
		-o $(PKG_BUILD_DIR)/alemprator-guard \
		$(PKG_BUILD_DIR)/guard.c \
		-lssl -lcrypto
endef

define Package/alemprator-guard/install
	$(INSTALL_DIR) $(1)/usr/libexec/hotspot-openwrt
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/alemprator-guard \
		$(1)/usr/libexec/hotspot-openwrt/alemprator-guard
endef

$(eval $(call BuildPackage,alemprator-guard))
