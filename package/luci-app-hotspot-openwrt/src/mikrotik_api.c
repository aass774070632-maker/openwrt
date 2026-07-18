#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <sys/time.h>
#include "md5.h"

int sock = -1;

void send_length(int len) {
    unsigned char c[4];
    if (len < 0x80) {
        c[0] = len;
        send(sock, c, 1, 0);
    } else if (len < 0x4000) {
        c[0] = (len >> 8) | 0x80;
        c[1] = len & 0xFF;
        send(sock, c, 2, 0);
    } else if (len < 0x200000) {
        c[0] = (len >> 16) | 0xC0;
        c[1] = (len >> 8) & 0xFF;
        c[2] = len & 0xFF;
        send(sock, c, 3, 0);
    } else if (len < 0x10000000) {
        c[0] = (len >> 24) | 0xE0;
        c[1] = (len >> 16) & 0xFF;
        c[2] = (len >> 8) & 0xFF;
        c[3] = len & 0xFF;
        send(sock, c, 4, 0);
    }
}

void send_word(const char *word) {
    int len = strlen(word);
    send_length(len);
    send(sock, word, len, 0);
}

int read_length() {
    unsigned char c;
    if (recv(sock, &c, 1, 0) <= 0) return -1;
    if ((c & 0x80) == 0x00) {
        return c;
    } else if ((c & 0xC0) == 0x80) {
        unsigned char c2;
        recv(sock, &c2, 1, 0);
        return ((c & ~0x80) << 8) | c2;
    } else if ((c & 0xE0) == 0xC0) {
        unsigned char c2[2];
        recv(sock, c2, 2, 0);
        return ((c & ~0xC0) << 16) | (c2[0] << 8) | c2[1];
    } else if ((c & 0xF0) == 0xE0) {
        unsigned char c2[3];
        recv(sock, c2, 3, 0);
        return ((c & ~0xE0) << 24) | (c2[0] << 16) | (c2[1] << 8) | c2[2];
    }
    return -1;
}

int read_word(char *buffer, int max_len) {
    int len = read_length();
    if (len < 0) return -1;
    if (len == 0) {
        buffer[0] = '\0';
        return 0;
    }
    if (len >= max_len) {
        // Just read and discard if it's too big, but we try to read what we can
        int read_len = max_len - 1;
        recv(sock, buffer, read_len, 0);
        buffer[read_len] = '\0';
        int remaining = len - read_len;
        while (remaining > 0) {
            char junk[256];
            int to_read = remaining > 256 ? 256 : remaining;
            recv(sock, junk, to_read, 0);
            remaining -= to_read;
        }
        return len;
    }
    int total_read = 0;
    while (total_read < len) {
        int r = recv(sock, buffer + total_read, len - total_read, 0);
        if (r <= 0) return -1;
        total_read += r;
    }
    buffer[len] = '\0';
    return len;
}

void hex2bin(const char *hex, unsigned char *bin) {
    while (*hex) {
        unsigned char byte = 0;
        if (*hex >= '0' && *hex <= '9') byte = (*hex - '0') << 4;
        else if (*hex >= 'a' && *hex <= 'f') byte = (*hex - 'a' + 10) << 4;
        hex++;
        if (*hex >= '0' && *hex <= '9') byte |= (*hex - '0');
        else if (*hex >= 'a' && *hex <= 'f') byte |= (*hex - 'a' + 10);
        hex++;
        *bin++ = byte;
    }
}

void bin2hex(const unsigned char *bin, int len, char *hex) {
    for (int i = 0; i < len; i++) {
        sprintf(hex + (i * 2), "%02x", bin[i]);
    }
}

int do_login(const char *user, const char *pass, int try_modern) {
    char word[2048];
    int login_success = 0;
    char challenge[128] = "";
    char name_arg[256];
    sprintf(name_arg, "=name=%s", user);

    if (try_modern) {
        /* ── Phase 1: Try the modern (>= 6.43) plaintext login ── */
        fprintf(stderr, ">>> Trying modern login (>=6.43)\n");
        send_word("/login");
        send_word(name_arg);
        
        char pass_arg[256];
        sprintf(pass_arg, "=password=%s", pass);
        send_word(pass_arg);
        send_word("");
        
        while (1) {
            if (read_word(word, sizeof(word)) < 0) {
                fprintf(stderr, "<<< EOF / Connection closed in modern login\n");
                return 0;
            }
            fprintf(stderr, "<<< Word: '%s'\n", word);
            if (word[0] == '\0') break;
            if (strcmp(word, "!done") == 0) {
                login_success = 1;
            } else if (strncmp(word, "=ret=", 5) == 0) {
                strncpy(challenge, word + 5, sizeof(challenge) - 1);
                challenge[sizeof(challenge) - 1] = '\0';
                login_success = 0;
            } else if (strcmp(word, "!trap") == 0) {
                fprintf(stderr, "TRAP in modern login\n");
                if (read_word(word, sizeof(word)) >= 0)
                    fprintf(stderr, "Message: %s\n", word);
                return 0;
            }
        }
        
        if (login_success && strlen(challenge) == 0) {
            fprintf(stderr, ">>> Modern login succeeded\n");
            return 1;
        }
    } else {
        /* Force Legacy Phase 1: Request Challenge */
        fprintf(stderr, ">>> Requesting legacy MD5 challenge\n");
        send_word("/login");
        send_word("");
        while (1) {
            if (read_word(word, sizeof(word)) < 0) {
                fprintf(stderr, "<<< EOF / Connection closed in legacy phase 1\n");
                return 0;
            }
            fprintf(stderr, "<<< Word: '%s'\n", word);
            if (word[0] == '\0') break;
            if (strcmp(word, "!done") == 0) {
                login_success = 1;
            } else if (strncmp(word, "=ret=", 5) == 0) {
                strncpy(challenge, word + 5, sizeof(challenge) - 1);
                challenge[sizeof(challenge) - 1] = '\0';
                login_success = 0;
            } else if (strcmp(word, "!trap") == 0) {
                fprintf(stderr, "TRAP in legacy phase 1\n");
                if (read_word(word, sizeof(word)) >= 0)
                    fprintf(stderr, "Message: %s\n", word);
                return 0;
            }
        }
    }
    
    /* ── Phase 2 (fallback/forced): Legacy MD5 challenge-response ── */
    if (strlen(challenge) > 0) {
        fprintf(stderr, ">>> Performing legacy MD5 login (challenge: %s)\n", challenge);
        unsigned char bin_challenge[64];
        hex2bin(challenge, bin_challenge);
        
        MD5_CTX ctx;
        unsigned char hash[16];
        char hex_hash[33];
        
        MD5Init(&ctx);
        unsigned char zero = 0;
        MD5Update(&ctx, &zero, 1);
        MD5Update(&ctx, (unsigned char*)pass, strlen(pass));
        MD5Update(&ctx, bin_challenge, strlen(challenge) / 2);
        MD5Final(hash, &ctx);
        bin2hex(hash, 16, hex_hash);
        
        fprintf(stderr, ">>> Sending legacy /login with MD5 response\n");
        send_word("/login");
        send_word(name_arg);
        
        char response[128];
        sprintf(response, "=response=00%s", hex_hash);
        send_word(response);
        send_word("");
        
        login_success = 0;
        while (1) {
            if (read_word(word, sizeof(word)) < 0) {
                fprintf(stderr, "<<< EOF / Connection closed in legacy phase 2\n");
                return 0;
            }
            fprintf(stderr, "<<< Legacy Word: '%s'\n", word);
            if (word[0] == '\0') break;
            if (strcmp(word, "!done") == 0) {
                login_success = 1;
            } else if (strcmp(word, "!trap") == 0) {
                fprintf(stderr, "TRAP in legacy login\n");
                if (read_word(word, sizeof(word)) >= 0)
                    fprintf(stderr, "Message: %s\n", word);
                return 0;
            }
        }
        return login_success;
    }
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc != 5) {
        fprintf(stderr, "Usage: %s <ip> <user> <pass> <hotspot_username>\n", argv[0]);
        return 1;
    }

    const char *ip = argv[1];
    const char *api_user = argv[2];
    const char *api_pass = argv[3];
    const char *hotspot_user = argv[4];

    struct sockaddr_in server;
    sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) return 1;

    server.sin_addr.s_addr = inet_addr(ip);
    server.sin_family = AF_INET;
    server.sin_port = htons(8728);

    struct timeval tv;
    tv.tv_sec = 180;
    tv.tv_usec = 0;
    setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, (const char*)&tv, sizeof tv);
    setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, (const char*)&tv, sizeof tv);

    if (connect(sock, (struct sockaddr *)&server, sizeof(server)) < 0) {
        printf("{\"error\": \"connect failed\"}\n");
        close(sock);
        return 1;
    }

    int login_ok = do_login(api_user, api_pass, 1);
    if (!login_ok) {
        fprintf(stderr, ">>> Modern login failed/dropped, reconnecting for legacy login...\n");
        close(sock);
        sock = socket(AF_INET, SOCK_STREAM, 0);
        if (sock < 0) return 1;
        setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, (const char*)&tv, sizeof tv);
        setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, (const char*)&tv, sizeof tv);
        if (connect(sock, (struct sockaddr *)&server, sizeof(server)) < 0) {
            printf("{\"error\": \"reconnect failed\"}\n");
            close(sock);
            return 1;
        }
        login_ok = do_login(api_user, api_pass, 0);
    }

    if (!login_ok) {
        printf("{\"error\": \"login failed\"}\n");
        close(sock);
        return 1;
    }

    fprintf(stderr, ">>> Sending /tool/user-manager/user/print with filter and proplist\n");
    send_word("/tool/user-manager/user/print");
    
    char query[256];
    int is_all = (strcmp(hotspot_user, "ALL") == 0);
    if (!is_all) {
        sprintf(query, "?username=%s", hotspot_user);
        send_word(query);
    }
    
    /* Request all fields to prevent proplist compatibility issues on older RouterOS v6 */
    send_word("");
    fprintf(stderr, ">>> Waiting for response...\n");

    char word[2048];
    int in_re = 0;
    
    /* Current record fields (reset per !re) */
    char cur_username[256] = "";
    char cur_limit_bytes[64] = "0";
    char cur_limit_uptime[64] = "0";
    char cur_uptime_used[64] = "0";
    char cur_download_used[64] = "0";
    char cur_upload_used[64] = "0";
    char cur_active[16] = "false";
    char cur_profile[128] = "";
    char cur_disabled[16] = "";
    char cur_comment[256] = "";

    /* Matched result fields */
    char limit_bytes[64] = "0";
    char limit_uptime[64] = "0";
    char uptime_used[64] = "0";
    char download_used[64] = "0";
    char upload_used[64] = "0";
    char active[16] = "false";
    char profile[128] = "";
    char disabled_str[16] = "";
    char comment_str[256] = "";
    int found = 0;

    while (1) {
        if (read_word(word, sizeof(word)) < 0) break;
        if (word[0] == '\0') {
            /* End of record — check if this record matches */
            if (in_re && (is_all || strcmp(cur_username, hotspot_user) == 0)) {
                found = 1;
                strncpy(limit_bytes, cur_limit_bytes, sizeof(limit_bytes) - 1);
                strncpy(limit_uptime, cur_limit_uptime, sizeof(limit_uptime) - 1);
                strncpy(uptime_used, cur_uptime_used, sizeof(uptime_used) - 1);
                strncpy(download_used, cur_download_used, sizeof(download_used) - 1);
                strncpy(upload_used, cur_upload_used, sizeof(upload_used) - 1);
                strncpy(active, cur_active, sizeof(active) - 1);
                strncpy(profile, cur_profile, sizeof(profile) - 1);
                strncpy(disabled_str, cur_disabled, sizeof(disabled_str) - 1);
                strncpy(comment_str, cur_comment, sizeof(comment_str) - 1);
                fprintf(stderr, ">>> Found matching user: %s\n", cur_username);
                
                /* If we are looking for a specific user, we can close socket and exit immediately! */
                if (!is_all) {
                    break;
                }
            }
            /* Reset for next record */
            in_re = 0;
            cur_username[0] = '\0';
            strcpy(cur_limit_bytes, "0");
            strcpy(cur_limit_uptime, "0");
            strcpy(cur_uptime_used, "0");
            strcpy(cur_download_used, "0");
            strcpy(cur_upload_used, "0");
            strcpy(cur_active, "false");
            cur_profile[0] = '\0';
            cur_disabled[0] = '\0';
            cur_comment[0] = '\0';
            continue;
        }
        if (strcmp(word, "!re") == 0) {
            in_re = 1;
            if (is_all) found = 1; /* For ALL mode, any record counts */
        } else if (strcmp(word, "!done") == 0) {
            break;
        } else if (strcmp(word, "!trap") == 0) {
            fprintf(stderr, ">>> !trap received in query response\n");
            while (1) {
                if (read_word(word, sizeof(word)) < 0) break;
                fprintf(stderr, "<<< Trap: '%s'\n", word);
                if (word[0] == '\0') break;
            }
            break;
        } else if (in_re) {
            if (strncmp(word, "=username=", 10) == 0) strncpy(cur_username, word + 10, sizeof(cur_username) - 1);
            else if (strncmp(word, "=credit-left=", 13) == 0) strncpy(cur_limit_bytes, word + 13, sizeof(cur_limit_bytes) - 1);
            else if (strncmp(word, "=uptime-left=", 13) == 0) strncpy(cur_limit_uptime, word + 13, sizeof(cur_limit_uptime) - 1);
            else if (strncmp(word, "=uptime-used=", 13) == 0) strncpy(cur_uptime_used, word + 13, sizeof(cur_uptime_used) - 1);
            else if (strncmp(word, "=download-used=", 15) == 0) strncpy(cur_download_used, word + 15, sizeof(cur_download_used) - 1);
            else if (strncmp(word, "=upload-used=", 13) == 0) strncpy(cur_upload_used, word + 13, sizeof(cur_upload_used) - 1);
            else if (strncmp(word, "=active=", 8) == 0) strncpy(cur_active, word + 8, sizeof(cur_active) - 1);
            else if (strncmp(word, "=actual-profile=", 16) == 0) strncpy(cur_profile, word + 16, sizeof(cur_profile) - 1);
            else if (strncmp(word, "=disabled=", 10) == 0) strncpy(cur_disabled, word + 10, sizeof(cur_disabled) - 1);
            else if (strncmp(word, "=comment=", 9) == 0) strncpy(cur_comment, word + 9, sizeof(cur_comment) - 1);
        }
    }

    close(sock);

    if (!found) {
        printf("{\"error\":\"User not found\"}\n");
        return 0;
    }
    
    printf("{\n");
    printf("  \"limit-bytes-total\": \"%s\",\n", limit_bytes);
    printf("  \"limit-uptime\": \"%s\",\n", limit_uptime);
    printf("  \"uptime-used\": \"%s\",\n", uptime_used);
    printf("  \"download-used\": \"%s\",\n", download_used);
    printf("  \"upload-used\": \"%s\",\n", upload_used);
    printf("  \"active\": \"%s\",\n", active);
    printf("  \"actual-profile\": \"%s\",\n", profile);
    printf("  \"disabled\": \"%s\",\n", disabled_str);
    printf("  \"comment\": \"%s\"\n", comment_str);
    printf("}\n");

    return 0;
}
