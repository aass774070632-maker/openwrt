#ifndef MD5_H
#define MD5_H

#include <stdint.h>
#include <stddef.h>

typedef struct {
    uint32_t state[4];
    uint32_t count[2];
    unsigned char buffer[64];
} MD5_CTX;

void MD5Init(MD5_CTX *context);
void MD5Update(MD5_CTX *context, const unsigned char *input, size_t inputLen);
void MD5Final(unsigned char digest[16], MD5_CTX *context);

#endif
