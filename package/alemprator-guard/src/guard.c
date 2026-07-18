/*
 * Alemprator Guard - Hardware License Validator
 * Version: 1.0
 *
 * This binary validates that this hardware is authorized to run
 * the Alemprator Hotspot package. It contacts the Alemprator
 * licensing server and returns:
 *   Exit 0 = Authorized
 *   Exit 1 = NOT authorized (hotspot will not start)
 *
 * The HMAC signing key is embedded as bytes (not plaintext).
 * Reverse engineering requires specialized tools and expertise.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <fcntl.h>
#include <syslog.h>
#include <openssl/hmac.h>
#include <openssl/evp.h>

/* ─── Embedded Constants ─────────────────────────────────────────── */

/* HMAC-SHA256 key stored as byte array (not grep-able plaintext) */
static const unsigned char GUARD_KEY[] = {
    0xF5, 0x03, 0x35, 0xE0, 0xDD, 0x43, 0x2F, 0x2C,
    0xC4, 0xEC, 0xE8, 0xEA, 0xC7, 0xDE, 0xF8, 0x7E,
    0x0B, 0xEC, 0x7D, 0x67, 0x81, 0x20, 0x6D, 0x36,
    0xF1, 0x2B, 0xB6, 0x8B, 0xBC, 0x52, 0x6C, 0xB0
};
static const int GUARD_KEY_LEN = 32;

/* Server endpoint — split across two variables to avoid simple grep */
static const char SRV_A[] = "https://ota.kartnet";
static const char SRV_B[] = ".org/api/hotspot-verify";

/* Token and MAC paths */
static const char TOKEN_PATH[] = "/etc/alemprator/device.token";
static const char CACHE_PATH[] = "/etc/config/hotspot_licensing";

/* Grace period in seconds (3 days) */
#define GRACE_SECONDS 259200
/* First-boot tolerance (24 hours before requiring server contact) */
#define FIRSTBOOT_SECONDS 86400

/* ─── Helpers ─────────────────────────────────────────────────────── */

static int read_file(const char *path, char *buf, int maxlen)
{
    int fd = open(path, O_RDONLY);
    if (fd < 0) return -1;
    int n = (int)read(fd, buf, maxlen - 1);
    close(fd);
    if (n <= 0) return -1;
    /* strip trailing whitespace / newlines */
    while (n > 0 && (buf[n-1] == '\n' || buf[n-1] == '\r' ||
                     buf[n-1] == ' '  || buf[n-1] == '\t'))
        n--;
    buf[n] = '\0';
    return n;
}

static int read_mac(char *buf, int maxlen)
{
    static const char *candidates[] = {
        "/sys/class/net/br-lan/address",
        "/sys/class/net/eth0/address",
        "/sys/class/net/eth0.1/address",
        NULL
    };
    for (int i = 0; candidates[i]; i++) {
        if (read_file(candidates[i], buf, maxlen) > 0)
            return 0;
    }
    return -1;
}

/* Compute HMAC-SHA256 → lowercase hex string in out (must be ≥ 65 bytes) */
static void guard_hmac(const char *data, char *out)
{
    unsigned char digest[EVP_MAX_MD_SIZE];
    unsigned int  dlen = 0;

    HMAC(EVP_sha256(),
         GUARD_KEY, GUARD_KEY_LEN,
         (const unsigned char *)data, strlen(data),
         digest, &dlen);

    for (unsigned int i = 0; i < dlen; i++)
        sprintf(out + i * 2, "%02x", digest[i]);
    out[dlen * 2] = '\0';
}

/* Read a single UCI option value (lightweight, no libuci dependency) */
static int uci_get_simple(const char *config_opt, char *buf, int maxlen)
{
    char cmd[256];
    snprintf(cmd, sizeof(cmd), "uci -q get %s 2>/dev/null", config_opt);
    FILE *fp = popen(cmd, "r");
    if (!fp) return -1;
    int n = (int)fread(buf, 1, maxlen - 1, fp);
    pclose(fp);
    if (n <= 0) return -1;
    while (n > 0 && (buf[n-1] == '\n' || buf[n-1] == '\r')) n--;
    buf[n] = '\0';
    return n;
}

/* ─── Cache helpers (read/write expires_at from UCI config) ──────── */

static long read_cache_expires(void)
{
    char buf[64] = {0};
    if (uci_get_simple("hotspot_licensing.main.expires_at", buf, sizeof(buf)) <= 0)
        return 0;
    return atol(buf);
}

static const char *read_cache_status(void)
{
    static char buf[32] = {0};
    if (uci_get_simple("hotspot_licensing.main.license_status", buf, sizeof(buf)) <= 0)
        return "unknown";
    return buf;
}

static long read_first_check(void)
{
    char buf[64] = {0};
    if (uci_get_simple("hotspot_licensing.main.first_check_epoch", buf, sizeof(buf)) <= 0)
        return 0;
    return atol(buf);
}

static void write_cache(const char *status, long expires_at, long now)
{
    char cmd[512];
    snprintf(cmd, sizeof(cmd),
        "uci set hotspot_licensing.main.license_status='%s' 2>/dev/null;"
        "uci set hotspot_licensing.main.expires_at='%ld' 2>/dev/null;"
        "uci set hotspot_licensing.main.last_check='%ld' 2>/dev/null;"
        "uci commit hotspot_licensing 2>/dev/null",
        status, expires_at, now);
    system(cmd);
}

static void write_first_check(long now)
{
    char cmd[256];
    snprintf(cmd, sizeof(cmd),
        "uci set hotspot_licensing.main.first_check_epoch='%ld' 2>/dev/null;"
        "uci commit hotspot_licensing 2>/dev/null", now);
    system(cmd);
}

/* ─── Main verification logic ─────────────────────────────────────── */

int main(void)
{
    char token[256]    = {0};
    char mac[64]       = {0};
    char sig[128]      = {0};
    char action[512]   = {0};
    char url[256]      = {0};
    char cmd[2048]     = {0};
    char response[1024] = {0};
    FILE *fp;
    long now = (long)time(NULL);

    openlog("alemprator-guard", LOG_PID | LOG_NDELAY, LOG_DAEMON);

    /* 1. Check if licensing is enabled */
    char enabled[8] = {0};
    if (uci_get_simple("hotspot_licensing.main.enabled", enabled, sizeof(enabled)) > 0) {
        if (enabled[0] == '0') {
            syslog(LOG_INFO, "licensing disabled in config → authorization granted");
            closelog();
            return 0;   /* disabled = always allow */
        }
    }

    /* 2. Read device token */
    int has_token = (read_file(TOKEN_PATH, token, sizeof(token)) > 0);
    if (!has_token) {
        token[0] = '\0';   /* no token yet */
        syslog(LOG_WARNING, "no device token at %s — cannot contact server", TOKEN_PATH);
    }

    /* 3. Read MAC */
    if (read_mac(mac, sizeof(mac)) < 0) {
        strncpy(mac, "00:00:00:00:00:00", sizeof(mac) - 1);
        syslog(LOG_WARNING, "could not read device MAC — using zero MAC");
    }

    /* 4. Check local cache */
    const char *cached_status = read_cache_status();
    long expires_at = read_cache_expires();

    if (strcmp(cached_status, "active") == 0 && expires_at > 0 && now < expires_at) {
        syslog(LOG_INFO, "valid cached license (active, expires in %lds) → authorized",
               (long)(expires_at - now));
        closelog();
        return 0;   /* Valid local cache → authorized */
    }

    if (strcmp(cached_status, "blocked") == 0) {
        syslog(LOG_ERR, "cached status is BLOCKED → NOT authorized");
        closelog();
        return 1;
    }

    if (strcmp(cached_status, "expired") == 0) {
        syslog(LOG_ERR, "cached status is EXPIRED → NOT authorized");
        closelog();
        return 1;
    }

    /* 5. Compute HMAC signature */
    snprintf(action, sizeof(action), "hotspot_guard|%s|%s", token, mac);
    guard_hmac(action, sig);

    /* 6. Build verify URL (split to defeat simple grep) */
    snprintf(url, sizeof(url), "%s%s", SRV_A, SRV_B);

    /* 7. Make HTTPS request via uclient-fetch */
    snprintf(cmd, sizeof(cmd),
        "uclient-fetch -q -O - --timeout=20 "
        "-H 'Content-Type: application/json' "
        "-H 'X-Guard-Sig: %s' "
        "--post-data='{\"token\":\"%s\",\"mac\":\"%s\"}' "
        "'%s' 2>/dev/null",
        sig, token, mac, url);

    fp = popen(cmd, "r");
    if (!fp) {
        syslog(LOG_ERR, "failed to spawn uclient-fetch → treating as server unreachable");
        goto grace;
    }

    int n = (int)fread(response, 1, sizeof(response) - 1, fp);
    pclose(fp);

    if (n <= 0) {
        syslog(LOG_ERR, "empty/timeout response from licensing server → unreachable");
        goto grace;
    }
    response[n] = '\0';

    /* 8. Parse response */
    if (strstr(response, "\"accepted\":true") ||
        strstr(response, "\"accepted\": true")) {
        /* ✅ Server approved */
        long new_exp = now + GRACE_SECONDS;
        write_cache("active", new_exp, now);
        syslog(LOG_INFO, "server ACCEPTED license (mac=%s) → authorized until %ld",
               mac, new_exp);
        closelog();
        return 0;
    }

    if (strstr(response, "\"expired\":true") ||
        strstr(response, "\"expired\": true") ||
        strstr(response, "\"status\":\"expired\"") ||
        strstr(response, "\"status\": \"expired\"")) {
        /* ⏰ Server reports license expired */
        write_cache("expired", 0, now);
        syslog(LOG_ERR, "license EXPIRED according to server (mac=%s) → NOT authorized",
               mac);
        closelog();
        return 1;
    }

    if (strstr(response, "\"accepted\":false") ||
        strstr(response, "\"accepted\": false")) {
        /* ❌ Server explicitly blocked */
        write_cache("blocked", 0, now);
        syslog(LOG_WARNING, "alemprator-guard: license BLOCKED by server");
        closelog();
        return 1;
    }

    /* Unrecognized response — treat as unreachable to avoid soft-lock */
    syslog(LOG_ERR, "unrecognized server response '%*.s' → treating as unreachable",
           n > 200 ? 200 : n, response);
    goto grace;

grace:
    /* Server unreachable — apply grace period */
    if (strcmp(cached_status, "active") == 0 && expires_at > 0) {
        long grace_end = expires_at + 86400;   /* +1 day extra for outage */
        if (now < grace_end) {
            syslog(LOG_INFO, "alemprator-guard: server unreachable, within grace period");
            closelog();
            return 0;   /* Still within grace window */
        }
        /* Grace expired */
        write_cache("grace_expired", 0, now);
        syslog(LOG_ERR, "alemprator-guard: license grace period expired");
        closelog();
        return 1;
    }

    /* Never verified — allow 24h first-boot window */
    long first_check = read_first_check();
    if (first_check == 0) {
        write_first_check(now);
        syslog(LOG_WARNING,
               "FIRST BOOT: no prior verification, granting %.0f-hour tolerance window (until %ld)",
               (double)FIRSTBOOT_SECONDS / 3600.0, now + FIRSTBOOT_SECONDS);
        closelog();
        return 0;   /* First ever boot */
    }
    if (now < first_check + FIRSTBOOT_SECONDS) {
        syslog(LOG_WARNING,
               "FIRST BOOT tolerance active (%.0f hours remaining) → authorized",
               (double)(first_check + FIRSTBOOT_SECONDS - now) / 3600.0);
        closelog();
        return 0;   /* Still within 24h first-boot window */
    }

    /* Never verified and 24h window expired */
    syslog(LOG_ERR,
           "no valid license and first-boot %.0f-hour window expired → NOT authorized",
           (double)FIRSTBOOT_SECONDS / 3600.0);
    closelog();
    return 1;
}
