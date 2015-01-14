//
//  FusionCore.m
//  TestNewCore
//
//  Created by Ryou Zhang on 6/30/13.
//  Copyright (c) 2013 Ryou Zhang. All rights reserved.
//

#import "FusionCore.h"
#import "FusionThread.h"
#import "FusionService.h"
#import "FusionNativeMessage.h"
#import "FusionTimerService.h"
#import "FusionTimerTask.h"
#import "FusionMessagePool.h"
#import "SafeARC.h"

#define Max_Worker_Thread   sysconf(_SC_NPROCESSORS_CONF) * 2
@interface FusionCore()<FusionThreadDelegate> {
@private
    id<IFusionConfig>       _fusionConfig;
    NSMutableArray          *_coreServiceArray;
    
    NSMutableDictionary     *_configDic;
    NSMutableDictionary     *_serviceDic;
    
    FusionThread            *_coreThread;
    FusionThread            *_networkThread;
    
    FusionMessagePool       *_messagePool;
    NSMutableArray          *_delayMessageArray;
    
    NSMutableArray          *_idleThreads;
    NSMutableArray          *_workerThreads;
}
@end


@implementation FusionCore
static FusionCore   *_FusionCore_Instance = nil;
+ (FusionCore *)getInstance {
    @synchronized(self) {
        if(_FusionCore_Instance == nil)
            _FusionCore_Instance = [FusionCore new];
    }
    return _FusionCore_Instance;
}

-(id)init {
    self = [super init];
    if(self) {
        _coreServiceArray = [NSMutableArray new];
        _serviceDic = [NSMutableDictionary new];
        
        _messagePool = [FusionMessagePool new];
        
        _delayMessageArray = [NSMutableArray new];
        
        _idleThreads = [NSMutableArray new];
        _workerThreads = [NSMutableArray new];
        
        _coreThread = [FusionThread new];
        _coreThread.nickName = @"Fusion_Core_Thread";
        [_coreThread setInterval:0.5];
        [_coreThread setDelegate:self];
        [_coreThread start];        
        
        _networkThread = [FusionThread new];
        _networkThread.nickName = @"Fusion_Network_Thread";        
        [_networkThread start];
        
        [self initWorkerThreadCount:Max_Worker_Thread];
    }
    return self;
}

- (void)prepareWithConfig:(id<IFusionConfig>)config {
    assert([config conformsToProtocol:NSProtocolFromString(@"IFusionConfig")]);
    _fusionConfig = SafeRetain(config);
    [self performSelector:@selector(onPrepareFusionCore)
                 onThread:_coreThread
               withObject:nil
            waitUntilDone:NO];
}

- (void)resetLogicService {
    [self performSelector:@selector(onResetService)
                 onThread:_coreThread
               withObject:nil
            waitUntilDone:NO];
}

- (void)initWorkerThreadCount:(NSInteger)count {
    if (count > Max_Worker_Thread)
        count = Max_Worker_Thread;
    
    for(int index=0; index < count; index++) {
        FusionThread *thread = [FusionThread new];
        thread.nickName = [NSString stringWithFormat:@"Fusion_Worker_%d_Thread", index];
        [_idleThreads addObject:thread];
        [thread start];
        SafeRelease(thread);
    }
}

- (void)onPrepareFusionCore {
    [self startCoreService];
    if ([_fusionConfig respondsToSelector:@selector(getTimeTaskArray)]) {
        [self registerTimerTask];
    }
}

- (void)startCoreService {
    NSArray *configArray = [_fusionConfig getCoreService];
    for (NSDictionary *config in configArray) {
        Class serviceClass = NSClassFromString([config valueForKey:@"class"]);
        if([serviceClass isSubclassOfClass:[FusionService class]]) {
            FusionService* service = [[serviceClass alloc] initWithConfig:config];
            [service setName:[config valueForKey:@"name"]];
            [_coreServiceArray addObject:service];
            [_serviceDic setValue:service forKey:[service name]];
            SafeRelease(service);
        }
    }
}

- (void)registerTimerTask {
    NSArray *configArray = [_fusionConfig getTimeTaskArray];
    for (NSDictionary *config in configArray) {
        Class taskClass = NSClassFromString([config valueForKey:@"class"]);
        if([taskClass isSubclassOfClass:[FusionTimerTask class]]) {
            NSTimeInterval interval = [[config valueForKey:@"interval"] doubleValue];
            NSTimeInterval delay = [[config valueForKey:@"delay"] doubleValue];
            
            FusionTimerTask *task = nil;
            if ([config valueForKey:@"forever"]) {
                task = [[taskClass alloc] initWithInterval:interval
                                                     Delay:delay
                                                   Forever:YES];
            } else {
                task = [[taskClass alloc] initWithInterval:interval
                                                     Delay:delay
                                                    Repeat:[[config valueForKey:@"count"] interval]];
            }
            if (task) {
                [[FusionTimerService getInstance] registerTimerTask:task];
                SafeRelease(task);
            }
        }
    }
}

- (void)registerCoreService:(FusionService *)service {
    [_coreServiceArray addObject:service];
    [_serviceDic setValue:service forKey:[service name]];
}

//动态重新加载配置文件
- (void)resetService:(NSNotification *)notify {
    [self performSelector:@selector(onResetService)
                 onThread:_coreThread
               withObject:nil
            waitUntilDone:NO];
}

- (void)onResetService {
    SafeRelease(_configDic);
    [_serviceDic removeAllObjects];
    [_coreServiceArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FusionService *service = (FusionService*)obj;
        [_serviceDic setValue:service forKey:[service name]];
    }];
}

//for corethread update
-(void)onFusionThreadUpdate {
    if ([_delayMessageArray count] == 0) {
        return;
    }    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSMutableArray *triggerArray = [NSMutableArray new];
    for (FusionNativeMessage *message in _delayMessageArray) {
        if (message.triggerTime <= now) {
            [message setDelay:0];
            [triggerArray addObject:message];
        }
    }
    if ([triggerArray count] != 0) {
        [_delayMessageArray removeObjectsInArray:triggerArray];
        [self onAsyncSendMessageArray:triggerArray];
    }
    SafeRelease(triggerArray);
}

#pragma AsyncSendMessage
- (void)asyncSendMessage:(FusionNativeMessage *)message {
    message.originThread = [NSThread currentThread];
    
    [self performSelector:@selector(onAsyncSendMessageArray:)
                 onThread:_coreThread
               withObject:@[message]
            waitUntilDone:NO];
}

- (void)asyncSendMessageArray:(NSArray *)messageArray {
    for (FusionNativeMessage *message in messageArray) {
        message.originThread = [NSThread currentThread];
    }
    [self performSelector:@selector(onAsyncSendMessageArray:)
                 onThread:_coreThread
               withObject:[NSArray arrayWithArray:messageArray]
            waitUntilDone:NO];
}

- (void)onAsyncSendMessageArray:(NSArray *)messageArray {
    for (FusionNativeMessage *message in messageArray) {
        FusionService *service = [self checkFusionServiceValid:message];
        if (service == nil) {
            continue;
        }
        if (message.delay != 0) {
            [message setTriggerTime:message.delay +  [[NSDate date] timeIntervalSince1970]];
            [_delayMessageArray addObject:message];
            continue;
        }
        if (service.threadType == FusionService_NET) {
            [service performSelector:@selector(processFusionNativeMessage:)
                            onThread:_networkThread
                          withObject:message
                       waitUntilDone:NO];
            continue;
        } else if (service.threadType == FusionService_UI) {
            [service performSelector:@selector(processFusionNativeMessage:)
                            onThread:[NSThread mainThread]
                          withObject:message
                       waitUntilDone:NO];
            continue;
        }
        [_messagePool sendMessage:message];
    }
    [self executeSchedule];
}

#pragma AsyncCancelMessage
- (void)asyncCancelMessage:(FusionNativeMessage *)message {
    [self performSelector:@selector(onDispatchCancelMessageArray:)
                 onThread:_coreThread
               withObject:[NSArray arrayWithObject:message]
            waitUntilDone:NO];
}

- (void)asyncCancelMessageArray:(NSArray *)messageArray {
    [self performSelector:@selector(onDispatchCancelMessageArray:)
                 onThread:_coreThread
               withObject:[NSArray arrayWithArray:messageArray]
            waitUntilDone:NO];
}

- (void)dispatchCancelMessage:(FusionNativeMessage *)message {
    [self performSelector:@selector(onDispatchCancelMessageArray:)
                 onThread:_coreThread
               withObject:[NSArray arrayWithObject:message]
            waitUntilDone:NO];
}

- (void)dispatchCancelMessageArray:(NSArray *)messageArray {
    [self performSelector:@selector(onDispatchCancelMessageArray:)
                 onThread:_coreThread
               withObject:[NSArray arrayWithArray:messageArray]
            waitUntilDone:NO];
}

- (void)onDispatchCancelMessageArray:(NSArray *)messageArray {
    for (FusionNativeMessage *message in messageArray) {
        FusionService *service = [self checkFusionServiceValid:message];
        if (service == nil) {
            continue;
        }
        
        if (service.threadType == FusionService_NET) {
            [self processFusionNativeMessage:message
                                messageLevel:Cancel_FusionCore_Level
                                workerThread:_networkThread];
            continue;
        } else if (service.threadType == FusionService_UI) {
            [self processFusionNativeMessage:message
                                messageLevel:Cancel_FusionCore_Level
                                workerThread:[NSThread mainThread]];
            continue;
        }
        [_messagePool cancelMessage:message];
    }
    [self executeSchedule];
}

#pragma DispatchNormalMessage
- (void)dispatchMessage:(FusionNativeMessage *)message {
    [self performSelector:@selector(onAsyncSendMessageArray:)
                 onThread:_coreThread
               withObject:[NSArray arrayWithObject:message]
            waitUntilDone:NO];
}

- (void)dispatchMessageArray:(NSArray *)messageArray {
    [self performSelector:@selector(onAsyncSendMessageArray:)
                 onThread:_coreThread
               withObject:messageArray
            waitUntilDone:NO];
}

#pragma DispatchCallbackMessage
- (void)dispatchCallbackFusionNativeMessage:(FusionNativeMessage *)message {
    [self performSelector:@selector(onDispatchCallbackFusionNativeMessage:)
                 onThread:_coreThread
               withObject:message
            waitUntilDone:NO];
}

- (void)onDispatchCallbackFusionNativeMessage:(FusionNativeMessage *)message {
    FusionService *service = [self checkFusionServiceValid:message.parent];
    if (service == nil) {
        return;
    }
    
    if (service.threadType == FusionService_NET) {
        [service performSelector:@selector(processCallbackFusionNativeMessage:)
                        onThread:_networkThread
                      withObject:message
                   waitUntilDone:NO];
        return;
    } else if (service.threadType == FusionService_UI) {
        [service performSelector:@selector(processCallbackFusionNativeMessage:)
                        onThread:[NSThread mainThread]
                      withObject:message
                   waitUntilDone:NO];
        return;
    }
    [_messagePool callbackMessage:message];
    [self executeSchedule];
}

- (void)processFusionNativeMessage:(FusionNativeMessage *)message
                      messageLevel:(NSUInteger)level
                      workerThread:(NSThread *)workerThread{
    switch (level) {
        case Cancel_FusionCore_Level:
            [self performSelector:@selector(processCancelFusionNativeMessage:)
                         onThread:workerThread
                       withObject:message
                    waitUntilDone:NO];
            break;
        case Normal_FusionCore_Level:
            [self performSelector:@selector(processFusionNativeMessage:)
                         onThread:workerThread
                       withObject:message
                    waitUntilDone:NO];
            break;
        case Callback_FusionCore_Level:
            [self performSelector:@selector(processCallbackFusionNativeMessage:)
                         onThread:workerThread
                       withObject:message
                    waitUntilDone:NO];
            break;
    }
}

- (void)executeSchedule {
    SafeAutoReleasePoolStart
    NSUInteger level = 0;
    NSUInteger index = 0;
    while ([_idleThreads count] > 0 && index < [_idleThreads count]) {
        FusionThread *workerThread = [_idleThreads objectAtIndex:index];
        FusionNativeMessage *message = [_messagePool fetchMessageForWorker:workerThread.nickName messageLevel:&level];
        if (message == nil) {
            index++;
            continue;
        }
        if (level == Normal_FusionCore_Level &&
            message.workerNick == nil) {
            message.workerNick = workerThread.nickName;
        }
        [self processFusionNativeMessage:message
                            messageLevel:level
                            workerThread:workerThread];
        [_workerThreads addObject:workerThread];
        [_idleThreads removeObject:workerThread];
        [self performSelector:@selector(restoreIdleThread)
                     onThread:workerThread
                   withObject:nil
                waitUntilDone:NO];
    }
    SafeAutoReleasePoolEnd
}

- (void)processFusionNativeMessage:(FusionNativeMessage *)message {
    FusionService *service = [_serviceDic valueForKey:message.service];
    if (service) {
        [service processFusionNativeMessage:message];
    }
}

- (void)processCallbackFusionNativeMessage:(FusionNativeMessage *)message {
    FusionService *service = [_serviceDic valueForKey:message.parent.service];
    if (service) {
        [service processCallbackFusionNativeMessage:message];
    }
}

- (void)processCancelFusionNativeMessage:(FusionNativeMessage *)message {
    FusionService *service = [_serviceDic valueForKey:message.service];
    if (service) {
        [service processCancelFusionNativeMessage:message];
    }
}

- (void)restoreIdleThread {
    [self performSelector:@selector(onRestoreIdleThread:)
                 onThread:_coreThread
               withObject:[NSThread currentThread]
            waitUntilDone:NO];
}

- (void)onRestoreIdleThread:(FusionThread *)thread {
    if (thread != _networkThread && thread != [NSThread mainThread]) {
        [_workerThreads removeObject:thread];
        [_idleThreads addObject:thread];
    }
    [self executeSchedule];
}

//check service valid
- (FusionService *)checkFusionServiceValid:(FusionNativeMessage *)message {
    FusionService *service = SafeRetain([_serviceDic valueForKey:[message service]]);
    if (service == nil) {
        NSDictionary *config = [_fusionConfig getLogicServiceByName:[message service]];
        if (config == nil ||
            [config isKindOfClass:[NSDictionary class]] == NO ||
            [[config allKeys] count] == 0)
            return nil;
        
        Class serviceClass = NSClassFromString([config valueForKey:@"class"]);
        if ([serviceClass isSubclassOfClass:[FusionService class]] == NO)
            return nil;
        
        service = [[serviceClass alloc] initWithConfig:config];
        [service setName:[message service]];
        [_serviceDic setValue:service forKey:[service name]];
    }
    if (NO == [service checkFusionActorValid:message]) {
        SafeRelease(service);
        return nil;
    }
    return SafeAutoRelease(service);
}

- (NSThread *)getNetworkThread {
    return _networkThread;
}

-(void)dealloc {
    SafeRelease(_delayMessageArray);
    SafeRelease(_messagePool);
    for (FusionThread *thread in _idleThreads) {
        [thread cancel];
    }
    SafeRelease(_idleThreads);
    SafeRelease(_workerThreads);
    [_coreThread cancel];
    SafeRelease(_coreThread);
    SafeRelease(_networkThread);
    SafeRelease(_serviceDic);
    SafeRelease(_coreServiceArray);
    SafeSuperDealloc(super);
}
@end