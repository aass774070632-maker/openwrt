#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <openssl/sha.h>
#include <sys/stat.h>
#include <sys/types.h>

#define GUARD_BIN "/usr/libexec/hotspot-openwrt/alemprator-guard"
#define HASH_STORE "/etc/alemprator/.guard_hash"
#define HEARTBEAT_FILE "/var/run/alemprator.heartbeat"
#define SLEEP_INTERVAL 60

// 1. Compute SHA-256 of a file
int compute_sha256(const char *path, char outputBuffer[65]) {
    FILE *file = fopen(path, "rb");
    if (!file) return -1;

    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256_CTX sha256;
    SHA256_Init(&sha256);
    const int bufSize = 32768;
    unsigned char *buffer = malloc(bufSize);
    int bytesRead = 0;
    if(!buffer) { fclose(file); return -1; }

    while((bytesRead = fread(buffer, 1, bufSize, file))) {
        SHA256_Update(&sha256, buffer, bytesRead);
    }
    SHA256_Final(hash, &sha256);
    fclose(file);
    free(buffer);

    for(int i = 0; i < SHA256_DIGEST_LENGTH; i++) {
        sprintf(outputBuffer + (i * 2), "%02x", hash[i]);
    }
    outputBuffer[64] = 0;
    return 0;
}

// 2. Kill-Switch Mechanism
void execute_kill_switch() {
    fprintf(stderr, "SENTINEL: BREACH DETECTED. EXECUTING KERNEL KILL-SWITCH.\n");
    // Kill dnsmasq
    system("killall -9 dnsmasq 2>/dev/null");
    
    // Inject un-bypassable nftables drop rules
    system("nft add table inet alemprator_lockdown 2>/dev/null");
    system("nft add chain inet alemprator_lockdown kill_input \\{ type filter hook input priority -300\\; policy drop\\; \\} 2>/dev/null");
    system("nft add chain inet alemprator_lockdown kill_forward \\{ type filter hook forward priority -300\\; policy drop\\; \\} 2>/dev/null");
    
    // Erase heartbeat to kill Hotspot
    unlink(HEARTBEAT_FILE);
}

// 3. Symbiotic Token Generator
void generate_heartbeat() {
    char token[65];
    char raw_data[128];
    snprintf(raw_data, sizeof(raw_data), "Alemprator_Symbiosis_%ld_%d", time(NULL), rand());
    
    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256((unsigned char*)raw_data, strlen(raw_data), hash);
    
    for(int i = 0; i < SHA256_DIGEST_LENGTH; i++) {
        sprintf(token + (i * 2), "%02x", hash[i]);
    }
    token[64] = 0;

    FILE *f = fopen(HEARTBEAT_FILE, "w");
    if (f) {
        fprintf(f, "%s\n", token);
        fclose(f);
    }
}

int main(int argc, char **argv) {
    // NOTE: Do NOT call daemon() here. The service is launched and supervised
    // by procd (see the init script), which handles daemonization and respawn.
    // Calling daemon() additionally would fork away from the process procd
    // tracks, causing procd to think the service exited and constantly respawn
    // it (and on shutdown, fail to terminate the real process cleanly).

    srand(time(NULL));
    char current_hash[65];
    char stored_hash[65];
    int in_lockdown = 0;

    // Main Watchdog Loop
    while (1) {
        if (access(GUARD_BIN, F_OK) != 0) {
            // Guard binary deleted! Execute kill switch.
            in_lockdown = 1;
            execute_kill_switch();
            sleep(SLEEP_INTERVAL);
            continue;
        }

        if (compute_sha256(GUARD_BIN, current_hash) != 0) {
            in_lockdown = 1;
            execute_kill_switch();
            sleep(SLEEP_INTERVAL);
            continue;
        }

        // TOFU (Trust On First Use) Hash storage
        FILE *store = fopen(HASH_STORE, "r");
        if (!store) {
            store = fopen(HASH_STORE, "w");
            if (store) {
                fprintf(store, "%s\n", current_hash);
                fclose(store);
            }
        } else {
            int read_ok = (fscanf(store, "%64s", stored_hash) == 1);
            fclose(store);
            if (!read_ok) {
                // Stored hash unreadable: re-establish TOFU baseline
                // rather than silently trusting an unknown state.
                FILE *w = fopen(HASH_STORE, "w");
                if (w) {
                    fprintf(w, "%s\n", current_hash);
                    fclose(w);
                }
            } else if (strcmp(current_hash, stored_hash) != 0) {
                // Hash mismatch! Tampering detected!
                in_lockdown = 1;
                execute_kill_switch();
                sleep(SLEEP_INTERVAL);
                continue; // Stay in lockdown
            }
        }

        // If we reach here, system is secure. Generate heartbeat for Hotspot.
        generate_heartbeat();

        // Restore network only when we were previously in lockdown.
        if (in_lockdown) {
            system("nft delete table inet alemprator_lockdown 2>/dev/null");
            in_lockdown = 0;
        }

        sleep(SLEEP_INTERVAL);
    }
    return 0;
}
