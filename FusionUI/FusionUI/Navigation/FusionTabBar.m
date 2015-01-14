//
//  FusionAppBar.m
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionTabBar.h"
#import "SafeARC.h"

@implementation FusionTabBar
@synthesize navigator = _navigator;
- (id)initWithConfig:(NSDictionary *)config {
    self = [super init];
    if (self) {
        _config = SafeRetain(config);
    }
    return self;
}

- (NSString *)getTabbarName {
    if ([_config valueForKey:@"tabbar_name"]) {
        return [_config valueForKey:@"tabbar_name"];
    }
    return [[self class] description];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)dealloc {
    _navigator = nil;
    SafeRelease(_config);
    SafeSuperDealloc(super);
}
@end
