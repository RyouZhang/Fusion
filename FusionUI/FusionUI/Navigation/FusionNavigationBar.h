//
//  FusionNavigationBar.h
//  FusionUI
//
//  Created by ZhangRyou on 1/21/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FusionNavigationBar : UIView {
@protected
    UIView      *_leftView;
    UIView      *_rightView;
    UIView      *_centerView;
}
@property(retain, atomic)UIView *leftView;
@property(retain, atomic)UIView *rightView;
@property(retain, atomic)UIView *centerView;
@end
