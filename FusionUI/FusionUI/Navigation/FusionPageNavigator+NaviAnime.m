//
//  FusionPageNavigator+NaviAnime.m
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionPageNavigator+NaviAnime.h"
#import "FusionPageNavigator+Internal.h"
#import "FusionPageNavigator+Tab.h"
#import "Anime/FusionNaviAnime.h"
#import "SafeARC.h"

@implementation FusionPageNavigator(NaviAnime)
- (void)onGotoAnimeFinish:(BOOL)destory {
    UIImageView *snapshotView = [UIImageView new];
    [snapshotView setBackgroundColor:[UIColor clearColor]];
    [snapshotView setImage:[self createContentViewSnapshot:_currentContentView]];
    if ([_targetController respondsToSelector:@selector(setPrevSnapView:)]) {
        [_targetController setPrevSnapView:snapshotView];
    }
    SafeRelease(snapshotView);
    
    [_maskView removeFromSuperview];
    SafeRelease(_maskView);
    
    [self refreshPageContentView:_targetContentView
                  pageController:_targetController];
    
    if (_currentController && [_currentController respondsToSelector:@selector(exitAnimeFinish)]) {
        [_currentController exitAnimeFinish];
    }
    if ([_targetController respondsToSelector:@selector(enterAnimeFinish)]) {
        [_targetController enterAnimeFinish];
    }
    
    [_currentContentView removeFromSuperview];
    SafeRelease(_currentContentView);
    _currentContentView = SafeRetain(_targetContentView);
    SafeRelease(_targetContentView);
   
    
    if (destory && _currentController) {
        [_pageNickStack removeObject:[_currentController getPageNick]];
        [_pageDic removeObjectForKey:[_currentController getPageNick]];
    }
    
    SafeRelease(_currentController);
    _currentController = SafeRetain(_targetController);
    SafeRelease(_targetController);
    
    if (_currentController.navigationItem) {
        [_naviBar pushNavigationItem:_currentController.navigationItem animated:NO];
    }
    
    [self recoverTabBarForPageController:_currentController];
    [self garbageCollection:NO];
    [self processWaittingArray];
}

- (void)gotoAnimeFinish:(NSNotification*)notify {
    [_containerView.layer setSublayerTransform:CATransform3DIdentity];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FusionNaviAnime_Finish
                                                  object:[notify object]];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FusionNaviAnime_Cancel
                                                  object:[notify object]];
    [self onGotoAnimeFinish:NO];
}

- (void)gotoAndDestoryAnimeFinish:(NSNotification*)notify {
    [_containerView.layer setSublayerTransform:CATransform3DIdentity];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FusionNaviAnime_Finish
                                                  object:[notify object]];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FusionNaviAnime_Cancel
                                                  object:[notify object]];
    [self onGotoAnimeFinish:YES];
}

- (void)gotoAnimeCancel:(NSNotification*)notify {
    [_containerView.layer setSublayerTransform:CATransform3DIdentity];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FusionNaviAnime_Finish
                                                  object:[notify object]];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FusionNaviAnime_Cancel
                                                  object:[notify object]];
    if (_currentController && [_currentController respondsToSelector:@selector(exitAnimeCancel)]) {
        [_currentController exitAnimeCancel];
    }
    if ([_targetController respondsToSelector:@selector(enterAnimeCancel)]) {
        [_targetController enterAnimeCancel];
    }
    SafeRelease(_targetController);
    [_targetContentView removeFromSuperview];
    SafeRelease(_targetContentView);
    [_maskView removeFromSuperview];
    SafeRelease(_maskView);
    
    [self recoverTabBarForPageController:_currentController];
}

- (void)onPopAnimeFinish {
    [_maskView removeFromSuperview];
    SafeRelease(_maskView);
    
    if (_currentController && [_currentController respondsToSelector:@selector(exitAnimeFinish)]) {
        [_currentController exitAnimeFinish];
    }
    if ([_targetController respondsToSelector:@selector(enterAnimeFinish)]) {
        [_targetController enterAnimeFinish];
    }
    
    [_currentContentView removeFromSuperview];
    SafeRelease(_currentContentView);
    _currentContentView = SafeRetain(_targetContentView);
    SafeRelease(_targetContentView);
    
    SafeRelease(_currentController);
    _currentController = SafeRetain(_targetController);
    SafeRelease(_targetController);
    
    [self recoverTabBarForPageController:_currentController];

    [self garbageCollection:YES];
    [self processWaittingArray];
}

- (void)poptoAnimeFinish:(NSNotification*)notify {
    [_containerView.layer setSublayerTransform:CATransform3DIdentity];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FusionNaviAnime_Finish
                                                  object:[notify object]];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FusionNaviAnime_Cancel
                                                  object:[notify object]];
    [self onPopAnimeFinish];
}

- (void)poptoAnimeCancel:(NSNotification*)notify {
    [_containerView.layer setSublayerTransform:CATransform3DIdentity];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FusionNaviAnime_Finish
                                                  object:[notify object]];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FusionNaviAnime_Cancel
                                                  object:[notify object]];
    
    if (_currentController && [_currentController respondsToSelector:@selector(exitAnimeCancel)]) {
        [_currentController exitAnimeCancel];
    }
    if ([_targetController respondsToSelector:@selector(enterAnimeCancel)]) {
        [_targetController enterAnimeCancel];
    }
    
    SafeRelease(_targetController);
    [_targetContentView removeFromSuperview];
    SafeRelease(_targetContentView);
    [_maskView removeFromSuperview];
    SafeRelease(_maskView);
    
    [self recoverTabBarForPageController:_currentController];
    
    [self refreshPageContentView:_currentContentView
                  pageController:_currentController];
}
@end
