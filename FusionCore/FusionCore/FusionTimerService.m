//
//  FusionTimerService.m
//  TestNewCore
//
//  Created by Ryou Zhang on 7/13/13.
//  Copyright (c) 2013 Ryou Zhang. All rights reserved.
//

#import "FusionTimerService.h"
#import "FusionTimerTask.h"
#import "../../Workspace/CommonHeader/SafeARC.h"

@implementation FusionTimerService
static FusionTimerService *_FusionTimerService_Instance = nil;
+ (FusionTimerService *)getInstance {
    @synchronized(self) {
        if(_FusionTimerService_Instance == nil)
            _FusionTimerService_Instance = [FusionTimerService new];
        return _FusionTimerService_Instance;
    }
}

- (id)init {
    self = [super init];
    if (self) {
        _taskArray = [NSMutableArray new];
        _timerThread = [[NSThread alloc] initWithTarget:self
                                               selector:@selector(timerThreadEntry)
                                                 object:nil];
        [_timerThread start];
    }
    return self;
}

- (void)timerThreadEntry {
    SafeAutoReleasePoolStart
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(onTimerThreadUpdate:)
                                           userInfo:nil
                                            repeats:YES];
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    
    while ([runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    
    SafeAutoReleasePoolEnd
}

- (void)onTimerThreadUpdate:(id)sender {
    
    @autoreleasepool {
        
        __block NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
        __block NSMutableArray* finishArray = [NSMutableArray new];
        [_taskArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            FusionTimerTask *task = (FusionTimerTask*)obj;
            if ([task isTimeToTrigger:current])
                [task doTask];
            if ([task isTimeFinish])
                [finishArray addObject:task];
        }];
        [_taskArray removeObjectsInArray:finishArray];
        SafeRelease(finishArray);
        
    }

}

- (void)registerTimerTask:(FusionTimerTask *)task {
    [self performSelector:@selector(onRegisterTimerTask:)
                 onThread:_timerThread
               withObject:task
            waitUntilDone:NO];
}

- (void)onRegisterTimerTask:(FusionTimerTask *)task {
    if (NO == [_taskArray containsObject:task])
        [_taskArray addObject:task];
}

- (void)unregisterTimerTask:(FusionTimerTask *)task {
    [self performSelector:@selector(onUnregisterTimerTask:)
                 onThread:_timerThread
               withObject:task
            waitUntilDone:NO];
}

- (void)onUnregisterTimerTask:(FusionTimerTask *)task {
    [_taskArray removeObject:task];
}

- (void)dealloc {
    SafeRelease(_timerThread);
    SafeRelease(_taskArray);
    SafeSuperDealloc(super);
}
@end
