//
//  FusionTimerService.h
//  TestNewCore
//
//  Created by Ryou Zhang on 7/13/13.
//  Copyright (c) 2013 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FusionTimerTask;

@interface FusionTimerService : NSObject {
@private
    NSThread        *_timerThread;
    NSMutableArray  *_taskArray;
}
+ (FusionTimerService *)getInstance;

- (void)registerTimerTask:(FusionTimerTask *)task;
- (void)unregisterTimerTask:(FusionTimerTask *)task;
@end
