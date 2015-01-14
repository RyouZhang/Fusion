//
//  SignatureHelper.h
//  
//
//  Created by Ryou Zhang on 10/23/11.
//  Copyright (c) 2011 mobiSage. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString* SignTripRequest(NSDictionary* args);

NSData* SignWithHMAC_SHA1(NSString* text, NSString* secret);

NSString* GenerateMD5Key(NSString* sourceText);

NSString* SignWithRSA(NSString* sourceText, NSString* publicKey);

NSData* GenerateMD5Data(NSData* data);

NSString* GenerateMD5KeyWithData(NSData* data);

NSString* GenerateBase64FromData(NSData* source);

NSString* GenerateBase64String(NSString* source);

NSString* ConvertDataToHEXText(NSData* data);

long caculateAESBufferSize(NSString *sourceText);
long aes128Encrypt(NSString *sourceText, unsigned char *targetPtr);
NSString *aes128Decrypt(const char* source_string, long source_length);