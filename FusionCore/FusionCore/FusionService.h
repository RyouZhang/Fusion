//
//  FusionService.h
//  TestNewCore
//
//  Created by Ryou Zhang on 6/30/13.
//  Copyright (c) 2013 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FusionNativeMessage;
@class FusionFilter;

typedef enum
{
    FusionService_Default   = 0,
    FusionService_NET       = 1,
    FusionService_UI        = 2
}FusionServiceThreadType;

@interface FusionService : NSObject {
@protected
    FusionServiceThreadType _threadType;
    
    NSString                *_name;
    NSDictionary            *_config;
    
    FusionFilter            *_filter;
    
    NSMutableDictionary     *_actorDic;;
}
@property(readonly, atomic)FusionServiceThreadType threadType;
@property(retain, atomic)NSString   *name;

- (id)initWithConfig:(NSDictionary *)config;

- (BOOL)canConcurrentExecute:(FusionNativeMessage*)message;

-(BOOL)filterFusionNativeMessage:(FusionNativeMessage *)message;

- (void)processFusionNativeMessage:(FusionNativeMessage *)message;

- (void)processCallbackFusionNativeMessage:(FusionNativeMessage *)message;

- (void)processCancelFusionNativeMessage:(FusionNativeMessage *)message;
- (BOOL)checkFusionActorValid:(FusionNativeMessage *)message;
@end