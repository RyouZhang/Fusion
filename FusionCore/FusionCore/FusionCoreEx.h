//
//  FusionCore.h
//  TestNewCore
//
//  Created by Ryou Zhang on 6/30/13.
//  Copyright (c) 2013 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IFusionConfig<NSObject>
@required
- (NSString *)appScheme;
- (NSArray *)getCoreService;
- (NSDictionary *)getLogicServiceByName:(NSString *)serviceName;
@optional
- (NSArray *)getTimeTaskArray;
@end


@class FusionNativeMessage;
@class FusionService;

@interface FusionCore : NSObject {
}
+ (FusionCore *)getInstance;
//must call
- (void)prepareWithConfig:(id<IFusionConfig>)config;
- (void)resetLogicService;

- (NSThread *)getNetworkThread;

- (void)registerCoreService:(FusionService *)service;

//only for inner, thread no safe
- (FusionService *)checkFusionServiceValid:(FusionNativeMessage *)message;

//for outside async call
- (void)asyncSendMessage:(FusionNativeMessage *)message;
- (void)asyncSendMessageArray:(NSArray *)messageArray;
- (void)asyncCancelMessage:(FusionNativeMessage *)message;
- (void)asyncCancelMessageArray:(NSArray *)messageArray;

//only for internal service call
- (void)dispatchMessage:(FusionNativeMessage *)message;
- (void)dispatchMessageArray:(NSArray *)messageArray;

- (void)dispatchCancelMessage:(FusionNativeMessage *)message;
- (void)dispatchCancelMessageArray:(NSArray *)messageArray;

- (void)dispatchCallbackFusionNativeMessage:(FusionNativeMessage *)message;
@end