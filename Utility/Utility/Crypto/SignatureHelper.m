//
//  SignatureHelper.m
//  
//
//  Created by Ryou Zhang on 10/23/11.
//  Copyright (c) 2011  All rights reserved.
//

#import "SignatureHelper.h"
#import "Base64Transcoder.h"
#import "../OpenSSL/include/openssl/hmac.h"
#import "../OpenSSL/include/openssl/rsa.h"
#import "../OpenSSL/include/openssl/bn.h"
#import "../OpenSSL/include/openssl/rand.h"
#import "../OpenSSL/include/openssl/md5.h"
#import "../OpenSSL/include/openssl/aes.h"
#import "SafeARC.h"

NSData* SignWithHMAC_SHA1(NSString* text, NSString* secret) {
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[32];
    unsigned int length = 0;
    
    HMAC(EVP_sha1(),
         (unsigned char *)[secretData bytes],
         (int)[secretData length],
         (unsigned char *)[clearTextData bytes],
         [clearTextData length],
         result, &length);
    return [NSData dataWithBytes:result length:length];
}

NSString* ConvertDataToHEXText(NSData* data) {
    NSMutableString *result = [NSMutableString new];

    unsigned char *ptr = (unsigned char*)[data bytes];
    for (NSInteger index = 0; index < [data length]; index++) {
        [result appendFormat:@"%02x", ptr[index]];
    }
    return SafeAutoRelease(result);
}

NSString* GenerateMD5Key(NSString* sourceText) {
    const char *cStr = [sourceText UTF8String];
    unsigned char result[16];

    MD5((unsigned char*)cStr, strlen(cStr), result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

NSString* SignWithRSA(NSString *sourceText, NSString *publicKey) {
    NSArray *pubKeyArray = [publicKey componentsSeparatedByString:@"\n"];

    const char *sourceData = [sourceText cStringUsingEncoding:NSASCIIStringEncoding];
    const char *module = [[pubKeyArray objectAtIndex:0] cStringUsingEncoding:NSASCIIStringEncoding];
    const char *publix_exp = [[pubKeyArray objectAtIndex:1] cStringUsingEncoding:NSASCIIStringEncoding];
    
    BIGNUM *bnn = BN_new();
    BN_init(bnn);
    BN_dec2bn(&bnn, module);
    
    BIGNUM *bne = BN_new();
    BN_init(bne);
    if (publix_exp[0] == '3')
        BN_set_word(bne, RSA_3);
    else
        BN_set_word(bne, RSA_F4);
    
    NSMutableString *temp = [NSMutableString new];
    for(NSInteger index=0; index<strlen(sourceData); index++)
        [temp appendFormat:@"%02x",sourceData[index]];
    
    BIGNUM *input = BN_new();
    BN_hex2bn(&input, [temp cStringUsingEncoding:NSASCIIStringEncoding]);
    SafeRelease(temp);
    
    BIGNUM *q = BN_new();

    BIGNUM *output = BN_new();
    BN_one(output);
    
    BN_CTX *ctx = BN_CTX_new();
    for(int i = 0; i<BN_num_bits(bne); i++) {
        BN_mul(output, output, output, ctx);
        BN_div(q, output, output, bnn, ctx);
        if (BN_is_bit_set(bne, i)) {
            BN_mul(output, output, input, ctx);
            BN_div(q, output, output, bnn, ctx);
        }
    }
    
    BN_CTX_free(ctx);
    BN_free(input);
    BN_free(bnn);
    BN_free(bne);
    BN_free(q);
 
    NSString *result = [NSString stringWithCString:BN_bn2hex(output)
                                          encoding:NSASCIIStringEncoding];
    BN_free(output);
    return [result lowercaseString];
//    RSA* rsa = RSA_new();
//    rsa->e = bne;
//    rsa->n = bnn;
//    
//    int flen = RSA_size(rsa);
//    unsigned char* result = (unsigned char *)malloc(flen);
//    memset(result, 0, flen);
//    
//    ret = RSA_public_encrypt(flen, (unsigned char*)sourceData, result, rsa, RSA_NO_PADDING);
//    RSA_free(rsa);
//    
//    NSMutableString* target = [NSMutableString new];
//    for(NSInteger index=0; index<ret; index++)
//        [target appendFormat:@"%02x",result[index]];
//    free(result);
//    return SafeAutoRelease(target);
}

NSString* SignTripRequest(NSDictionary *args) {
    NSArray *keys = [[args allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    
    __block NSMutableString *rawText = [NSMutableString new];
    [rawText appendString:@"B8jo2Hdw7fH3sx0sd12WERc78"];
    [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [rawText appendFormat:@"%@%@",obj, [args valueForKey:obj]];
    }];
    [rawText appendString:@"B8jo2Hdw7fH3sx0sd12WERc78"];
    
    NSString *token = GenerateMD5Key(rawText);
    SafeRelease(rawText);
    return token;
}

NSData* GenerateMD5Data(NSData* data) {
    const void *ptrData = [data bytes];
    unsigned char result[16];
    MD5(ptrData, [data length], result);
    return [NSData dataWithBytes:result length:16];
}

NSString* GenerateMD5KeyWithData(NSData* data) {
    NSData *md5data = GenerateMD5Data(data);
    const unsigned char *result = (const unsigned char *)[md5data bytes];
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

NSString* GenerateBase64FromData(NSData* source) {
#if __IPHONE_7_0
    return [source base64Encoding];
#else
    return [source base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
#endif
}

NSString* GenerateBase64String(NSString* source) {
    NSData *rawData = [source dataUsingEncoding:NSUTF8StringEncoding];
    return GenerateBase64FromData(rawData);
}

long caculateAESBufferSize(NSString *sourceText) {
    long length = [sourceText lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
    if (length % 16 == 0 ) {
        length = length + 16;
    } else {
        length = length + (16 - length % 16);
    }
    return length;
}

long aes128Encrypt(NSString *sourceText, unsigned char *targetPtr) {
    if(NULL == sourceText) {
        return 0;
    }
    
    int iLoop = 0;
    AES_KEY aes;
    unsigned char key[AES_BLOCK_SIZE];
    unsigned char iv[AES_BLOCK_SIZE];
    
    //Generate own AES Key
    memcpy(key,"c5843d58457c4d",AES_BLOCK_SIZE);
    // Set encryption key
    for (iLoop=0; iLoop<AES_BLOCK_SIZE; iLoop++) {
        iv[iLoop] = 0;
    }
    
    if (AES_set_encrypt_key(key, 128, &aes) < 0) {
        return 0 ;
    }
    
    const char *sourcePtr = [sourceText cStringUsingEncoding:NSUTF8StringEncoding];
    long length = [sourceText lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
    AES_cbc_encrypt((const unsigned char*)sourcePtr, targetPtr, length, &aes, iv, AES_ENCRYPT);
    
    if (length % 16 == 0 ) {
        length = length + 16;
    } else {
        length = length + (16 - length % 16);
    }
    return length;
}


NSString *aes128Decrypt(const char* source_string, long source_length) {
    int iLoop = 0;
    AES_KEY aes;
    unsigned char key[AES_BLOCK_SIZE];
    unsigned char iv[AES_BLOCK_SIZE];
    if(NULL == source_string) {
        return nil;
    }
    
    //Generate own AES Key
    memcpy(key,"c5843d58457c4d",AES_BLOCK_SIZE);
    
    // Set encryption key
    for (iLoop=0; iLoop<AES_BLOCK_SIZE; iLoop++) {
        iv[iLoop] = 0;
    }
    
    if (AES_set_decrypt_key(key, 128, &aes) < 0) {
        return nil;
    }
    
    long length = source_length;
    unsigned char buf[length];
    memset(buf, '\0', length);
    unsigned char *targetPtr = buf;    
    AES_cbc_encrypt((const unsigned char*)source_string, targetPtr, length, &aes, iv, AES_DECRYPT);
    return [NSString stringWithCString:(const char*)targetPtr encoding:NSUTF8StringEncoding];
}