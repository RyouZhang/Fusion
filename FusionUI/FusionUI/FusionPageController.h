//
//  FusionPageController.h
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FusionNavigationBar;
@class FusionTabBar;
@class FusionPageNavigator;
@class FusionNaviAnime;

@protocol IFusionPageProtocol;

@interface FusionPageController : UIViewController<UIGestureRecognizerDelegate> {
@protected
    BOOL                _naviBarHidden;
    FusionNavigationBar *_naviBar;
@private
//for manual navi anime
    CGPoint             _speed;
    CGPoint             _startPosition;
    NSTimeInterval      _startTimestamp;
    FusionNaviAnime     *_manualAnime;
}
#pragma GestureRecognizer
- (void)enableGestureRecognizer;
- (void)disableGestureRecognizer;
@end
