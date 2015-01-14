//
//  NeoSocketContext.h
//  TestLibuv
//
//  Created by Ryou Zhang on 6/13/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NeoNetTask;

@interface NeoSocketContext : NSObject {
@private
    NSUInteger  _referanceCount;
@public
    NSTimeInterval  bornTime;
    CFSocketRef socketRef;
    CFRunLoopSourceRef  sourceRef;
    socklen_t   socket;
    NeoNetTask  *task;
}
@property(assign, atomic, readonly)NSUInteger referanceCount;

- (void)IncrReferanceCount;
- (void)DecrReferanceCount;

- (void)disableSocketCallback;
@end
