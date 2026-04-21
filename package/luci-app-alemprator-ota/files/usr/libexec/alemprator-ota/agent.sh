#!/bin/sh

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
. "$SCRIPT_DIR/common.sh"

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
	local url expected got
	url="$1"
	expected="$2"

	uclient-fetch -q -T "$CONNECT_TIMEOUT" -O "$TMP_IMAGE" "$url" || return 1
	got="$(sha256sum "$TMP_IMAGE" | awk '{print $1}')"
	[ "$got" = "$expected" ]
}

run_check_cycle() {
	local response has_update server_version server_sha server_force server_rollout bucket should_rollout server_changelog url
	local allow_now block_reason bypass_retry

	bypass_retry=0
	[ "$1" = "force-check" ] && bypass_retry=1
	[ "$1" = "force-update" ] && bypass_retry=1

	load_config
	load_state
	ensure_model_file
	ensure_token >/dev/null
	current_version="$(get_current_version)"
	last_check_epoch="$(date +%s)"
	status="checking"
	last_error=""
	write_state

	if [ "$bypass_retry" != "1" ] && ! retry_allowed_now; then
		status="backoff"
		last_result="retry_wait"
		write_state
		return 0
	fi

	do_register_if_needed || {
		status="error"
		last_result="register_failed"
		retry_schedule_failure
		write_state
		return 1
	}

	response="$(check_update_json 2>/tmp/alemprator-ota-check.err)" || {
		status="error"
		last_error="update check request failed"
		last_result="check_failed"
		retry_schedule_failure
		write_state
		return 1
	}

	has_update="$(printf '%s' "$response" | jsonfilter -e '@.update_available')"
	server_version="$(printf '%s' "$response" | jsonfilter -e '@.version')"
	server_sha="$(printf '%s' "$response" | jsonfilter -e '@.sha256')"
	server_force="$(printf '%s' "$response" | jsonfilter -e '@.force')"
	server_rollout="$(printf '%s' "$response" | jsonfilter -e '@.rollout_percent')"
	server_changelog="$(printf '%s' "$response" | jsonfilter -e '@.changelog')"

	[ -n "$server_rollout" ] || server_rollout=100
	server_rollout="$(safe_int "$server_rollout" 100)"
	bucket="$(device_rollout_bucket)"
	should_rollout=0
	[ "$bucket" -lt "$server_rollout" ] && should_rollout=1

	update_available=0
	latest_version="${server_version:-}"
	changelog="${server_changelog:-}"

	if [ "$has_update" = "1" ] || [ "$has_update" = "true" ]; then
		if [ -n "$server_version" ] && compare_is_newer "$server_version" "$current_version"; then
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

	download_and_verify "$url" "$server_sha" || {
		status="error"
		last_result="download_or_hash_failed"
		last_error="download failed or sha mismatch"
		retry_schedule_failure
		write_state
		return 1
	}

	status="upgrading"
	last_result="upgrade_start"
	write_state

	if [ "$server_force" = "true" ] || [ "$server_force" = "1" ]; then
		server_force=1
	else
		server_force=0
	fi

	clear_retry
	write_state
	heartbeat_device

	apply_sysupgrade "$TMP_IMAGE" "$server_force"
}

run_loop() {
	load_config
	random_jitter
	while :; do
		run_check_cycle
		sleep "$CHECK_INTERVAL"
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
		AUTO_UPGRADE=0
		run_check_cycle
		;;
	force-check)
		AUTO_UPGRADE=0
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
