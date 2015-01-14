//
//  FusionAndFilter.m
//  FusionCore
//
//  Created by Ryou Zhang on 8/11/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import "FusionAndFilter.h"
#import "SafeARC.h"

@implementation FusionAndFilter
- (id)initWithConfig:(NSDictionary *)config {
    self = [super initWithConfig:config];
    if (self) {
        _filterArray = [NSMutableArray new];
        for (NSDictionary *filterInfo in [config valueForKey:@"filters"]) {
            FusionFilter *filter = [[NSClassFromString([filterInfo valueForKey:@"class"]) alloc] initWithConfig:filterInfo];
            [_filterArray addObject:filter];
        }
    }
    return self;
}

- (BOOL)filterFusionNativeMessage:(FusionNativeMessage *)message {
    for (FusionFilter *filter in _filterArray) {
        if (NO == [filter filterFusionNativeMessage:message]) {
            return NO;
        }
    }
    return YES;
}

- (void)dealloc{
    SafeRelease(_filterArray);
    SafeSuperDealloc(super);
}
@end
