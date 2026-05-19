include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-setup
PKG_VERSION:=1.0
PKG_RELEASE:=120
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKGARCH:=all
PKG_LICENSE:=GPL-3.0-only

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-setup
  SECTION:=luci
  CATEGORY:=LuCI
	TITLE:=LuCI Support for ALemprator Setup
	DEPENDS:=+luci-base +luci-theme-bootstrap +rpcd
endef

define Package/luci-app-setup/description
 Portable ALemprator LuCI frontend for standard OpenWrt LAN, Wi-Fi and button policies.
 Optional backend binaries may still be used on targets where they are available.
 When luci-app-hotspot-openwrt is also installed, the setup wizard gains a quick-setup
 step for CoovaChilli + MikroTik RADIUS (Hotspot) without opening the separate hotspot page.
endef

define Package/luci-app-setup/conffiles
/etc/config/setup
endef

define Package/luci-app-setup/postinst
#!/bin/sh
[ -n "$$IPKG_INSTROOT" ] && exit 0

base_ssid="$$(uci -q get setup.default.wifi_ssid)"
manual_ssid_2g="$$(uci -q get setup.default.wifi_ssid_vlan_2g)"
[ -n "$$manual_ssid_2g" ] || manual_ssid_2g="$$(uci -q get setup.default.wifi_ssid_vlan)"
manual_ssid_5g="$$(uci -q get setup.default.wifi_ssid_vlan_5g)"
primary_ssid_5g_mode="$$(uci -q get setup.default.wifi_ssid_5g_mode)"
primary_ssid_5g_custom="$$(uci -q get setup.default.wifi_ssid_5g)"
lan_ipaddr="$$(uci -q get network.lan.ipaddr)"
[ -n "$$lan_ipaddr" ] || lan_ipaddr="$$(uci -q get setup.default.lan_ipaddr)"
ip_suffix=''
case "$$lan_ipaddr" in
	*.*.*.*) ip_suffix="$$(printf '%s' "$$lan_ipaddr" | awk -F. 'NF == 4 { print $$3 "." $$4 }')" ;;
esac
append_ip_suffix() {
	local value="$$1"
	[ "$$(uci -q get setup.default.wifi_ssid_vlan_ip_suffix)" = '1' ] || { printf '%s' "$$value"; return; }
	[ -n "$$value" ] || { printf '%s' "$$value"; return; }
	[ -n "$$ip_suffix" ] || { printf '%s' "$$value"; return; }
	case "$$value" in *"_$$ip_suffix") printf '%s' "$$value" ;; *) printf '%s_%s' "$$value" "$$ip_suffix" ;; esac
}
secondary_2g="$${manual_ssid_2g:-$${base_ssid}_VLAN}"
secondary_2g="$$(append_ip_suffix "$$secondary_2g")"
secondary_5g="$${manual_ssid_5g:-$${secondary_2g}_5G}"
[ -n "$$manual_ssid_5g" ] && secondary_5g="$$(append_ip_suffix "$$manual_ssid_5g")"
primary_2g="$$(append_ip_suffix "$$base_ssid")"
primary_5g="$${primary_2g}_5G"
[ "$$primary_ssid_5g_mode" = 'custom' ] && [ -n "$$primary_ssid_5g_custom" ] && primary_5g="$$(append_ip_suffix "$$primary_ssid_5g_custom")"
changed=0

[ -n "$$base_ssid" ] || exit 0

for section in $$(uci show wireless 2>/dev/null | sed -n "s/^wireless\.\([^.=]*\)=wifi-iface$$/\1/p"); do
	[ "$$(uci -q get wireless.$$section.mode)" = 'ap' ] || continue
	network="$$(uci -q get wireless.$$section.network)"
	[ "$$network" = 'lan' ] || [ "$$network" = 'wizardvlan' ] || continue

	device="$$(uci -q get wireless.$$section.device)"
	[ -n "$$device" ] || continue
	band="$$(uci -q get wireless.$$device.band)"
	[ "$$band" = '2g' ] || [ "$$band" = '5g' ] || continue

	ssid="$$(uci -q get wireless.$$section.ssid)"
	if [ "$$network" = 'lan' ]; then
		new_ssid="$$primary_2g"
		[ "$$band" = '5g' ] && new_ssid="$$primary_5g"
	else
		new_ssid="$$secondary_2g"
		[ "$$band" = '5g' ] && new_ssid="$$secondary_5g"
	fi
	[ "$$ssid" = "$$new_ssid" ] && continue

	uci -q set wireless.$$section.ssid="$$new_ssid"
	changed=1
done

if [ "$$changed" = 1 ]; then
	uci -q commit wireless
	wifi reload >/dev/null 2>&1 || /etc/init.d/network reload >/dev/null 2>&1 || true
fi

rm -f /tmp/luci-indexcache /tmp/luci-indexcache.*.json

if [ -x /usr/libexec/alemprator-setup/cleanup-hotspot ]; then
	/usr/libexec/alemprator-setup/cleanup-hotspot --reload >/dev/null 2>&1 || true
fi

uhttpd_reload_result=0
/etc/init.d/uhttpd reload >/dev/null 2>&1 || uhttpd_reload_result=$$?

exit 0
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
endef

define Package/luci-app-setup/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/setup $(1)/etc/config/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/setup $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/40_luci-app-setup $(1)/etc/uci-defaults/
	$(INSTALL_BIN) ./files/etc/uci-defaults/45_luci-app-setup-migrate-wizardvlan $(1)/etc/uci-defaults/
	$(INSTALL_BIN) ./files/etc/uci-defaults/46_luci-app-setup-disable-low-ack $(1)/etc/uci-defaults/
	$(INSTALL_BIN) ./files/etc/uci-defaults/47_luci-app-setup-fix-5g-vlan-ssid $(1)/etc/uci-defaults/
	$(INSTALL_BIN) ./files/etc/uci-defaults/48_luci-app-setup-recover-state $(1)/etc/uci-defaults/
	$(INSTALL_BIN) ./files/etc/uci-defaults/49_luci-app-setup-apply-radio-htmode $(1)/etc/uci-defaults/
	$(INSTALL_BIN) ./files/etc/uci-defaults/alemprator_c $(1)/etc/uci-defaults/
	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d
	$(INSTALL_DATA) ./files/usr/share/luci/menu.d/luci-app-setup.json $(1)/usr/share/luci/menu.d/zzz-luci-app-setup.json
	$(INSTALL_DIR) $(1)/usr/share/ucitrack
	$(INSTALL_DATA) ./files/usr/share/ucitrack/luci-app-setup.json $(1)/usr/share/ucitrack/
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./files/usr/share/rpcd/acl.d/luci-app-setup.json $(1)/usr/share/rpcd/acl.d/
	$(INSTALL_DIR) $(1)/www/luci-static/resources/view/setup
	$(INSTALL_DATA) ./files/www/luci-static/resources/view/setup/setup.js $(1)/www/luci-static/resources/view/setup/
	$(INSTALL_DATA) ./files/www/luci-static/resources/view/setup/setup.js $(1)/www/luci-static/resources/view/setup/setup_r93.js
	$(INSTALL_DATA) ./files/www/luci-static/resources/view/setup/landing.js $(1)/www/luci-static/resources/view/setup/
	$(INSTALL_DATA) ./files/www/luci-static/resources/view/setup/landing.js $(1)/www/luci-static/resources/view/setup/landing_r2.js
	$(INSTALL_DIR) $(1)/www
	$(INSTALL_DATA) ./files/www/captive-portal.html $(1)/www/captive-portal.html
	$(INSTALL_DIR) $(1)/usr/libexec/alemprator-setup
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-setup/reset-disabled $(1)/usr/libexec/alemprator-setup/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-setup/wps-disabled $(1)/usr/libexec/alemprator-setup/
	$(INSTALL_BIN) ./files/usr/libexec/alemprator-setup/cleanup-hotspot $(1)/usr/libexec/alemprator-setup/
	$(INSTALL_DIR) $(1)/etc/rc.d
	$(LN) ../init.d/setup $(1)/etc/rc.d/S99setup
endef

$(eval $(call BuildPackage,luci-app-setup))