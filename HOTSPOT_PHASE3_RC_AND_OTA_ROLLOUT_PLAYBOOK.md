# Hotspot OpenWrt Phase-3 RC And OTA Rollout Playbook

Date: 2026-05-16

## Scope

- Package: luci-app-hotspot-openwrt
- Target runtime mode: quick dual hotspot (`hotspot` + `hotspot2`)
- Non-negotiable constraint: no VLAN-based hotspot interfaces

## 1) RC Gate (must pass before rollout)

Run on router:

```sh
/usr/libexec/hotspot-openwrt/phase3-rc-gate
```

Expected:

- Exit code: 0
- JSON field: `"ok": true`
- Checks include:
  - quick dual flags enabled
  - wireless quick primary/secondary sections present and enabled
  - interface bindings remain `hotspot` and `hotspot2`
  - no VLAN device notation on hotspot interfaces
  - primary/secondary interfaces are up
  - `phase2-smoke` passes
  - `status-json` confirms dual mode and running chilli

## 2) Clean Reboot Gate (must pass again)

Run from host:

```sh
ssh root@192.168.1.20 'reboot'
```

After SSH returns, run:

```sh
ssh root@192.168.1.20 '/usr/libexec/hotspot-openwrt/phase3-rc-gate; echo RC:$?'
```

Expected:

- `RC:0`
- `"ok": true`

## 3) Capture RC Evidence Artifact

Run from repository root:

```sh
TS="$(date +%Y%m%d-%H%M%S)"
OUT="hotspot-backups/phase3-rc-evidence-${TS}.md"
{
  echo "# Phase-3 RC Evidence"
  echo
  echo "- Timestamp: $(date -Iseconds)"
  echo "- Router: 192.168.1.20"
  echo
  echo "## Package Status"
  ssh root@192.168.1.20 "opkg status luci-app-hotspot-openwrt | sed -n '1,8p'"
  echo
  echo "## RC Gate"
  ssh root@192.168.1.20 "/usr/libexec/hotspot-openwrt/phase3-rc-gate"
  echo
  echo "## Smoke"
  ssh root@192.168.1.20 "/usr/libexec/hotspot-openwrt/phase2-smoke; echo PHASE2_RC:$?"
  echo
  echo "## Status JSON"
  ssh root@192.168.1.20 "/usr/libexec/hotspot-openwrt/status-json"
  echo
  echo "## Wireless Quick Sections"
  ssh root@192.168.1.20 "uci -q show wireless.wizard_hotspot_quick_primary; uci -q show wireless.wizard_hotspot_quick_secondary"
} > "$OUT"

echo "Evidence saved to $OUT"
```

## 4) OTA Staged Rollout (campaign based)

Assumptions:

- OTA backend is reachable on `BASE_URL`
- Operator has admin credentials
- Release and campaign APIs are enabled (`/api/admin/...`)

### Step A: Login

```sh
BASE_URL="http://127.0.0.1:8080"
AUTH_JSON="$(curl -fsS -X POST "$BASE_URL/api/admin/auth/login" -H 'Content-Type: application/json' -d '{"email":"admin@example.com","password":"CHANGE_ME"}')"
TOKEN="$(printf '%s' "$AUTH_JSON" | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')"
```

### Step B: Create or identify release

- Use existing release creation flow (`/api/admin/releases` or `/api/admin/releases/upload`).
- Record returned `release.id`.

### Step C: Create canary campaign at 10%

```sh
curl -fsS -X POST "$BASE_URL/api/admin/campaigns" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{
    "release_id": 123,
    "name": "hotspot-phase3-canary",
    "channel": "stable",
    "rollout_percent": 10,
    "active": true,
    "priority": 100
  }'
```

### Step D: Observe before expansion

- Monitor campaign devices and heartbeat/error fields for at least one update window.
- Expand only if no critical regression.

Suggested expansion sequence:

1. 10% (canary)
2. 25%
3. 50%
4. 100%

Update rollout percent:

```sh
curl -fsS -X PATCH "$BASE_URL/api/admin/campaigns/456" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"rollout_percent":25}'
```

## 5) Rollback

Fast rollback options:

1. Pause campaign immediately:

```sh
curl -fsS -X POST "$BASE_URL/api/admin/campaigns/456/pause" -H "Authorization: Bearer $TOKEN"
```

2. Or set rollout to minimum while investigating:

```sh
curl -fsS -X PATCH "$BASE_URL/api/admin/campaigns/456" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"rollout_percent":1}'
```

## 6) Release Exit Criteria

- RC gate passes before rollout and after reboot.
- Canary batch shows no critical hotspot regression.
- Rollout expanded in stages with health checks between stages.
- Rollback path validated and operator-ready.
