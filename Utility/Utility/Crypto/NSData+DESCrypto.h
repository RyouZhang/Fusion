//
//  NSData+DESCrypto.h
//  Utility
//
//  Created by DengLiujun on 14/9/23.
//  Copyright (c) 2014年 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (DESCrypto)

- (NSData *)DESDecryptWithKey:(NSString *)key;

@end
