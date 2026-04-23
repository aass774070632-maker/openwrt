#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:3000}"
TOKEN="smoke-token-$(date +%s)"
MODEL="AR-07-102H"
VERSION="1.0.0"
MAC="AA:BB:CC:DD:EE:99"
BOARD="ipq6018"

json_post() {
  local path body
  path="$1"
  body="$2"
  curl -sS -X POST "${BASE_URL}${path}" -H 'Content-Type: application/json' -d "$body"
}

json_post_expect_200() {
  local path body tmp_file status_code
  path="$1"
  body="$2"
  tmp_file="$(mktemp)"
  status_code="$(curl -sS -o "$tmp_file" -w '%{http_code}' -X POST "${BASE_URL}${path}" -H 'Content-Type: application/json' -d "$body")"
  cat "$tmp_file"
  rm -f "$tmp_file"

  if [[ "$status_code" != "200" ]]; then
    echo "Expected HTTP 200 for POST ${path}, got ${status_code}" >&2
    exit 1
  fi
}

echo "[1/6] health"
curl -fsS "${BASE_URL}/api/health" >/dev/null

echo "[2/6] register"
register_resp="$(json_post_expect_200 "/api/register" "{\"token\":\"${TOKEN}\",\"model\":\"${MODEL}\",\"version\":\"${VERSION}\",\"mac\":\"${MAC}\",\"board\":\"${BOARD}\"}")"
echo "$register_resp"
printf '%s' "$register_resp" | grep -q '"accepted":true'

echo "[3/6] update available"
update_resp="$(curl -sS "${BASE_URL}/api/update?token=${TOKEN}&model=${MODEL}&version=${VERSION}&mac=${MAC}&board=${BOARD}")"
echo "$update_resp"
printf '%s' "$update_resp" | grep -q '"update_available"'

echo "[4/6] heartbeat"
heartbeat_resp="$(json_post_expect_200 "/api/heartbeat" "{\"token\":\"${TOKEN}\",\"status\":\"upgrading\",\"current_version\":\"${VERSION}\",\"last_result\":\"upgrade_start\",\"last_error\":\"\"}")"
echo "$heartbeat_resp"
printf '%s' "$heartbeat_resp" | grep -q '"ok":true'

echo "[5/6] model mismatch must be rejected"
status_code="$(curl -sS -o /tmp/smoke_mismatch_body.json -w '%{http_code}' "${BASE_URL}/api/update?token=${TOKEN}&model=WRONG-MODEL&version=${VERSION}&mac=${MAC}&board=${BOARD}")"
cat /tmp/smoke_mismatch_body.json
if [[ "$status_code" != "403" ]]; then
  echo "Expected HTTP 403 for model mismatch, got ${status_code}" >&2
  exit 1
fi

echo "[6/6] done"
echo "SMOKE_E2E_OK token=${TOKEN}"