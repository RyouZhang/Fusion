//
//  FusionNavigationBar.h
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FusionNaviBar : UIView {
@protected
    NSDictionary    *_config;
    CGFloat         _leftViewWidth;
    CGFloat         _rightViewWidth;
    
    UIView          *_leftView;
    UIView          *_centerView;
    UIView          *_rightView;
}
@property(assign, atomic)CGFloat    leftViewWidth;
@property(assign, atomic)CGFloat    rightViewWidth;

@property(retain, nonatomic)UIView *leftView;
@property(retain, nonatomic)UIView *centerView;
@property(retain, nonatomic)UIView *rightView;

- (id)initWithConfig:(NSDictionary *)config;

- (CGFloat)getNaviBarHeight;
@end
