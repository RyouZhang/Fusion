//
//  FusionSlideR2LAnime.m
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionSlideR2LAnime.h"

@implementation FusionSlideR2LAnime
- (void)prepare {
    if (_direction == FusionNaviAnimeForward) {
        [_maskView setBackgroundColor:[UIColor blackColor]];
        [self updateProcess:0.0];
    } else {
        [_maskView setBackgroundColor:[UIColor blackColor]];
        [self updateProcess:1.0];
    }
}

- (void)updateProcess:(CGFloat)process {
    [super updateProcess:process];
    [_backgroundView setTransform:CGAffineTransformMakeTranslation(-_backgroundView.frame.size.width * 0.4 * _process, 0)];
    [_maskView setAlpha:0.65 * process];
    [_foregroundView setTransform:CGAffineTransformMakeTranslation(_foregroundView.frame.size.width * (1.0 - _process), 0)];
}
@end
