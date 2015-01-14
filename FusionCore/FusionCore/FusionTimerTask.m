//
//  FusionTimeTask.m
//  TestNewCore
//
//  Created by Ryou Zhang on 7/13/13.
//  Copyright (c) 2013 Ryou Zhang. All rights reserved.
//

#import "FusionTimerTask.h"
#import "SafeARC.h"

@implementation FusionTimerTask
- (id)initWithInterval:(NSTimeInterval)interval
                 Delay:(NSTimeInterval)delay
                Repeat:(NSUInteger)repeat {
    self = [super init];
    if (self) {
        _interval = interval;
        _repeat = repeat;
        
        if (delay == 0)
            _lastTime = 0;
        else
            _lastTime = [[NSDate date] timeIntervalSince1970] - _interval + delay;
        _triggerCount = 0;
    }
    return self;
}

- (id)initWithInterval:(NSTimeInterval)interval
                 Delay:(NSTimeInterval)delay
               Forever:(BOOL)forever {
    self = [super init];
    if (self) {
        _interval = interval;
        if (forever)
            _repeat = 0;
        else
            _repeat = 1;
        
        if (delay == 0)
            _lastTime = 0;
        else
            _lastTime = [[NSDate date] timeIntervalSince1970] - _interval + delay;
        _triggerCount = 0;
    }
    return self;
}

- (BOOL)isTimeToTrigger:(NSTimeInterval)currentTime {
    if (currentTime - _lastTime > _interval) {
        _triggerCount++;
		_lastTime = currentTime;
        return YES;
    }
    return NO;
}

- (BOOL)isTimeFinish {
    if (_repeat == 0)
        return NO;
    if (_triggerCount >= _repeat) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FusionTimerTaskFinish object:self];
        return YES;
    }
    return NO;
}

- (void)resetTimer {
    _lastTime = [[NSDate date] timeIntervalSince1970];
}

- (void)doTask {
    [[NSNotificationCenter defaultCenter] postNotificationName:FusionTimerTaskTrigger object:self];
}

- (void)dealloc {
    SafeSuperDealloc(super);
}
@end
