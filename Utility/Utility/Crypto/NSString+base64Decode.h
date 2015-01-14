//
//  NSString+base64Decode.h
//  Trip2013
//
//  Created by jinrong.sjr on 14-4-1.
//  Copyright (c) 2014年 alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (base64Decode)

- (NSString *)base64Decode;
- (NSString *)base64DecodeWithDESkey:(NSString *)key;

@end
