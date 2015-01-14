//
//  NeoDNSEngine.m
//  CoreService
//
//  Created by Ryou Zhang on 12/4/14.
//  Copyright (c) 2014 trip.taobao.com. All rights reserved.
//

#import "NeoDNSEngine.h"
#import "NeoNetTask.h"
#import "DNSSocketContext.h"
#import "NeoReachability.h"
#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <netdb.h>
#import "../libares/ares.h"
#import "SafeARC.h"

#define RESOLVE_START_TIME  @"start"
#define RESOLVE_ADDRESS     @"resolve"
#define MAX_DNS_VALID_TIME  3600

@interface NeoDNSEngine() {
@private
    NSMutableDictionary *_wifiCacheDic;
    NSMutableDictionary *_wwanCacheDic;
    NSMutableDictionary *_waittingDic;
    
    NSMutableArray      *_socketArray;
    
    NetworkStatus       _networkStatus;
    ares_channel        _channel;
}

- (NSInteger)onAresCreateSocket:(ares_socket_t)socket_fd
                           type:(int)type
                        channel:(void *)channel;

- (void)onAresHostCallback:(NSString *)host
                   address:(NSString *)address;
@end

int
on_ares_sock_create_callback(ares_socket_t socket_fd,
                             int type,
                             void *data) {
    return [[NeoDNSEngine getInstance] onAresCreateSocket:socket_fd type:type channel:data];
}

void
on_dns_cfsocket_callback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    ares_channel channel = (ares_channel)info;
    if (type & kCFSocketReadCallBack) {
        ares_process_fd(channel, CFSocketGetNative(s), ARES_SOCKET_BAD);
    } else if (type & kCFSocketWriteCallBack) {
        ares_process_fd(channel, ARES_SOCKET_BAD, CFSocketGetNative(s));
    }
}

void on_ares_host_callback(void *arg,
                           int status,
                           int timeouts,
                           struct hostent *hostent) {
    if (status != ARES_SUCCESS) {
        [[NeoDNSEngine getInstance] onAresHostCallback:arg address:nil];
        return;
    }
    char buf[128];
    inet_ntop(hostent->h_addrtype, hostent->h_addr, buf, sizeof(buf));
    NSString *address = [NSString stringWithCString:buf encoding:NSASCIIStringEncoding];
    [[NeoDNSEngine getInstance] onAresHostCallback:arg address:address];
}

@implementation NeoDNSEngine
static NeoDNSEngine *_NeoDNSEngine_Instance = nil;
+ (NeoDNSEngine *)getInstance {
    @synchronized(self) {
        if(_NeoDNSEngine_Instance == nil)
            _NeoDNSEngine_Instance = [NeoDNSEngine new];
    }
    return _NeoDNSEngine_Instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _wifiCacheDic = [NSMutableDictionary new];
        _wwanCacheDic = [NSMutableDictionary new];

        _socketArray = [NSMutableArray new];
        
        _waittingDic = [NSMutableDictionary new];

        ares_library_init(ARES_LIB_INIT_ALL);
        
        struct ares_options options;
        options.timeout = 1;
        options.flags = ARES_FLAG_IGNTC|ARES_FLAG_STAYOPEN;
        ares_init_options(&_channel, &options, ARES_OPT_FLAGS|ARES_OPT_TIMEOUT);
        ares_set_servers_csv(_channel, "223.6.6.6,223.5.5.5");
        ares_set_socket_callback(_channel, on_ares_sock_create_callback, _channel);
    }
    return self;
}

- (NSInteger)onAresCreateSocket:(ares_socket_t)socket_fd
                           type:(int)type
                        channel:(void *)channel {
    NSMutableArray *deleteArray = [NSMutableArray new];
    DNSSocketContext *target = nil;
    for (DNSSocketContext *context in _socketArray) {
        if (CFSocketIsValid(context->socketRef) == NO) {
            [deleteArray addObject:context];
        } else if (context->socket == socket_fd) {
            target = context;
        }
    }
    [_socketArray removeObjectsInArray:deleteArray];
    SafeRelease(deleteArray);
    
    if (target) {
        return 0;
    }
    
    CFSocketContext ctxt = {0, channel, NULL, NULL, NULL};
    target = [DNSSocketContext new];
    target->socket = socket_fd;
    target->socketRef = CFSocketCreateWithNative(kCFAllocatorDefault,
                                                 target->socket,
                                                 kCFSocketReadCallBack|kCFSocketWriteCallBack|kCFSocketConnectCallBack,
                                                 on_dns_cfsocket_callback,
                                                 &ctxt);
    target->sourceRef = CFSocketCreateRunLoopSource(kCFAllocatorDefault, target->socketRef, 0);
    CFRunLoopRef runloop = [[NSRunLoop currentRunLoop] getCFRunLoop];
    CFRunLoopAddSource(runloop, target->sourceRef, kCFRunLoopCommonModes);
    [_socketArray addObject:target];
    SafeRelease(target);
    return 0;
}

- (void)onAresHostCallback:(NSString *)host
                   address:(NSString *)address {
    if (address) {
        NSMutableDictionary *info = [NSMutableDictionary new];
        [info setValue:address forKey:RESOLVE_ADDRESS];
        [info setValue:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]
                forKey:RESOLVE_START_TIME];
        
        NSMutableDictionary *targetDic = nil;
        if ([[NeoReachability getInstance] currentReachabilityStatus] == kReachableViaWWAN) {
            targetDic = _wwanCacheDic;
        } else {
            targetDic = _wifiCacheDic;
        }
        
        NSMutableDictionary *cacheInfo = [targetDic valueForKey:host];
        if (cacheInfo == nil) {
            [targetDic setValue:info forKey:host];
        } else {
            NSTimeInterval startTime = [[cacheInfo valueForKey:RESOLVE_START_TIME] doubleValue];
            if ([[NSDate date] timeIntervalSince1970] > startTime + MAX_DNS_VALID_TIME ) {
                [targetDic setValue:info forKey:host];
            } else {
                SafeRelease(info);
                info = SafeRetain(cacheInfo);
            }
        }
        
        NSMutableArray *array = [_waittingDic valueForKey:host];
        for (NeoNetTask *task in array) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NeoDNSEngineLookupFinsih
                                                                object:task
                                                              userInfo:info];
        }
        SafeRelease(info);
    }
    [_waittingDic removeObjectForKey:host];
    SafeRelease(host);
}

- (NSString *)findResolveInfo:(NSString *)host {
    NSMutableDictionary *targetDic = nil;
    if ([[NeoReachability getInstance] currentReachabilityStatus] == kReachableViaWWAN) {
        targetDic = _wwanCacheDic;
    } else {
        targetDic = _wifiCacheDic;
    }
    
    NSDictionary *info = [targetDic valueForKey:host];
    if (info == nil) {
        return nil;
    }
    
    NSTimeInterval startTime = [[info valueForKey:RESOLVE_START_TIME] doubleValue];
    if ([[NSDate date] timeIntervalSince1970] > startTime + MAX_DNS_VALID_TIME ) {
        [targetDic removeObjectForKey:host];
        return nil;
    }
    return [NSString stringWithFormat:@"%@:%@", host, [info valueForKey:RESOLVE_ADDRESS]];
}

- (void)asyncStartLookup:(NeoNetTask *)task {
    NSString *host = SafeRetain([[task url] host]);
    NSMutableArray *array = [_waittingDic valueForKey:host];
    if (array) {
        [array addObject:task];
    } else {
        array = [NSMutableArray new];
        [_waittingDic setValue:array forKey:host];
        [array addObject:task];
        SafeRelease(array);
        
        ares_gethostbyname(_channel, [host cStringUsingEncoding:NSUTF8StringEncoding], AF_INET, on_ares_host_callback, host);
    }
}

- (void)asyncCancelLookup:(NeoNetTask *)task {
    NSString *host = [[task url] host];
    NSMutableArray *array = [_waittingDic valueForKey:host];
    [array removeObject:task];
    if ([array count] == 0) {
        [_waittingDic removeObjectForKey:host];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SafeRelease(_socketArray);
    SafeRelease(_waittingDic);
    SafeRelease(_wwanCacheDic);
    SafeRelease(_wifiCacheDic);
    ares_destroy(_channel);
    ares_library_cleanup();
    SafeSuperDealloc(super);
}
@end
