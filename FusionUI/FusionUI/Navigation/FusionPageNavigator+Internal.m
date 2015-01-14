//
//  FusionPageNavigator+Internal.m
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionPageNavigator+Internal.h"
#import "FusionPageNavigator+Auto.h"
#import "FusionPageController.h"
#import "FusionTabBar.h"
#import "FusionPageMessage.h"
#import "SafeARC.h"

@implementation FusionPageNavigator(Internal)
#pragma mark ceate&refresh PageContentView
- (UIView*)createPageContentView:(UIViewController<IFusionPageProtocol> *)controller {
    UIView *contentView = [UIView new];
    
    [contentView setFrame:CGRectMake(0.0,
                                     0.0,
                                     _containerView.frame.size.width,
                                     _containerView.frame.size.height)];
    [contentView setClipsToBounds:YES];
    
    UIView *prevSnapView = nil;
    if ([controller respondsToSelector:@selector(getPrevSnapView)]) {
        prevSnapView = [controller performSelector:@selector(getPrevSnapView)];
    }
    
    if (prevSnapView) {
        [prevSnapView setFrame:CGRectMake(0.0,
                                          0.0,
                                          contentView.frame.size.width,
                                          contentView.frame.size.height)];
        [contentView addSubview:prevSnapView];
    }
    UIView *prevMaskView = nil;
    if ([controller respondsToSelector:@selector(getPrevMaskView)]) {
        prevMaskView = [controller performSelector:@selector(getPrevMaskView)];
    }
    if (prevMaskView) {
        [prevMaskView setFrame:CGRectMake(0.0,
                                          0.0,
                                          contentView.frame.size.width,
                                          contentView.frame.size.height)];
        [contentView addSubview:prevMaskView];
    }
    [controller.view setFrame:CGRectMake(0.0,
                                         0.0,
                                         contentView.frame.size.width,
                                         contentView.frame.size.height)];
    [contentView addSubview:controller.view];
    
    controller.view.clipsToBounds = YES;
    
    return SafeAutoRelease(contentView);
}

#pragma mark PageScreenShot
- (UIImage*)createContentViewSnapshot:(UIView*)contentView {
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(_containerView.frame.size.width * scale,
                                                      _containerView.frame.size.height * scale),
                                           NO,
                                           1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == nil) {
        return nil;
    }
    
    CGContextSaveGState(context);
    CGRect rect = [contentView.layer convertRect:CGRectMake(0.0,
                                                            0.0,
                                                            contentView.layer.bounds.size.width,
                                                            contentView.layer.bounds.size.height)
                                         toLayer:_containerView.layer];
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformMakeScale(rect.size.width/_containerView.layer.bounds.size.width * scale,
                                           rect.size.height/_containerView.layer.bounds.size.height * scale);
    transform = CGAffineTransformTranslate(transform,
                                           rect.origin.x/(rect.size.width/_containerView.layer.bounds.size.width),
                                           rect.origin.y/(rect.size.height/_containerView.layer.bounds.size.height));
    CGContextConcatCTM(context, transform);
    [contentView.layer renderInContext:context];
    CGContextRestoreGState(context);
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIViewController<IFusionPageProtocol> *)findTargetPageController:(FusionPageMessage *)message {
    NSDictionary *pageConfig = [_adapter getPageConfig:message.pageName];
    if (pageConfig == nil) {
        return nil;
    }
    UIViewController<IFusionPageProtocol> *targetController = nil;
    if ([pageConfig valueForKey:@"singleton"] &&
        [[pageConfig valueForKey:@"singleton"] boolValue]) {
        targetController = SafeRetain([_pageDic valueForKey:message.pageName]);
    } else {
        targetController = SafeRetain([_pageDic valueForKey:message.pageNick]);
    }
    if (targetController == nil) {
        assert(_adapter);
        targetController = SafeRetain([_adapter generateFusionPageController:pageConfig]);
        [targetController setPageName:message.pageName];
        if ([pageConfig valueForKey:@"singleton"] &&
            [[pageConfig valueForKey:@"singleton"] boolValue]) {
            [targetController setPageNick:message.pageName];
        } else {
            [targetController setPageNick:message.pageNick];
        }
    }
    [targetController setNavigator:self];
    return SafeAutoRelease(targetController);
}

- (void)refreshPageContentView:(UIView*)contentView
                pageController:(UIViewController<IFusionPageProtocol>*)controller {
    
    if ([controller getPrevSnapView] &&
        [[contentView subviews] containsObject:[controller getPrevSnapView]] == NO) {
        [[controller getPrevSnapView] setFrame:CGRectMake(0.0, 0.0, contentView.frame.size.width, contentView.frame.size.height)];
        [contentView addSubview:[controller getPrevSnapView]];
    }
    if ([controller getPrevMaskView] &&
        [[contentView subviews] containsObject:[controller getPrevMaskView]] == NO) {
        [[controller getPrevMaskView] setFrame:CGRectMake(0.0, 0.0, contentView.frame.size.width, contentView.frame.size.height)];
        [contentView addSubview:[controller getPrevMaskView]];
    }
    [contentView bringSubviewToFront:controller.view];
}

- (void)garbageCollection {
    [_pageDic setValue:_currentController
                forKey:[_currentController getPageNick]];
    
    NSString *targetKey = nil;
    if ([_currentController getTabBar]) {
        FusionTabBar *tabbar = [_currentController getTabBar];
        NSString *tabbarName = [tabbar getTabbarName];
        NSMutableArray *pageArray = [_tabbarPageDic valueForKey:tabbarName];
        if (pageArray == nil) {
            pageArray = [NSMutableArray array];
            [_tabbarPageDic setValue:pageArray
                              forKey:tabbarName];
        }
        if ([pageArray containsObject:_currentController]) {
            [pageArray addObject:_currentController];
        }
        targetKey = tabbarName;
    } else {
        targetKey = [_currentController getPageNick];
    }
    
    if ([_pageNickStack containsObject:targetKey] == NO) {
        if ([_pageNickStack count] == 0) {
            [_pageNickStack addObject:targetKey];
        } else {
            [_pageNickStack insertObject:targetKey atIndex:1];
        }
    }
    NSInteger index = [_pageNickStack indexOfObject:targetKey];
    [_pageNickStack removeObjectsInRange:NSMakeRange(index + 1, [_pageNickStack count] - index - 1)];
    
    NSMutableArray *deleteArray = [NSMutableArray new];
    for (NSString *key in [_tabbarDic allKeys]) {
        if ([_pageNickStack containsObject:key] == NO) {
            [deleteArray addObject:key];
        }
    }
    for (NSString *key in deleteArray) {
        NSArray *pageArray = [_tabbarPageDic valueForKey:key];
        for (UIViewController<IFusionPageProtocol> *controller in pageArray) {
            [_pageDic removeObjectForKey:[controller getPageNick]];
        }
        [_tabbarPageDic removeObjectForKey:key];
    }
    [_tabbarDic removeObjectsForKeys:deleteArray];
    [deleteArray removeAllObjects];
    
    for (NSString *key in [_pageDic allKeys]) {
        if ([_pageNickStack containsObject:key] == NO) {
            [deleteArray addObject:key];
        }
    }
    [_pageDic removeObjectsForKeys:deleteArray];
    SafeRelease(deleteArray);
}

- (void)processWaittingArray {
    if ([_waittingArray count] == 0) {
        return;
    }
    FusionPageMessage *message = [_waittingArray firstObject];
    [self openPage:message];
    [_waittingArray removeObject:message];
}
@end
