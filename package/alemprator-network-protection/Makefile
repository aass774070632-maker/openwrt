include $(TOPDIR)/rules.mk

PKG_NAME:=alemprator-network-protection
PKG_VERSION:=1.0
PKG_RELEASE:=11
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKGARCH:=all
PKG_LICENSE:=GPL-3.0-only
PKG_MAINTAINER:=ALemprator

include $(INCLUDE_DIR)/package.mk

define Package/alemprator-network-protection
  SECTION:=base
  CATEGORY:=Alemprator
  TITLE:=Alemprator Network Protection - Layer 2 Security Suite
  DEPENDS:=+ip-full +bridge +nftables +jshn +ucode +ucode-mod-fs +ucode-mod-ubus +rpcd +rpcd-mod-file +rpcd-mod-ucode
endef

define Package/alemprator-network-protection/description
  Alemprator Network Protection provides Layer 2 network security
  including loop detection, broadcast/ARP storm detection, DHCP rogue
  detection, MAC flapping detection, port isolation, and RSTP management.
  Event-driven, low-footprint design for embedded OpenWrt devices.
endef

define Package/alemprator-network-protection/conffiles
/etc/config/alemprator-network-protection
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/ 2>/dev/null || true
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-O2 -s -Wall \
		-o $(PKG_BUILD_DIR)/np-monitor \
		$(PKG_BUILD_DIR)/np-monitor.c 2>/dev/null || true
endef

define Package/alemprator-network-protection/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/alemprator-network-protection $(1)/etc/config/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/alemprator-network-protection $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/etc/hotplug.d/iface/99-alemprator-network-protection $(1)/etc/hotplug.d/iface/
	$(INSTALL_DIR) $(1)/usr/libexec/alemprator-network-protection
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-network-protection/common.sh $(1)/usr/libexec/alemprator-network-protection/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-network-protection/monitor $(1)/usr/libexec/alemprator-network-protection/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-network-protection/event-dispatcher $(1)/usr/libexec/alemprator-network-protection/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-network-protection/detector $(1)/usr/libexec/alemprator-network-protection/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-network-protection/action-manager $(1)/usr/libexec/alemprator-network-protection/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-network-protection/rstp-manager $(1)/usr/libexec/alemprator-network-protection/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-network-protection/port-isolation $(1)/usr/libexec/alemprator-network-protection/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-network-protection/logger $(1)/usr/libexec/alemprator-network-protection/
	$(INSTALL_DIR) $(1)/usr/libexec/alemprator-network-protection/modules
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-network-protection/modules/loop $(1)/usr/libexec/alemprator-network-protection/modules/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-network-protection/modules/broadcast $(1)/usr/libexec/alemprator-network-protection/modules/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-network-protection/modules/arp $(1)/usr/libexec/alemprator-network-protection/modules/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-network-protection/modules/dhcp-rogue $(1)/usr/libexec/alemprator-network-protection/modules/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-network-protection/modules/mac-flapping $(1)/usr/libexec/alemprator-network-protection/modules/
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./files/usr/share/rpcd/acl.d/alemprator-network-protection.json $(1)/usr/share/rpcd/acl.d/
	$(INSTALL_DIR) $(1)/usr/share/rpcd/ucode
	$(INSTALL_DATA) ./files/usr/share/rpcd/ucode/alemprator-network-protection $(1)/usr/share/rpcd/ucode/
	$(INSTALL_DIR) $(1)/etc/rc.d
	$(LN) ../init.d/alemprator-network-protection $(1)/etc/rc.d/S98alemprator-network-protection
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/np-monitor $(1)/usr/libexec/alemprator-network-protection/ 2>/dev/null || true
endef

$(eval $(call BuildPackage,alemprator-network-protection))
