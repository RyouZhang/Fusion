//
//  FusionNotFilter.m
//  FusionCore
//
//  Created by Ryou Zhang on 8/11/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import "FusionNotFilter.h"
#import "SafeARC.h"

@implementation FusionNotFilter
- (id)initWithConfig:(NSDictionary *)config {
    self = [super initWithConfig:config];
    if (self) {
        if ([config valueForKey:@"filter"]) {
            NSDictionary *childConfig = [config valueForKey:@"filter"];
            _filter = [[NSClassFromString([childConfig valueForKey:@"class"]) alloc] initWithConfig:childConfig];
        }
    }
    return self;
}

- (BOOL)filterFusionNativeMessage:(FusionNativeMessage *)message {
    if (_filter) {
        return ![_filter filterFusionNativeMessage:message];
    } else {
        return YES;
    }
}

- (void)dealloc {
    SafeRelease(_filter);
    SafeSuperDealloc(super);
}
@end
