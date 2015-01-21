//
//  FusionNavigationBar.m
//  FusionUI
//
//  Created by ZhangRyou on 1/21/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionNavigationBar.h"
#import "SafeARC.h"

@interface FusionNavigationBar() {
}
@end

@implementation FusionNavigationBar
@synthesize leftView = _leftView, rightView = _rightView, centerView = _centerView;
- (id)initWithConfig:(NSDictionary *)config {
    self = [super init];
    if (self) {
        _config = SafeRetain(config);        
    }
    return self;
}

- (CGFloat)getNaviBarHeight {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        return 44.0;
    }
    if (self.superview.frame.size.width > self.superview.frame.size.height) {
        return 44.0;
    } else {
        return 64.0;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)dealloc {
    SafeRelease(_config);
    SafeSuperDealloc(super);
}
@end
