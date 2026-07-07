# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023-2025 muink <https://github.com/muink>

include $(TOPDIR)/rules.mk

LUCI_NAME:=luci-app-netspeedtest

LUCI_TITLE:=LuCI Net Speedtest
LUCI_DEPENDS:=+iperf3 +librespeed-go +mikrotik-btest +uhttpd +rpcd +rpcd-mod-file

LUCI_DESCRIPTION:=Test Net speed

PKG_MAINTAINER:=Anya Lin <hukk1996@gmail.com>
PKG_LICENSE:=MIT

define Package/$(LUCI_NAME)/conffiles
/etc/config/netspeedtest
endef

define Package/$(LUCI_NAME)/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0

if [ -f /etc/init.d/netspeedtest ]; then
	chmod 0755 /etc/init.d/netspeedtest
	/etc/init.d/netspeedtest enable >/dev/null 2>&1 || true
fi

exit 0
endef

define Package/$(LUCI_NAME)/prerm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0

if [ -x /etc/init.d/netspeedtest ]; then
	/etc/init.d/netspeedtest stop >/dev/null 2>&1 || true
	/etc/init.d/netspeedtest disable >/dev/null 2>&1 || true
fi

exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
