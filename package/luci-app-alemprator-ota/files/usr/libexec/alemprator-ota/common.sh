#!/bin/sh

. /lib/functions.sh

CONFIG_NAME="alemprator_ota"
SECTION="main"

STATE_DIR="/tmp/alemprator-ota"
PERSIST_DIR="/etc/alemprator"
RETRY_FILE="$PERSIST_DIR/ota.retry"
REGISTERED_FILE="$PERSIST_DIR/registered"

SERVER_URL=""
REGISTER_PATH=""
UPDATE_PATH=""
HEARTBEAT_PATH=""
CHECK_INTERVAL="21600"
RANDOM_DELAY_MAX="3600"
AUTO_UPGRADE="1"
KEEP_CONFIG="1"
ALLOW_FORCE="1"
WINDOW_START="2"
WINDOW_END="6"
RETRY_BASE="900"
RETRY_MAX="21600"
TOKEN_SALT=""
CONNECT_TIMEOUT="20"
MODEL_FILE="/etc/model"
TOKEN_FILE="/etc/alemprator/device.token"
STATE_FILE="/tmp/alemprator-ota/state.env"

status="idle"
update_available="0"
latest_version=""
changelog=""
last_error=""
last_check_epoch="0"
last_result="idle"
last_download_url=""
current_version=""
retry_attempts="0"
next_retry_epoch="0"

log() {
	logger -t alemprator-ota "$*"
}

safe_int() {
	case "$1" in
		''|*[!0-9]*) echo "$2" ;;
		*) echo "$1" ;;
	esac
}

escape_sq() {
	printf '%s' "$1" | sed "s/'/'\\''/g"
}

json_escape() {
	printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e ':a;N;$!ba;s/\n/\\n/g'
}

safe_text() {
	printf '%s' "$1" | tr '\r\n' ' ' | sed "s/'//g"
}

load_config() {
	config_load "$CONFIG_NAME"
	config_get SERVER_URL "$SECTION" server_url "https://updates.example.com"
	config_get REGISTER_PATH "$SECTION" register_path "/api/register"
	config_get UPDATE_PATH "$SECTION" update_path "/api/update"
	config_get HEARTBEAT_PATH "$SECTION" heartbeat_path "/api/heartbeat"
	config_get CHECK_INTERVAL "$SECTION" check_interval "21600"
	config_get RANDOM_DELAY_MAX "$SECTION" random_delay_max "3600"
	config_get AUTO_UPGRADE "$SECTION" auto_upgrade "1"
	config_get KEEP_CONFIG "$SECTION" keep_config "1"
	config_get ALLOW_FORCE "$SECTION" allow_force "1"
	config_get WINDOW_START "$SECTION" window_start "2"
	config_get WINDOW_END "$SECTION" window_end "6"
	config_get RETRY_BASE "$SECTION" retry_base "900"
	config_get RETRY_MAX "$SECTION" retry_max "21600"
	config_get TOKEN_SALT "$SECTION" token_salt "CHANGE_ME_UNIQUE_PER_BRAND"
	config_get CONNECT_TIMEOUT "$SECTION" connect_timeout "20"
	config_get MODEL_FILE "$SECTION" model_file "/etc/model"
	config_get TOKEN_FILE "$SECTION" token_file "/etc/alemprator/device.token"
	config_get STATE_FILE "$SECTION" state_file "/tmp/alemprator-ota/state.env"

	CHECK_INTERVAL="$(safe_int "$CHECK_INTERVAL" 21600)"
	RANDOM_DELAY_MAX="$(safe_int "$RANDOM_DELAY_MAX" 3600)"
	WINDOW_START="$(safe_int "$WINDOW_START" 2)"
	WINDOW_END="$(safe_int "$WINDOW_END" 6)"
	RETRY_BASE="$(safe_int "$RETRY_BASE" 900)"
	RETRY_MAX="$(safe_int "$RETRY_MAX" 21600)"
	CONNECT_TIMEOUT="$(safe_int "$CONNECT_TIMEOUT" 20)"

	mkdir -p "$STATE_DIR" "$PERSIST_DIR"
}

load_state() {
	[ -f "$STATE_FILE" ] || return 0
	. "$STATE_FILE"
}

write_state() {
	mkdir -p "$STATE_DIR"
	cat > "$STATE_FILE" <<EOF
status='$(escape_sq "$(safe_text "$status")")'
update_available='$(escape_sq "$update_available")'
latest_version='$(escape_sq "$(safe_text "$latest_version")")'
changelog='$(escape_sq "$(safe_text "$changelog")")'
last_error='$(escape_sq "$(safe_text "$last_error")")'
last_check_epoch='$(escape_sq "$last_check_epoch")'
last_result='$(escape_sq "$(safe_text "$last_result")")'
last_download_url='$(escape_sq "$(safe_text "$last_download_url")")'
current_version='$(escape_sq "$(safe_text "$current_version")")'
retry_attempts='$(escape_sq "$retry_attempts")'
next_retry_epoch='$(escape_sq "$next_retry_epoch")'
EOF
}

load_retry() {
	retry_attempts=0
	next_retry_epoch=0
	[ -f "$RETRY_FILE" ] || return 0
	. "$RETRY_FILE"
	retry_attempts="$(safe_int "$retry_attempts" 0)"
	next_retry_epoch="$(safe_int "$next_retry_epoch" 0)"
}

save_retry() {
	cat > "$RETRY_FILE" <<EOF
retry_attempts='$(safe_int "$retry_attempts" 0)'
next_retry_epoch='$(safe_int "$next_retry_epoch" 0)'
EOF
}

clear_retry() {
	retry_attempts=0
	next_retry_epoch=0
	rm -f "$RETRY_FILE"
}

retry_schedule_failure() {
	load_retry
	retry_attempts=$((retry_attempts + 1))
	delay=$((RETRY_BASE * (2 ** (retry_attempts - 1))))
	[ "$delay" -gt "$RETRY_MAX" ] && delay="$RETRY_MAX"
	next_retry_epoch=$(( $(date +%s) + delay ))
	save_retry
}

retry_allowed_now() {
	load_retry
	now="$(date +%s)"
	[ "$now" -ge "$next_retry_epoch" ]
}

get_board_name() {
	ubus call system board 2>/dev/null | jsonfilter -e '@.board_name'
}

get_device_model() {
	if [ -s "$MODEL_FILE" ]; then
		head -n1 "$MODEL_FILE"
		return 0
	fi
	ubus call system board 2>/dev/null | jsonfilter -e '@.model'
}

get_current_version() {
	local version revision
	version="$(ubus call system board 2>/dev/null | jsonfilter -e '@.release.version')"
	revision="$(ubus call system board 2>/dev/null | jsonfilter -e '@.release.revision')"
	[ -n "$version" ] || version="unknown"
	[ -n "$revision" ] || revision="unknown"
	printf '%s (%s)' "$version" "$revision"
}

is_firstboot_enabled() {
	[ "$(uci -q get alemprator_firstboot.main.enabled)" = '1' ]
}

is_initial_setup_complete() {
	[ "$(uci -q get setup.default.initial_setup_complete)" = '1' ]
}

get_upgrade_block_reason() {
	if is_firstboot_enabled; then
		echo 'firstboot_active'
		return 0
	fi

	if ! is_initial_setup_complete; then
		echo 'initial_setup_incomplete'
		return 0
	fi

	return 1
}

get_upgrade_block_message() {
	local reason
	reason="${1:-$(get_upgrade_block_reason 2>/dev/null || true)}"

	case "$reason" in
		firstboot_active)
			echo 'upgrade blocked until firstboot provisioning is disabled'
			return 0
			;;
		initial_setup_incomplete)
			echo 'upgrade blocked until initial setup is completed'
			return 0
			;;
		esac

	return 1
}

upgrade_allowed_now() {
	! get_upgrade_block_reason >/dev/null 2>&1
}

get_primary_mac() {
	for iface in eth0 wan br-lan lan0; do
		if [ -r "/sys/class/net/$iface/address" ]; then
			head -n1 "/sys/class/net/$iface/address"
			return 0
		fi
	done
	echo "00:00:00:00:00:00"
}

generate_token() {
	local board mac seed
	board="$(get_board_name)"
	mac="$(get_primary_mac)"
	seed="$board|$mac|$TOKEN_SALT"
	printf '%s' "$seed" | sha256sum | awk '{print $1}'
}

ensure_token() {
	if [ -s "$TOKEN_FILE" ]; then
		head -n1 "$TOKEN_FILE"
		return 0
	fi

	mkdir -p "$(dirname "$TOKEN_FILE")"
	token="$(generate_token)"
	printf '%s\n' "$token" > "$TOKEN_FILE"
	chmod 600 "$TOKEN_FILE"
	echo "$token"
}

ensure_model_file() {
	[ -s "$MODEL_FILE" ] && return 0
	mkdir -p "$(dirname "$MODEL_FILE")"
	get_device_model > "$MODEL_FILE"
}

device_rollout_bucket() {
	local token prefix
	token="$(ensure_token)"
	prefix="$(printf '%s' "$token" | cut -c1-2)"
	printf '%d\n' $((16#$prefix % 100))
}

is_in_update_window() {
	local now hour start end
	now="$(date +%H)"
	hour="$(safe_int "$now" 0)"
	start="$(safe_int "$WINDOW_START" 2)"
	end="$(safe_int "$WINDOW_END" 6)"

	if [ "$start" -lt "$end" ]; then
		[ "$hour" -ge "$start" ] && [ "$hour" -lt "$end" ]
		return $?
	fi

	[ "$hour" -ge "$start" ] || [ "$hour" -lt "$end" ]
}

random_jitter() {
	local max raw
	max="$(safe_int "$RANDOM_DELAY_MAX" 0)"
	[ "$max" -gt 0 ] || return 0
	raw="$(dd if=/dev/urandom bs=2 count=1 2>/dev/null | od -An -tu2 | tr -d ' ')"
	[ -n "$raw" ] || raw=0
	delay=$((raw % max))
	[ "$delay" -gt 0 ] && sleep "$delay"
}

post_json() {
	local url payload
	url="$1"
	payload="$2"
	uclient-fetch -q -T "$CONNECT_TIMEOUT" --header 'Content-Type: application/json' --post-data "$payload" -O - "$url"
}

fetch_url() {
	local url
	url="$1"
	uclient-fetch -q -T "$CONNECT_TIMEOUT" -O - "$url"
}

register_device() {
	local token model version mac board payload response accepted
	token="$(ensure_token)"
	model="$(get_device_model)"
	version="$(get_current_version)"
	mac="$(get_primary_mac)"
	board="$(get_board_name)"

	payload="{\"token\":\"$token\",\"model\":\"$model\",\"version\":\"$version\",\"mac\":\"$mac\",\"board\":\"$board\"}"
	response="$(post_json "$SERVER_URL$REGISTER_PATH" "$payload" 2>/tmp/alemprator-ota-register.err)" || {
		last_error="register request failed"
		return 1
	}

	accepted="$(printf '%s' "$response" | jsonfilter -e '@.accepted')"
	if [ "$accepted" = "1" ] || [ "$accepted" = "true" ]; then
		touch "$REGISTERED_FILE"
		return 0
	fi

	last_error="register rejected"
	return 1
}

check_update_json() {
	local token model version mac board url
	token="$(ensure_token)"
	model="$(get_device_model)"
	version="$(get_current_version)"
	mac="$(get_primary_mac)"
	board="$(get_board_name)"
	url="$SERVER_URL$UPDATE_PATH?token=$token&model=$model&version=$version&mac=$mac&board=$board"
	fetch_url "$url"
}

compare_is_newer() {
	local incoming current
	incoming="$1"
	current="$2"
	opkg compare-versions "$incoming" '>' "$current"
}

apply_sysupgrade() {
	local image force_flag args
	image="$1"
	force_flag="$2"

	sysupgrade -T "$image" || return 1

	args=""
	if [ "$KEEP_CONFIG" != "1" ]; then
		args="$args -n"
	fi
	if [ "$force_flag" = "1" ] && [ "$ALLOW_FORCE" = "1" ]; then
		args="$args -F"
	fi

	# shellcheck disable=SC2086
	sysupgrade $args "$image"
}

heartbeat_device() {
	local token model version payload
	token="$(ensure_token)"
	model="$(get_device_model)"
	version="$(get_current_version)"
	payload="{\"token\":\"$token\",\"model\":\"$model\",\"version\":\"$version\",\"status\":\"$status\"}"
	post_json "$SERVER_URL$HEARTBEAT_PATH" "$payload" >/dev/null 2>&1 || true
}
