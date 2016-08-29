#include <CommonCrypto/CommonCryptor.h>
#include <Foundation/Foundation.h>
#include <stdio.h>

int decode(unsigned char *dest, const char *buf) {
    char b[3];
    int i;

    b[2] = 0;
    for(i=0;buf[i];i+=2) {
        b[0] = buf[i];
        b[1] = buf[i+1];
        dest[i/2] = (int) strtol(b, NULL, 0x10);
    }
    return 0;
}

int decryptText(
    const unsigned char *cipherKey,
    const unsigned char *cipherText
) {
    CCCryptorStatus status;
    int len = strlen(cipherText) / 2;
    unsigned char clearText[len];
    unsigned char decodedCipherText[len];
    unsigned char decodedKey[len];
    size_t nDecrypted;
    int i;

    decode(decodedKey, cipherKey);
    decode(decodedCipherText, cipherText);
    printf("Decrypting...\n");

    status = CCCrypt(kCCDecrypt,
        kCCAlgorithmAES128,
        kCCOptionPKCS7Padding,
        decodedKey,
        kCCKeySizeAES128,
        NULL,
        decodedCipherText, len,
        clearText, sizeof(clearText),
        &nDecrypted);
    if (status != kCCSuccess) {
        printf("CCCrypt() failed with error %d\n", status);
        return status;
    }

    printf("successfully decrypted %ld bytes\n", nDecrypted);
    printf("=> %s\n", clearText);

    return 0;
}

int main(int argc, char *argv[]) {

    if (argc < 3) {
        printf("Syntax: %s <key> <ciphertext>\n", argv[0]);
        return EXIT_FAILURE;
    }
    decryptText(argv[1], argv[2]);
}

