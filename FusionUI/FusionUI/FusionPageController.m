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
#import "Navigation/FusionTabBar.h"
#import "FusionNavigationBar.h"
#import "Navigation/Anime/FusionNaviAnimeHelper.h"
#import "Navigation/Anime/FusionNaviAnime.h"
#import "UIViewController+Fusion.h"
#import "FusionPageMessage.h"
#import "SafeARC.h"

@interface FusionPageController() {
@private
    UIVisualEffectView  *_naviBarHost;
    
    UIView              *_prevSnapView;
    UIView              *_prevMaskView;
}
@end


@implementation FusionPageController
- (id)initWithConfig:(NSDictionary*)pageConfig {
    self = [super initWithConfig:pageConfig];
    if (self) {
        if ([pageConfig valueForKey:@"hide_navi"] &&
            [[pageConfig valueForKey:@"hide_navi"] boolValue]) {
            _naviBarHidden = YES;
        } else {
            _naviBarHidden = NO;
        }
        NSDictionary *navibarInfo = [pageConfig valueForKey:@"navibar"];
        if (navibarInfo == nil ||[navibarInfo valueForKey:@"class"] == nil) {
            _naviBar = [[FusionNavigationBar alloc] initWithConfig:navibarInfo];
        } else {
            _naviBar = [[NSClassFromString([navibarInfo valueForKey:@"class"]) alloc] initWithConfig:navibarInfo];
        }
        [_naviBar setHidden:_naviBarHidden];
        [_naviBar setClipsToBounds:YES];
        [self.view addSubview:_naviBar];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            _naviBarHost = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
            [_naviBarHost setHidden:_naviBarHidden];
            [self.view addSubview:_naviBarHost];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        if (![[self getPageConfig] objectForKey:@"no_gesture_navi"] ||
            [[[self getPageConfig] objectForKey:@"no_gesture_navi"] boolValue] == NO) {
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
    if (_naviBarHost) {
        [self.view bringSubviewToFront:_naviBarHost];
    }
    [self.view bringSubviewToFront:_naviBar];
    if ([self getTabBar]) {
        [self.view bringSubviewToFront:[self getTabBar]];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        if([[self getPageConfig] valueForKey:@"status_bar_style"]) {
            [[UIApplication sharedApplication] setStatusBarStyle:[[[self getPageConfig] valueForKey:@"status_bar_style"] integerValue]];
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
    [_naviBarHost setFrame:CGRectMake(0, 0, self.view.frame.size.width, [_naviBar getNaviBarHeight])];
    if ([self getTabBar]) {
        [[self getTabBar] setFrame:CGRectMake(0,
                                              self.view.frame.size.height - [[self getTabBar] getTabbarHeight],
                                              self.view.frame.size.width,
                                              [[self getTabBar] getTabbarHeight])];
    }
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
    CGPoint pos = [recognizer locationInView:[self getNavigator].view];
    
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
                [_manualAnime updateProcess:1.0 - pos.x / [self getNavigator].view.frame.size.width];
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
    SafeRelease(_prevSnapView);
    SafeRelease(_prevMaskView);
    SafeRelease(_manualAnime);
    SafeRelease(_naviBar);
    SafeRelease(_naviBarHost);
    SafeSuperDealloc(super);
}
@end
