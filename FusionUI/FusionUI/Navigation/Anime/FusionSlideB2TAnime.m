//
//  FusionSlideB2TAnime.m
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionSlideB2TAnime.h"

@implementation FusionSlideB2TAnime
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
    [_foregroundView setTransform:CGAffineTransformMakeTranslation(0, _foregroundView.layer.bounds.size.height * (1.0 - process))];
}
@end
