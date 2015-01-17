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
    if ([_pageDic valueForKey:message.pageNick]) {
        return [_pageDic valueForKey:message.pageNick];
    }
    return nil;
}

- (UIViewController<IFusionPageProtocol> *)generateTargetPageController:(FusionPageMessage *)message {
    NSDictionary *pageConfig = [_adapter getPageConfig:message.pageName];
    if (pageConfig == nil) {
        if ([_pageDic valueForKey:message.pageNick]) {
            return [_pageDic valueForKey:message.pageNick];
        }
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
    
    UIView *prevSnapView = nil;
    UIView *prevMaskView = nil;
    if ([controller respondsToSelector:@selector(getPrevSnapView)]) {
        prevSnapView = [controller getPrevSnapView];
    }
    if ([controller respondsToSelector:@selector(getPrevMaskView)]) {
        prevMaskView = [controller getPrevMaskView];
    }
    
    if (prevSnapView &&
        [[contentView subviews] containsObject:prevSnapView] == NO) {
        [prevSnapView setFrame:CGRectMake(0.0, 0.0, contentView.frame.size.width, contentView.frame.size.height)];
        [contentView addSubview:prevSnapView];
    }
    if (prevMaskView &&
        [[contentView subviews] containsObject:prevMaskView] == NO) {
        [prevMaskView setFrame:CGRectMake(0.0, 0.0, contentView.frame.size.width, contentView.frame.size.height)];
        [contentView addSubview:prevMaskView];
    }
    [contentView bringSubviewToFront:controller.view];
}

- (void)garbageCollection:(BOOL)isPop {
    [_pageDic setValue:_currentController
                forKey:[_currentController getPageNick]];
    //clean stack
    NSString *targetKey = [_currentController getPageNick];
    if ([_currentController getTabBar]) {
        targetKey = [[_currentController getTabBar] getTabbarName];
    }
    if (isPop) {
        if (NO == [_pageNickStack containsObject:targetKey]) {
            [_pageNickStack insertObject:targetKey atIndex:1];
        }
    } else {
        if (NO == [_pageNickStack containsObject:targetKey]) {
            [_pageNickStack addObject:targetKey];
        }
    }
    NSInteger index = [_pageNickStack indexOfObject:targetKey];
    NSArray *deleteArray = [_pageNickStack subarrayWithRange:NSMakeRange(index + 1, [_pageNickStack count] - index - 1)];    
    for (NSString *key in deleteArray) {
        if ([_tabbarDic valueForKey:key]) {
            [_tabbarDic removeObjectForKey:key];
            [_tabbarPageDic removeObjectForKey:key];
        } else if([_pageDic valueForKey:key]) {
            [_pageDic removeObjectForKey:key];
        }
    }
    [_pageNickStack removeObjectsInRange:NSMakeRange(index + 1, [_pageNickStack count] - index - 1)];
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
