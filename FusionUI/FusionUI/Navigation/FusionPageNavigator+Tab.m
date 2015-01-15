//
//  FusionPageNavigator+Tab.m
//  FusionUI
//
//  Created by ZhangRyou on 1/14/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionPageNavigator+Tab.h"
#import "FusionTabBar.h"

@implementation FusionPageNavigator(Tab)
- (void)processTabBarForPageController:(UIViewController<IFusionPageProtocol> *)controller {
    NSString *tabbarName = [[_targetController getPageConfig] valueForKey:@"tabbar_name"];
    if (tabbarName) {
        if ([_tabbarDic valueForKey:tabbarName]) {
            FusionTabBar *tarbar = [_tabbarDic valueForKey:tabbarName];
            if (tarbar.superview) {
                [tarbar removeFromSuperview];
            }
            [_targetController setTabBar:tarbar];
        } else {
            FusionTabBar *tarbar = [_adapter generateFusionTabbar:tabbarName];
            [tarbar setNavigator:self];
            [_targetController setTabBar:tarbar];
            [_tabbarDic setValue:tarbar forKey:tabbarName];
        }
        if (_currentController &&
            [_currentController getTabBar] &&
            [[_currentController getTabBar] isEqual:[_targetController getTabBar]]) {
            FusionTabBar *tarbar = [_currentController getTabBar];
            [tarbar removeFromSuperview];
            [tarbar setFrame:CGRectMake(0,
                                        self.view.frame.size.height - tarbar.frame.size.height,
                                        tarbar.frame.size.width,
                                        tarbar.frame.size.height)];
            [self.view addSubview:tarbar];
            if ([tarbar isHidden]) {
                [tarbar showTabbar:YES];
            }
        } else {
            FusionTabBar *tarbar = [_targetController getTabBar];
            if ([tarbar isHidden]) {
                [tarbar showTabbar:YES];
            }
        }
    }
}

- (void)recoverTabBarForPageController:(UIViewController<IFusionPageProtocol> *)controller {
    FusionTabBar *tarbar = [controller getTabBar];
    if (tarbar == nil) {
        return;
    }
    [tarbar removeFromSuperview];
    [tarbar setFrame:CGRectMake(0,
                                controller.view.frame.size.height - tarbar.frame.size.height,
                                tarbar.frame.size.width,
                                tarbar.frame.size.height)];
    [controller.view addSubview:tarbar];
}
@end
