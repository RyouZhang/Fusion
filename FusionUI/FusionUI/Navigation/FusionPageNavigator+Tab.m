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
            FusionTabBar *tabbar = [_tabbarDic valueForKey:tabbarName];
            [_targetController setTabBar:tabbar];
        } else {
            FusionTabBar *tabbar = [_adapter generateFusionTabbar:tabbarName];
            [tabbar setNavigator:self];
            [_targetController setTabBar:tabbar];
            [_tabbarDic setValue:tabbar forKey:tabbarName];
        }
        if (_currentController &&
            [_currentController getTabBar] &&
            [[_currentController getTabBar] isEqual:[_targetController getTabBar]]) {
            FusionTabBar *tabbar = [_currentController getTabBar];
            [tabbar removeFromSuperview];
            [tabbar setFrame:CGRectMake(0,
                                        self.view.frame.size.height - tabbar.frame.size.height,
                                        tabbar.frame.size.width,
                                        tabbar.frame.size.height)];
            [self.view addSubview:tabbar];
            if ([tabbar isHidden]) {
                [tabbar showTabbar:YES];
            }
        } else {
            FusionTabBar *tabbar = [_targetController getTabBar];
            [tabbar setFrame:CGRectMake(0,
                                        self.view.frame.size.height - tabbar.frame.size.height,
                                        tabbar.frame.size.width,
                                        tabbar.frame.size.height)];
            [_targetController.view addSubview:tabbar];
            if ([tabbar isHidden]) {
                [tabbar showTabbar:YES];
            }
        }
    } else {
        if ([_currentController getTabBar]) {
            FusionTabBar *tabbar = [_currentController getTabBar];
            [tabbar removeFromSuperview];
            [_currentController.view addSubview:tabbar];
        }
    }
}

- (void)recoverTabBarForPageController {    
    FusionTabBar *tabbar = [_targetController getTabBar];
    if (tabbar == nil) {
        return;
    }
    [tabbar setFrame:CGRectMake(0,
                                self.view.frame.size.height - tabbar.frame.size.height,
                                tabbar.frame.size.width,
                                tabbar.frame.size.height)];
    [self.view addSubview:tabbar];
}
@end
