//
//  FusionTimeTask.h
//  TestNewCore
//
//  Created by Ryou Zhang on 7/13/13.
//  Copyright (c) 2013 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FusionTimerTaskTrigger  @"FusionTimerTaskTrigger"
#define FusionTimerTaskFinish   @"FusionTimerTaskFinish"

@interface FusionTimerTask : NSObject {
@private
    NSTimeInterval  _interval;
    NSUInteger      _repeat;
    
    NSUInteger      _triggerCount;
    NSTimeInterval  _lastTime;
}
- (id)initWithInterval:(NSTimeInterval)interval
                 Delay:(NSTimeInterval)delay
                Repeat:(NSUInteger)repeat;

- (id)initWithInterval:(NSTimeInterval)interval
                 Delay:(NSTimeInterval)delay
               Forever:(BOOL)forever;

- (BOOL)isTimeToTrigger:(NSTimeInterval)currentTime;
- (BOOL)isTimeFinish;

- (void)doTask;

- (void)resetTimer;
@end
