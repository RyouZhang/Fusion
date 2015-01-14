//
//  FusionScrollL2RAnime.m
//  FusionUI
//
//  Created by ZhangRyou on 1/14/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionScrollL2RAnime.h"

@implementation FusionScrollL2RAnime
- (void)prepare {
    if (_direction == FusionNaviAnimeForward) {
        [self updateProcess:0.0];
    } else {
        [self updateProcess:1.0];
    }
}

- (void)updateProcess:(CGFloat)process {
    [super updateProcess:process];
    [_backgroundView setTransform:CGAffineTransformMakeTranslation(_backgroundView.frame.size.width * _process, 0)];
    [_foregroundView setTransform:CGAffineTransformMakeTranslation(-_foregroundView.frame.size.width * (1.0 - _process), 0)];
}
@end
