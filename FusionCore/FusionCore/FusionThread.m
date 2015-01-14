//
//  FusionThread.m
//  TestNewCore
//
//  Created by Ryou Zhang on 6/30/13.
//  Copyright (c) 2013 Ryou Zhang. All rights reserved.
//

#import "FusionThread.h"
#import "SafeARC.h"

@implementation FusionThread
@synthesize interval = _interval;
@synthesize delegate = _delegate;
- (id)init {
    self = [super init];
    if (self) {
        _interval = 30;
        _delegate = nil;
        L = NULL;
    }
    return self;
}

- (void)main {
    SafeAutoReleasePoolStart
    [[NSThread currentThread] setName:_nickName];
    
    NSRunLoop *currentLoop = [NSRunLoop currentRunLoop];
    
    [currentLoop addTimer:[NSTimer timerWithTimeInterval:_interval
                                                  target:self
                                                selector:@selector(onThreadUpdate:)
                                                userInfo:nil
                                                 repeats:YES]
                  forMode:NSDefaultRunLoopMode];
    
    while ([currentLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    
    SafeAutoReleasePoolEnd
}

- (void)onThreadUpdate:(id)sender {
    @autoreleasepool {
    
        if (_delegate) {
            [_delegate onFusionThreadUpdate];
        }
    }
}


- (void)dealloc {
    _delegate = nil;
    if (L != NULL) {
        lua_close(L);
    }
    SafeSuperDealloc(super);
}
@end
