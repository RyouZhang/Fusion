//
//  NeoSocketContext.m
//  TestLibuv
//
//  Created by Ryou Zhang on 6/13/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import "NeoSocketContext.h"
#import "SafeARC.h"

@implementation NeoSocketContext
@synthesize referanceCount = _referanceCount;
- (instancetype)init {
    self = [super init];
    if (self) {
        _referanceCount = 0;
    }
    return self;
}

- (void)IncrReferanceCount {
    _referanceCount = _referanceCount + 1;
}

- (void)DecrReferanceCount {
    _referanceCount = _referanceCount - 1;
}

- (void)disableSocketCallback {
    CFSocketInvalidate(socketRef);
}

- (void)dealloc {
    if (sourceRef) {
        CFRunLoopSourceInvalidate(sourceRef);
        CFRelease(sourceRef);
    }
    if (socketRef) {
        CFRelease(socketRef);
    }
    task = nil;
    SafeSuperDealloc(super);
}
@end
