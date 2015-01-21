//
//  UIViewController+Fusion.m
//  FusionUI
//
//  Created by ZhangRyou on 1/21/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "UIViewController+Fusion.h"
#import "FusionPageNavigator.h"
#import "FusionTabBar.h"
#import "SafeARC.h"
#import <objc/runtime.h>

static IMP Fusion_Dealloc_IMP = nil;

@interface UIViewControllerHook : NSObject {
}
+ (UIViewControllerHook *)getInstance;
@end

@implementation UIViewControllerHook
static UIViewControllerHook *UIViewControllerHook_Instance = nil;
+ (UIViewControllerHook *)getInstance {
    if (UIViewControllerHook_Instance == nil) {
        UIViewControllerHook_Instance = [UIViewControllerHook new];
    }
    return UIViewControllerHook_Instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        Method method = class_getInstanceMethod([UIViewController class], NSSelectorFromString(@"dealloc"));
        Fusion_Dealloc_IMP = method_getImplementation(method);
        method_setImplementation(method, [self methodForSelector:NSSelectorFromString(@"fusionDealloc")]);
    }
    return self;
}

- (void)fusionDealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    objc_removeAssociatedObjects(self);
#if !__has_feature(objc_arc)
    Fusion_Dealloc_IMP(self, NSSelectorFromString(@"dealloc"));
#endif
}
@end

@implementation UIViewController(Fusion)
#pragma IFusionPageProtocol
- (id)initWithConfig:(NSDictionary *)pageConfig {
    self = [super init];
    if (self) {
        [UIViewControllerHook getInstance];
        objc_setAssociatedObject(self, "pageConfig", pageConfig, OBJC_ASSOCIATION_RETAIN);
    }
    return self;
}

- (NSDictionary *)getPageConfig {
    return objc_getAssociatedObject(self, "pageConfig");
}

- (void)setNaviAnimeType:(NSUInteger)animeType {
    objc_setAssociatedObject(self, "naviAnimeType", [NSNumber numberWithUnsignedInteger:animeType], OBJC_ASSOCIATION_ASSIGN);
}

- (NSUInteger)getNaviAnimeType {
    NSNumber *result = objc_getAssociatedObject(self, "naviAnimeType");
    if (result == nil) {
        return 0;
    }
    return [result unsignedIntegerValue];
}

- (void)setPageName:(NSString *)pageName {
    objc_setAssociatedObject(self, "pageName", pageName, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)getPageName {
    return objc_getAssociatedObject(self, "pageName");
}

- (void)setPageNick:(NSString *)pageNick {
    objc_setAssociatedObject(self, "pageNick", pageNick, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)getPageNick {
    return objc_getAssociatedObject(self, "pageNick");
}

- (void)setCallbackUrl:(NSURL *)callbackUrl {
    objc_setAssociatedObject(self, "callbackUrl", callbackUrl, OBJC_ASSOCIATION_RETAIN);
}

- (NSURL*)getCallbackUrl {
    return objc_getAssociatedObject(self, "callbackUrl");
}

- (void)setNavigator:(FusionPageNavigator *)navigator {
    objc_setAssociatedObject(self, "navigator", navigator, OBJC_ASSOCIATION_ASSIGN);
}

- (FusionPageNavigator *)getNavigator {
    return objc_getAssociatedObject(self, "navigator");
}

- (void)processPageCommand:(NSString *)command args:(NSDictionary *)args {
    
}

- (void)setTabBar:(FusionTabBar *)tabBar {
    objc_setAssociatedObject(self, "fusionTabBar", tabBar, OBJC_ASSOCIATION_RETAIN);
    [self.view addSubview:tabBar];
}

- (FusionTabBar *)getTabBar {
    return objc_getAssociatedObject(self, "fusionTabBar");
}
@end
