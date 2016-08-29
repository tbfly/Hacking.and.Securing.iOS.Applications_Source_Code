#include <CommonCrypto/CommonCryptor.h>
#include <Foundation/Foundation.h>
#include <stdio.h>

int encryptText(const unsigned char *clearText) {
    CCCryptorStatus status;
    unsigned char cipherKey[kCCKeySizeAES128];
    unsigned char cipherText[strlen(clearText) + kCCBlockSizeAES128];
    size_t nEncrypted;
    int i;

    printf("Encrypting text: %s\n", clearText);

    printf("Using encryption key: ");
    for(i=0;i<kCCKeySizeAES128;++i) {
        cipherKey[i] = arc4random() % 255;
        printf("%02x", cipherKey[i]);
    }
    printf("\n");

    status = CCCrypt(kCCEncrypt,
        kCCAlgorithmAES128,
        kCCOptionPKCS7Padding,
        cipherKey,
        kCCKeySizeAES128,
        NULL,
        clearText, strlen(clearText),
        cipherText, sizeof(cipherText),
        &nEncrypted);
    if (status != kCCSuccess) {
        printf("CCCrypt() failed with error %d\n", status);
        return status;
    }

    printf("successfully encrypted %ld bytes\n", nEncrypted);
    for(i=0;i<nEncrypted;++i) 
        printf("%02x", (unsigned int) cipherText[i]);

    printf("\n");
    return 0;
}

int main(int argc, char *argv[]) {

    if (argc < 2) {
        printf("Syntax: %s <text to encrypt>\n", argv[0]);
        return EXIT_FAILURE;
    }
    encryptText(argv[1]);
}

