//
//  NSString+base64Decode.m
//  Trip2013
//
//  Created by jinrong.sjr on 14-4-1.
//  Copyright (c) 2014年 alibaba. All rights reserved.
//

#import "NSString+base64Decode.h"
#import "Base64Transcoder.h"
#import "NSData+DESCrypto.h"
#import "SafeARC.h"

@implementation NSString (base64Decode)

- (NSString *)base64Decode {
    NSString *stringValue = self; /*the UTF8 string parsed from xml data*/
    Byte inputData[[stringValue lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];//prepare a Byte[]
    [[stringValue dataUsingEncoding:NSUTF8StringEncoding] getBytes:inputData];//get the pointer of the data
    size_t inputDataSize = (size_t)[stringValue length];
    size_t outputDataSize = EstimateBas64DecodedDataSize(inputDataSize);//calculate the decoded data size
    Byte outputData[outputDataSize];//prepare a Byte[] for the decoded data
    Base64DecodeData(inputData, inputDataSize, outputData, &outputDataSize);//decode the data
    NSData *theData = [[NSData alloc] initWithBytes:outputData length:outputDataSize];//create a NSData object from the decoded data
//    theData = [theData DESDecryptWithKey:@"Gel^hl8s"];
    NSString *result = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    SafeRelease(theData);
    return SafeAutoRelease(result);
}


- (NSString *)base64DecodeWithDESkey:(NSString *)key {
    NSString *stringValue = self; /*the UTF8 string parsed from xml data*/
    Byte inputData[[stringValue lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];//prepare a Byte[]
    [[stringValue dataUsingEncoding:NSUTF8StringEncoding] getBytes:inputData];//get the pointer of the data
    size_t inputDataSize = (size_t)[stringValue length];
    size_t outputDataSize = EstimateBas64DecodedDataSize(inputDataSize);//calculate the decoded data size
    Byte outputData[outputDataSize];//prepare a Byte[] for the decoded data
    Base64DecodeData(inputData, inputDataSize, outputData, &outputDataSize);//decode the data
    NSData *theData = [[NSData alloc] initWithBytes:outputData length:outputDataSize];//create a NSData object from the decoded data
    theData = [theData DESDecryptWithKey:key];
    NSString *result = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    SafeRelease(theData);
    return SafeAutoRelease(result);
}
@end
