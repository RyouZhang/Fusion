//
//  FusionPageController.m
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionPageController.h"
#import "Navigation/FusionPageNavigator.h"
#import "Navigation/FusionPageNavigator+Manual.h"
#import "Navigation/FusionNaviBar.h"
#import "Navigation/FusionTabBar.h"
#import "Navigation/Anime/FusionNaviAnimeHelper.h"
#import "Navigation/Anime/FusionNaviAnime.h"
#import "FusionPageMessage.h"
#import "SafeARC.h"

@interface FusionPageController() {
@private
    NSDictionary    *_pageConfig;
    NSString        *_pageName;
    NSString        *_pageNick;
    NSUInteger      _naviAnimeType;
    NSURL           *_callbackUrl;
    
    UIView              *_prevSnapView;
    UIView              *_prevMaskView;
    
    __unsafe_unretained FusionPageNavigator *_navigator;
}
@end


@implementation FusionPageController
- (id)initWithConfig:(NSDictionary*)pageConfig {
    self = [super init];
    if (self) {
        _pageConfig = SafeRetain(pageConfig);
        if ([_pageConfig valueForKey:@"hide_navi"] &&
            [[_pageConfig valueForKey:@"hide_navi"] boolValue]) {
            _naviBarHidden = YES;
        } else {
            _naviBarHidden = NO;
        }
        if (_naviBarHidden == NO) {
            NSDictionary *navibarInfo = [_pageConfig valueForKey:@"navibar"];
            if ([navibarInfo valueForKey:@"class"] == nil) {
                _naviBar = [[FusionNaviBar alloc] initWithConfig:navibarInfo];
            } else {
                _naviBar = [[NSClassFromString([navibarInfo valueForKey:@"class"]) alloc] initWithConfig:navibarInfo];
            }
            _naviBar.clipsToBounds = YES;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_naviBar) {
        [self.view addSubview:_naviBar];
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        if (![_pageConfig objectForKey:@"no_gesture_navi"] ||
            [[_pageConfig objectForKey:@"no_gesture_navi"] boolValue] == NO) {
            Class gestureClass = NSClassFromString(@"UIScreenEdgePanGestureRecognizer");
            if (gestureClass == nil) {
                gestureClass = [UIPanGestureRecognizer class];
            }
            id recognizer = [[gestureClass alloc] initWithTarget:self
                                                          action:@selector(onTriggerPanGesture:)];
            if ([recognizer respondsToSelector:@selector(setEdges:)]) {
                [(UIScreenEdgePanGestureRecognizer *)recognizer setEdges:UIRectEdgeLeft];
            }
            [(UIGestureRecognizer *)recognizer setDelegate:self];
            [(UIGestureRecognizer *)recognizer setDelaysTouchesBegan:YES];
            [self.view addGestureRecognizer:recognizer];
            SafeRelease(recognizer);
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        if([_pageConfig valueForKey:@"status_bar_style"]) {
            [[UIApplication sharedApplication] setStatusBarStyle:[[_pageConfig valueForKey:@"status_bar_style"] integerValue]];
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:3];
    }
    [self updateSubviewsLayout];
}

- (void)updateSubviewsLayout {
    [_naviBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, [_naviBar getNaviBarHeight])];
    [_tabBar setFrame:CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50)];
}

- (void)processPageCommand:(NSString *)command args:(NSDictionary *)args {
    
}

#pragma mark UIViewController+Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (NSDictionary *)getPageConfig {
    return _pageConfig;
}

- (void)setPageName:(NSString *)pageName {
    SafeRelease(_pageName);
    _pageName = SafeRetain(pageName);
}

- (NSString *)getPageName {
    return _pageName;
}

- (void)setPageNick:(NSString *)pageNick {
    SafeRelease(_pageNick);
    _pageNick = SafeRetain(pageNick);
}

- (NSString *)getPageNick {
    return _pageNick;
}

- (void)setNaviAnimeType:(NSUInteger)animeType {
    _naviAnimeType = animeType;
}

- (NSUInteger)getNaviAnimeType {
    return _naviAnimeType;
}

- (void)setCallbackUrl:(NSURL *)callbackUrl {
    SafeRelease(_callbackUrl);
    _callbackUrl = SafeRetain(callbackUrl);
}

- (NSURL*)getCallbackUrl {
    return _callbackUrl;
}

- (void)setNavigator:(FusionPageNavigator *)navigator {
    _navigator = navigator;
}

- (FusionPageNavigator *)getNavigator {
    return _navigator;
}

- (void)setPrevSnapView:(UIView *)prevSnapView {
    SafeRelease(_prevSnapView);
    _prevSnapView = SafeRetain(prevSnapView);
}

- (UIView *)getPrevSnapView {
    return _prevSnapView;
}

- (void)setPrevMaskView:(UIView *)prevMaskView {
    SafeRelease(_prevMaskView);
    _prevMaskView = SafeRetain(prevMaskView);
}

- (UIView *)getPrevMaskView {
    return _prevMaskView;
}

- (void)setTabBar:(FusionTabBar *)tabBar {
    SafeRelease(_tabBar);
    _tabBar = SafeRetain(tabBar);
    [self.view addSubview:_tabBar];
}
- (FusionTabBar *)getTabBar {
    return _tabBar;
}

#pragma Reuse
- (id)dumpPageContext {
    return nil;
}

- (void)reloadPageContext:(id)context {
    
}

#pragma mark Animation Delegate
- (void)enterAnimeStart {
    
}

- (void)enterAnimeFinish {
    
}

- (void)enterAnimeCancel {
    
}

- (void)exitAnimeStart {
    
}

- (void)exitAnimeFinish {
    
}

- (void)exitAnimeCancel {
    
}

#pragma GestureRecognizer
- (void)enableGestureRecognizer {
    for (UIGestureRecognizer *recognizer in [self.view gestureRecognizers]) {
        if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
            [recognizer setEnabled:YES];
            return;
        }
    }
}

- (void)disableGestureRecognizer {
    for (UIGestureRecognizer *recognizer in [self.view gestureRecognizers]) {
        if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
            [recognizer setEnabled:NO];
            return;
        }
    }
}

- (void)onTriggerPanGesture:(UIPanGestureRecognizer*)recognizer {
    CGPoint pos = [recognizer locationInView:_navigator.view];
    
    switch ([recognizer state]) {
        case UIGestureRecognizerStateBegan: {
            if (_manualAnime) {
                return;
            }
            _startPosition = pos;
            _startTimestamp = [[NSDate date] timeIntervalSince1970];
            NSURL *url = [self getCallbackUrl];
            if (url == nil) {
                return;
            }
            
            NSInteger animeType = [self getNaviAnimeType];
            if (animeType == No_NaviAnime) {
                animeType = SlideR2L_NaviAnime;
            }
            [self.view endEditing:YES];
            
            FusionPageMessage *message = [[FusionPageMessage alloc] initWithURL:url];
            [message setNaviAnimeType:animeType];
            [message setNaviAnimeDirection:FusionNaviAnimeBackward];
            
            _manualAnime = [[self getNavigator] manualPoptoPage:message];
            SafeRelease(message);
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if (_manualAnime) {
                NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
                CGFloat detal = now - _startTimestamp;
                _speed = CGPointMake((pos.x - _startPosition.x)/detal, (pos.y - _startPosition.y)/detal);
                [_manualAnime updateProcess:1.0 - pos.x / _navigator.view.frame.size.width];
            }
        }
            break;
        default: {
            if (_manualAnime) {
                if (fabs(_speed.x) > 400 || [_manualAnime process] < 0.5) {
                    [_manualAnime forcePlay];
                } else {
                    [_manualAnime play];
                }
                _manualAnime = nil;
            }
        }
            break;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    objc_removeAssociatedObjects(self);
    _navigator = nil;
    SafeRelease(_pageName);
    SafeRelease(_pageNick);
    SafeRelease(_callbackUrl);
    SafeRelease(_pageConfig);
    SafeRelease(_prevSnapView);
    SafeRelease(_prevMaskView);
    SafeRelease(_manualAnime);
    SafeRelease(_naviBar);
    SafeRelease(_tabBar);
    SafeSuperDealloc(super);
}
@end
