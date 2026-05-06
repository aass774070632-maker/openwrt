# Hotspot OpenWrt Recovery And Next Steps - 2026-05-04

## 2026-05-04 Final Cleanup After Router Reset

The router was factory reset/formatted and recovered at `192.168.1.20`. The temporary hotspot/provisioning work was then backed up and removed from the live router.

Current confirmed live router state:

```text
Router: KT KM14-102H / OpenWrt 24.10.4
Management IP: 192.168.1.20/24 on br-lan
Chilli UCI disabled: 1
Chilli init enabled: no
Chilli process: none
tun0: absent
Temporary SSID ALemprator-KT-KM14-102H: absent
Default open SSID OpenWrt: removed
Portal files: absent
SSH: reachable
```

Local backup directory before cleanup:

```text
hotspot-backups/20260504-231807-before-temp-hotspot-delete
```

Backup contents:

```text
hotspot-before-delete-20260504-231807.tar.gz
hotspot-temp-files-before-delete.tar.gz
wireless-before-temp-hotspot-delete.uci
wireless-before-openwrt-ssid-clean.uci
network-before-temp-hotspot-delete.uci
dhcp-before-temp-hotspot-delete.uci
chilli-before-temp-hotspot-delete.uci
remote-backup-path.txt
```

Cleanup actions completed:

```sh
/etc/init.d/chilli stop
/etc/init.d/chilli disable
uci set chilli.@chilli[0].disabled='1'
uci commit chilli
rm -rf /www/hotspot
rm -f /www/cgi-bin/api/accept /www/api/accept
```

The default open `OpenWrt` SSID left by the reset was also removed after taking `wireless-before-openwrt-ssid-clean.uci`. The remaining active SSID is:

```text
KT-KM14-102H-2.4GHz_BEC0
```

The previous lockout root cause remains valid: never attach CoovaChilli to `br-lan` while `br-lan` is the management/uplink interface.

## Current State

The Hotspot work reached a live CoovaChilli run, but SSH access to the router was lost after Chilli was started on `br-lan`.

The last confirmed router state before SSH loss:

```text
Router: KT KM14-102H / OpenWrt 24.10.4
Previous management IP: 192.168.1.21
MikroTik/RADIUS: 192.168.1.2
CoovaChilli: running
TUN: loaded
/dev/net/tun: present
tun0: 192.168.10.1/24
iptables: iptables v1.8.10 (nf_tables)
```

Confirmed installed/build items:

```text
coova-chilli - 1.6-r12
kmod-tun - 6.6.110-r1 with /lib/modules/6.6.110/tun.ko
iptables-nft - 1.8.10-r1
xtables-nft - 1.8.10-r1
libxtables12 - 1.8.10-r1
libiptext0 - 1.8.10-r1
libiptext6-0 - 1.8.10-r1
libiptext-nft0 - 1.8.10-r1
```

Confirmed deployed files:

```text
/www/hotspot/terms.html
/www/hotspot/login.html
/www/cgi-bin/api/accept
/www/api/accept
```

Last confirmed Chilli sessions showed clients receiving `192.168.10.x` addresses.

## What Went Wrong

Chilli was started with the client interface as `br-lan`. On this device `br-lan` was also the management/uplink bridge, so Chilli began intercepting the management path. After that, SSH to `192.168.1.21`, `192.168.10.1`, and previously seen fallback addresses was no longer reachable from the workstation.

This is not a package/build failure. It is an interface-placement issue.

## Immediate Recovery Command

Run this from any available local console, LuCI terminal, serial console, or any SSH path that can still reach the router:

```sh
/etc/init.d/chilli stop
/etc/init.d/chilli disable
```

Then confirm management returns:

```sh
ip -4 addr
ip route
pgrep -af chilli || true
```

If Chilli is stopped and management still does not return, restart networking:

```sh
/etc/init.d/network restart
/etc/init.d/dnsmasq restart
/etc/init.d/firewall restart
```

## Safer Architecture For Next Attempt

Do not run Chilli on `br-lan` while `br-lan` is also management/uplink.

Use one of these safer layouts:

1. Dedicated hotspot SSID/interface:

```text
br-lan: management/uplink, keep 192.168.1.21 or intended management IP
hotspot SSID: separate network/interface, passed to CoovaChilli as dhcpif
chilli/tun0: 192.168.10.1/24 captive network
MikroTik/RADIUS: 192.168.1.2 via br-lan
```

2. Dedicated VLAN/port for hotspot clients:

```text
br-lan: management/uplink only
br-hotspot or vlan-hotspot: client-facing segment only
chilli dhcpif: br-hotspot/vlan-hotspot
```

## Chilli Values To Keep

```sh
uci set chilli.@chilli[0].disabled='0'
uci set chilli.@chilli[0].tundev='tun0'
uci set chilli.@chilli[0].net='192.168.10.0/24'
uci set chilli.@chilli[0].dynip='192.168.10.0/24'
uci set chilli.@chilli[0].uamlisten='192.168.10.1'
uci set chilli.@chilli[0].uamport='3990'
uci set chilli.@chilli[0].radiusserver1='192.168.1.2'
uci set chilli.@chilli[0].radiusserver2='192.168.1.2'
uci set chilli.@chilli[0].radiussecret='123456'
uci set chilli.@chilli[0].radiusnasid='hotspot-openwrt'
uci set chilli.@chilli[0].radiusauthport='1812'
uci set chilli.@chilli[0].radiusacctport='1813'
uci set chilli.@chilli[0].uamserver='http://192.168.1.21/hotspot/login.html'
uci set chilli.@chilli[0].uamhomepage='http://192.168.1.21/hotspot/terms.html'
uci set chilli.@chilli[0].dns1='8.8.8.8'
uci set chilli.@chilli[0].dns2='82.114.163.31'
```

But change this before enabling Chilli again:

```sh
# Do NOT use br-lan if it is management/uplink.
uci set chilli.@chilli[0].dhcpif='<dedicated-hotspot-interface>'
```

## Current Blocker

From the workstation, the router is currently not reachable by SSH. Tested unreachable or not usable:

```text
192.168.1.20
192.168.1.21
192.168.10.1
192.168.137.12
192.168.137.35
```

Reachable SSH devices on the workstation network were:

```text
192.168.137.1
192.168.137.2
```

But root login using key and password `123456` failed, so they were not usable as the current OpenWrt control path.
