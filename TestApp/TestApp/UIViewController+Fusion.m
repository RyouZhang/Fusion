//
//  UIViewController+Fusion.m
//  TestApp
//
//  Created by Ryou Zhang on 1/18/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "UIViewController+Fusion.h"
#import <objc/runtime.h>
#import "SafeARC.h"

@implementation UIViewController(Fusion)
- (id)initWithConfig:(NSDictionary *)pageConfig {
    self = [super init];
    if (self) {
        objc_setAssociatedObject(self,
                                 "pageConfig",
                                 pageConfig,
                                 OBJC_ASSOCIATION_RETAIN);
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
    return [objc_getAssociatedObject(self, "naviAnimeType") unsignedIntegerValue];
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
    assert(NO);
}

- (FusionTabBar *)getTabBar {
    return nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    objc_removeAssociatedObjects(self);
    SafeSuperDealloc(super);
}
@end
