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
- The current live router works because `tun.ko` was manually copied to `/lib/modules/6.6.110/tun.ko`, `/etc/modules.d/30-tun` was created, and CoovaChilli userland files were manually extracted from the IPK. `opkg` still does not have a clean installed package record for these two components.

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
- `/www/hotspot/status.html`
- `/www/cgi-bin/hotspot-login`
- `/www/cgi-bin/hotspot-card-info`
- `/www/cgi-bin/hotspot-logout`

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

9. CoovaChilli/TUN runtime recovery
   - Symptom: router fell back to dnsmasq mode because `/usr/sbin/chilli`, `/etc/init.d/chilli`, and a working TUN driver were missing.
   - Root cause: official `opkg` had no installable `kmod-tun`, and the local `kmod-tun` IPK had a mismatched kernel ABI/hash and an empty data archive.
   - Fix: copied the working build artifact `build_dir/target-mipsel_24kc_musl/linux-ramips_mt7621/linux-6.6.110/drivers/net/tun.ko` to the router, installed it at `/lib/modules/6.6.110/tun.ko`, added `/etc/modules.d/30-tun`, extracted `coova-chilli_1.6-r12_mipsel_24kc.ipk` data directly to `/`, then ran `/usr/libexec/hotspot-openwrt/apply --start`.
   - Verified live state: `chilli_running:true`, `tun0_present:true`, `bridge_has_ip:false`, `route_ok:true`, `network.hotspot.proto='none'`, and `tun0` owns `192.168.10.1/24`.

10. Blank-password card login
   - Symptom: card login failed when the portal forced the entered card number into the hidden password field.
   - Fix: `flash/hotspot1/login.html` now sends a blank password, while still appending `@userman2` only for 11-digit card numbers.
   - Verified live portal content from `http://192.168.10.1/hotspot/login.html` showed `password.value = ''` and `/login?username=...&password=...`.
   - User confirmed that login succeeded after this repair.

11. Post-login status page stays visible and reads live session data
   - Source: `flash/hotspot1/status.html`
   - Removed the `status.html` meta refresh that caused the information page to disappear/reload after login.
   - `flash/hotspot1/login.html` now sends `userurl` to `status.html?t=<timestamp>` to avoid old browser cache.
   - Added `/www/cgi-bin/hotspot-card-info` on the live router and package source `package/luci-app-hotspot-openwrt/files/www/cgi-bin/hotspot-card-info`.
   - `status.html` fetches `/cgi-bin/hotspot-card-info?username=<saved-card>` and displays the card number and CoovaChilli session state.
   - Verified live CGI returned a real authenticated session, for example: `card_number:101255625`, `state:pass`, `authenticated:true`, `source:coovachilli`.
   - Later repair added a server-side RouterOS REST bridge, so `hotspot-card-info` can now embed real MikroTik User Manager profile/balance/expiry when REST is enabled in OpenWrt UCI.

12. Reliable logout closes internet access
   - Symptom: after pressing logout, the browser left the client unable to log in cleanly while internet access could remain open because the old `:3990/logoff` flow did not reliably terminate the Chilli session.
   - Reliable Chilli command: `chilli_query -s /var/run/chilli_hotspot_openwrt.sock logout ip <client-ip>`.
   - Added live router endpoint `/www/cgi-bin/hotspot-logout` and package source `package/luci-app-hotspot-openwrt/files/www/cgi-bin/hotspot-logout`.
   - `flash/hotspot1/status.html` now calls `/cgi-bin/hotspot-logout?format=json&username=<saved-card>`, clears `localStorage.hotspot_username`, then redirects to `/hotspot/login.html?t=<timestamp>`.
   - The CGI prefers `REMOTE_ADDR` to avoid logging out the wrong device, then falls back to exact username/card matching from `chilli_query list`.
   - Verified direct command changed `192.168.10.180` from `pass` to `dnat`.
   - Verified direct CGI test returned `ok:true` with `state:"dnat"` for card `101482710`.
   - Rebuilt package after this change; build output packaged `status.html`, `hotspot-card-info`, and `hotspot-logout` into `bin/packages/mipsel_24kc/base/luci-app-hotspot-openwrt_1.0-r1_mipsel_24kc.ipk`.

13. Status page appears again after logout then login
   - Symptom: logout worked and the next login succeeded, but the browser did not reliably show the card/status information page.
   - Root cause: the logout flow removed `localStorage.hotspot_username`, so after returning to login the status page could lose the card number context. Also some clients can land back on `login.html` while Chilli already has the device in `pass` state.
   - Fix in `flash/hotspot1/login.html`: save the card into `sessionStorage.hotspot_session_username` and `localStorage.hotspot_last_username`, pass `username=<card>` in the `userurl`, and auto-redirect from login to status when `/cgi-bin/hotspot-card-info` says the client is already authenticated.
   - Fix in `flash/hotspot1/status.html`: read the username from query string first, then session storage, remembered username, and last username.
   - Same robustness was added to the basic package portal under `package/luci-app-hotspot-openwrt/files/www/hotspot/`.
   - Deployed live to `/www/hotspot/login.html` and `/www/hotspot/status.html` on `192.168.1.20`.
   - Rebuilt package successfully after these edits.
   - Verified live CGI for `REMOTE_ADDR=192.168.10.10` and `username=101482710` returned `state:"pass"` and `authenticated:true`, so the auto-redirect condition has valid data.

14. Re-login while staying connected after logout
   - Symptom: if the user disconnected and reconnected Wi-Fi, the login page worked; if the phone stayed connected after logout, submitting the card could return to the same login page instead of showing information.
   - Root cause: browser-side redirects through `http://192.168.10.1:3990/login` were fragile after logout/captive-portal state changes, even though Chilli/RADIUS accepted the login.
   - Fix: added router-side `/www/cgi-bin/hotspot-login` and package source `package/luci-app-hotspot-openwrt/files/www/cgi-bin/hotspot-login`.
   - The CGI reads `REMOTE_ADDR`, runs `chilli_query -s /var/run/chilli_hotspot_openwrt.sock login ip <client-ip> username <card> password <blank> url <status-url>`, verifies the client state is `pass`, then redirects to `/hotspot/status.html?...&username=<card>`.
   - `flash/hotspot1/login.html` and the basic package login page now use `/cgi-bin/hotspot-login` instead of direct `:3990/login`.
   - Deployed live to `192.168.1.20`: `/www/cgi-bin/hotspot-login`, `/www/cgi-bin/hotspot-card-info`, `/www/hotspot/login.html`, `/www/hotspot/status.html`.
   - Verified live server-side test returned `ok:true`, `state:"pass"`, and redirect `/hotspot/status.html?t=test&username=101255625` for `REMOTE_ADDR=192.168.10.10`.
   - `hotspot-card-info` now returns `session_id`, `input_octets`, `output_octets`, and optional `user_manager` data so the status page can show live Chilli session IP/MAC/usage plus User Manager profile information.
   - Rebuilt package after cleaning `package/luci-app-hotspot-openwrt`; verified the final IPK data archive contains `./www/cgi-bin/hotspot-login`, `./www/cgi-bin/hotspot-card-info`, `./www/cgi-bin/hotspot-logout`, and `./www/hotspot/status.html`.
   - Real MikroTik User Manager balance/profile/expiry is now provided by the router-side RouterOS REST bridge. Browser JavaScript must still never hold MikroTik credentials.

15. MikroTik-style Active / Hosts view
    - User requested MikroTik Hotspot behavior: logout removes the subscriber from Active and leaves the device in Hosts with `H`; login moves it back to Active.
    - Mapping implemented in `package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/status-json`:
       - CoovaChilli `pass` => `active_list` with flag `A`.
       - CoovaChilli `dnat` or any non-`pass` state => `hosts_list` with flag `H`.
    - LuCI tab `Active / Hosts` in `package/luci-app-hotspot-openwrt/files/www/luci-static/resources/view/services/hotspot-openwrt.js` now renders two live tables instead of only counters.
    - Deployed live to `192.168.1.20` and reloaded `rpcd`/`uhttpd` after clearing LuCI index cache.
    - Verified live transition using safe client `192.168.10.180` / card `101482710`:
       - login via `/www/cgi-bin/hotspot-login` changed state to `pass`, `active_clients:1`, `active_list[0].flag:"A"`.
       - logout via `/www/cgi-bin/hotspot-logout` changed state back to `dnat`, `active_clients:0`, `hosts_list` contains the client with `flag:"H"`.
    - Rebuilt `bin/packages/mipsel_24kc/base/luci-app-hotspot-openwrt_1.0-r1_mipsel_24kc.ipk` and verified the package contains the new `active_list`/`hosts_list` code and LuCI table renderer.

16. RouterOS REST bridge for real User Manager balance/profile/expiry
    - User requested the second part: show the real MikroTik User Manager balance and profile expiration time on the subscriber status page.
    - Added server-side helper `package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/userman-info`.
    - Added optional RouterOS REST settings to `/etc/config/hotspot_openwrt` and LuCI RADIUS/User Manager settings:
       - `userman_rest_enabled`
       - `userman_rest_scheme`
       - `userman_rest_host`
       - `userman_rest_port`
       - `userman_rest_username`
       - `userman_rest_password`
       - `userman_rest_insecure_ssl`
       - `userman_rest_user_field`
       - `userman_rest_timeout`
    - `hotspot-card-info` now embeds a `user_manager` object from the helper and keeps credentials completely server-side on OpenWrt. Browser JavaScript never receives MikroTik credentials.
    - `flash/hotspot1/status.html` and the basic package `www/hotspot/status.html` now show User Manager balance/profile/expiration when `user_manager.ok` is true, and otherwise show the existing session information with a clear message.
    - The helper uses RouterOS REST over `/rest` with HTTP Basic Auth through `uclient-fetch`, then parses JSON with `jsonfilter`.
    - Important `jsonfilter` rule on OpenWrt: RouterOS fields with hyphens must use bracket notation, for example `@[0]["end-time"]`, `@[0]["transfer-limit"]`, and `@[0]["uptime-limit"]`. Dot notation fails.
    - Live router has the bridge deployed at `/usr/libexec/hotspot-openwrt/userman-info`, `/www/cgi-bin/hotspot-card-info`, `/www/hotspot/status.html`, and `/www/luci-static/resources/view/services/hotspot-openwrt.js`.
    - Live REST is enabled through OpenWrt UCI and uses MikroTik `www` HTTP on `192.168.1.2:80`, restricted to the OpenWrt router side. HTTPS `www-ssl` failed earlier with `SSL - A fatal alert message was received from our peer` because RouterOS had no usable SSL certificate configured.
    - Live UCI values are expected to be: `userman_rest_enabled='1'`, `userman_rest_scheme='http'`, `userman_rest_host='192.168.1.2'`, `userman_rest_port='80'`, `userman_rest_username='admin'`, `userman_rest_user_field='name'`, `userman_rest_timeout='8'`, and the password stored server-side only.
    - RouterOS REST credentials were validated with `/rest/system/resource`, returning MikroTik `hAP ax^2`, `arm64`, RouterOS `7.22.1 (stable)`.
    - User Manager v7 mapping discovered for card `101482710`:
       - `/rest/user-manager/user?name=101482710` returns the user record but no balance field.
       - `/rest/user-manager/user-profile?user=101482710` returns `profile:"100"`, `state:"running-active"`, and `end-time:"2026-05-08 02:42:32"`.
       - `/rest/user-manager/profile?name=100` returns profile metadata including `validity:"2d"` and price/name fields.
       - `/rest/user-manager/limitation?name=100` returns `transfer-limit:"314572800"` and `uptime-limit:"2d"`.
       - The current status page displays package transfer limit as balance, so `314572800` is shown as `300.0 MB`.
    - Live validation after BusyBox-compatible deploy showed:
       - `/usr/libexec/hotspot-openwrt/userman-info 101482710` -> `profile:"100"`, `balance:"300.0 MB"`, `expires_at:"2026-05-08 02:42:32"`, `validity:"2d"`.
       - `REMOTE_ADDR=192.168.10.180 QUERY_STRING="username=101482710" /www/cgi-bin/hotspot-card-info` embeds the same `user_manager` object.
    - OpenWrt router shell does not have `install`; deploy live helper/CGI files with `cp` and `chmod`, not `install -m`.
    - Rebuilt `bin/packages/mipsel_24kc/base/luci-app-hotspot-openwrt_1.0-r1_mipsel_24kc.ipk` and verified the IPK contains:
       - `./usr/libexec/hotspot-openwrt/userman-info`
       - `./www/cgi-bin/hotspot-card-info`
       - `./www/hotspot/status.html`
       - `./www/luci-static/resources/view/services/hotspot-openwrt.js`

17. Status page no longer disappears before confirmed logout
   - User reported: balance appeared, then the status page immediately returned to login while internet remained open.
   - Direct backend tests proved `/www/cgi-bin/hotspot-logout` can move the phone from Chilli `pass` to `dnat`, so the remaining issue was browser/page flow.
   - `flash/hotspot1/status.html` and the basic package `www/hotspot/status.html` now disable duplicate logout clicks, call `/cgi-bin/hotspot-logout?format=json&username=<card>`, then re-check `/cgi-bin/hotspot-card-info` before redirecting.
   - The redirect to `/hotspot/login.html?...&logged_out=1` is allowed only after an explicit `authenticated:false` response. If the session is still active or the verification request fails, the page stays open and shows an Arabic retry message instead of hiding the status page.
   - Deployment note: do not copy both status pages to `/tmp/status.html` in one `scp`; the second file overwrites the first. Deploy the converted Arabic portal as `/tmp/hotspot-status-flash.html`, then `cp` it to `/www/hotspot/status.html`.

## Current Portal Behavior

The converted portal in `flash/hotspot1/login.html` currently does this:

```text
Form action: /cgi-bin/hotspot-login
Method: GET
Visible input: username/card number
Hidden input: password
Before submit: password is explicitly set to empty
If the entered username length is 11: append @userman2 to username
```

Examples:

```text
Entered 27801248303 -> username=27801248303@userman2, password=<empty>
Entered 101255625   -> username=101255625, password=<empty>
```

This matches the current MikroTik User Manager card setup where cards can authenticate with a blank password.

After successful login, the portal redirects to:

```text
http://192.168.10.1/hotspot/status.html?t=<timestamp>
```

The browser submits to local OpenWrt CGI first, and the CGI performs the Chilli login using the real client IP from `REMOTE_ADDR`. This is the active fix for re-login after logout while the phone remains connected to Wi-Fi.

The status page reads the saved card number from browser `localStorage`, then calls:

```text
/cgi-bin/hotspot-card-info?username=<card-or-username>
```

The CGI exposes safe live session details from CoovaChilli: card/username, client IP, MAC, state, session id, input/output octets, and authenticated flag. It also includes optional `user_manager` data from the router-side RouterOS REST bridge. Do not put MikroTik credentials in browser JavaScript.

Real User Manager profile/balance/expiry is active on the live router through the server-side RouterOS REST bridge. For card `101482710`, live validation returned `profile:"100"`, `balance:"300.0 MB"`, `expires_at:"2026-05-08 02:42:32"`, and `validity:"2d"`.

Logout from the status page now calls:

```text
/cgi-bin/hotspot-logout?format=json&username=<card-or-username>
```

The router-side CGI terminates the matching CoovaChilli session with `chilli_query logout ip <client-ip>`, so the client should return to `dnat` or disappear from the list and must log in again before internet is allowed.

After the latest repair, if a client returns to `login.html` while already authenticated, the login page checks `/cgi-bin/hotspot-card-info` and redirects the browser to `status.html?t=<timestamp>&username=<card>`. This is meant to handle browser/cache/captive-portal flows after logout and re-login.

## Latest Verified State

User confirmed login succeeded after the blank-password login repair. Logout and the new server-side re-login CGI have been verified by direct router/CGI tests; final phone-browser click validation is still pending.

The RouterOS REST bridge for real User Manager balance/profile/expiry is deployed, packaged, enabled on the live router, and validated with real User Manager data. MikroTik REST currently works over HTTP `192.168.1.2:80`; HTTPS `www-ssl` should only be revisited later after configuring a real certificate on RouterOS.

Latest live User Manager validation for card `101482710`:

```json
{"enabled":true,"ok":true,"source":"routeros_rest","card_number":"101482710","profile":"100","balance":"300.0 MB","expires_at":"2026-05-08 02:42:32","validity":"2d","disabled":"false","comment":"","message":"تمت قراءة معلومات الكرت من MikroTik User Manager عبر RouterOS REST."}
```

The latest page-flow repair was deployed and verified server-side. The live `/www/hotspot/status.html` is the converted Arabic portal and contains the strict logout verification flow. Phone-browser validation is still the final check: stay connected to Wi-Fi, click logout, log in again, and confirm that the status/card information page appears automatically.

Latest router verification showed:

```text
chilli_running: true
tun0_present: true
bridge_has_ip: false
route_ok: true
network.hotspot.proto='none'
tun0: 192.168.10.1/24
```

The live router also showed a real hotspot client in Chilli's waiting state before login:

```text
D2-22-B3-86-CB-15 192.168.10.180 dnat
```

Latest logout repair verification:

```text
chilli_query -s /var/run/chilli_hotspot_openwrt.sock logout ip 192.168.10.180
D2-22-B3-86-CB-15 192.168.10.180 dnat ... 101482710

REMOTE_ADDR=192.168.10.180 QUERY_STRING="format=json&username=101482710" /www/cgi-bin/hotspot-logout
{"ok":true,...,"state":"dnat","message":"تم تسجيل الخروج وإيقاف تصريح الإنترنت لهذا الجهاز."}
```

Known remaining warning:

```text
/etc/chilli/up.sh: line 14: iptables: not found
```

Interpretation: Chilli still runs and fw4/nft rules for `tun0` forwarding are present, so this warning is not the current blocker. It should be cleaned up later by making Chilli hook scripts compatible with fw4/nft-only OpenWrt images or by installing the expected iptables compatibility package.

## Next Validation Steps

Start from here in the next conversation:

1. Recheck the live Chilli state before changing anything:

```sh
ssh root@192.168.1.20 '/usr/libexec/hotspot-openwrt/status-json; ip -4 addr show tun0; uci -q show network.hotspot'
```

2. Recheck live User Manager REST output if changing anything around status/user data:

```sh
ssh root@192.168.1.20 '/usr/libexec/hotspot-openwrt/userman-info 101482710; REMOTE_ADDR=192.168.10.180 QUERY_STRING="username=101482710" /www/cgi-bin/hotspot-card-info | sed -n "1,24p"'
```

3. Validate logout from the real phone browser:

```sh
ssh root@192.168.1.20 'chilli_query -s /var/run/chilli_hotspot_openwrt.sock list'
```

Expected after clicking `تسجيل الخروج`: the phone entry changes from `pass` to `dnat` or disappears, internet closes, and login works again from `/hotspot/login.html`.

4. If login fails again, confirm RADIUS path from OpenWrt to MikroTik:

```sh
ssh root@192.168.1.20 'ip route get 192.168.1.2; ping -c3 -W2 192.168.1.2; uci -q show hotspot_openwrt.main | grep radius; uci -q show chilli.hotspot_openwrt | grep radius'
```

5. Check if MikroTik User Manager sees Access-Request counters from NAS `192.168.1.20`.
   - NAS/client IP in MikroTik should be `192.168.1.20`.
   - Secret should match `123456` unless changed in LuCI.
   - UDP 1812/1813 must be allowed.

6. While attempting login, watch OpenWrt logs:

```sh
ssh root@192.168.1.20 'logread -f | grep -Ei "chilli|radius|Access|Reject|Accept|101255625|timeout|login|uam"'
```

7. If the router can reach MikroTik by ping but RADIUS times out, inspect MikroTik side first. Previous UDP `nc` from host to `192.168.1.2:1812/1813` succeeded, but OpenWrt-side BusyBox `nc` is limited and not reliable for UDP diagnostics.

8. Optional packet capture if tools exist:

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

Deploy latest helper/CGI files directly to the live router when testing without reinstalling the IPK. Use `cp`/`chmod` because the OpenWrt router does not provide `install`:

```sh
scp -O -o StrictHostKeyChecking=no -o UserKnownHostsFile=/tmp/openwrt-known-hosts \
   package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/userman-info \
   package/luci-app-hotspot-openwrt/files/www/cgi-bin/hotspot-card-info \
   root@192.168.1.20:/tmp/
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/tmp/openwrt-known-hosts root@192.168.1.20 '
cp /tmp/userman-info /usr/libexec/hotspot-openwrt/userman-info
cp /tmp/hotspot-card-info /www/cgi-bin/hotspot-card-info
chmod 0755 /usr/libexec/hotspot-openwrt/userman-info /www/cgi-bin/hotspot-card-info
'
```

## What Not To Waste Time On

- Do not debug TCP RADIUS refused as a failure. RADIUS is UDP here.
- Do not reintroduce MikroTik `$(...)` CHAP template logic into the OpenWrt portal.
- Do not put `192.168.10.1/24` on `br-hotspot`.
- Do not move Chilli onto `br-lan`.
- Do not revert the portal to `password=<card number>` unless MikroTik card policy changes; the current confirmed working behavior is blank password.
- Do not assume `opkg list-installed` accurately reflects the live Coova/TUN runtime on this router; Coova was restored by manual IPK data extraction and TUN by direct module copy.
- Do not use `install -m...` inside the live OpenWrt router shell; BusyBox image lacks that command. Use `cp` then `chmod`.
- Do not rely on OpenWrt-side BusyBox `nc -z/-v` for MikroTik port diagnostics. This `nc` supports only `nc [IPADDR PORT]`; use `uclient-fetch` for RouterOS REST validation.

## Conversation Log Source

## Session Delta (2026-05-16)

This section records exactly what was changed during the latest session and what was approved for next execution.

### A) Changes already applied in this session (code-level)

Hotspot package hardening and runtime-alignment edits were applied in the workspace:

- `package/luci-app-hotspot-openwrt/Makefile`
   - Added missing runtime dependencies (`uclient-fetch`, `jsonfilter`).
   - Installed missing runtime files (uci-defaults firewall bootstrap, `generate_204`, kick-client helper, firewall include script).
- `package/luci-app-hotspot-openwrt/files/www/cgi-bin/hotspot-login`
   - Reworked fallback login path to use `uclient-fetch` + `jsonfilter`.
   - Removed risky per-login NAT insertion behavior.
- `package/luci-app-hotspot-openwrt/files/etc/uci-defaults/99_hotspot-openwrt-firewall`
   - Rewritten to idempotent include/domain-redirect behavior.
   - Added captive redirect behavior through `/cgi-bin/generate_204`.
- `package/luci-app-hotspot-openwrt/files/etc/hotspot-openwrt/firewall.sh`
   - Replaced hardcoded hotspot subnet assumptions with dynamic subnet derivation from UCI.
- `package/luci-app-hotspot-openwrt/files/www/cgi-bin/generate_204`
   - Redirect target is now computed from hotspot UCI fields, no external hardcoded domain.
- `package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/license-check`
   - Guard-binary-missing path now falls back to validation helper instead of hard lockout.
- `package/luci-app-hotspot-openwrt/files/etc/config/hotspot_openwrt`
   - Added practical defaults used by UI/runtime (branding/login/speed profile defaults).
- `package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/apply`
   - Tightened local variable scope in orchestration path.
- `package/luci-app-hotspot-openwrt/files/www/cgi-bin/hotspot-speedtest`
   - Improved client lookup matching (exact IP match logic).
- `package/luci-app-hotspot-openwrt/files/www/index.html`
   - Removed external hardcoded redirect and aligned with local portal path.

### B) Architecture decision approved in this session

For quick setup integration:

1. Add hotspot quick option inside the setup wizard flow.
2. Enforce strict policy: **Hotspot and VLAN can never be enabled together**.
3. When hotspot quick mode is enabled, VLAN fields must be hidden/disabled, validation must block any VLAN attempt, and apply pipeline must skip VLAN creation.

### C) Final execution spec approved for next implementation (not yet coded)

The user-approved target is:

- Hotspot quick mode creates **two hotspot networks** automatically.
- Each network has:
   - Independent SSID.
   - Independent gateway/exit IP for that hotspot network.
   - Independent subscriber pool.
   - Independent policy profile mapping.
- Remaining steps are automated (interface wiring, DHCP/firewall/chilli alignment, apply + status check).
- VLAN remains fully disabled in hotspot quick mode.

### D) Planned implementation files (next coding phase)

- `package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js`
   - Add hotspot quick state fields, UI card, no-VLAN guards, and ordered apply flow.
- `package/luci-app-setup/files/usr/share/rpcd/acl.d/luci-app-setup.json`
   - Extend ACL to required hotspot/chilli read-write + apply/status exec scope.
- `package/luci-app-setup/files/etc/config/setup`
   - Add persistent `hotspot_quick_*` keys for dual-network setup.
- `package/luci-app-hotspot-openwrt/files/etc/config/hotspot_openwrt`
   - Add/normalize dual-network fields consumed by backend apply logic.
- `package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/apply`
   - Implement dual-network build path while preserving strict no-VLAN rule in hotspot quick mode.

### E) Acceptance criteria for the upcoming implementation

1. If `hotspot_quick_enabled=1` and any VLAN flag is on, wizard validation must fail with clear message.
2. Applying hotspot quick mode must never create or bind `wizardvlan`.
3. Two hotspot networks are created and mapped as configured (SSID/IP pool/policy per network).
4. Apply completes with deterministic status output and no dependency on manual post-fix commands.
5. Existing non-hotspot quick wizard path continues to work as before.

### F) Scope discipline requested by user

- No build during planning/design steps.
- Keep context file updated each session with:
   - What changed.
   - What is approved next.
   - Which files are expected to change.

### G) Implemented in this session (2026-05-16, execution phase)

The following implementation was completed in workspace code (no build run):

1. Quick Setup now has a Hotspot Quick card in step 4 (advanced).
2. Strict no-conflict policy is enforced end-to-end:
   - If Hotspot Quick is enabled, VLAN is auto-disabled in state/UI.
   - VLAN controls are disabled while Hotspot Quick is active.
   - Validation rejects any attempt to combine Hotspot Quick with VLAN.
3. Dual hotspot profile fields were added to setup state/config:
   - Network 1: ssid/gateway/pool_start/pool_end/policy
   - Network 2: ssid/gateway/pool_start/pool_end/policy
4. Save/apply pipeline now writes Hotspot Quick values to:
   - `/etc/config/setup` (`hotspot_quick_*`)
   - `/etc/config/hotspot_openwrt` (`quick_*` mirror + primary runtime mapping)
5. Setup wizard now invokes hotspot backend apply command after generic apply when Hotspot Quick is enabled.
6. ACL of `luci-app-setup` was expanded to include required hotspot UCI scope and apply/status exec commands.

Important runtime note:

- Current implementation provisions two SSIDs through the quick wizard hotspot path and maps primary runtime gateway/pool directly into `hotspot_openwrt.main`.
- Secondary profile values are persisted for orchestration/automation continuity in `quick_*` fields.

### H) Files changed in this execution phase

- `package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js`
- `package/luci-app-setup/files/usr/share/rpcd/acl.d/luci-app-setup.json`
- `package/luci-app-setup/files/etc/config/setup`
- `package/luci-app-setup/files/etc/uci-defaults/40_luci-app-setup`
- `package/luci-app-hotspot-openwrt/files/etc/config/hotspot_openwrt`

### I) Phase 2 implemented (2026-05-16, runtime-independent dual hotspot)

This phase was executed in code (no build run) to make the second hotspot profile active at runtime, not only persisted:

1. Quick Setup now derives a second subscriber interface automatically from the primary one.
   - SSID-1 binds to primary subscriber interface.
   - SSID-2 binds to derived secondary subscriber interface.
2. Save/apply in setup now seeds both subscriber interfaces in `network` and writes:
   - `setup.default.hotspot_quick_subscriber_interface_2`
   - `hotspot_openwrt.main.quick_subscriber_interface_secondary`
   - `hotspot_openwrt.main.quick_runtime_dual_enabled`
3. Backend apply (`hotspot-openwrt/apply`) now supports dual runtime in quick mode:
   - Creates/updates secondary network interface + device.
   - Creates/updates secondary DHCP section.
   - Adds secondary interface into hotspot firewall zone.
   - Creates second CoovaChilli instance `chilli.hotspot_openwrt_secondary` on `tun1`.
   - Uses independent secondary gateway and pool.
4. Policy now affects runtime per profile in quick dual mode:
   - Primary and secondary quick policy values are mapped to per-instance bandwidth limits (`defbandwidthmaxup/down`).
   - Primary and secondary profiles can run different limits simultaneously.
5. Firewall nft compatibility generator now supports both primary (`tun0`) and secondary (`tun1`) forward/srcnat rules.
6. Runtime verification now checks both instances in dual mode:
   - primary (`tun0`, primary hotspot IP)
   - secondary (`tun1`, secondary hotspot IP)
7. `status-json` now exposes dual-runtime fields (secondary interface/IP, tun1 presence, secondary route status, dual mode flag).

### J) Files additionally changed in phase 2

- `package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/apply`
- `package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/status-json`

### K) Validation executed after phase 2 (2026-05-16)

The following tests were run and passed:

1. Syntax checks:
   - `node --check package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js`
   - `sh -n package/luci-app-setup/files/etc/uci-defaults/40_luci-app-setup`
   - `sh -n package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/apply`
   - `sh -n package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/status-json`
2. JSON check:
   - `python3 -m json.tool package/luci-app-setup/files/usr/share/rpcd/acl.d/luci-app-setup.json`
3. Diagnostics:
   - No editor errors on all modified files.
4. Build checks (targeted package compile):
   - `make package/luci-app-hotspot-openwrt/compile -j$(nproc) V=s` (PASS)
   - `make package/luci-app-setup/compile -j$(nproc) V=s` (PASS)

Generated IPK artifacts observed after compile:

- `bin/packages/aarch64_cortex-a53/base/luci-app-hotspot-openwrt_1.0-r1_aarch64_cortex-a53.ipk`
- `bin/packages/aarch64_cortex-a53/base/luci-app-setup_1.0-r95_aarch64_cortex-a53.ipk`
- `bin/packages/mipsel_24kc/base/luci-app-hotspot-openwrt_1.0-r1_mipsel_24kc.ipk`
- `bin/packages/mipsel_24kc/base/luci-app-setup_1.0-r95_mipsel_24kc.ipk`

### L) Next operational step (post-build)

Run live runtime smoke test on target router after installing updated IPKs/image:

1. Apply Hotspot Quick with two profiles from setup wizard.
2. Verify interfaces and tunnels:
   - `ip -4 addr show tun0`
   - `ip -4 addr show tun1`
3. Verify services and status output:
   - `/usr/libexec/hotspot-openwrt/status-json`
4. Verify chilli instances:
   - `uci show chilli | grep hotspot_openwrt`
   - `pidof chilli`
5. Verify routing/NAT/firewall4 compatibility:
   - `ip route | grep -E 'tun0|tun1'`
   - `cat /etc/nftables.d/90-hotspot-openwrt-forward-nat.nft`

### M) Automation added for next step (2026-05-16)

To make router-side validation deterministic, an executable smoke test helper was added to the hotspot package:

- `/usr/libexec/hotspot-openwrt/phase2-smoke`

It validates phase-2 runtime expectations and returns JSON + exit code:

1. Quick dual mode enabled flags.
2. Primary/secondary subscriber interfaces are distinct.
3. Primary and secondary chilli sections exist.
4. `tun0` and `tun1` have IPv4 addresses.
5. Primary/secondary routes point to `tun0`/`tun1`.
6. nft compatibility file includes rules for `tun0` and `tun1`.
7. `status-json` reports `dual_quick_mode=true`.

Run command on router:

- `/usr/libexec/hotspot-openwrt/phase2-smoke`

Success criteria:

- Exit code `0`
- JSON field `"ok": true`

### N) Live runtime test executed (2026-05-16)

Live test was executed on router `192.168.1.20` and passed:

1. Reachability:
   - `ping -c 2 192.168.1.20` (PASS)
2. Runtime flags on router:
   - `hotspot_openwrt.main.quick_setup_enabled=1`
   - `hotspot_openwrt.main.quick_runtime_dual_enabled=1`
3. Smoke validation:
   - `/usr/libexec/hotspot-openwrt/phase2-smoke`
   - Result: `"ok": true`
   - Exit code: `0`
4. Status snapshot:
   - `/usr/libexec/hotspot-openwrt/status-json`
   - `"chilli_running": true`
   - `"tun0_present": true`
   - `"tun1_present": true`

Conclusion:

- Phase 2 runtime path is operational on the live target router.

### O) Live bugfix after runtime retest (2026-05-16)

During advanced live validation, policy labels were loaded correctly (`standard` / `premium`) but both chilli instances received identical bandwidth values.

Root cause:

1. In `quick_policy_limits()` normalization, whitespace deletion used:
   - `tr -d '[:space:]'`
2. On BusyBox `tr`, this removed literal letters from policy words (e.g. `standard` -> `tndrd`, `premium` -> `rmium`), so case matching never reached policy branches.

Fix applied:

1. Replaced normalization with BusyBox-safe form:
   - `tr -d ' \t\r\n'`
2. Deployed fixed `apply` script to live router and executed apply again.

Post-fix live results on `192.168.1.20`:

1. `quick_policy_primary=standard`
2. `quick_policy_secondary=premium`
3. Primary limits:
   - `defbandwidthmaxup=5000000`
   - `defbandwidthmaxdown=10000000`
4. Secondary limits:
   - `defbandwidthmaxup=15000000`
   - `defbandwidthmaxdown=30000000`
5. `/usr/libexec/hotspot-openwrt/phase2-smoke`:
   - `ok=true`
   - exit code `0`

Final status:

- Runtime dual hotspot is active and policy separation is now effective in live operation.

### P) Next-step executor added (2026-05-16)

To execute the true next step (two-client E2E) directly from router without external client devices, a new helper was added:

- `/usr/libexec/hotspot-openwrt/phase2-client-sim`

Purpose:

1. Creates temporary veth pairs and attaches them to `br-hotspot` and `br-hotspot2`.
2. Requests DHCP on both simulated client interfaces.
3. Runs HTTP probe to `http://neverssl.com` from each simulated client path.
4. Reports JSON with:
   - DHCP/IP status per simulated client
   - HTTP code per simulated client
   - chilli client counters per instance
   - `ok` + `failed[]`
5. Cleans up temporary interfaces (non-persistent).

Run command on router:

- `/usr/libexec/hotspot-openwrt/phase2-client-sim`

### Q) Current blocker at execution time

While starting this next step from workspace, direct SSH to previous live target became unreachable (`192.168.1.20`) and current reachable gateway (`192.168.137.1`) requires password.

Impact:

1. The newly added `phase2-client-sim` is ready and built, but could not be executed remotely from this workspace due access/network change.
2. No code blocker remains for phase-2 validation logic itself.

### R) Post-reboot live execution cycle (2026-05-16)

After device reboot, direct reachability to `192.168.1.20` was restored from workspace and live execution resumed.

Observed live outcomes:

1. `/usr/libexec/hotspot-openwrt/status-json`:
   - `chilli_running=true`
   - `tun0_present=true`
   - `tun1_present=true`
   - `dual_quick_mode=true`
2. `/usr/libexec/hotspot-openwrt/phase2-smoke`:
   - PASS (`ok=true`, `exit code 0`)
3. Initial `/usr/libexec/hotspot-openwrt/phase2-client-sim`:
   - script missing on router after reboot image state, then redeployed.
4. Runtime kernel limits discovered on target:
   - `veth` create fails (`RTNETLINK: Not supported`)
   - `ipvlan` unsupported too
   - `macvlan` creation works but DHCP does not obtain lease through chilli path on both simulated clients
5. Config drift discovered and fixed live:
   - `hotspot_openwrt.main.quick_runtime_dual_enabled=1` existed
   - but `wireless` lacked active secondary hotspot SSID/interface
   - operational fix applied by creating `wireless.wizard_hotspot_quick_secondary` on `radio1` network `hotspot2` and reloading wifi
6. `phase2-client-sim` improved in code:
   - tries `veth` first
   - falls back to `macvlan`
   - reports explicit blocker reasons (`veth_unavailable`, `sim_blocked_require_real_clients`)
7. Current live `phase2-client-sim` result:
   - `chilli_primary_clients=0`
   - `chilli_secondary_clients=2`
   - fails with explicit blockers because no primary real client and no usable kernel simulation backend.
8. Additional kernel-module attempt:
   - local `kmod-veth` package built for target arch and installed marker appears in `opkg`
   - module file `veth.ko` still absent because kernel config has `CONFIG_VETH` unset, so package payload is effectively empty.

Operational conclusion now:

1. Phase-2 runtime itself is healthy and verified (`phase2-smoke` PASS).
2. Full internal two-client simulation on this router image remains kernel-limited unless `CONFIG_VETH` is enabled in firmware kernel build.
3. Immediate E2E completion path is real-client validation with at least one connected client on each hotspot network.

### S) Final live closure after user connected client (2026-05-16)

After user confirmation that a client connected to primary SSID, final live verification was rerun.

Final verification outcome:

1. Runtime health:
   - PASS
   - `status-json`: chilli running, dual runtime active, tun interfaces present.
   - `phase2-smoke`: `ok=true`, `exit code 0`.
2. Dual policy divergence:
   - PASS
   - Primary runtime (192.168.10.0/24): `defbandwidthmaxdown=10000000`, `defbandwidthmaxup=5000000`
   - Secondary runtime (192.168.20.0/24): `defbandwidthmaxdown=30000000`, `defbandwidthmaxup=15000000`
3. Client presence on both networks:
   - PASS
   - Primary sessions count: `1`
   - Secondary sessions count: `3`

Final verdict:

1. Phase-2 target requirements are now satisfied end-to-end in live environment.
2. Overall final status: PASS.

### T) Phase-3 started: persistent quick wireless self-heal (2026-05-16)

Goal of this step:

1. Prevent future config drift where secondary hotspot SSID disappears after reboot or operational changes.

Implemented in `/usr/libexec/hotspot-openwrt/apply`:

1. Added wireless self-heal helpers that run in quick dual mode.
2. `apply` now enforces both sections on each run:
   - `wireless.wizard_hotspot_quick_primary`
   - `wireless.wizard_hotspot_quick_secondary`
3. Both sections are explicitly bound to subscriber interfaces (`hotspot` / `hotspot2`) and enabled.
4. Existing LAN AP entries are disabled in quick mode, and `wizardvlan` AP leftovers are removed.
5. Quick SSID values are persisted back to `hotspot_openwrt.main` during apply.

Live drift-recovery validation:

1. Secondary section was intentionally deleted on router (`wireless.wizard_hotspot_quick_secondary`).
2. Running `/usr/libexec/hotspot-openwrt/apply` recreated it automatically.
3. `hotspot2` came back up and wired correctly.
4. Final re-check: `phase2-smoke` PASS (`RC=0`) after re-apply cycle.

Current state after phase-3 step-1:

1. Runtime remains healthy.
2. Quick dual wireless layout is now self-healing and no longer dependent on manual repair.

### U) Phase-3 step-2: clean boot verification (2026-05-16)

Objective:

1. Validate behavior after reboot (without manual post-boot wireless fixes).

Execution summary:

1. Confirmed updated apply logic is present on router (`configure_quick_wireless` found in runtime script).
2. Pre-reboot baseline:
   - `phase2-smoke` PASS (`PRE_SMOKE_RC=0`).
3. Reboot issued and SSH returned after ~35 seconds.
4. Post-boot checks:
   - `wireless.wizard_hotspot_quick_primary` present.
   - `wireless.wizard_hotspot_quick_secondary` present.
   - `network.interface.hotspot2` up.
   - `phase2-smoke` PASS (`POST_SMOKE_RC=0`).
5. Package state safety check:
   - `luci-app-hotspot-openwrt` status: `install ok installed`.
   - current smoke state remains PASS (`SMOKE_NOW_RC=0`).

Conclusion:

1. Phase-3 step-2 (clean reboot validation) is PASS.
2. Dual quick wireless self-heal survives reboot lifecycle and runtime remains healthy.

### V) Phase-3 step-3 kickoff: RC gate + staged OTA playbook (2026-05-16)

Implementation completed in workspace:

1. Added new reproducible router-side gate script:
   - `/usr/libexec/hotspot-openwrt/phase3-rc-gate`
2. Script validates release-candidate readiness for quick dual mode:
   - quick dual flags
   - quick wireless primary/secondary sections and bindings
   - hotspot/hotspot2 interface up
   - no VLAN notation on hotspot interfaces
   - `phase2-smoke` pass
   - `status-json` dual/chilli healthy
3. Package install manifest updated to include the new script.
4. Added operator runbook:
   - `HOTSPOT_PHASE3_RC_AND_OTA_ROLLOUT_PLAYBOOK.md`
   - includes RC evidence capture flow + staged OTA campaign rollout + rollback commands.

Operational intent for next execution:

1. Deploy updated package to target router.
2. Run `/usr/libexec/hotspot-openwrt/phase3-rc-gate` and record artifact evidence.
3. Start canary OTA campaign (10%) then expand by health gates.

Live execution result after implementation:

1. `phase3-rc-gate` was deployed to target router and executed.
2. Output: `"ok": true`, exit code `0`.
3. `no_vlan_primary=true` and `no_vlan_secondary=true` checks passed.
4. RC evidence artifact generated at:
   - `hotspot-backups/phase3-rc-evidence-20260516-102947.md`

The full conversation transcript was read from VS Code Copilot transcript/log resources during the previous session and cross-checked with `HOTSPOT_DEVICE_ENV_REPORT_2026-05-04.md`. The important facts needed for continuation are consolidated in this file.