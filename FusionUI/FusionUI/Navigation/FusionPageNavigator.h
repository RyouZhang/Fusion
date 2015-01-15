//
//  FusionPageNavigator.h
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FusionTabBar;
@class FusionPageMessage;
@class FusionPageController;
@class FusionPageNavigator;

@protocol IFusionPageProtocol<NSObject>
@required
- (id)initWithConfig:(NSDictionary *)pageConfig;

- (NSDictionary *)getPageConfig;

- (void)setNaviAnimeType:(NSUInteger)animeType;
- (NSUInteger)getNaviAnimeType;

- (void)setPageName:(NSString *)pageName;
- (NSString *)getPageName;

- (void)setPageNick:(NSString *)pageNick;
- (NSString *)getPageNick;

- (void)setCallbackUrl:(NSURL *)callbackUrl;
- (NSURL*)getCallbackUrl;

- (void)setNavigator:(FusionPageNavigator *)navigator;
- (FusionPageNavigator *)getNavigator;

- (void)processPageCommand:(NSString *)command args:(NSDictionary *)args;

- (void)setTabBar:(FusionTabBar *)tabBar;
- (FusionTabBar *)getTabBar;

@optional
- (void)updateSubviewsLayout;

- (void)setPrevSnapView:(UIView *)prevSnapView;
- (UIView *)getPrevSnapView;

- (void)setPrevMaskView:(UIView *)prevMaskView;
- (UIView *)getPrevMaskView;

- (void)enterAnimeStart;
- (void)enterAnimeFinish;
- (void)enterAnimeCancel;

- (void)exitAnimeStart;
- (void)exitAnimeFinish;
- (void)exitAnimeCancel;

- (id)dumpPageContext;
- (void)reloadPageContext:(id)context;
@end


@protocol IFusionRewriteProtocol<NSObject>
@required
-(FusionPageMessage *)rewriteFusionPageMessage:(FusionPageMessage *)message;
@end


@protocol IFusionPageAdapterProtocol<NSObject>
@required
- (UIViewController<IFusionPageProtocol> *)generateFusionPageController:(NSDictionary *)pageConfig;
- (NSDictionary *)getPageConfig:(NSString *)pageName;
- (FusionTabBar *)generateFusionTabbar:(NSString *)tabbarName;
@end

@interface FusionPageNavigator : UIViewController {
@private
    NSMutableDictionary     *_pageDic;
    NSMutableDictionary     *_tabbarDic;
    NSMutableDictionary     *_tabbarPageDic;
    
    NSMutableArray          *_pageNickStack;    
    NSMutableArray          *_waittingArray;
    
    CGFloat                 _cornerRadius;
    
    UIView                  *_containerView;
    UIView                  *_maskView;
    
    UIView                  *_currentContentView;
    UIView                  *_targetContentView;
    
    UIViewController<IFusionPageProtocol>    *_currentController;
    UIViewController<IFusionPageProtocol>    *_targetController;
    
    __unsafe_unretained id<IFusionRewriteProtocol> _rewriter;
    __unsafe_unretained id<IFusionPageAdapterProtocol>  _adapter;
}
@property(assign, atomic)CGFloat cornerRadius;
@property(assign, atomic)id<IFusionRewriteProtocol> rewriter;
@property(assign, atomic)id<IFusionPageAdapterProtocol> adapter;

- (UIViewController<IFusionPageProtocol> *)visableViewController;

- (void)showCurrentTabbarAnimated:(BOOL)animated;
- (void)hideCurrentTabbarAnimated:(BOOL)animated;

- (UIImage*)getPageSnapshot;

+ (NSURL *)generateCallbackUrl:(UIViewController<IFusionPageProtocol>*)controller;
@end
