//
//  FusionPageNavigator+NaviBar.m
//  FusionUI
//
//  Created by ZhangRyou on 1/17/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionPageNavigator+NaviBar.h"
#import "FusionPageNavigator+Auto.h"
#import "FusionPageNavigator+Internal.h"
#import "FusionPageMessage.h"
#import "FusionNaviAnime.h"
#import "SafeARC.h"

@implementation FusionPageNavigator(NaviBar)
- (void)recoverPushNavigationBar {
    NSMutableArray *items = [NSMutableArray new];
    FusionPageMessage *message = [[FusionPageMessage alloc] initWithURL:[_targetController getCallbackUrl]
                                                                   args:nil];
    UIViewController<IFusionPageProtocol> *temp = [self findTargetPageController:message];
    SafeRelease(message);
    if (temp) {
        [items addObject:temp.navigationItem];
    }
    if (_targetController) {
        [items addObject:_targetController.navigationItem];
    }
    [_naviBar setItems:items animated:NO];
    SafeRelease(items);
}

- (void)recoverPopNavigationBar {
    NSMutableArray *items = [NSMutableArray new];
    FusionPageMessage *message = [[FusionPageMessage alloc] initWithURL:[_targetController getCallbackUrl]
                                                                   args:nil];
    UIViewController<IFusionPageProtocol> *temp = [self findTargetPageController:message];
    SafeRelease(message);
    if (temp) {
        [items addObject:temp.navigationItem];
    }
    if (_targetController) {
        [items addObject:_targetController.navigationItem];
    }
    [_naviBar setItems:items animated:NO];
    SafeRelease(items);
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item {
    return YES;
}

- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item {
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    NSURL *callbackUrl = [_currentController getCallbackUrl];
    FusionPageMessage *message = [[FusionPageMessage alloc] initWithURL:callbackUrl args:nil];
    [message setNaviAnimeType:[_currentController getNaviAnimeType]];
    [message setNaviAnimeDirection:FusionNaviAnimeBackward];
    [self poptoPage:message];
    SafeRelease(message);
    return YES;
}

- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item {
}
@end
