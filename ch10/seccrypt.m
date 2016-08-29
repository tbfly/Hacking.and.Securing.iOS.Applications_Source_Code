#import <Foundation/Foundation.h>
#import <Security/Security.h>

void example_pki( ) {
    SecKeyRef publicKey;
    SecKeyRef privateKey; 

    CFDictionaryRef keyDefinitions;
    CFTypeRef keys[2];
    CFTypeRef values[2];

    /* Specify the parameters of the new key pair */
    keys[0] = kSecAttrKeyType;
    values[0] = kSecAttrKeyTypeRSA;

    keys[1] = kSecAttrKeySizeInBits;
    int iByteSize = 1024;
    values[1] = CFNumberCreate(NULL, kCFNumberIntType, &iByteSize);

    keyDefinitions = CFDictionaryCreate(
        NULL, keys, values, sizeof(keys) / sizeof(keys[0]), NULL, NULL );

    /* Generate new key pair */
    OSStatus status = SecKeyGeneratePair(keyDefinitions, 
        &publicKey, &privateKey);

    /* Example credentials sent to the server */
    unsigned char *clearText = "username=USERNAME&password=PASSWORD";
    unsigned char cipherText[1024];
    size_t buflen = 1024;

    /* Encrypt: Done on the device */
    status = SecKeyEncrypt(
        publicKey, kSecPaddingNone, clearText, strlen(clearText) + 1, 
        &cipherText[0], &buflen);

    /* Decrypt: Done on the server */
    unsigned char decryptedText[buflen];
    status = SecKeyDecrypt(privateKey, kSecPaddingNone, &cipherText[0],
        buflen, &decryptedText[0], &buflen);
}
