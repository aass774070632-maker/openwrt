#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

/* The compressed script will be placed here */
unsigned char compressed_script[] = { {{COMPRESSED_DATA}} };
unsigned int compressed_len = {{COMPRESSED_LEN}};

int main(int argc, char *argv[]) {
    char tmp_bin_path[] = "/tmp/.alemp_XXXXXX";
    int fd = mkstemp(tmp_bin_path);
    if (fd == -1) {
        fprintf(stderr, "Alemprator: mkstemp failed\\n");
        return 1;
    }
    
    FILE *f = fdopen(fd, "wb");
    if (!f) {
        fprintf(stderr, "Alemprator: fdopen failed\\n");
        return 1;
    }
    fwrite(compressed_script, 1, compressed_len, f);
    fclose(f);

    char sh_path[256];
    snprintf(sh_path, sizeof(sh_path), "%s.sh", tmp_bin_path);

    char cmd[512];
    snprintf(cmd, sizeof(cmd), "zcat %s > %s && chmod +x %s", tmp_bin_path, sh_path, sh_path);
    if (system(cmd) != 0) {
        fprintf(stderr, "Alemprator: decompression failed\\n");
        unlink(tmp_bin_path);
        unlink(sh_path);
        return 1;
    }
    unlink(tmp_bin_path);

    char exec_cmd[1024];
    snprintf(exec_cmd, sizeof(exec_cmd), "/bin/sh %s", sh_path);
    for (int i = 1; i < argc; i++) {
        strcat(exec_cmd, " \"");
        strcat(exec_cmd, argv[i]);
        strcat(exec_cmd, "\"");
    }

    int ret = system(exec_cmd);
    if (ret == -1) {
        fprintf(stderr, "Alemprator: execution failed\\n");
    }
    unlink(sh_path);
    return WEXITSTATUS(ret);
}


