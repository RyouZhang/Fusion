//
//  FusionSlideT2BAnime.m
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionSlideT2BAnime.h"

@implementation FusionSlideT2BAnime
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
    [_maskView setAlpha:0.65 * process];
    [_foregroundView setTransform:CGAffineTransformMakeTranslation(0, _foregroundView.layer.bounds.size.height * (process - 1.0))];
}
@end
