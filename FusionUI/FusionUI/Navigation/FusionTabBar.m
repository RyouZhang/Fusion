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
@synthesize isHidden = _isHidden;
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

- (CGFloat)getTabbarHeight {
    return 50.0;
}

- (void)hideTabbar:(BOOL)isAnime {
    _isHidden = YES;
    if (isAnime) {
        [UIView animateWithDuration:0.4
                         animations:^{
                             [self setTransform:CGAffineTransformMakeTranslation(0, self.frame.size.height)];
                         } completion:^(BOOL finished) {
                         }];
    } else {
        [self setTransform:CGAffineTransformMakeTranslation(0, self.frame.size.height)];
    }
}

- (void)showTabbar:(BOOL)isAnime {
    _isHidden = NO;
    if (isAnime) {
        [UIView animateWithDuration:0.4
                         animations:^{
                             [self setTransform:CGAffineTransformIdentity];
                         } completion:^(BOOL finished) {
                         }];
    } else {
        [self setTransform:CGAffineTransformIdentity];
    }
}

- (void)dealloc {
    _navigator = nil;
    SafeRelease(_config);
    SafeSuperDealloc(super);
}
@end
