#!/bin/sh
set -eu

ROUTER_IP="${ROUTER_IP:-192.168.1.20}"
ROUTER_USER="${ROUTER_USER:-root}"
SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=5"
RELEASE_DIR="/home/galal/openwrt/ota-server/public/firmware/km14/packages"

HOTSPOT_IPK="$(ls -1 "$RELEASE_DIR"/luci-app-hotspot-openwrt_*_mipsel_24kc.ipk | head -n1)"
CPUPERF_IPK="$(ls -1 "$RELEASE_DIR"/luci-app-cpu-perf_*_all.ipk | head -n1)"

if [ ! -f "$HOTSPOT_IPK" ] || [ ! -f "$CPUPERF_IPK" ]; then
  echo "Missing required IPK files in $RELEASE_DIR"
  exit 1
fi

echo "Router: $ROUTER_USER@$ROUTER_IP"
echo "Hotspot IPK: $HOTSPOT_IPK"
echo "CPU Perf IPK: $CPUPERF_IPK"

if ! ping -c 1 -W 1 "$ROUTER_IP" >/dev/null 2>&1; then
  echo "Router is not reachable by ping: $ROUTER_IP"
  exit 1
fi

scp $SSH_OPTS "$HOTSPOT_IPK" "$CPUPERF_IPK" "$ROUTER_USER@$ROUTER_IP:/tmp/"

ssh $SSH_OPTS "$ROUTER_USER@$ROUTER_IP" '
set -eu
HOTSPOT_FILE=$(ls -1 /tmp/luci-app-hotspot-openwrt_*_mipsel_24kc.ipk | head -n1)
CPUPERF_FILE=$(ls -1 /tmp/luci-app-cpu-perf_*_all.ipk | head -n1)

opkg install --force-reinstall "$HOTSPOT_FILE" "$CPUPERF_FILE"

rm -f /tmp/luci-indexcache
rm -rf /tmp/luci-modulecache/*
/etc/init.d/rpcd restart
/etc/init.d/uhttpd restart
sleep 2

echo "== Installed versions =="
opkg status luci-app-hotspot-openwrt | sed -n "1,8p"
opkg status luci-app-cpu-perf | sed -n "1,8p"

echo "== Hotspot menu JSON quick check =="
MENU_FILE=/usr/share/luci/menu.d/luci-app-hotspot-openwrt.json
head -c 1 "$MENU_FILE" | grep -q "{" && echo "Menu JSON starts correctly" || (echo "Menu JSON malformed"; exit 1)
grep -q "admin/services/hotspot-openwrt" "$MENU_FILE" && echo "Menu path exists" || (echo "Menu path missing"; exit 1)

echo "== LuCI page checks (local fetch) =="
uclient-fetch -q -O - "http://127.0.0.1/cgi-bin/luci/admin/services/hotspot-openwrt" > /tmp/hotspot_page.html || true
uclient-fetch -q -O - "http://127.0.0.1/cgi-bin/luci/admin/services/cpu-perf" > /tmp/cpu_perf_page.html || true

grep -qi "hotspot" /tmp/hotspot_page.html && echo "Hotspot page reachable" || echo "Hotspot page content check inconclusive"
if grep -q "Cannot read properties" /tmp/cpu_perf_page.html; then
  echo "CPU Perf page still contains JS error marker"
  exit 1
else
  echo "CPU Perf page error marker not found"
fi

echo "Verification completed"
'

echo "Done"
