//
//  NeoNetEngine.m
//  TestLibuv
//
//  Created by Ryou Zhang on 6/11/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import "NeoNetEngine.h"
#import "NeoNetTask.h"
#import "NeoSocketContext.h"
#import "NeoDNSEngine.h"
#import "NeoReachability.h"
#import <netinet/in.h>
#import <netdb.h>
#import <Enviroment/Enviroment.h>
#import <FusionCore/FusionCore.h>
#import "SafeARC.h"

@interface NeoNetEngine() {
@private
    NetworkStatus       _netStatus;
}
@end

@interface NeoNetEngine(Private)
- (void)startSocketTimeout:(long)timeout;
- (int)handle:(CURL *)easy
       socket:(curl_socket_t)socket
       action:(int)action
        userp:(void *)userp
       scketp:(void*)socketp;

- (void)socket:(CFSocketRef)socket
  callbackType:(CFSocketCallBackType)type
       address:(CFDataRef)address
          data:(const void*)data
          info:(void*)info;

- (int)closeSocket:(socklen_t)socket;
@end

int
curl_handle_socket(CURL *easy, curl_socket_t s, int action, void *userp, void *socketp) {
    return [[NeoNetEngine getInstance] handle:easy
                                        socket:s
                                        action:action
                                         userp:userp
                                        scketp:socketp];
}

void
start_socket_timeout(CURLM *multi, long timeout_ms, void *userp) {
    [[NeoNetEngine getInstance] startSocketTimeout:timeout_ms];
}

void
on_cfsocket_callback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    [[NeoNetEngine getInstance] socket:s callbackType:type address:address data:data info:info];
}

int
on_curl_closesocket_callback(void *clientp, curl_socket_t item) {
    return [[NeoNetEngine getInstance] closeSocket:item];
}

@implementation NeoNetEngine
@synthesize hostThread = _hostThread, config = _config;
static NeoNetEngine *_NeoNetEngine_Instance = nil;
+ (NeoNetEngine *)getInstance {
    @synchronized(self) {
        if(_NeoNetEngine_Instance == nil)
            _NeoNetEngine_Instance = [NeoNetEngine new];
    }
    return _NeoNetEngine_Instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _hostThread = nil;
        
        _timeout = 10;
        if ([[AppEnvironment getInstance] getEnviroment] == App_Release) {
            _timeout = 30;
        }
        curl_global_init(CURL_GLOBAL_DEFAULT);

        _taskArray = [NSMutableArray new];
        _socketDic = [NSMutableDictionary new];
        
        _curl_mhandle = curl_multi_init();
//        curl_multi_setopt(_curl_mhandle, CURLMOPT_PIPELINING, 1);
        curl_multi_setopt(_curl_mhandle, CURLMOPT_SOCKETFUNCTION, curl_handle_socket);
        curl_multi_setopt(_curl_mhandle, CURLMOPT_TIMERFUNCTION, start_socket_timeout);
        curl_multi_setopt(_curl_mhandle, CURLMOPT_MAXCONNECTS, 32);
        curl_multi_setopt(_curl_mhandle, CURLMOPT_MAX_TOTAL_CONNECTIONS, 32);
        _share_handle = curl_share_init();
        curl_share_setopt(_share_handle, CURLSHOPT_SHARE, CURL_LOCK_DATA_SSL_SESSION);
        curl_share_setopt(_share_handle, CURLSHOPT_SHARE, CURL_LOCK_DATA_COOKIE);
        curl_share_setopt(_share_handle, CURLSHOPT_SHARE, CURL_LOCK_DATA_DNS);
        
        [[NeoReachability getInstance] startNotifier];
        _netStatus = [[NeoReachability getInstance] currentReachabilityStatus];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onReachabilyChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:[NeoReachability getInstance]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onDNSLookupFinish:)
                                                     name:NeoDNSEngineLookupFinsih
                                                   object:nil];
    }
    return self;
}

#pragma Reachability ChangedNotification
- (void)onReachabilyChanged:(NSNotification*)notify {
    if (_hostThread) {
        [self performSelector:@selector(reachbilityChanged)
                     onThread:_hostThread
                   withObject:nil
                waitUntilDone:NO];
    } else {
        [self performSelector:@selector(reachbilityChanged)
                     onThread:[[FusionCore getInstance] getNetworkThread]
                   withObject:nil
                waitUntilDone:NO];
    }
}
    
- (void)reachbilityChanged {
    if (_netStatus == [[NeoReachability getInstance] currentReachabilityStatus])
        return;
    
    NetworkStatus neoStatus = [[NeoReachability getInstance] currentReachabilityStatus];
    if (neoStatus < _netStatus) {
        for (NeoNetTask *task in _taskArray) {
            curl_multi_remove_handle(_curl_mhandle, task.handle);
            [task resetData];
        }
        [_socketDic removeAllObjects];
        
        if (neoStatus != 0) {
            for (NeoNetTask *task in _taskArray) {
                task->timeStamp = [[NSDate date] timeIntervalSince1970];
                curl_multi_add_handle(_curl_mhandle, task.handle);
            }
        } else {
            while ([_taskArray count] != 0) {
                NeoNetTask *task = SafeRetain([_taskArray firstObject]);
                [_taskArray removeObject:task];
                curl_multi_remove_handle(_curl_mhandle, task.handle);
                task.code = CURLE_NO_CONNECTION_AVAILABLE;
                [task taskFailed];
                SafeRelease(task);
            }
            [_taskArray removeAllObjects];
        }
    }
    _netStatus = neoStatus;
}

#pragma Socket Timeout
- (void)startSocketTimeout:(long)timeout {
    if (timeout <= 0) {
        timeout = 1;
    }
    [self performSelector:@selector(onSocketTimeOut:) withObject:nil afterDelay:timeout/1000.0];
}

- (void)onSocketTimeOut:(id)sender {
    int running_handles;
    curl_multi_socket_action(_curl_mhandle, CURL_SOCKET_TIMEOUT, 0, &running_handles);
}

- (void)onTimerTrigger:(id)sender {
    [self checkCurlMutilQueue];
    [self checkCurlTimeout];
}

#pragma Proxy
- (void)configProxy:(NeoNetTask*)task {
    CFDictionaryRef proxyInfo = CFNetworkCopySystemProxySettings();
    
    CFArrayRef proxys = CFNetworkCopyProxiesForURL((__bridge CFURLRef)task.url,
                                                   proxyInfo);
    if (CFArrayGetCount(proxys) == 0) {
        CFRelease(proxyInfo);
        CFRelease(proxys);
        return;
    }
    NSDictionary *proxy = CFArrayGetValueAtIndex(proxys, 0);
    if ([[task.url scheme] isEqualToString:@"https"]) {
        curl_easy_setopt(task.handle, CURLOPT_HTTPPROXYTUNNEL, 1);
    }
    curl_easy_setopt(task.handle, CURLOPT_PROXY,
                     [[proxy valueForKey:(NSString *)kCFProxyHostNameKey] cStringUsingEncoding:NSUTF8StringEncoding]);
    curl_easy_setopt(task.handle, CURLOPT_PROXYPORT, [[proxy objectForKey:(NSString *)kCFProxyPortNumberKey] intValue]);
    if ([proxy valueForKey:(NSString*)kCFProxyUsernameKey]) {
        curl_easy_setopt(task.handle, CURLOPT_PROXYUSERNAME,
                         [[proxy valueForKey:(NSString*)kCFProxyUsernameKey] cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    if ([proxy valueForKey:(NSString*)kCFProxyPasswordKey]) {
        curl_easy_setopt(task.handle, CURLOPT_PROXYUSERPWD,
                         [[proxy valueForKey:(NSString*)kCFProxyPasswordKey] cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    CFRelease(proxyInfo);
    CFRelease(proxys);
}

#pragma Task
- (void)startTask:(NeoNetTask *)task {
    
    if (_hostThread) {
        [self performSelector:@selector(onStartTask:)
                     onThread:_hostThread
                   withObject:task
                waitUntilDone:NO];
    } else {
        [self onStartTask:task];
    }
}

- (void)onStartTask:(NeoNetTask *)task {
    NSString *host = [[task url] host];
    NSString *resolve = [[NeoDNSEngine getInstance] findResolveInfo:host];
    if (resolve) {
        [task setResolveArray:@[resolve]];
        [self doTask:task];
    } else {
        [[NeoDNSEngine getInstance] asyncStartLookup:task];
    }
}

- (void)onDNSLookupFinish:(NSNotification*)notify {
    NeoNetTask *task = (NeoNetTask*)[notify object];
    NSDictionary *info = [notify userInfo];
    if ([info valueForKey:@"resolve"]) {
        [task setResolveArray:@[[info valueForKey:@"resolve"]]];
    }
    [self doTask:task];
}

- (void)doTask:(NeoNetTask *)task {
    if (_timer == nil) {
        _timer = SafeRetain([NSTimer scheduledTimerWithTimeInterval:0.2
                                                             target:self
                                                           selector:@selector(onTimerTrigger:)
                                                           userInfo:nil
                                                            repeats:YES]);
    }
    curl_easy_setopt(task.handle, CURLOPT_SHARE, _share_handle);
    if (_config) {
        if ([_config valueForKey:@"dns_service"]) {
            curl_easy_setopt(task.handle, CURLOPT_DNS_SERVERS, [[_config valueForKey:@"dns_service"] cStringUsingEncoding:NSUTF8StringEncoding]);
        }
        if ([_config valueForKey:@"dns_cache_time"]) {
            curl_easy_setopt(task.handle, CURLOPT_DNS_CACHE_TIMEOUT, [[_config valueForKey:@"dns_cache_time"] integerValue]);
        }
        if ([_config valueForKey:@"timeout"]) {
            curl_easy_setopt(task.handle, CURLOPT_TIMEOUT, [[_config valueForKey:@"timeout"] integerValue]);
        }
        if ([_config valueForKey:@"connect_timeout"]) {
            curl_easy_setopt(task.handle, CURLOPT_CONNECTTIMEOUT, [[_config valueForKey:@"connect_timeout"] integerValue]);
        }
    } else {
        curl_easy_setopt(task.handle, CURLOPT_CONNECTTIMEOUT, 10);
        curl_easy_setopt(task.handle, CURLOPT_TIMEOUT, 15);
        curl_easy_setopt(task.handle, CURLOPT_DNS_CACHE_TIMEOUT, 3600);
        curl_easy_setopt(task.handle, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
    }

    curl_easy_setopt(task.handle, CURLOPT_SSL_VERIFYPEER, 0);
    curl_easy_setopt(task.handle, CURLOPT_SSL_VERIFYHOST, 0);

    if ([[AppEnvironment getInstance] getEnviroment] != App_Release) {
        curl_easy_setopt(task.handle, CURLOPT_VERBOSE, 1);
    }

    curl_easy_setopt(task.handle, CURLOPT_NOSIGNAL, 1);
    curl_easy_setopt(task.handle, CURLOPT_TCP_KEEPALIVE, 1);
    curl_easy_setopt(task.handle, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_2_0);

    curl_easy_setopt(task.handle, CURLOPT_SSL_ENABLE_NPN, 1);
    curl_easy_setopt(task.handle, CURLOPT_SSL_ENABLE_ALPN, 1);
    
    [task prepareHandle];
    
    [self configProxy:task];
    
    [_taskArray addObject:task];
    curl_easy_setopt(task.handle, CURLOPT_CLOSESOCKETFUNCTION, on_curl_closesocket_callback);
    task->timeStamp = [[NSDate date] timeIntervalSince1970];
    curl_multi_add_handle(_curl_mhandle, task.handle);
}

- (void)cancelTask:(NeoNetTask *)task {
    [[NeoDNSEngine getInstance] asyncCancelLookup:task];
    [self performSelector:@selector(onCancelTask:)
                 onThread:[NSThread currentThread]
               withObject:task waitUntilDone:NO];
}

- (void)onCancelTask:(NeoNetTask *)task {
    NSString *key = [NSString stringWithFormat:@"%d", task->socket];
    NeoSocketContext *context = [_socketDic valueForKey:key];
    if (context) {
        [context DecrReferanceCount];
        if ([context referanceCount] == 0) {
            [context disableSocketCallback];
            [_socketDic removeObjectForKey:key];
        }
    }
    curl_multi_remove_handle(_curl_mhandle, task.handle);
    [_taskArray removeObject:task];
}

- (void)onTimeoutTask:(NeoNetTask *)task {
    NSString *key = [NSString stringWithFormat:@"%d", task->socket];
    [_socketDic removeObjectForKey:key];
    
    curl_multi_remove_handle(_curl_mhandle, task.handle);
    [self processTaskFailed:task];
}

- (void)processTaskFailed:(NeoNetTask*)task {
    NSString *key = [NSString stringWithFormat:@"%d", task->socket];
    NeoSocketContext *context = [_socketDic valueForKey:key];
    if (context) {
        [context DecrReferanceCount];
        if ([context referanceCount] == 0) {
            [context disableSocketCallback];
            [_socketDic removeObjectForKey:key];
        }
    }
    [task taskFailed];
    [_taskArray removeObject:task];
}

- (void)processTaskFinish:(NeoNetTask *)task {
    NSString *key = [NSString stringWithFormat:@"%d", task->socket];
    NeoSocketContext *context = [_socketDic objectForKey:key];
    if (context) {
        [context DecrReferanceCount];
        CFRunLoopRef runloop = [[NSRunLoop currentRunLoop] getCFRunLoop];
        CFRunLoopRemoveSource(runloop, context->sourceRef, kCFRunLoopCommonModes);
    }

    [task taskFinish];
    [_taskArray removeObject:task];
}

- (NeoNetTask *)findNeoNetTask:(CURL*)handle {
    for (NeoNetTask *task in _taskArray) {
        if (task.handle == handle) {
            return task;
        }
    }
    return nil;
}

- (int)handle:(CURL *)easy
       socket:(curl_socket_t)socket
       action:(int)action
        userp:(void *)userp
       scketp:(void*)socketp {
    NeoNetTask *task = [self findNeoNetTask:easy];
    NeoSocketContext *context = (NeoSocketContext*)socketp;

    if ((action == CURL_POLL_IN || action == CURL_POLL_OUT)
        && task ) {
        if (socketp == nil) {
            if (task && task->socket == 0 && socket != 0) {
                task->socket = socket;
                task->timeStamp = [[NSDate date] timeIntervalSince1970];
                context = [self generateSocketContext:task];
                assert(context != nil);
            }
            curl_multi_assign(_curl_mhandle, socket, context);
        }
    }
    return 0;
}

- (void)socket:(CFSocketRef)socket
  callbackType:(CFSocketCallBackType)type
       address:(CFDataRef)address
          data:(const void*)data
          info:(void*)info {
    int running_handles;
    int flags = 0;

    if (type & kCFSocketReadCallBack)
        flags = CURL_CSELECT_IN;
    if (type & kCFSocketWriteCallBack)
        flags = CURL_CSELECT_OUT;
    
    NeoSocketContext *context = [_socketDic valueForKey:[NSString stringWithFormat:@"%d", CFSocketGetNative(socket)]];
    if (context && context->task && address && data) {
        context->task->timeStamp = [[NSDate date] timeIntervalSince1970];
    }
    if (context && context->socketRef && CFSocketIsValid(context->socketRef)) {
        curl_multi_socket_action(_curl_mhandle, context->socket, flags,
                                 &running_handles);
    }
    [self checkCurlMutilQueue];
}

- (int)closeSocket:(socklen_t)socket {
    NSString *key = [NSString stringWithFormat:@"%d", socket];
    NeoSocketContext *context = [_socketDic objectForKey:key];
    if (context == nil) {
        return 1;
    }
    [_socketDic removeObjectForKey:key];
    if (context->task != nil) {
        curl_multi_remove_handle(_curl_mhandle, context->task.handle);
        if (context->task.code == CURLE_OK) {
            [self processTaskFinish:context->task];
        } else {
            [self processTaskFailed:context->task];
        }
    }
    return 0;
}

- (void)checkCurlTimeout {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    for (NeoNetTask *task in _taskArray) {
        NSTimeInterval detal = now - task->timeStamp;
        if ([task checkError]) {
            NSString *key = [NSString stringWithFormat:@"%d", task->socket];
            NeoSocketContext *context = [_socketDic objectForKey:key];
            if (context) {
                if ([context referanceCount] == 0) {
                    [context disableSocketCallback];
                }
            }
            [self performSelector:@selector(onErrorTask:)
                         onThread:[NSThread currentThread]
                       withObject:task
                    waitUntilDone:NO];
        } else if (task->timeStamp != 0 && detal > _timeout) {
            NSString *key = [NSString stringWithFormat:@"%d", task->socket];
            NeoSocketContext *context = [_socketDic objectForKey:key];
            if (context) {
                if ([context referanceCount] == 0) {
                    [context disableSocketCallback];
                }
            }
            task.code = CURLE_OPERATION_TIMEDOUT;
            [self performSelector:@selector(onTimeoutTask:)
                         onThread:[NSThread currentThread]
                       withObject:task
                    waitUntilDone:NO];
        }
    }
}

- (void)onErrorTask:(NeoNetTask *)task {
    NSString *key = [NSString stringWithFormat:@"%d", task->socket];
    [_socketDic removeObjectForKey:key];
    
    if ([_taskArray containsObject:task]) {
        curl_multi_remove_handle(_curl_mhandle, task.handle);
        [task resetData];
        [self onStartTask:task];
    }
    
}

- (void)checkCurlMutilQueue {
    CURLMsg *message;
    int pending;
    
    while ((message = curl_multi_info_read(_curl_mhandle, &pending))) {
        switch (message->msg) {
            case CURLMSG_DONE: {
                NeoNetTask *task = [self findNeoNetTask:message->easy_handle];
                curl_multi_remove_handle(_curl_mhandle, message->easy_handle);
                if (task) {
                    task.code = message->data.result;
                    if (task.code == CURLE_OK) {
                        [self processTaskFinish:task];
                    } else {
                        [self processTaskFailed:task];
                    }
                }
            }
                break;
            default:
                fprintf(stderr, "CURLMSG default\n");
                abort();
        }
    }
}

- (NeoSocketContext *)generateSocketContext:(NeoNetTask *)task {
    if (task == nil) {
        return nil;
    }
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSString *key = [NSString stringWithFormat:@"%d", task->socket];
    NeoSocketContext *context = [_socketDic valueForKey:key];
    if (context) {
        if (CFSocketIsValid(context->socketRef)) {
            context->task = task;
            [context IncrReferanceCount];
            CFRunLoopRef runloop = [[NSRunLoop currentRunLoop] getCFRunLoop];
            CFRunLoopAddSource(runloop, context->sourceRef, kCFRunLoopCommonModes);
            return context;
        } else {
            [_socketDic removeObjectForKey:key];
        }
    }
    
    context = [NeoSocketContext new];
    context->bornTime = now;
    context->socket = task->socket;
    context->task = task;
    
    [context IncrReferanceCount];
    
    CFSocketContext ctxt = {0, context, NULL, NULL, NULL};
    context->socketRef = CFSocketCreateWithNative(kCFAllocatorDefault,
                                                  context->socket,
                                                  kCFSocketWriteCallBack|kCFSocketReadCallBack,
                                                  on_cfsocket_callback,
                                                  &ctxt);
    context->sourceRef = CFSocketCreateRunLoopSource(kCFAllocatorDefault, context->socketRef, 0);
    CFRunLoopRef runloop = [[NSRunLoop currentRunLoop] getCFRunLoop];
    CFRunLoopAddSource(runloop, context->sourceRef, kCFRunLoopCommonModes);
    
    [_socketDic setObject:context forKey:key];    
    return SafeAutoRelease(context);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_timer) {
        [_timer invalidate];
        SafeRelease(_timer);
    }
    [[NeoReachability getInstance] stopNotifier];
    curl_share_cleanup(_share_handle);
    curl_multi_cleanup(_curl_mhandle);
    SafeRelease(_hostThread);
    SafeRelease(_taskArray);
    SafeRelease(_socketDic);
    SafeRelease(_config);
    curl_global_cleanup();
    SafeSuperDealloc(super);
}
@end
