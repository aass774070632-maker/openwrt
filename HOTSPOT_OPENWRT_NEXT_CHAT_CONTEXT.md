# Hotspot OpenWrt Next Chat Context

Current date when written: 2026-05-06

This file is the practical handoff for continuing the Hotspot OpenWrt work in a new conversation. Read this before changing code or router settings.

## Main Goal

Build and stabilize `luci-app-hotspot-openwrt`, an OpenWrt LuCI package that turns the KT KM14-102H router into a captive portal hotspot using CoovaChilli, while MikroTik User Manager remains the card/user database through RADIUS UDP.

Target behavior:

```text
Phone/client -> Hotspot-OpenWrt SSID -> CoovaChilli/tun0 -> RADIUS UDP -> MikroTik User Manager -> internet
```

Do not create local OpenWrt users/cards. Cards remain in MikroTik User Manager.

## Important Files

- Package source: `package/luci-app-hotspot-openwrt/`
- Main apply engine: `package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/apply`
- Status helper: `package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/status-json`
- LuCI view: `package/luci-app-hotspot-openwrt/files/www/luci-static/resources/view/services/hotspot-openwrt.js`
- Basic package portal source: `package/luci-app-hotspot-openwrt/files/www/hotspot/`
- Converted MikroTik-style portal source: `flash/hotspot1/`
- Backup of original MikroTik-style portal: `flash/hotspot1.mikrotik-backup/`
- Main long environment report: `HOTSPOT_DEVICE_ENV_REPORT_2026-05-04.md`
- Design notes: `HOTSPOT_OPENWRT_PACKAGE_DESIGN.md`
- Earlier recovery notes: `HOTSPOT_OPENWRT_RECOVERY_AND_NEXT_STEPS_2026-05-04.md`

## Current Router And Network

Latest active router target in the session:

```text
OpenWrt router: 192.168.1.20
Model: KT KM14-102H
OpenWrt: 24.10.4 / ramips mt7621 / kernel 6.6.110
MikroTik/User Manager: 192.168.1.2
RADIUS secret used in package/session: 123456
RADIUS auth/acct: UDP 1812/1813 only
Hotspot gateway: 192.168.10.1
Hotspot client subnet: 192.168.10.0/24
Chilli UAM: http://192.168.10.1:3990/login
```

Note: older logs mention `192.168.1.21`. Treat those as historical unless current reachability proves otherwise. The most recent successful deploy and diagnostics used `192.168.1.20`.

## Safety Rules Learned

- Never attach CoovaChilli directly to `br-lan` when `br-lan` is also management/uplink. This caused an earlier lockout.
- Correct design is: management/uplink remains on `br-lan`; hotspot clients use a dedicated interface/bridge such as `br-hotspot`; Chilli creates and owns `tun0`.
- `br-hotspot` must be layer-2 only. Do not put `192.168.10.1/24` on `br-hotspot`. `tun0` must own `192.168.10.1/24`.
- RADIUS is UDP. TCP refused on 1812/1813 is normal and not a failure.
- OpenWrt `kmod-tun` package install can fail because of kernel ABI/hash mismatch. During this session, `tun.ko` had to be extracted/copied/loaded manually at least once.

## Package State And Built Artifact

The package builds as:

```text
bin/packages/mipsel_24kc/base/luci-app-hotspot-openwrt_1.0-r1_mipsel_24kc.ipk
```

The package includes:

- LuCI menu under Services -> Hotspot OpenWrt
- JS LuCI tabs inspired by MikroTik HotSpot concepts
- rpcd ACL
- `/etc/config/hotspot_openwrt`
- `/usr/libexec/hotspot-openwrt/apply`
- `/usr/libexec/hotspot-openwrt/status-json`
- `/usr/libexec/hotspot-openwrt/portal-upload`
- portal files under `/www/hotspot`

## Fixes Already Applied

These have already been diagnosed and should not be rediscovered from scratch:

1. Portal TCP/80 access before authentication
   - Symptom: client had `192.168.10.x`, but `http://192.168.10.1/hotspot/terms.html` did not open.
   - Fix: Chilli config/apply manages `HS_TCP_PORTS="80"` so unauthenticated clients can reach local portal HTTP.

2. Login endpoint and field names
   - Symptom: browser opened `192.168.10.1:3990/log...` and got `ERR_EMPTY_RESPONSE`.
   - Log: `No username found in login request`.
   - Fix: portal submits `GET` to `/login`, not `/logon`, using lowercase `username` and `password`.

3. PAP/no challenge mode
   - Fix: `nochallenge=1` so plain PAP credentials are sent to MikroTik User Manager.

4. `tun0` and route ownership
   - Symptom: client authenticated but internet still failed.
   - Root cause: both `br-hotspot` and `tun0` owned `192.168.10.1/24`.
   - Fix: `network.hotspot` is `proto none`; `br-hotspot` has no IPv4; `tun0` owns `192.168.10.1/24`.

5. NAT and forwarding
   - Symptom: client was `pass` but had no internet.
   - Fix: firewall `lan` zone was bound to network `lan` and given `masq=1` / `mtu_fix=1`, producing `srcnat_lan` masquerade for traffic exiting `br-lan`.

6. DNS before login
   - Symptom: `DNS_PROBE_FINISHED_NO_INTERNET` while client was still `dnat`.
   - Fix: Chilli now hands out and forces DNS through `192.168.10.1`: `dns1`, `dns2`, `forcedns1`, `forcedns2`, port `53`.

7. Portal flow after login
   - Symptom: browser looped back to the portal after successful login.
   - Fix: fallback `userurl` changed away from `http://192.168.10.1/`; terms/login preserve query parameters.

8. MikroTik-style portal conversion
   - Source: `flash/hotspot1/`
   - Original backup: `flash/hotspot1.mikrotik-backup/`
   - Deployed to router: `/www/hotspot`
   - Router backup before deploy: `/www/hotspot-backup-20260506-011214`
   - HTTP verification after deploy showed login page served from `http://192.168.1.20/hotspot/login.html` with action `http://192.168.10.1:3990/login` and status page logoff action `http://192.168.10.1:3990/logoff`.

## Current Portal Behavior

The converted portal in `flash/hotspot1/login.html` currently does this:

```text
Form action: http://192.168.10.1:3990/login
Method: GET
Visible input: username/card number
Hidden input: password
Before submit: password is set to the original entered card number
If the entered username length is 11: append @userman2 to username
```

Examples:

```text
Entered 27801248303 -> username=27801248303@userman2, password=27801248303
Entered 101255625   -> username=101255625, password=101255625
```

This behavior may be wrong if MikroTik User Manager has a blank password for some users. The page currently does not send an empty password.

## Latest Known Problem

User reported:

```text
Entered username/card 101255625 without a password. Card exists in MikroTik User Manager, but login did not work.
```

Router diagnostics after this showed:

```text
Page fields are correct for CoovaChilli (/login, username/password).
Clients were still dnat, not pass:
D2-22-B3-86-CB-15 192.168.10.10 dnat ... http://play.googleapis.com/generate_204
36-5D-F3-EF-19-25 192.168.10.12 dnat ...
```

Relevant logs:

```text
Successful earlier login existed for username=101202735 IP=192.168.10.12.
For later attempts, Chilli logged repeated RADIUS request timeouts, not Access-Reject:
RADIUS request id=... timed out for session ...
Radius request timed out
```

Interpretation:

- The latest blocker is probably RADIUS reachability/response or MikroTik RADIUS client configuration, not simply whether the card exists.
- However, the portal also forces `password=<card number>`, which may not match MikroTik users configured with an empty password. This should be tested explicitly.

## Next Debug Steps

Start from here in the next conversation:

1. Confirm RADIUS path from OpenWrt to MikroTik:

```sh
ssh root@192.168.1.20 'ip route get 192.168.1.2; ping -c3 -W2 192.168.1.2; uci -q show hotspot_openwrt.main | grep radius; uci -q show chilli.hotspot_openwrt | grep radius'
```

2. Check if MikroTik User Manager sees Access-Request counters from NAS `192.168.1.20`.
   - NAS/client IP in MikroTik should be `192.168.1.20`.
   - Secret should match `123456` unless changed in LuCI.
   - UDP 1812/1813 must be allowed.

3. While attempting login, watch OpenWrt logs:

```sh
ssh root@192.168.1.20 'logread -f | grep -Ei "chilli|radius|Access|Reject|Accept|101255625|timeout|login|uam"'
```

4. Test credential variants for user `101255625`:

```text
username=101255625, password=101255625
username=101255625, password=<empty>
username=101255625@userman2, password=101255625
username=101255625@userman2, password=<empty>
```

If blank-password users are required, update `flash/hotspot1/login.html` so the hidden `password` can be empty or configurable, then redeploy to `/www/hotspot`.

5. If the router can reach MikroTik by ping but RADIUS times out, inspect MikroTik side first. Previous UDP `nc` from host to `192.168.1.2:1812/1813` succeeded, but OpenWrt-side BusyBox `nc` is limited and not reliable for UDP diagnostics.

6. Optional packet capture if tools exist:

```sh
ssh root@192.168.1.20 'tcpdump -ni br-lan host 192.168.1.2 and udp port 1812'
```

If `tcpdump` is unavailable, rely on Chilli logs and MikroTik RADIUS counters.

## Useful Commands

Deploy converted portal again:

```sh
cd /home/baalwy/openwrt
tar -C flash/hotspot1 -cf /tmp/hotspot1-openwrt-portal.tar .
scp -O -o StrictHostKeyChecking=no -o UserKnownHostsFile=/tmp/openwrt-known-hosts /tmp/hotspot1-openwrt-portal.tar root@192.168.1.20:/tmp/
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/tmp/openwrt-known-hosts root@192.168.1.20 '
backup="/www/hotspot-backup-$(date +%Y%m%d-%H%M%S)"
[ -d /www/hotspot ] && cp -a /www/hotspot "$backup"
mkdir -p /www/hotspot
tar -C /www/hotspot -xf /tmp/hotspot1-openwrt-portal.tar
chmod -R a+rX /www/hotspot
rm -f /tmp/hotspot1-openwrt-portal.tar
printf "backup=%s\n" "$backup"
'
```

Verify portal from workstation:

```sh
curl -fsS --max-time 8 http://192.168.1.20/hotspot/login.html | grep -E '3990/login|OPENWRT_REALM|شبكة البرق' | head
curl -fsS --max-time 8 http://192.168.1.20/hotspot/status.html | grep -E '3990/logoff|Hotspot OpenWrt|حالة الاتصال' | head
```

Check router hotspot status:

```sh
ssh root@192.168.1.20 '/usr/libexec/hotspot-openwrt/status-json; chilli_query -s /var/run/chilli_hotspot_openwrt.sock list 2>&1 | sed -n "1,80p"; logread | grep -Ei "chilli|radius|login|Access|Reject|Accept|timeout" | tail -120'
```

Build package:

```sh
make package/luci-app-hotspot-openwrt/compile V=s
```

## What Not To Waste Time On

- Do not debug TCP RADIUS refused as a failure. RADIUS is UDP here.
- Do not reintroduce MikroTik `$(...)` CHAP template logic into the OpenWrt portal.
- Do not put `192.168.10.1/24` on `br-hotspot`.
- Do not move Chilli onto `br-lan`.
- Do not assume a card exists means RADIUS is reachable; the latest failure is timeout-like.

## Conversation Log Source

The full conversation transcript was read from VS Code Copilot transcript/log resources during the previous session and cross-checked with `HOTSPOT_DEVICE_ENV_REPORT_2026-05-04.md`. The important facts needed for continuation are consolidated in this file.