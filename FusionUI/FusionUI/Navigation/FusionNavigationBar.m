//
//  FusionNavigationBar.m
//  FusionUI
//
//  Created by ZhangRyou on 1/21/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionNavigationBar.h"
#import "SafeARC.h"

@implementation FusionNavigationBar
@synthesize leftView = _leftView, rightView = _rightView, centerView = _centerView;
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    SafeSuperDealloc(super);
}
@end
