//
//  FusionFilter.m
//  TestNewCore
//
//  Created by Ryou Zhang on 7/5/13.
//  Copyright (c) 2013 Ryou Zhang. All rights reserved.
//

#import "FusionFilter.h"
#import "SafeARC.h"

@implementation FusionFilter
- (id)initWithConfig:(NSDictionary *)config {
    self = [super init];
    if (self) {
        _config = SafeRetain(config);
    }
    return self;
}

- (BOOL)filterFusionNativeMessage:(FusionNativeMessage *)message {
    return YES;
}

- (void)dealloc {
    SafeRelease(_config);
    SafeSuperDealloc(super);
}
@end
