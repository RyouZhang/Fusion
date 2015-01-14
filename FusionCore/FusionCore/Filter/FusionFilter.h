//
//  FusionFilter.h
//  TestNewCore
//
//  Created by Ryou Zhang on 7/5/13.
//  Copyright (c) 2013 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FusionNativeMessage;

@interface FusionFilter : NSObject {
@protected
    NSDictionary    *_config;
}
- (id)initWithConfig:(NSDictionary *)config;
- (BOOL)filterFusionNativeMessage:(FusionNativeMessage *)message;
@end
