//
//  FusionPageNavigator.m
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionPageNavigator.h"
#import "FusionPageNavigator+Internal.h"
#import "FusionPageNavigator+NaviAnime.h"
#import "FusionPageNavigator+Auto.h"
#import "FusionPageNavigator+NaviBar.h"
#import "FusionNaviAnimeHelper.h"
#import "FusionPageMessage.h"
#import "FusionTabBar.h"
#import "SafeARC.h"

@interface FusionPageNavigator() {
}
@end

@implementation FusionPageNavigator
@synthesize cornerRadius = _cornerRadius;
@synthesize adapter = _adapter, rewriter = _rewriter;
- (id)init {
    self = [super init];
    if (self) {
        _pageDic = [NSMutableDictionary new];
        _pageNickStack = [NSMutableArray new];
        _tabbarDic = [NSMutableDictionary new];
        _tabbarPageDic = [NSMutableDictionary new];
        
        _waittingArray = [NSMutableArray new];
        
        _containerView = [UIView new];
        [_containerView setBackgroundColor:[UIColor clearColor]];
        [self.view setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:_containerView];
        
        _naviBar = [UINavigationBar new];
        [_naviBar setDelegate:self];
        [_naviBar setBarStyle:UIBarStyleDefault];
        [self.view addSubview:_naviBar];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onStatusBarFrameChanged:)
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];
        
    }
    return self;
}

- (void)onStatusBarFrameChanged:(NSNotification*)notify {
    [self updateSubviewsLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateSubviewsLayout];
}

- (void)updateSubviewsLayout {
    if (self.view.frame.size.width > self.view.frame.size.height) {
        [_naviBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    } else {
        [_naviBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    }
    [self.view bringSubviewToFront:_naviBar];
    
    [_containerView setFrame:self.view.bounds];
    [_maskView setFrame:CGRectMake(0,
                                   0,
                                   _containerView.frame.size.width,
                                   _containerView.frame.size.height)];
    [_currentContentView setFrame:CGRectMake(0,
                                             0,
                                             _containerView.frame.size.width,
                                             _containerView.frame.size.height)];
    
    if (_currentController &&
        [_currentController respondsToSelector:@selector(updateSubviewsLayout)]) {
        [_currentController updateSubviewsLayout];
    }
    if ([_currentController getTabBar]) {
        FusionTabBar *tabbar = [_currentController getTabBar];
        [tabbar setFrame:CGRectMake(0,
                                    self.view.frame.size.height - tabbar.frame.size.height,
                                    self.view.frame.size.width,
                                    tabbar.frame.size.height)];
    }
}

#pragma mark rotation
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self updateSubviewsLayout];
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    NSString *pageNick = [_pageNickStack lastObject];
    UIViewController<IFusionPageProtocol> *controller = [_pageDic valueForKey:pageNick];
    if (controller) {
        return [controller shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
    return YES;
}

- (BOOL)shouldAutorotate {
    NSString *pageNick = [_pageNickStack lastObject];
    UIViewController<IFusionPageProtocol> *controller = [_pageDic valueForKey:pageNick];
    if (controller) {
        return [controller shouldAutorotate];
    }
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    NSString *pageNick = [_pageNickStack lastObject];
    UIViewController<IFusionPageProtocol> *controller = [_pageDic valueForKey:pageNick];
    if (controller) {
        return [controller supportedInterfaceOrientations];
    }
    return UIInterfaceOrientationMaskAll;
}


#ifdef __IPHONE_8_0
- (CGSize)sizeForChildContentContainer:(id <UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    [self updateSubviewsLayout];
    return parentSize;
}
#endif

- (UIViewController<IFusionPageProtocol> *)visableViewController {
    if ([_pageNickStack count] == 0) {
        return nil;
    }
    NSString *pageNick = [_pageNickStack lastObject];
    return [_pageDic valueForKey:pageNick];
}

- (UIImage*)getPageSnapshot {
    return [self createContentViewSnapshot:_containerView];
}


- (void)hideCurrentTabbarAnimated:(BOOL)animated {
}

- (void)showCurrentTabbarAnimated:(BOOL)animated {
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _rewriter = nil;
    _adapter = nil;
    
    SafeRelease(_maskView);
    SafeRelease(_currentContentView);
    SafeRelease(_targetContentView);
    SafeRelease(_currentController);
    SafeRelease(_targetController);
    SafeRelease(_containerView);
    
    SafeRelease(_waittingArray);
    SafeRelease(_tabbarPageDic);
    SafeRelease(_tabbarDic);    
    SafeRelease(_pageNickStack);
    SafeRelease(_pageDic);
    SafeSuperDealloc(super);
}

+ (NSURL *)generateCallbackUrl:(UIViewController<IFusionPageProtocol>*)controller {
    NSURL *url = [[NSURL alloc] initWithScheme:FusionScheme
                                          host:FusionPageHost
                                          path:[NSString stringWithFormat:@"/%@",[controller getPageNick]]];
    return SafeAutoRelease(url);
}
@end
