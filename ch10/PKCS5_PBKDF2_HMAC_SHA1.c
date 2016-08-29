#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#include <CommonCrypto/CommonCryptor.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int PKCS5_PBKDF2_HMAC_SHA1(
    const char *pass,
    int passlen,
    const unsigned char *salt,
    int saltlen,
    int iter,
    int keylen,
    unsigned char *out) 
{
    unsigned char digtmp[CC_SHA1_DIGEST_LENGTH], *p, itmp[4];
    int cplen, j, k, tkeylen;
    unsigned long i = 1;
    CCHmacContext hctx;
    p = out;
    tkeylen = keylen;

    if (!pass)
        passlen = 0;
    else if (passlen == -1)
       passlen = strlen(pass);

    while(tkeylen) {
        if (tkeylen > CC_SHA1_DIGEST_LENGTH)
            cplen = CC_SHA1_DIGEST_LENGTH;
        else
            cplen = tkeylen;

        itmp[0] = (unsigned char)((i >> 24) & 0xff);
        itmp[1] = (unsigned char)((i >> 16) & 0xff);
        itmp[2] = (unsigned char)((i >> 8) & 0xff);
        itmp[3] = (unsigned char)(i & 0xff);
        CCHmacInit(&hctx, kCCHmacAlgSHA1, pass, passlen);
        CCHmacUpdate(&hctx, salt, saltlen);
        CCHmacUpdate(&hctx, itmp, 4);
        CCHmacFinal(&hctx, digtmp);
        memcpy(p, digtmp, cplen);
        for (j = 1; j < iter; j++) {
            CCHmac(kCCHmacAlgSHA1, pass, passlen, digtmp, 
                CC_SHA1_DIGEST_LENGTH, digtmp);
            for(k = 0; k < cplen; k++)
                p[k] ^= digtmp[k];
        }
        tkeylen-= cplen;
        i++;
        p+= cplen;
    }
    return 1;
}

int encrypt_master_key(
    unsigned char *dest,
    const unsigned char *master_key,
    size_t key_len,
    const char *passphrase,
    const unsigned char *salt,
    int slen
) {
    CCCryptorStatus status;
    unsigned char cipherKey[key_len];
    unsigned char cipherText[key_len + kCCBlockSizeAES128];
    size_t nEncrypted;
    int r;


    r = PKCS5_PBKDF2_HMAC_SHA1(
        passphrase, strlen(passphrase), 
        salt, slen,
        10000, key_len, cipherKey);

    if (r < 0)
        return r;

    status = CCCrypt(kCCEncrypt,
        kCCAlgorithmAES128,
        kCCOptionPKCS7Padding,
        cipherKey,
        key_len,
        NULL,
        master_key, key_len,
        cipherText, sizeof(cipherText),
        &nEncrypted);
    if (status != kCCSuccess) {
        printf("CCCrypt() failed with error %d\n", status);
        return status;
    }

    memcpy(dest, cipherText, key_len);
    return 0;
}

int geo_encrypt_master_key(
    unsigned char *dest,
    const unsigned char *master_key,
    size_t key_len,
    const char *geocoordinates,
    const char *passphrase,
    const unsigned char *salt,
    int slen
) {
    CCCryptorStatus status;
    unsigned char cKey1[key_len], cKey2[key_len];
    unsigned char cipherText[key_len + kCCBlockSizeAES128];
    size_t nEncrypted;
    int r, i;

    r = PKCS5_PBKDF2_HMAC_SHA1(
        passphrase, strlen(passphrase),
        salt, slen,
        10000, key_len, cKey1);
    if (r < 0)
        return r;

    r = PKCS5_PBKDF2_HMAC_SHA1(
        geocoordinates, strlen(geocoordinates),
        salt, slen,
        650000, key_len, cKey2);
    if (r < 0)
        return r;

    for(i=0;i<key_len;++i)
        cKey1[i] ^= cKey2[i];

    status = CCCrypt(kCCEncrypt,
        kCCAlgorithmAES128,
        kCCOptionPKCS7Padding,
        cKey1,
        key_len,
        NULL,
        master_key, key_len,
        cipherText, sizeof(cipherText),
        &nEncrypted);
    if (status != kCCSuccess) {
        printf("CCCrypt() failed with error %d\n", status);
        return status;
    }

    memcpy(dest, cipherText, key_len);
    return 0;
}

