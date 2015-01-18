//
//  FusionAppBar.h
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FusionPageNavigator;

@interface FusionTabBar : UIView {
@protected
    NSDictionary    *_config;
    BOOL            _isHidden;
    __unsafe_unretained FusionPageNavigator *_navigator;
}
@property(assign, atomic)FusionPageNavigator *navigator;
@property(assign, readonly)BOOL isHidden;

- (id)initWithConfig:(NSDictionary *)config;

- (NSString *)getTabbarName;

- (CGFloat)getTabbarHeight;

- (void)hideTabbar:(BOOL)isAnime;
- (void)showTabbar:(BOOL)isAnime;
@end
