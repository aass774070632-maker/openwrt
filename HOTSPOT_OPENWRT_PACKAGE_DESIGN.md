# Hotspot OpenWrt Package Design

Date: 2026-05-04
Project name: Hotspot OpenWrt

## Current Implementation Status

Implemented in `package/luci-app-hotspot-openwrt`:

```text
1. LuCI menu: Services -> Hotspot OpenWrt
2. Wizard persistence to /etc/config/hotspot_openwrt
3. Backend validation with RADIUS UDP 1812/1813 enforcement
4. Backend apply engine for network, Chilli DHCP, firewall, wireless binding, and CoovaChilli
5. Runtime verification for /dev/net/tun, tun0, Chilli process, hotspot IP, and br-lan management IPv4
6. Captive portal files under /www/hotspot/
7. Package builds as bin/packages/mipsel_24kc/base/luci-app-hotspot-openwrt_1.0-r1_mipsel_24kc.ipk
```

Remaining live validation:

```text
1. Install on router or include in firmware image
2. Open LuCI wizard and apply a dedicated hotspot interface
3. Confirm tun0, UAM 3990, WiFi client redirect, and MikroTik User Manager card login
```

## Goal

Build a real OpenWrt package named `luci-app-hotspot-openwrt` that adds a LuCI page under:

```text
Services -> Hotspot OpenWrt
```

The page provides a MikroTik-style setup wizard. After the user clicks `Apply / Finish`, the package configures OpenWrt as a full captive portal hotspot using CoovaChilli and authenticates users against MikroTik User Manager through RADIUS over UDP.

## Exact Product Behavior

Before this package, the router behaves like a normal access point.

After this package is configured and enabled, the router becomes a full hotspot gateway:

```text
User device -> OpenWrt Hotspot -> RADIUS UDP -> MikroTik User Manager
```

OpenWrt does not store cards or users. MikroTik User Manager remains the source of truth.

```text
Valid card in User Manager     -> RADIUS Access-Accept -> internet allowed
Invalid/missing card           -> RADIUS Access-Reject -> internet blocked
```

## LuCI User Flow

### Step 1: Interface Roles

The wizard asks for:

```text
WAN / uplink interface: internet source from MikroTik
LAN / bridge interface: subscriber/client side
WiFi interface: AP interface used for hotspot clients
```

The UI must make it clear that the management/uplink interface must not be captured by Chilli unless the admin intentionally accepts that topology.

### Step 2: Hotspot Interface

The wizard chooses the exact interface that CoovaChilli will own.

This must be a dedicated client-facing interface, for example:

```text
phy0-ap0
br-hotspot
hotspot
```

Do not use `br-lan` if it is also the management/uplink bridge.

### Step 3: Hotspot IP Network

The wizard asks for the captive network gateway/CIDR, for example:

```text
192.168.10.1/24
```

The engine derives:

```text
uamlisten = 192.168.10.1
net       = 192.168.10.0/24
```

### Step 4: DHCP Pool

The wizard asks for the client pool range, for example:

```text
Start: 192.168.10.10
End:   192.168.10.254
```

CoovaChilli owns this DHCP pool, not dnsmasq on the same interface.

### Step 5: DNS Servers

The wizard asks for DNS servers, for example:

```text
8.8.8.8
82.114.163.31
```

### Step 6: Domain

The wizard asks for an optional hotspot/domain value, for example:

```text
hotspot.local
```

This is stored in `/etc/config/hotspot_openwrt` and used where supported by Chilli/uhttpd page generation.

### Step 7: RADIUS

The wizard asks for:

```text
MikroTik/User Manager IP: 192.168.1.2
RADIUS secret:           123456
Auth port:               1812
Accounting port:         1813
NAS ID:                  KT-KM14-102H-HOTSPOT
```

Transport requirement:

```text
RADIUS must use UDP only.
TCP 1812/1813 being refused is normal and must not be treated as a failure.
```

### Apply / Finish

After clicking `Apply / Finish`, LuCI calls the backend engine:

```text
/usr/libexec/hotspot-openwrt/apply
```

The engine validates inputs, creates a backup marker, applies UCI, writes portal files, restarts services, and reports JSON status back to LuCI.

## Automatic Engine Actions

The backend must do all of this without manual CLI steps:

```text
1. Create / update hotspot network configuration
2. Separate subscriber interface from normal LAN when needed
3. Configure DHCP ownership correctly
4. Configure firewall zone and NAT/forwarding rules
5. Configure CoovaChilli
6. Deploy captive portal pages under /www/hotspot/
7. Enable/start CoovaChilli
8. Verify tun0 and UAM port 3990
9. Verify management interface remains reachable
10. Return success/failure to LuCI
```

## Package Structure In This Repository

This OpenWrt tree uses modern LuCI JavaScript views with `menu.d` JSON and rpcd ACLs. So the implementation should use this structure instead of relying only on old `controller/*.lua` patterns:

```text
package/luci-app-hotspot-openwrt/
├── Makefile
└── files/
    ├── etc/config/hotspot_openwrt
    ├── etc/init.d/hotspot-openwrt
    ├── usr/libexec/hotspot-openwrt/apply
    ├── usr/libexec/hotspot-openwrt/status-json
    ├── usr/libexec/hotspot-openwrt/validate
    ├── usr/share/luci/menu.d/luci-app-hotspot-openwrt.json
    ├── usr/share/rpcd/acl.d/luci-app-hotspot-openwrt.json
    ├── www/luci-static/resources/view/services/hotspot-openwrt.js
    └── www/hotspot/
        ├── login.html
        ├── terms.html
        └── style.css
```

Compatibility mapping for the older structure requested in the idea:

```text
controller/hotspot.lua      -> usr/share/luci/menu.d/*.json + JS view
view/hotspot/wizard.htm     -> www/luci-static/resources/view/services/hotspot-openwrt.js
model/cbi/hotspot.lua       -> /etc/config/hotspot_openwrt + JS form rendering
root/www/hotspot/login.html -> files/www/hotspot/login.html
root/usr/bin/hotspot-setup.sh -> files/usr/libexec/hotspot-openwrt/apply
```

## OpenWrt Package Dependencies

The package should depend on:

```text
luci-base
rpcd
rpcd-mod-file
uhttpd
coova-chilli
kmod-tun
iptables-nft
```

Recommended for firmware builds:

```text
CONFIG_PACKAGE_luci-app-hotspot-openwrt=y
CONFIG_PACKAGE_coova-chilli=y
CONFIG_PACKAGE_kmod-tun=y
```

For production images, CoovaChilli and `kmod-tun` should be included in the firmware image. Installing `kmod-tun` later by IPK can fail when the package kernel ABI does not match the running firmware.

## Main UCI Config

File:

```text
/etc/config/hotspot_openwrt
```

Example:

```text
config hotspot 'main'
        option enabled '0'
        option wan_interface 'lan'
        option subscriber_interface 'hotspot'
        option bridge_ports ''
        option wifi_iface 'phy0-ap0'
        option hotspot_ip '192.168.10.1'
        option hotspot_cidr '24'
        option pool_start '192.168.10.10'
        option pool_end '192.168.10.254'
        list dns '8.8.8.8'
        list dns '82.114.163.31'
        option domain 'hotspot.local'
        option radius_server '192.168.1.2'
        option radius_secret '123456'
        option radius_auth_port '1812'
        option radius_acct_port '1813'
        option radius_nas_id 'KT-KM14-102H-HOTSPOT'
        option terms_enabled '1'
```

## Generated CoovaChilli UCI

File:

```text
/etc/config/chilli
```

Generated values:

```text
config chilli
        option disabled '0'
        option tundev 'tun0'
        option network '<subscriber_network>'
        option net '192.168.10.0/24'
        option dynip '192.168.10.0/24'
        option dhcpstart '10'
        option dhcpend '254'
        option uamlisten '192.168.10.1'
        option uamport '3990'
        option uamserver 'http://192.168.10.1/hotspot/terms.html'
        option uamhomepage 'http://192.168.10.1/hotspot/terms.html'
        option radiusserver1 '192.168.1.2'
        option radiusserver2 '192.168.1.2'
        option radiussecret '123456'
        option radiusauthport '1812'
        option radiusacctport '1813'
        option radiusnasid 'KT-KM14-102H-HOTSPOT'
        option dns1 '8.8.8.8'
        option dns2 '82.114.163.31'
        option uamanydns '1'
```

Important CoovaChilli option name:

```text
radiusnasid is valid.
nasid is invalid for this package/version and causes Chilli startup failure.
```

## Firewall Design

The package creates a dedicated firewall zone for hotspot clients:

```text
zone hotspot:
        input REJECT or ACCEPT only where needed for DNS/DHCP/UAM
        output ACCEPT
        forward REJECT before authentication
```

Chilli controls client authorization. The firewall must still allow:

```text
UDP 1812/1813 from OpenWrt to MikroTik RADIUS
DNS according to configured DNS policy
HTTP to local portal/UAM
Forward/NAT after Chilli authorization
```

NAT/masquerade is enabled toward the WAN/uplink side if OpenWrt is acting as the hotspot gateway.

## Captive Portal Pages

The package installs:

```text
/www/hotspot/login.html
/www/hotspot/terms.html
/www/hotspot/style.css
```

Login page behavior:

```text
User enters card username/password
Form submits to CoovaChilli UAM endpoint
CoovaChilli sends RADIUS Access-Request to MikroTik User Manager
```

Terms page behavior:

```text
Optional only
No local storage required
User accepts terms then continues to login
```

## Safety Requirements

The package must protect the admin from repeating the earlier lockout:

```text
1. Warn if selected hotspot interface is br-lan and br-lan has the management IP.
2. Require explicit confirmation before using the management bridge as subscriber interface.
3. Prefer a dedicated AP/interface/VLAN for Chilli.
4. Before applying, write a rollback file under /tmp.
5. Start a rollback timer that disables Chilli if verification fails.
6. Confirm SSH/LuCI management IP remains reachable after applying.
```

Rollback behavior:

```text
If tun0/UAM/management checks fail:
        stop Chilli
        disable Chilli
        restore dnsmasq ownership where needed
        restart network/dnsmasq/firewall
```

## LuCI Wizard Implementation Notes

The LuCI view should be one JavaScript file:

```text
www/luci-static/resources/view/services/hotspot-openwrt.js
```

It should use:

```text
'require view'
'require uci'
'require rpc'
'require fs'
'require ui'
```

It should render a single wizard with steps:

```text
1. Interfaces
2. Hotspot interface
3. IP network
4. DHCP pool
5. DNS
6. Domain
7. RADIUS
8. Review / Apply
```

The apply button writes `/etc/config/hotspot_openwrt`, then executes:

```text
/usr/libexec/hotspot-openwrt/apply
```

via rpcd file exec ACL.

## rpcd ACL

The ACL must allow:

```text
UCI read/write: hotspot_openwrt, network, dhcp, firewall, wireless, chilli
ubus read: system board, network interfaces, wireless status
file exec: /usr/libexec/hotspot-openwrt/apply, status-json, validate
```

## Menu Definition

File:

```text
/usr/share/luci/menu.d/luci-app-hotspot-openwrt.json
```

Menu path:

```json
{
  "admin/services/hotspot-openwrt": {
    "title": "Hotspot OpenWrt",
    "order": 50,
    "action": {
      "type": "view",
      "path": "services/hotspot-openwrt"
    },
    "depends": {
      "acl": [ "luci-app-hotspot-openwrt" ]
    }
  }
}
```

## Implementation Phases

### Phase 1: Package Skeleton

Create installable package with:

```text
LuCI menu entry
JS wizard placeholder
ACL
default /etc/config/hotspot_openwrt
portal static files
```

Success check:

```text
Package builds as luci-app-hotspot-openwrt.ipk
Menu appears under Services -> Hotspot OpenWrt
Wizard page loads
```

### Phase 2: Wizard Persistence

The wizard reads/writes `/etc/config/hotspot_openwrt`.

Success check:

```text
Values survive page reload
Validation catches missing/invalid fields
```

### Phase 3: Backend Apply Engine

Implement `/usr/libexec/hotspot-openwrt/apply`.

Success check:

```text
Creates generated UCI for network/dhcp/firewall/chilli
Does not start Chilli if validation fails
Returns JSON result
```

### Phase 4: Safe Chilli Start

Enable CoovaChilli with rollback guard.

Success check:

```text
tun0 appears with configured hotspot IP
192.168.10.1:3990 listens
management IP remains reachable
RADIUS auth/acct uses UDP ports 1812/1813
```

### Phase 5: Portal Flow

Validate with a real WiFi client.

Success check:

```text
Client receives hotspot pool IP
Client is redirected to terms/login
Valid MikroTik card logs in
Invalid card is rejected
Internet works only after Access-Accept
```

## Key Decision

This must be a firmware/package feature, not a one-time manual router modification.

The clean production target is:

```text
Firmware image includes luci-app-hotspot-openwrt + coova-chilli + kmod-tun
User opens LuCI -> Services -> Hotspot OpenWrt
User completes wizard
Router becomes a MikroTik-backed OpenWrt hotspot
```