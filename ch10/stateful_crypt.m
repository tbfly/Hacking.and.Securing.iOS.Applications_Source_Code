#include <CommonCrypto/CommonCryptor.h>
#include <Foundation/Foundation.h>
#include <stdio.h>

NSData *encrypt_AES128(
    NSData *clearText,
    NSData *key,
    NSData *iv
) {
    CCCryptorStatus cryptorStatus = kCCSuccess;
    CCCryptorRef cryptor = NULL;
    NSData *cipherText = nil;
    size_t len_outputBuffer = 0;
    size_t nRemaining = 0;
    size_t nEncrypted = 0;
    size_t len_clearText = 0;
    size_t nWritten = 0;
    unsigned char *ptr, *buf;
    int i;

    len_clearText = [ clearText length ];
    
    cryptorStatus = CCCryptorCreate( kCCEncrypt,
                                kCCAlgorithmAES128, 
                                kCCOptionPKCS7Padding,
                                (const void *) [ key bytes ], 
                                kCCBlockSizeAES128,
                                (const void *) [ iv bytes ], 
                                &cryptor
                            );
    
    /* Determine the size of the output, based on the input length */
    len_outputBuffer = CCCryptorGetOutputLength(cryptor, len_clearText, true);
    nRemaining = len_outputBuffer;
    buf = calloc(1, len_outputBuffer);
    ptr = buf;
    
    cryptorStatus = CCCryptorUpdate(
        cryptor,
        (const void *) [ clearText bytes ],
        len_clearText,
        ptr,
        nRemaining,
        &nEncrypted
    );
    
    ptr += nEncrypted;
    nRemaining -= nEncrypted;
    nWritten += nEncrypted;
    
    cryptorStatus = CCCryptorFinal(
        cryptor,
        ptr,
        nRemaining,
        &nEncrypted
    );
    
    nWritten += nEncrypted;
    CCCryptorRelease(cryptor);
    
    cipherText = [ NSData dataWithBytes: (const void *) buf 
                                 length: (NSUInteger) nWritten ];
 
    free(buf);
    return cipherText;
}

int main(int argc, char *argv[]) {
    NSData *clearText, *key, *iv, *cipherText;
    unsigned char u_key[kCCKeySizeAES128], u_iv[kCCBlockSizeAES128];
    int i;

    NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];

    if (argc < 2) {
        printf("Syntax: %s <cleartext>\n", argv[0]);
        return EXIT_FAILURE;
    }

    /* Generate a random key and iv */
    for(i=0;i<sizeof(key);++i)
        u_key[i] = arc4random() % 255;
    for(i=0;i<sizeof(iv);++i)
        u_iv[i] = arc4random() % 255;

    key = [ NSData dataWithBytes: u_key length: sizeof(key) ];
    iv  = [ NSData dataWithBytes: u_iv  length: sizeof(iv)  ];
    clearText = [ NSData dataWithBytes: argv[1] length: strlen(argv[1]) ]; 

    cipherText = encrypt_AES128(clearText, key, iv);    
    
    for(i=0;i<[ cipherText length];++i) 
        printf("%02x", ((unsigned char *) [ cipherText bytes ])[i]);
    printf("\n");

    [ pool release ];
}
