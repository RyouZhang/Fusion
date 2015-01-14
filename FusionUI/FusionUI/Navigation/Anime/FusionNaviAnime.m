//
//  FusionNaviAnime.m
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionNaviAnime.h"
#import "SPTransitions.h"
#import "SafeARC.h"

@implementation FusionNaviAnime
@synthesize duration = _duration, isAuto = _isAuto, direction = _direction, process = _process;
@synthesize backgroundView = _backgroundView, maskView = _maskView, foregroundView = _foregroundView;
- (id)init {
    self = [super init];
    if (self) {
        _process = 0.0;
        
        _startTime = 0.0;
        _endTime = 0.0;
        
        _startProcess = 0.0;
        _endProcess = 1.0;
        
        _duration = 0.4;
        _direction = FusionNaviAnimeForward;
        
        _isAuto = YES;
    }
    return self;
}

- (void)prepare {
}

- (void)forcePlay {
    _isAuto = YES;
    [self play];
}

- (void)play {
    if(_displayLink)
        return;
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    _displayLinkStart = YES;
    _displayLinkOver = NO;
    
    _totalFrame = 0;
    
    _displayLink = SafeRetain([CADisplayLink displayLinkWithTarget:self
                                                          selector:@selector(updateNaviAnime)]);
    [_displayLink setFrameInterval:0.03];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop]
                       forMode:NSRunLoopCommonModes];
}

- (void)updateNaviAnime {
    NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
    if (_displayLinkStart) {
        _displayLinkStart = NO;
        
        if (_isAuto) {
            if (_direction == FusionNaviAnimeForward) {
                _startTime = current;
                _startProcess = 0.0;
                _endProcess = 1.0;
                _endTime = current + _duration;
            } else {
                _startTime = current;
                _startProcess = 1.0;
                _endProcess = 0.0;
                _endTime = current + _duration;
            }
        } else {
            if (_direction == FusionNaviAnimeForward) {
                _startTime = current;
                _startProcess = _process;
                if (_startProcess > 0.5) {
                    _endTime = current + _duration * (1.0 - _process);
                    _endProcess = 1.0;
                } else {
                    _endTime = current + _duration * _process;
                    _endProcess = 0.0;
                }
            } else {
                _startTime = current;
                _startProcess = _process;
                if (_startProcess < 0.5) {
                    _endTime = current + _duration * _process;
                    _endProcess = 0.0;
                } else {
                    _endTime = current + _duration * (1.0 - _process);
                    _endProcess = 1.0;
                }
            }
        }
    }
    _totalFrame++;
    
    if (_displayLinkOver) {
        [self updateProcess:_endProcess];
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
        [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [_displayLink invalidate];
        SafeRelease(_displayLink);
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    } else {
        CGFloat process = (current - _startTime)/(_endTime - _startTime) * (_endProcess - _startProcess) + _startProcess;
        if(isnan(process) == YES || isinf(process) == YES) return;
        if (process < 0.0) {
            process = 0.0;
        } else if(process > 1.0) {
            process = 1.0;
        }
        
        [self updateProcess:process];
        
        if(current >= _endTime) {
            _displayLinkOver = YES;
        }
    }
}

- (void)updateProcess:(CGFloat)process {
    _process = process;
}

- (void)setConfig:(NSDictionary*)config {
    for (NSString *key in [config allKeys]) {
        [self setValue:[config valueForKey:key] forKeyPath:key];
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SafeRelease(_foregroundView);
    SafeRelease(_maskView);
    SafeRelease(_backgroundView);
    
    if(_displayLink != nil) {
        [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop]
                                forMode:NSRunLoopCommonModes];
        SafeRelease(_displayLink);
    }
    SafeSuperDealloc(super);
}
@end