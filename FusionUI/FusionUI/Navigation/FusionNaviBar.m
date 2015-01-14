//
//  FusionNavigationBar.m
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionNaviBar.h"
#import "SafeARC.h"

#define Default_NavibarItem_Width   60

@implementation FusionNaviBar
@synthesize leftView = _leftView, centerView = _centerView, rightView = _rightView;
@synthesize leftViewWidth = _leftViewWidth, rightViewWidth = _rightViewWidth;
- (instancetype)init {
    self = [super init];
    if (self) {
        _leftViewWidth = Default_NavibarItem_Width;
        _rightViewWidth = Default_NavibarItem_Width;
    }
    return self;
}

- (id)initWithConfig:(NSDictionary *)config {
    self = [super init];
    if (self) {
        _config = SafeRetain(config);
        
        _leftViewWidth = Default_NavibarItem_Width;
        _rightViewWidth = Default_NavibarItem_Width;
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

- (void)setLeftView:(UIView *)leftView {
    if (_leftView) {
        [_leftView removeFromSuperview];
        SafeRelease(_leftView);
    }
    _leftView = SafeRetain(leftView);
    [self addSubview:_leftView];
    [self setNeedsLayout];
}

- (void)setRightView:(UIView *)rightView {
    if (_rightView) {
        [_rightView removeFromSuperview];
        SafeRelease(_rightView);
    }
    _rightView = SafeRetain(rightView);
    [self addSubview:_rightView];
    [self setNeedsLayout];
}

- (void)setCenterView:(UIView *)centerView {
    if (_centerView) {
        [_centerView removeFromSuperview];
        SafeRelease(_centerView);
    }
    _centerView = SafeRetain(centerView);
    [self addSubview:_centerView];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat topOffset = 0.0;
    if ([self getNaviBarHeight] == 64.0) {
        topOffset = 20.0;
    }
    
    if (_leftView) {
        [_leftView setFrame:CGRectMake(0,
                                       topOffset,
                                       _leftViewWidth,
                                       self.frame.size.height - topOffset)];
    }
    if (_centerView) {
        [_centerView setFrame:CGRectMake(_leftViewWidth,
                                         topOffset,
                                         self.frame.size.width - _leftViewWidth - _rightViewWidth,
                                         self.frame.size.height - topOffset)];
    }
    if (_rightView) {
        [_rightView setFrame:CGRectMake(self.frame.size.width - _rightViewWidth,
                                        topOffset,
                                        _rightViewWidth,
                                        self.frame.size.height - topOffset)];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SafeRelease(_leftView);
    SafeRelease(_centerView);
    SafeRelease(_rightView);
    SafeRelease(_config);
    SafeSuperDealloc(super);
}
@end
