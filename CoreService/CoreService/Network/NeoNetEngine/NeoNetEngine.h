//
//  NeoNetEngine.h
//  TestLibuv
//
//  Created by Ryou Zhang on 6/11/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "curl.h"


//config keys
//dns_service,dns_cache_time,timeout,connect_timeout


@class NeoNetTask;

@interface NeoNetEngine : NSObject {
@private
    NSMutableArray      *_taskArray;
    NSMutableDictionary *_socketDic;
    
    CURLM               *_curl_mhandle;
    CURLSH              *_share_handle;
    
    NSThread            *_hostThread;
    NSDictionary        *_config;
    
    NSTimer             *_updateTimer;
    
    NSInteger           _timeout;
    NSTimer             *_timer;
}
@property(retain, atomic)NSThread *hostThread;
@property(retain, atomic)NSDictionary *config;

+ (NeoNetEngine*)getInstance;

- (void)startTask:(NeoNetTask *)task;
- (void)cancelTask:(NeoNetTask *)task;
@end
