//
//  NetNormalActor.m
//  Trip2013
//
//  Created by 淘中天 on 13-11-25.
//  Copyright (c) 2013年 alibaba. All rights reserved.
//

#import "NetNormalActor.h"
#import "NeoHttpTask.h"
#import "NeoHttpPostTask.h"
#import "NeoNetEngine.h"
#import "NetworkCommon.h"
#import "SafeARC.h"

@implementation NetNormalActor

- (id)initWithConfig:(NSDictionary *)config {
    self = [super initWithConfig:config];
    if (self) {
        _waitingQueue = [NSMutableArray new];
        _connectionDic = [NSMutableDictionary new];
        _concurrency = 16;
    }
    return self;
}

- (void)processFusionNativeMessage:(FusionNativeMessage *)message {
    NSString *url = [message.params objectForKey:NET_REMOTE_URL];
    if (url == nil || [NSURL URLWithString:url] == nil) {
        [message setErrorDomainCode:ERROR_DOMAIN_NETWORK
                          errorCode:ERROR_INVALID_URL
                           errorMsg:@"无效的URL"];
        
        [message setState:FusionNativeMessageFailed];
        return;
    }
    [_waitingQueue addObject:message];
    [self schedulerNetConnection];
}

- (void)schedulerNetConnection {
    @autoreleasepool {
        while ([_connectionDic count] < _concurrency)
        {
            if([_waitingQueue count] == 0)
                break;
            FusionNativeMessage* message = SafeRetain([_waitingQueue objectAtIndex:0]);
            [_waitingQueue removeObjectAtIndex:0];
            
            NeoHttpTask *task = nil;
            if ([message.params valueForKey:NET_HTTP_METHOD] &&
                [[message.params valueForKey:NET_HTTP_METHOD] isEqualToString:HTTP_POST_METHOD]) {
                
                task = [NeoHttpPostTask new];
                if ([message.params valueForKey:NET_DNS_RESOLVE]) {
                    [task setResolveArray:@[[message.params valueForKey:NET_DNS_RESOLVE]]];
                }
                [task setUrl:[NSURL URLWithString:[message.params valueForKey:NET_REMOTE_URL]]];
                [task setHeaderDic:[message.params valueForKey:NET_HTTP_HEADER]];
                [(NeoHttpPostTask*)task setPostFields:[message.params valueForKey:NET_HTTP_PARAMS]];
                
            } else {
                task = [NeoHttpTask new];
                if ([message.params valueForKey:NET_DNS_RESOLVE]) {
                    [task setResolveArray:@[[message.params valueForKey:NET_DNS_RESOLVE]]];
                }
                [task setUrl:[NSURL URLWithString:[message.params valueForKey:NET_REMOTE_URL]]];
                [task setHeaderDic:[message.params valueForKey:NET_HTTP_HEADER]];
            }
            
            [task setSource:message];
            SafeRelease(message);
            [_connectionDic setObject:task forKey:[NSValue valueWithPointer:(__bridge const void *)(message)]];

            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(processNeoHttpTaskFinish:)
                                                         name:NeoNetTask_Finish
                                                       object:task];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(processNeoHttpTaskFailed:)
                                                         name:NeoNetTask_Failed
                                                       object:task];            
//            if ([[NeoNetEngine getInstance] hostThread] == nil) {
//                [[NeoNetEngine getInstance] setHostThread:[[FusionCore getInstance] getNetworkThread]];
//            }
            [[NeoNetEngine getInstance] startTask:task];
            SafeRelease(task);
        }
    }
}

- (void)processNeoHttpTaskFinish:(NSNotification*)notify {
    NeoHttpTask *task = SafeRetain([notify object]);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NeoNetTask_Failed object:task];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NeoNetTask_Finish object:task];

    FusionNativeMessage *message = SafeRetain((FusionNativeMessage*)[task source]);
    if (message == nil) {
        [self schedulerNetConnection];
        SafeRelease(task);
        return;
    }
    
    [message setValue:[task rawData] ToDataTableWith:HTTP_RESPONSE_DATA];
    [message setValue:[task responseHeader] ToDataTableWith:HTTP_RESPONSE_HEADER];
    [message setValue:[NSNumber numberWithInteger:[task getResponseCode]]
      ToDataTableWith:HTTP_RESPONSE_CODE];

    [task setSource:nil];
    [_connectionDic removeObjectForKey:[NSValue valueWithPointer:(__bridge const void *)(message)]];
    
    if ([message.params valueForKey:HTTP_DISABLE_FOLLOW] &&
        [[message.params valueForKey:HTTP_DISABLE_FOLLOW] boolValue]) {
        [message setState:FusionNativeMessageFinish];
        SafeRelease(message);
        [self schedulerNetConnection];
        SafeRelease(task);
        return;
    }
    NSInteger statusCode = [[message getValueFromDataTableWith:HTTP_RESPONSE_CODE] integerValue];
    if (statusCode == 302 || statusCode == 301) {
        NSDictionary *responseHeader = [message getValueFromDataTableWith:HTTP_RESPONSE_HEADER];
        NSString *location = [responseHeader valueForKey:@"Location"];
        if (location == nil) {
            location = [responseHeader valueForKey:@"location"];
        }
        if (location == nil) {
            [message setState:FusionNativeMessageFinish];
            SafeRelease(message);
            [self schedulerNetConnection];
            return;
        }
        NeoHttpTask *neoTask = [NeoHttpTask new];
        [neoTask setUrl:[NSURL URLWithString:location]];
        
        [message setValue:location ToDataTableWith:HTTP_EFFECTIVE_URL];
   
        [neoTask setSource:message];
        SafeRelease(message);
        [_connectionDic setObject:neoTask forKey:[NSValue valueWithPointer:(__bridge const void *)(message)]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(processNeoHttpTaskFinish:)
                                                     name:NeoNetTask_Finish
                                                   object:neoTask];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(processNeoHttpTaskFailed:)
                                                     name:NeoNetTask_Failed
                                                   object:neoTask];
        [[NeoNetEngine getInstance] startTask:neoTask];
        SafeRelease(neoTask);
    } else {
        [message setState:FusionNativeMessageFinish];
        SafeRelease(message);
        [self schedulerNetConnection];
    }
    SafeRelease(task);
}

- (void)processNeoHttpTaskFailed:(NSNotification*)notify {
    NeoHttpTask *task = [notify object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NeoNetTask_Failed object:task];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NeoNetTask_Finish object:task];
    
    FusionNativeMessage* message = SafeRetain((FusionNativeMessage*)[task source]);
    if (message == nil) {
        [self schedulerNetConnection];
        return;
    }
    
    [task setSource:nil];
    [message setValue:[NSNumber numberWithInteger:[task getResponseCode]]
      ToDataTableWith:HTTP_RESPONSE_CODE];
    [message setValue:[task responseHeader]
      ToDataTableWith:HTTP_RESPONSE_HEADER];
    [message setErrorDomainCode:ERROR_DOMAIN_NETWORK
                      errorCode:task.code
                       errorMsg:[task errorMsg]];
    
    [_connectionDic removeObjectForKey:[NSValue valueWithPointer:(__bridge const void *)(message)]];
    [message setState:FusionNativeMessageFailed];
    SafeRelease(message);
    [self schedulerNetConnection];
}

- (void)cancelFusionNativeMessage:(FusionNativeMessage *)message {
    [_waitingQueue removeObject:message];

    NeoHttpTask* task = [_connectionDic objectForKey:[NSValue valueWithPointer:(__bridge const void *)(message)]];
    if(task != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NeoNetTask_Failed object:task];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NeoNetTask_Finish object:task];
        [task setSource:nil];
        [[NeoNetEngine getInstance] cancelTask:task];
        [_connectionDic removeObjectForKey:[NSValue valueWithPointer:(__bridge const void *)(message)]];
        [self schedulerNetConnection];
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SafeRelease(_waitingQueue);
    SafeRelease(_connectionDic);
    SafeSuperDealloc(super);
}

@end
