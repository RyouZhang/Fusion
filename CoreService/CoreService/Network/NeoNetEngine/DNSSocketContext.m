//
//  DNSSocketContext.m
//  CoreService
//
//  Created by Ryou Zhang on 12/7/14.
//  Copyright (c) 2014 trip.taobao.com. All rights reserved.
//

#import "DNSSocketContext.h"
#import "SafeARC.h"

@implementation DNSSocketContext
- (void)dealloc {
    if (sourceRef) {
        CFRunLoopSourceInvalidate(sourceRef);
        CFRelease(sourceRef);
    }
    if (socketRef) {
        CFSocketInvalidate(socketRef);
        CFRelease(socketRef);
    }
    SafeSuperDealloc(super);
}
@end
