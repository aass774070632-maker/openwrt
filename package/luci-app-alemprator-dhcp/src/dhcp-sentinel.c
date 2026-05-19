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
    if (daemon(0, 0) == -1) {
        perror("Failed to daemonize");
        exit(EXIT_FAILURE);
    }

    srand(time(NULL));
    char current_hash[65];
    char stored_hash[65];

    // Main Watchdog Loop
    while (1) {
        if (access(GUARD_BIN, F_OK) != 0) {
            // Guard binary deleted! Execute kill switch.
            execute_kill_switch();
            sleep(SLEEP_INTERVAL);
            continue;
        }

        if (compute_sha256(GUARD_BIN, current_hash) != 0) {
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
            if (fscanf(store, "%64s", stored_hash) == 1) {
                if (strcmp(current_hash, stored_hash) != 0) {
                    // Hash mismatch! Tampering detected!
                    fclose(store);
                    execute_kill_switch();
                    sleep(SLEEP_INTERVAL);
                    continue; // Stay in lockdown
                }
            }
            fclose(store);
        }

        // If we reach here, system is secure. Generate heartbeat for Hotspot.
        generate_heartbeat();

        // Restore network if it was temporarily locked and now secure (re-auth)
        system("nft delete table inet alemprator_lockdown 2>/dev/null");

        sleep(SLEEP_INTERVAL);
    }
    return 0;
}
