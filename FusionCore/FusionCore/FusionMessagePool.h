//
//  FusionMessagePool.h
//  FusionCore
//
//  Created by Ryou Zhang on 12/26/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Cancel_FusionCore_Level         0
#define Callback_FusionCore_Level       1
#define Normal_FusionCore_Level         2
#define Max_FusionCore_Level            3

@class FusionNativeMessage;

@interface FusionMessagePool : NSObject {
}
- (void)sendMessage:(FusionNativeMessage*)message;
- (void)sendMessageArray:(NSArray*)messageArray;

- (void)callbackMessage:(FusionNativeMessage *)message;
- (void)callbackMessageArray:(NSArray *)messageArray;

- (void)cancelMessage:(FusionNativeMessage *)message;
- (void)cancelMessageArray:(NSArray *)messageArray;

- (FusionNativeMessage *)fetchMessageForWorker:(NSString *)nickName messageLevel:(NSUInteger*)level;
@end
