#!/bin/sh
set -eu

BASE_URL="${OTA_PRODUCTION_BASE_URL:-https://ota.kartnet.org}"
TMP_INDEX="/tmp/ota-admin-index.$$"
TMP_APP="/tmp/ota-admin-app.$$"
cleanup() {
	rm -f "$TMP_INDEX" "$TMP_APP"
}
trap cleanup EXIT

fetch() {
	curl -k -fsS "$@"
}

fetch "$BASE_URL/admin-app/index.html" > "$TMP_INDEX"
APP_PATH="$(sed -n 's/.*src="\([^"]*app.js[^"]*\)".*/\1/p' "$TMP_INDEX" | head -n 1)"
if [ -z "$APP_PATH" ]; then
	echo "ERROR: admin app script path was not found in production index" >&2
	exit 1
fi

fetch "$BASE_URL$APP_PATH" > "$TMP_APP"
if grep -q 'hotspot-license' "$TMP_APP"; then
	status="$(curl -k -sS -o /tmp/ota-hotspot-license-route.$$ -w '%{http_code}' \
		-X PATCH "$BASE_URL/api/admin/devices/0/hotspot-license" \
		-H 'Content-Type: application/json' \
		-d '{"licensed":true}' || true)"
	rm -f /tmp/ota-hotspot-license-route.$$
	case "$status" in
		401|403|400) ;;
		404)
			echo "ERROR: production frontend exposes hotspot-license, but backend route returns 404" >&2
			exit 1
			;;
		*)
			echo "ERROR: unexpected hotspot-license route status: $status" >&2
			exit 1
			;;
	esac
fi

echo "OK: production hotspot-license frontend/backend contract is consistent"
