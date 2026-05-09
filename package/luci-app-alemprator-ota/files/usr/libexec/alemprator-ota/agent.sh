#!/bin/sh


. /lib/functions.sh

CONFIG_NAME="alemprator_ota"
SECTION="main"

STATE_DIR="/tmp/alemprator-ota"
PERSIST_DIR="/etc/alemprator"
RETRY_FILE="$PERSIST_DIR/ota.retry"
REGISTERED_FILE="$PERSIST_DIR/registered"
MANUAL_IMAGE_PATH="/tmp/alemprator-ota/manual-update.bin"

SERVER_URL=""
REGISTER_PATH=""
UPDATE_PATH=""
HEARTBEAT_PATH=""
CHECK_INTERVAL="21600"
RANDOM_DELAY_MAX="3600"
AUTO_UPGRADE="1"
REQUIRE_SETUP_COMPLETE="0"
KEEP_CONFIG="1"
ALLOW_FORCE="1"
WINDOW_START="2"
WINDOW_END="6"
RETRY_BASE="900"
RETRY_MAX="21600"
TOKEN_SALT=""
HMAC_SECRET=""
CONNECT_TIMEOUT="20"
UPGRADE_EXPECTED_SECONDS="180"
MODEL_FILE="/etc/model"
MODEL_IDENTITY_FILE="/etc/alemprator/model-identities"
TOKEN_FILE="/etc/alemprator/device.token"
VERSION_FILE="/etc/alemprator/firmware-version"
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
download_bytes="0"
download_size_bytes="0"
download_percent="0"
download_rate_bps="0"
download_eta_seconds="0"
download_started_epoch="0"
download_updated_epoch="0"
upgrade_started_epoch="0"
upgrade_expected_seconds="$UPGRADE_EXPECTED_SECONDS"

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

trim_text() {
	printf '%s' "$1" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

url_encode() {
	local input hex out ch
	input="$1"
	out=""

	if command -v od >/dev/null 2>&1; then
		set -- $(printf '%s' "$input" | od -An -tx1 -v)
	else
		set -- $(printf '%s' "$input" | hexdump -v -e '1/1 "%02x "')
	fi
	for hex in "$@"; do
		ch="$(printf "\\x$hex")"
		case "$ch" in
			[a-zA-Z0-9.~_-]) out="$out$ch" ;;
			*) out="$out%$(printf '%s' "$hex" | tr '[:lower:]' '[:upper:]')" ;;
		esac
	done

	printf '%s' "$out"
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
	config_get REQUIRE_SETUP_COMPLETE "$SECTION" require_setup_complete "0"
	config_get KEEP_CONFIG "$SECTION" keep_config "1"
	config_get ALLOW_FORCE "$SECTION" allow_force "1"
	config_get WINDOW_START "$SECTION" window_start "2"
	config_get WINDOW_END "$SECTION" window_end "6"
	config_get RETRY_BASE "$SECTION" retry_base "900"
	config_get RETRY_MAX "$SECTION" retry_max "21600"
	config_get TOKEN_SALT "$SECTION" token_salt "CHANGE_ME_UNIQUE_PER_BRAND"
	config_get HMAC_SECRET "$SECTION" hmac_secret ""
	config_get CONNECT_TIMEOUT "$SECTION" connect_timeout "20"
	config_get MODEL_FILE "$SECTION" model_file "/etc/model"
	config_get MODEL_IDENTITY_FILE "$SECTION" model_identity_file "/etc/alemprator/model-identities"
	config_get TOKEN_FILE "$SECTION" token_file "/etc/alemprator/device.token"
	config_get VERSION_FILE "$SECTION" version_file "/etc/alemprator/firmware-version"
	config_get STATE_FILE "$SECTION" state_file "/tmp/alemprator-ota/state.env"
	config_get UPGRADE_EXPECTED_SECONDS "$SECTION" upgrade_expected_seconds "180"

	CHECK_INTERVAL="$(safe_int "$CHECK_INTERVAL" 21600)"
	RANDOM_DELAY_MAX="$(safe_int "$RANDOM_DELAY_MAX" 3600)"
	WINDOW_START="$(safe_int "$WINDOW_START" 2)"
	WINDOW_END="$(safe_int "$WINDOW_END" 6)"
	RETRY_BASE="$(safe_int "$RETRY_BASE" 900)"
	RETRY_MAX="$(safe_int "$RETRY_MAX" 21600)"
	CONNECT_TIMEOUT="$(safe_int "$CONNECT_TIMEOUT" 20)"
	UPGRADE_EXPECTED_SECONDS="$(safe_int "$UPGRADE_EXPECTED_SECONDS" 180)"
	upgrade_expected_seconds="$UPGRADE_EXPECTED_SECONDS"

	mkdir -p "$STATE_DIR" "$PERSIST_DIR"
}

load_state() {
	[ -f "$STATE_FILE" ] || return 0
	. "$STATE_FILE"
}

write_state() {
	local tmp_file

	mkdir -p "$STATE_DIR"
	tmp_file="$STATE_FILE.$$"
	cat > "$tmp_file" <<EOF
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
download_bytes='$(escape_sq "$download_bytes")'
download_size_bytes='$(escape_sq "$download_size_bytes")'
download_percent='$(escape_sq "$download_percent")'
download_rate_bps='$(escape_sq "$download_rate_bps")'
download_eta_seconds='$(escape_sq "$download_eta_seconds")'
download_started_epoch='$(escape_sq "$download_started_epoch")'
download_updated_epoch='$(escape_sq "$download_updated_epoch")'
upgrade_started_epoch='$(escape_sq "$upgrade_started_epoch")'
upgrade_expected_seconds='$(escape_sq "$upgrade_expected_seconds")'
EOF
	mv "$tmp_file" "$STATE_FILE"
}

reset_progress_state() {
	download_bytes="0"
	download_size_bytes="0"
	download_percent="0"
	download_rate_bps="0"
	download_eta_seconds="0"
	download_started_epoch="0"
	download_updated_epoch="0"
	upgrade_started_epoch="0"
	upgrade_expected_seconds="$UPGRADE_EXPECTED_SECONDS"
}

start_download_progress() {
	reset_progress_state
	download_size_bytes="$(safe_int "$1" 0)"
	download_started_epoch="$(date +%s)"
	download_updated_epoch="$download_started_epoch"
}

update_download_progress() {
	local current_bytes total_bytes now elapsed remaining

	current_bytes="$(safe_int "$1" 0)"
	total_bytes="$(safe_int "$download_size_bytes" 0)"
	now="$(date +%s)"
	elapsed=$((now - $(safe_int "$download_started_epoch" "$now")))
	[ "$elapsed" -gt 0 ] || elapsed=1

	download_bytes="$current_bytes"
	download_updated_epoch="$now"
	download_rate_bps=$((current_bytes / elapsed))

	if [ "$total_bytes" -gt 0 ]; then
		download_percent=$((current_bytes * 100 / total_bytes))
		[ "$download_percent" -gt 100 ] && download_percent=100
		remaining=$((total_bytes - current_bytes))
		[ "$remaining" -lt 0 ] && remaining=0
		if [ "$download_rate_bps" -gt 0 ]; then
			download_eta_seconds=$(((remaining + download_rate_bps - 1) / download_rate_bps))
		else
			download_eta_seconds="0"
		fi
	else
		download_percent="0"
		download_eta_seconds="0"
	fi
}

start_upgrade_progress() {
	upgrade_started_epoch="$(date +%s)"
	upgrade_expected_seconds="$UPGRADE_EXPECTED_SECONDS"
	download_percent="100"
	download_eta_seconds="0"
	download_updated_epoch="$upgrade_started_epoch"
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

get_model_identity_field() {
	local board field field_index
	board="$1"
	field="$2"

	[ -n "$board" ] || board="$(get_board_name)"
	[ -n "$board" ] || return 1
	[ -s "$MODEL_IDENTITY_FILE" ] || return 1

	case "$field" in
		model_key) field_index=2 ;;
		firmware_version) field_index=3 ;;
		version_code) field_index=4 ;;
		model_id) field_index=5 ;;
		*) return 1 ;;
	esac

	awk -F '|' -v board="$board" -v field_index="$field_index" '
		$1 == board && $0 !~ /^#/ {
			print $field_index
			found = 1
			exit
		}
		END {
			if (found)
				exit 0
			exit 1
		}
	' "$MODEL_IDENTITY_FILE"
}

get_expected_device_model() {
	get_model_identity_field "$(get_board_name)" model_key 2>/dev/null && return 0
	ubus call system board 2>/dev/null | jsonfilter -e '@.model'
}

get_device_model() {
	if [ -s "$MODEL_FILE" ]; then
		head -n1 "$MODEL_FILE"
		return 0
	fi
	get_expected_device_model
}

get_board_firmware_version() {
	get_model_identity_field "$(get_board_name)" firmware_version
}

get_current_version() {
	local version revision board_version
	if [ -s "$VERSION_FILE" ]; then
		version="$(head -n1 "$VERSION_FILE")"
		board_version="$(get_board_firmware_version 2>/dev/null || true)"
		[ -n "$board_version" ] && [ "$version" != "$board_version" ] && echo "$board_version" && return 0
		echo "$version"
		return 0
	fi

	board_version="$(get_board_firmware_version 2>/dev/null || true)"
	[ -n "$board_version" ] && echo "$board_version" && return 0

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
	[ "$REQUIRE_SETUP_COMPLETE" = "1" ] || return 1

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
	local expected current
	expected="$(get_expected_device_model 2>/dev/null || true)"
	current="$(head -n1 "$MODEL_FILE" 2>/dev/null)"

	[ -n "$expected" ] && [ "$current" = "$expected" ] && return 0
	[ -z "$expected" ] && [ -s "$MODEL_FILE" ] && return 0

	mkdir -p "$(dirname "$MODEL_FILE")"
	if [ -n "$expected" ]; then
		printf '%s\n' "$expected" > "$MODEL_FILE"
	else
		get_device_model > "$MODEL_FILE"
	fi
}

device_rollout_bucket() {
	local token prefix
	token="$(ensure_token)"
	prefix="$(printf '%s' "$token" | cut -c1-8 | tr '[:upper:]' '[:lower:]')"
	printf '%s\n' "$prefix" | awk '
		{
			value = 0
			for (i = 1; i <= length($0); i++) {
				digit = index("0123456789abcdef", substr($0, i, 1)) - 1
				if (digit < 0) {
					digit = 0
				}
				value = ((value * 16) + digit) % 100
			}
			print value
		}'
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

next_window_start_epoch() {
	local start end now hour minute second seconds_today window_start_epoch

	start="$(safe_int "$WINDOW_START" 2)"
	end="$(safe_int "$WINDOW_END" 6)"
	now="$(date +%s)"
	hour="$(date +%H | sed 's/^0*//; s/^$/0/')"
	minute="$(date +%M | sed 's/^0*//; s/^$/0/')"
	second="$(date +%S | sed 's/^0*//; s/^$/0/')"

	hour="$(safe_int "$hour" 0)"
	minute="$(safe_int "$minute" 0)"
	second="$(safe_int "$second" 0)"

	[ "$start" -lt 0 ] && start=0
	[ "$start" -gt 23 ] && start=23
	[ "$end" -lt 0 ] && end=0
	[ "$end" -gt 23 ] && end=23

	if [ "$start" -eq "$end" ]; then
		echo "$now"
		return 0
	fi

	seconds_today=$((hour * 3600 + minute * 60 + second))
	window_start_epoch=$((now - seconds_today + start * 3600))

	if [ "$start" -lt "$end" ]; then
		if [ "$hour" -lt "$start" ]; then
			echo "$window_start_epoch"
			return 0
		fi

		if [ "$hour" -ge "$end" ]; then
			echo $((window_start_epoch + 86400))
			return 0
		fi

		echo "$now"
		return 0
	fi

	# Wrapped window, e.g. 22:00 -> 06:00
	if [ "$hour" -ge "$start" ] || [ "$hour" -lt "$end" ]; then
		echo "$now"
		return 0
	fi

	echo "$window_start_epoch"
}

random_jitter() {
	local max raw
	max="$(safe_int "$RANDOM_DELAY_MAX" 0)"
	[ "$max" -gt 0 ] || return 0
	if command -v od >/dev/null 2>&1; then
		raw="$(dd if=/dev/urandom bs=2 count=1 2>/dev/null | od -An -tu2 | tr -d ' ')"
	else
		raw="$(dd if=/dev/urandom bs=2 count=1 2>/dev/null | hexdump -v -e '1/2 "%u"')"
	fi
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

hmac_sha256() {
	local data
	data="$1"

	if command -v openssl >/dev/null 2>&1; then
		printf '%s' "$data" | openssl dgst -sha256 -hmac "$HMAC_SECRET" | awk '{print $NF}'
		return 0
	fi

	return 1
}

signed_fetch_url() {
	local url action ts data sig
	url="$1"
	action="$2"

	if [ -z "$HMAC_SECRET" ]; then
		fetch_url "$url"
		return $?
	fi

	ts="$(date +%s)"
	data="$ts|$action"
	sig="$(hmac_sha256 "$data")" || {
		last_error="hmac requested but openssl is missing"
		return 1
	}

	uclient-fetch -q -T "$CONNECT_TIMEOUT" --header "X-OTA-TS: $ts" --header "X-OTA-Signature: $sig" -O - "$url"
}

signed_post_json() {
	local url payload action ts data sig
	url="$1"
	payload="$2"
	action="$3"

	if [ -z "$HMAC_SECRET" ]; then
		post_json "$url" "$payload"
		return $?
	fi

	ts="$(date +%s)"
	data="$ts|$action"
	sig="$(hmac_sha256 "$data")" || {
		last_error="hmac requested but openssl is missing"
		return 1
	}

	uclient-fetch -q -T "$CONNECT_TIMEOUT" --header 'Content-Type: application/json' --header "X-OTA-TS: $ts" --header "X-OTA-Signature: $sig" --post-data "$payload" -O - "$url"
}

fetch_url() {
	local url
	url="$1"
	uclient-fetch -q -T "$CONNECT_TIMEOUT" -O - "$url"
}

register_device() {
	local token model version mac board payload response accepted action err_file err_detail reject_reason
	token="$(ensure_token)"
	model="$(get_device_model)"
	version="$(get_current_version)"
	mac="$(get_primary_mac)"
	board="$(get_board_name)"
	err_file="/tmp/alemprator-ota-register.err"

	payload="{\"token\":\"$(json_escape "$token")\",\"model\":\"$(json_escape "$model")\",\"version\":\"$(json_escape "$version")\",\"mac\":\"$(json_escape "$mac")\",\"board\":\"$(json_escape "$board")\"}"
	action="register|$token|$model|$version|$mac|$board"
	response="$(signed_post_json "$SERVER_URL$REGISTER_PATH" "$payload" "$action" 2>"$err_file")" || {
		err_detail="$(tr '\n' ' ' < "$err_file" 2>/dev/null | sed 's/[[:space:]]\+/ /g' | sed 's/^ //; s/ $//' | cut -c1-180)"
		if [ -n "$err_detail" ]; then
			last_error="register request failed: $err_detail"
		else
			last_error="register request failed"
		fi
		return 1
	}

	accepted="$(printf '%s' "$response" | jsonfilter -e '@.accepted')"
	if [ "$accepted" = "1" ] || [ "$accepted" = "true" ]; then
		touch "$REGISTERED_FILE"
		return 0
	fi

	reject_reason="$(printf '%s' "$response" | jsonfilter -e '@.message')"
	if [ -z "$reject_reason" ]; then
		reject_reason="$(printf '%s' "$response" | jsonfilter -e '@.error')"
	fi
	reject_reason="$(safe_text "$reject_reason")"
	if [ -n "$reject_reason" ]; then
		last_error="register rejected: $reject_reason"
	else
		last_error="register rejected"
	fi
	return 1
}

check_update_json() {
	local token model version mac board url action
	token="$(ensure_token)"
	model="$(get_device_model)"
	version="$(get_current_version)"
	mac="$(get_primary_mac)"
	board="$(get_board_name)"
	url="$SERVER_URL$UPDATE_PATH?token=$(url_encode "$token")&model=$(url_encode "$model")&version=$(url_encode "$version")&mac=$(url_encode "$mac")&board=$(url_encode "$board")"
	action="update|$token|$model|$version|$mac|$board"
	signed_fetch_url "$url" "$action"
}

compare_is_newer() {
	local incoming current
	incoming="$1"
	current="$2"
	opkg compare-versions "$incoming" '>' "$current"
}

version_model_marker() {
	local version board model_key firmware_version version_code model_id
	version="$1"

	[ -s "$MODEL_IDENTITY_FILE" ] || { echo ""; return 0; }
	while IFS='|' read -r board model_key firmware_version version_code model_id; do
		case "$board" in ''|'#'*) continue ;; esac
		[ -n "$model_id" ] || continue
		case "$version" in
			*"$model_id"*) echo "$model_id"; return 0 ;;
		esac
	done < "$MODEL_IDENTITY_FILE"

	echo ""
}

should_accept_update_version() {
	local incoming current incoming_marker current_marker
	incoming="$1"
	current="$2"

	[ -n "$incoming" ] || return 1
	[ "$incoming" != "$current" ] || return 1

	if compare_is_newer "$incoming" "$current"; then
		return 0
	fi

	incoming_marker="$(version_model_marker "$incoming")"
	current_marker="$(version_model_marker "$current")"
	[ -n "$incoming_marker" ] || return 1
	[ -n "$current_marker" ] || return 1
	[ "$incoming_marker" != "$current_marker" ]
}

apply_sysupgrade() {
	local image force_flag args
	image="$1"
	force_flag="$2"

	sysupgrade -T "$image" || return 1

	args=""
	# OTA upgrades must preserve configuration. A wiped config re-enables
	# firstboot provisioning, which resets LAN to 192.168.1.20 on next boot.
	if [ "$KEEP_CONFIG" != "1" ]; then
		logger -t alemprator-ota "ignoring keep_config=$KEEP_CONFIG during OTA sysupgrade to preserve device configuration"
	fi
	if [ "$force_flag" = "1" ] && [ "$ALLOW_FORCE" = "1" ]; then
		args="$args -F"
	fi

	# shellcheck disable=SC2086
	sysupgrade $args "$image"
}

heartbeat_device() {
	local token model version payload action
	token="$(ensure_token)"
	model="$(get_device_model)"
	version="$(get_current_version)"
	payload="{\"token\":\"$(json_escape "$token")\",\"model\":\"$(json_escape "$model")\",\"current_version\":\"$(json_escape "$version")\",\"status\":\"$(json_escape "$status")\",\"last_result\":\"$(json_escape "$last_result")\",\"last_error\":\"$(json_escape "$last_error")\"}"
	action="heartbeat|$token|$status|$version|$last_result|$last_error"
	signed_post_json "$SERVER_URL$HEARTBEAT_PATH" "$payload" "$action" >/dev/null 2>&1 || true
}


TMP_IMAGE="/tmp/alemprator-ota-update.bin"

do_register_if_needed() {
	if [ ! -f "$REGISTERED_FILE" ]; then
		register_device || return 1
	fi
	return 0
}

choose_download_url() {
	local json primary idx candidate
	json="$1"
	primary="$(printf '%s' "$json" | jsonfilter -e '@.download_url')"
	[ -n "$primary" ] && { echo "$primary"; return 0; }

	idx=0
	while :; do
		candidate="$(printf '%s' "$json" | jsonfilter -e "@.download_urls[$idx]")"
		[ -n "$candidate" ] || break
		echo "$candidate"
		return 0
	done

	return 1
}

download_and_verify() {
	local url expected total_size fetch_pid got current_bytes
	url="$1"
	expected="$2"
	total_size="$(safe_int "$3" 0)"

	rm -f "$TMP_IMAGE"
	start_download_progress "$total_size"
	write_state

	uclient-fetch -q -T "$CONNECT_TIMEOUT" -O "$TMP_IMAGE" "$url" &
	fetch_pid=$!

	while kill -0 "$fetch_pid" 2>/dev/null; do
		if [ -f "$TMP_IMAGE" ]; then
			current_bytes="$(wc -c < "$TMP_IMAGE" 2>/dev/null | tr -d ' ')"
		else
			current_bytes="0"
		fi

		update_download_progress "$current_bytes"
		write_state
		sleep 1
	done

	wait "$fetch_pid" || return 1

	if [ -f "$TMP_IMAGE" ]; then
		current_bytes="$(wc -c < "$TMP_IMAGE" 2>/dev/null | tr -d ' ')"
	else
		current_bytes="0"
	fi

	update_download_progress "$current_bytes"
	write_state

	got="$(sha256sum "$TMP_IMAGE" | awk '{print $1}')"
	[ "$got" = "$expected" ]
}

run_check_cycle() {
	local response has_update server_version server_sha server_force server_rollout bucket should_rollout server_changelog server_size url
	local allow_now block_reason bypass_retry check_only

	bypass_retry=0
	check_only=0
	[ "$1" = "force-check" ] && { bypass_retry=1; check_only=1; }
	[ "$1" = "check-only" ] && check_only=1
	[ "$1" = "force-update" ] && bypass_retry=1

	load_config
	[ "$check_only" = "1" ] && AUTO_UPGRADE=0
	load_state
	ensure_model_file
	ensure_token >/dev/null
	current_version="$(get_current_version)"
	last_check_epoch="$(date +%s)"
	status="checking"
	last_error=""
	reset_progress_state
	write_state

	if [ "$bypass_retry" != "1" ] && ! retry_allowed_now; then
		status="backoff"
		last_result="retry_wait"
		write_state
		return 0
	fi

	if ! do_register_if_needed; then
		log "register failed; continuing with update check: $last_error"
	fi

	response="$(check_update_json 2>/tmp/alemprator-ota-check.err)" || {
		status="error"
		last_error="update check request failed"
		check_err="$(tr '\n' ' ' < /tmp/alemprator-ota-check.err 2>/dev/null | sed 's/[[:space:]]\+/ /g' | sed 's/^ //; s/ $//' | cut -c1-180)"
		[ -n "$check_err" ] && last_error="$last_error: $check_err"
		last_result="check_failed"
		retry_schedule_failure
		write_state
		return 1
	}

	clear_retry

	has_update="$(printf '%s' "$response" | jsonfilter -e '@.update_available')"
	server_version="$(trim_text "$(printf '%s' "$response" | jsonfilter -e '@.version')")"
	server_sha="$(trim_text "$(printf '%s' "$response" | jsonfilter -e '@.sha256')")"
	server_force="$(trim_text "$(printf '%s' "$response" | jsonfilter -e '@.force')")"
	server_rollout="$(trim_text "$(printf '%s' "$response" | jsonfilter -e '@.rollout_percent')")"
	server_changelog="$(trim_text "$(printf '%s' "$response" | jsonfilter -e '@.changelog')")"
	server_size="$(trim_text "$(printf '%s' "$response" | jsonfilter -e '@.size_bytes')")"

	[ -n "$server_rollout" ] || server_rollout=100
	server_rollout="$(safe_int "$server_rollout" 100)"
	server_size="$(safe_int "$server_size" 0)"
	bucket="$(device_rollout_bucket)"
	should_rollout=0
	[ "$bucket" -lt "$server_rollout" ] && should_rollout=1

	update_available=0
	latest_version="${server_version:-}"
	changelog="${server_changelog:-}"

	if [ "$has_update" = "1" ] || [ "$has_update" = "true" ]; then
		if should_accept_update_version "$server_version" "$current_version"; then
			update_available=1
		fi
	fi

	if [ "$update_available" != "1" ]; then
		status="idle"
		last_result="up_to_date"
		clear_retry
		write_state
		heartbeat_device
		return 0
	fi

	if [ "$should_rollout" != "1" ]; then
		status="staged"
		last_result="staged_wait"
		last_error="waiting for rollout batch"
		write_state
		heartbeat_device
		return 0
	fi

	if ! upgrade_allowed_now; then
		block_reason="$(get_upgrade_block_reason || true)"
		status="blocked"
		last_result="upgrade_blocked"
		last_error="$(get_upgrade_block_message "$block_reason" || echo 'upgrade blocked')"

		write_state
		heartbeat_device
		return 0
	fi

	if [ "$AUTO_UPGRADE" != "1" ] && [ "$1" != "force-update" ]; then
		status="available"
		last_result="manual_required"
		write_state
		heartbeat_device
		return 0
	fi

	if ! is_in_update_window && [ "$1" != "force-update" ]; then
		status="window_wait"
		last_result="outside_window"
		last_error="outside update window"
		write_state
		heartbeat_device
		return 0
	fi

	url="$(choose_download_url "$response")" || {
		status="error"
		last_result="missing_url"
		last_error="update url missing"
		retry_schedule_failure
		write_state
		return 1
	}

	status="downloading"
	last_download_url="$url"
	write_state

	download_and_verify "$url" "$server_sha" "$server_size" || {
		status="error"
		last_result="download_or_hash_failed"
		last_error="download failed or sha mismatch"
		retry_schedule_failure
		write_state
		return 1
	}

	status="upgrading"
	last_result="upgrade_start"
	start_upgrade_progress
	clear_retry
	write_state

	if [ "$server_force" = "true" ] || [ "$server_force" = "1" ]; then
		server_force=1
	else
		server_force=0
	fi

	heartbeat_device

	apply_sysupgrade "$TMP_IMAGE" "$server_force" || {
		status="error"
		last_result="sysupgrade_failed"
		last_error="failed to start sysupgrade"
		retry_schedule_failure
		write_state
		return 1
	}
}

run_loop() {
	local delay

	load_config
	random_jitter
	while :; do
		run_check_cycle
		delay="$CHECK_INTERVAL"
		if [ "$AUTO_UPGRADE" = "1" ] && [ "$last_result" = "outside_window" ]; then
			target_epoch="$(next_window_start_epoch)"
			now_epoch="$(date +%s)"
			delay=$((target_epoch - now_epoch + 5))
			[ "$delay" -lt 60 ] && delay=60
			[ "$delay" -gt "$CHECK_INTERVAL" ] && delay="$CHECK_INTERVAL"
		fi
		sleep "$delay"
	done
}

case "$1" in
	daemon)
		run_loop
		;;
	once)
		run_check_cycle
		;;
	check-only)
		run_check_cycle check-only
		;;
	force-check)
		run_check_cycle force-check
		;;
	update-now)
		run_check_cycle force-update
		;;
	register)
		load_config
		ensure_model_file
		register_device
		;;
	*)
		echo "Usage: $0 {daemon|once|check-only|force-check|update-now|register}" >&2
		exit 1
		;;
esac
