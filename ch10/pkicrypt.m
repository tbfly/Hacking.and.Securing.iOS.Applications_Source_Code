#import <Foundation/Foundation.h>
#import <Security/Security.h>

NSData *exportKey(SecKeyRef key) {
    SecItemImportExportKeyParameters params;
    CFMutableArrayRef keyUsage 
        = (CFMutableArrayRef) [ NSMutableArray 
            arrayWithObjects: kSecAttrCanEncrypt, kSecAttrCanDecrypt, nil ];
    CFMutableArrayRef keyAttributes 
        = (CFMutableArrayRef) [ NSMutableArray array ];
    SecExternalFormat format = kSecFormatUnknown;
    CFDataRef keyData;
    OSStatus oserr;
    int flags = 0;

    memset(&params, 0, sizeof(params));
    params.version = SEC_KEY_IMPORT_EXPORT_PARAMS_VERSION;
    params.keyUsage = keyUsage;
    params.keyAttributes = keyAttributes;

    oserr = SecItemExport(key, format, flags, &params, &keyData);
    if (oserr) {
        fprintf(stderr, "SecItemExport failed\n", oserr);
        return nil;
    }

    return (NSData *) keyData;
}

SecKeyRef importKey(NSString *filename) {
    SecItemImportExportKeyParameters params;
    SecExternalItemType itemType = kSecItemTypeUnknown;
    SecExternalFormat format = kSecFormatUnknown;
    __block CFArrayRef items = NULL;
    SecKeyRef loadedKey;
    NSData *keyData;
    OSStatus oserr;
    int flags = 0;

    keyData = [ NSData dataWithContentsOfFile: filename ];

    memset(&params, 0, sizeof(params));
    params.keyUsage = NULL;
    params.keyAttributes = NULL;

    oserr = SecItemImport((CFDataRef) keyData, NULL, &format, &itemType,
        flags, &params, NULL, &items);
    if (oserr) {
        fprintf(stderr, "SecItemExport failed\n", oserr);
        exit(-1);
    }

    loadedKey = (SecKeyRef)CFArrayGetValueAtIndex(items, 0);
    return loadedKey;
}

void generateRandomKeyPair(NSString *filename) {
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

    NSData *privateKeyData = exportKey(privateKey);
    [ privateKeyData writeToFile: filename atomically: NO ];

    NSData *publicKeyData = exportKey(publicKey);
    [ publicKeyData writeToFile: 
        [ NSString stringWithFormat: @"%@.pub", filename ] 
        atomically: NO ];
}

int main() {
    unsigned char clearText[1024];
    unsigned char cipherText[1024];
    size_t len = sizeof(cipherText);
    OSStatus status;
    int i;

    NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];

    generateRandomKeyPair(@"mykeys");

    /* Encrypt */
    SecKeyRef publicKey = importKey(@"mykeys.pub");
    strcpy(clearText, "username=USERNAME&password=PASSWORD");
    memset(cipherText, 0, sizeof(cipherText));
    CFShow(publicKey);
    status = SecKeyEncrypt(
        publicKey, kSecPaddingPKCS1, clearText, strlen(clearText) + 1,
        &cipherText, &len);
    if (status != errSecSuccess) { 
        NSLog(@"Encryption failed: %d\n", status);
        return EXIT_FAILURE;
    }

    printf("Cipher Text: ");
    for(i=0;i<strlen(clearText);++i) 
        printf("%02x", cipherText[i]);
    printf("\n");


    /* Decrypt */
    SecKeyRef privateKey = importKey(@"mykeys");
    memset(clearText, 0, sizeof(clearText));
    CFShow(privateKey);
    status = SecKeyDecrypt(privateKey, kSecPaddingPKCS1, &cipherText,
        len, &clearText, &len);
    if (status != errSecSuccess) {
        NSLog(@"Decryption failed: %d\n", status);
        return EXIT_FAILURE;
    }
    printf("Clear Text: %s\n", clearText);

    [ pool release ];
}
