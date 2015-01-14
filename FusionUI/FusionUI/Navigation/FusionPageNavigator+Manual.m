//
//  FusionPageNavigator+Manual.m
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionPageNavigator+Manual.h"
#import "FusionPageNavigator+Internal.h"
#import "FusionPageNavigator+NaviAnime.h"
#import "FusionNaviAnime.h"
#import "FusionPageMessage.h"
#import "Anime/FusionNaviAnimeHelper.h"
#import "SafeARC.h"

@implementation FusionPageNavigator(Manual)
- (FusionNaviAnime *)manualOpenPage:(FusionPageMessage *)message {
    if (message.naviAnimeDirection == FusionNaviAnimeForward) {
        return [self manualGotoPage:message];
    } else {
        return [self manualPoptoPage:message];
    }
}

- (FusionNaviAnime *)manualGotoPage:(FusionPageMessage *)message {
    if (message == nil) {
        return nil;
    }
    
    if (_rewriter) {
        message = [_rewriter rewriteFusionPageMessage:message];
    }
    
    _targetController = [self findTargetPageController:message];
    if (_targetController == nil) {
        return nil;
    }
    
    FusionNaviAnime *anime = [FusionNaviAnimeHelper createPageNaviAnime:message.naviAnimeType
                                                         animeDirection:FusionNaviAnimeForward];
    if (anime == nil) {
        return nil;
    }
    
    if ([_targetController respondsToSelector:@selector(setPrevSnapView:)]) {
        [_targetController setPrevSnapView:nil];
    }
    if ([_targetController respondsToSelector:@selector(setPrevMaskView:)]) {
        [_targetController setPrevMaskView:nil];
    }
    [_targetController setNaviAnimeType:message.naviAnimeType];
    
    SafeRelease(_targetContentView)
    _targetContentView = SafeRetain([self createPageContentView:_targetController]);
    [_targetContentView setFrame:CGRectMake(0.0, 0.0, _containerView.frame.size.width, _containerView.frame.size.height)];
    
    SafeRelease(_maskView);
    _maskView = [UIView new];
    [_maskView setUserInteractionEnabled:NO];
    [_maskView setFrame:_currentContentView.frame];
    [_containerView addSubview:_maskView];
    [_targetController setPrevMaskView:_maskView];
    
    [_containerView addSubview:_targetContentView];
    
    
    if (_currentController && [_currentController respondsToSelector:@selector(exitAnimeStart)]) {
        [_currentController exitAnimeStart];
    }
    if ([_targetController respondsToSelector:@selector(enterAnimeStart)]) {
        [_targetController enterAnimeStart];
    }
    
    [_targetController processPageCommand:message.command args:message.args];
    
    [anime setIsAuto:NO];
    [anime setBackgroundView:_currentContentView];
    [anime setMaskView:_maskView];
    [anime setForegroundView:_targetContentView];
    if (message.isDestory) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(gotoAndDestoryAnimeFinish:)
                                                     name:FusionNaviAnime_Finish
                                                   object:anime];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(gotoAnimeFinish:)
                                                     name:FusionNaviAnime_Finish
                                                   object:anime];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotoAnimeCancel:)
                                                 name:FusionNaviAnime_Cancel
                                               object:anime];
    [anime prepare];
    return anime;
}

- (FusionNaviAnime *)manualPoptoPage:(FusionPageMessage *)message {
    if(_targetController) {
        return nil;
    }
    
    
    FusionNaviAnime *anime = [FusionNaviAnimeHelper createPageNaviAnime:message.naviAnimeType
                                                         animeDirection:FusionNaviAnimeBackward];
    if (anime == nil) {
        return nil;
    }
    
    if (_rewriter) {
        message = [_rewriter rewriteFusionPageMessage:message];
    }
    
    _targetController = [self findTargetPageController:message];
    if (_targetController == _currentController) {
        _targetController = nil;
        return nil;
    }
    
    SafeRelease(_targetContentView)
    _targetContentView = SafeRetain([self createPageContentView:_targetController]);
    [_targetContentView setFrame:CGRectMake(0.0, 0.0, _containerView.frame.size.width, _containerView.frame.size.height)];
    [_containerView addSubview:_targetContentView];
    
    if ([_currentController respondsToSelector:@selector(getPrevSnapView)]) {
        [[_currentController getPrevSnapView] removeFromSuperview];
    }
    
    if ([_currentController respondsToSelector:@selector(getPrevMaskView)]) {
        [[_currentController getPrevMaskView] removeFromSuperview];
    }
    SafeRelease(_maskView);
    _maskView = SafeRetain([_currentController getPrevMaskView]);
    
    [_containerView insertSubview:_maskView belowSubview:_currentContentView];
    [_containerView sendSubviewToBack:_targetContentView];
    
    
    if (_currentController && [_currentController respondsToSelector:@selector(exitAnimeStart)]) {
        [_currentController exitAnimeStart];
    }
    if ([_targetController respondsToSelector:@selector(enterAnimeStart)]) {
        [_targetController enterAnimeStart];
    }
    
    [_targetController processPageCommand:message.command args:message.args];
    
    [anime setIsAuto:NO];
    [anime setForegroundView:_currentContentView];
    [anime setMaskView:_maskView];
    [anime setBackgroundView:_targetContentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(poptoAnimeFinish:)
                                                 name:FusionNaviAnime_Finish
                                               object:anime];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(poptoAnimeCancel:)
                                                 name:FusionNaviAnime_Cancel
                                               object:anime];
    [anime prepare];
    return anime;
}
@end
