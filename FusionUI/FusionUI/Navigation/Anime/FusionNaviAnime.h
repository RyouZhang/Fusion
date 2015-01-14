//
//  FusionNaviAnime.h
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

#define FusionNaviAnime_Finish  @"FusionNaviAnime_Finish"
#define FusionNaviAnime_Cancel  @"FusionNaviAnime_Cancel"


typedef enum {
    FusionNaviAnimeForward  = 0,
    FusionNaviAnimeBackward = 1
}FusionNaviAnimeDirection;

@interface FusionNaviAnime : NSObject
{
@private
    BOOL                        _displayLinkStart;
    BOOL                        _displayLinkOver;
@protected
    FusionNaviAnimeDirection    _direction;
    BOOL                        _isAuto;
    
    NSTimeInterval              _duration;
    
    CGFloat                     _process;
    
    NSTimeInterval              _startTime;
    NSTimeInterval              _endTime;
    
    CGFloat                     _startProcess;
    CGFloat                     _endProcess;
    
    CADisplayLink               *_displayLink;
    
    UIView                      *_maskView;
    UIView                      *_backgroundView;
    UIView                      *_foregroundView;
    
    
    NSUInteger                  _totalFrame;
}
@property(readwrite, atomic)NSTimeInterval  duration;
@property(assign, atomic)BOOL   isAuto;
@property(assign, atomic)FusionNaviAnimeDirection direction;
@property(assign, readonly)CGFloat process;

@property(retain, atomic)UIView *maskView;
@property(retain, atomic)UIView *backgroundView;
@property(retain, atomic)UIView *foregroundView;


- (void)prepare;

- (void)forcePlay;

- (void)play;

//process [0.0 , 1.0]
-(void)updateProcess:(CGFloat)process;

- (void)setConfig:(NSDictionary*)config;
@end