//
//  FusionPageNavigator+Tab.h
//  FusionUI
//
//  Created by ZhangRyou on 1/14/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//


#import "FusionPageNavigator.h"

@interface FusionPageNavigator(Tab)
- (void)processTabBarForPageController:(UIViewController<IFusionPageProtocol> *)controller;

- (void)recoverTabBarForPageController:(UIViewController<IFusionPageProtocol> *)controller;
@end
