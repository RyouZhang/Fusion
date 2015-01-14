//
//  FusionPageNavigator+NaviAnime.h
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionPageNavigator.h"

@interface FusionPageNavigator(NaviAnime)
- (void)onGotoAnimeFinish:(BOOL)destory;
- (void)gotoAnimeFinish:(NSNotification*)notify;
- (void)gotoAndDestoryAnimeFinish:(NSNotification*)notify;
- (void)gotoAnimeCancel:(NSNotification*)notify;

- (void)onPopAnimeFinish;
- (void)poptoAnimeFinish:(NSNotification*)notify;
- (void)poptoAnimeCancel:(NSNotification*)notify;
@end
