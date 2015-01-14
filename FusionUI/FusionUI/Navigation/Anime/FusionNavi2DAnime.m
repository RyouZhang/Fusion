//
//  FusionNavi2DAnime.m
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionNavi2DAnime.h"
#import "SafeARC.h"

@implementation FusionNavi2DAnime
- (void)prepare {
    //设置动画的初始状态
}

- (void)play {
    if (_isAuto) {
        if (_direction == FusionNaviAnimeForward) {
            _startProcess = _process;
            _endProcess = 1.0;
        } else {
            _startProcess = _process;
            _endProcess = 0.0;
        }
    } else {
        if (_direction == FusionNaviAnimeForward) {
            _startProcess = _process;
            if (_startProcess > 0.5) {
                _endProcess = 1.0;
            } else {
                _endProcess = 0.0;
            }
        } else {
            _startProcess = _process;
            if (_startProcess < 0.5) {
                _endProcess = 0.0;
            } else {
                _endProcess = 1.0;
            }
        }
    }
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [UIView beginAnimations:[self description] context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:_duration * fabs(_endProcess - _startProcess)];
    [UIView setAnimationDelegate:self];
    [self updateProcess:_endProcess];
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([animationID isEqualToString:[self description]]) {
        if (_isAuto) {
            [[NSNotificationCenter defaultCenter] postNotificationName:FusionNaviAnime_Finish object:self];
        } else {
            if (_direction == FusionNaviAnimeForward) {
                if (_endProcess == 0.0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:FusionNaviAnime_Cancel object:self];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:FusionNaviAnime_Finish object:self];
                }
            } else {
                if (_endProcess == 1.0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:FusionNaviAnime_Cancel object:self];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:FusionNaviAnime_Finish object:self];
                }
            }
        }
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SafeRelease(_foregroundView);
    SafeRelease(_maskView);
    SafeRelease(_backgroundView);
    SafeSuperDealloc(super);
}
@end
