//
//  FusionActor.h
//  TestNewCore
//
//  Created by Ryou Zhang on 6/30/13.
//  Copyright (c) 2013 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FusionNativeMessage;
@class FusionFilter;

@interface FusionActor : NSObject {
@protected
    NSString        *_name;
    NSDictionary    *_config;

    FusionFilter    *_filter;
}
@property(retain, atomic)NSString   *name;

-(id)initWithConfig:(NSDictionary *)config;

-(BOOL)filterFusionNativeMessage:(FusionNativeMessage *)message;

-(void)processFusionNativeMessage:(FusionNativeMessage *)message;

-(void)processCallbackMessage:(FusionNativeMessage *)message ParentMessage:(FusionNativeMessage *)parent;

-(void)cancelFusionNativeMessage:(FusionNativeMessage *)message;
@end