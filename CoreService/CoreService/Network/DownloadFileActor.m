//
//  DownloadFileActor.m
//  Trip2013
//
//  Created by 淘中天 on 13-11-26.
//  Copyright (c) 2013年 alibaba. All rights reserved.
//

#import "DownloadFileActor.h"
#import "DownloadFileCluster.h"
#import "NeoHttpDownloadTask.h"
#import "NeoNetEngine.h"
#import "NetworkCommon.h"
#import <Utility/Utility.h>
#import "SafeARC.h"

@implementation DownloadFileActor

- (id)initWithConfig:(NSDictionary *)config {
    self = [super initWithConfig:config];
    if (self) {
        _waitingQueue = [NSMutableArray new];
        _connectionDic = [NSMutableDictionary new];
        _clusterDic = [NSMutableDictionary new];
        _concurrency = 16;
    }
    return self;
}

- (void)processFusionNativeMessage:(FusionNativeMessage *)message {
    BOOL forceDownload = NO;
    
    NSString *localPath = [message.params valueForKey:NET_LOCAL_PATH];
    if ([message.params valueForKey:NET_FORCE_DOWNLOAD]) {
        forceDownload = [[message.params valueForKey:NET_FORCE_DOWNLOAD] boolValue];
    }
    
    if ([[FileKit getInstance] isFileExist:localPath] && forceDownload == NO) {
        [[FileKit getInstance] updateFileModifyTime:localPath];
        [message setState:FusionNativeMessageFinish];
        return;
    }
    
    NSString *url = [message.params valueForKey:NET_REMOTE_URL];
    if (url == nil || [NSURL URLWithString:url] == nil) {
        [message setErrorDomainCode:ERROR_DOMAIN_NETWORK
                          errorCode:ERROR_INVALID_URL
                           errorMsg:@"无效的URL"];
        [message setState:FusionNativeMessageFailed];
        return;
    }
    
    NSDictionary *httpHeaders = [message.params valueForKey:NET_HTTP_HEADER];
    NSString *httpMethod = [message.params valueForKey:NET_HTTP_METHOD];
    
    NSString *tempPath = [message.params valueForKey:NET_TEMP_PATH];
    if (tempPath == nil || tempPath.length == 0) {
        tempPath = [FileHelper getTempPath:url];
    }
    
    DownloadFileCluster *cluster = [_clusterDic valueForKey:url];
    if (cluster == nil) {
        cluster = [[DownloadFileCluster alloc] init];
        [cluster.downloadParams setValue:url forKey:NET_REMOTE_URL];
        [cluster.downloadParams setValue:localPath forKey:NET_LOCAL_PATH];
        [cluster.downloadParams setValue:tempPath forKey:NET_TEMP_PATH];
        if (httpHeaders != nil) {
            [cluster.downloadParams setValue:httpHeaders forKey:NET_HTTP_HEADER];
        }
        if (httpMethod != nil) {
            [cluster.downloadParams setValue:httpMethod forKey:NET_HTTP_METHOD];
        }
        
        [cluster pushNativeMessage:message];
        
        [_clusterDic setValue:cluster forKey:url];
        [_waitingQueue addObject:cluster];
        SafeRelease(cluster);
        [self schedulerDownloadConnection];
    } else {
        [cluster pushNativeMessage:message];
    }
}

- (void)schedulerDownloadConnection {
    @autoreleasepool {
        while ([_connectionDic count] < _concurrency) {
            if([_waitingQueue count] == 0) break;
            
            DownloadFileCluster *cluster = SafeRetain([_waitingQueue objectAtIndex:0]);
            [_waitingQueue removeObjectAtIndex:0];
            
            NeoHttpDownloadTask *task = [NeoHttpDownloadTask new];
            [task setUrl:[NSURL URLWithString:[cluster.downloadParams valueForKey:NET_REMOTE_URL]]];
            [task setCachePath:[cluster.downloadParams valueForKey:NET_TEMP_PATH]];
            [task setTargetPath:[cluster.downloadParams valueForKey:NET_LOCAL_PATH]];
            [task setHeaderDic:[cluster.downloadParams valueForKey:NET_HTTP_HEADER]];
            
            [task setSource:cluster];
            [_connectionDic setObject:task forKey:[NSValue valueWithPointer:(__bridge const void *)(cluster)]];
            SafeRelease(cluster);
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(processNeoDownloadTaskFinish:)
                                                         name:NeoNetTask_Finish
                                                       object:task];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(processNeoDownloadTaskFailed:)
                                                         name:NeoNetTask_Failed
                                                       object:task];
            [[NeoNetEngine getInstance] startTask:task];
            SafeRelease(task);
        }
    }
}

- (void)processNeoDownloadTaskFinish:(NSNotification*)notify {
    NeoHttpDownloadTask *task = [notify object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NeoNetTask_Failed object:task];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NeoNetTask_Finish object:task];
    
    DownloadFileCluster *cluster = SafeRetain([task source]);
    [task setSource:nil];
    [_connectionDic removeObjectForKey:[NSValue valueWithPointer:(__bridge const void *)(cluster)]];
    
    if (cluster == nil) {
        [self schedulerDownloadConnection];
        return;
    }
    
    NSDictionary *responseHeader = [task responseHeader];
    NSString *location = [responseHeader valueForKey:@"Location"];
    if (location == nil) {
        location = [responseHeader valueForKey:@"location"];
    }
    
    NSUInteger statusCode = [task getResponseCode];
    
    if ((statusCode == 302 || statusCode == 301) && location) {
        if ([[FileKit getInstance] isFileExist:[cluster.downloadParams valueForKey:NET_TEMP_PATH]]) {
            [[FileKit getInstance] deleteFile:[cluster.downloadParams valueForKey:NET_TEMP_PATH]];
        }        
        NeoHttpDownloadTask *task = [NeoHttpDownloadTask new];
        [task setUrl:[NSURL URLWithString:location]];
        [task setCachePath:[cluster.downloadParams valueForKey:NET_TEMP_PATH]];
        [task setTargetPath:[cluster.downloadParams valueForKey:NET_LOCAL_PATH]];
        [task setSource:cluster];
        [_connectionDic setObject:task forKey:[NSValue valueWithPointer:(__bridge const void *)(cluster)]];
        SafeRelease(cluster);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(processNeoDownloadTaskFinish:)
                                                     name:NeoNetTask_Finish
                                                   object:task];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(processNeoDownloadTaskFailed:)
                                                     name:NeoNetTask_Failed
                                                   object:task];
        [[NeoNetEngine getInstance] startTask:task];
        SafeRelease(task);
    } else {
        for (FusionNativeMessage *message in [cluster getMessageList]) {
            [message setValue:[NSNumber numberWithInteger:[task getResponseCode]]
              ToDataTableWith:HTTP_RESPONSE_CODE];
            [message setValue:[task responseHeader] ToDataTableWith:HTTP_RESPONSE_HEADER];
            [message setState:FusionNativeMessageFinish];
        }
        
        [cluster removeAllMessages];
        [_clusterDic removeObjectForKey:[cluster.downloadParams valueForKey:NET_REMOTE_URL]];
        SafeRelease(cluster);
        [self schedulerDownloadConnection];
    }
}

-(void)processNeoDownloadTaskFailed:(NSNotification*)notify {
    
    NeoHttpDownloadTask *task = [notify object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NeoNetTask_Failed object:task];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NeoNetTask_Finish object:task];
    DownloadFileCluster *cluster = SafeRetain([task source]);
    [task setSource:nil];
    [_connectionDic removeObjectForKey:[NSValue valueWithPointer:(__bridge const void *)(cluster)]];
    
    if (cluster == nil) {
        [self schedulerDownloadConnection];
        return;
    }
    
    for (FusionNativeMessage *message in [cluster getMessageList]) {
        [message setValue:[NSNumber numberWithInteger:[task getResponseCode]]
          ToDataTableWith:HTTP_RESPONSE_CODE];
        [message setValue:[task responseHeader] ToDataTableWith:HTTP_RESPONSE_HEADER];
        [message setState:FusionNativeMessageFailed];
    }
    
    [cluster removeAllMessages];
    [_clusterDic removeObjectForKey:[cluster.downloadParams valueForKey:NET_REMOTE_URL]];
    SafeRelease(cluster);
    [self schedulerDownloadConnection];
}

- (void)cancelFusionNativeMessage:(FusionNativeMessage *)message {
    NSString *url = [message.params valueForKey:NET_REMOTE_URL];
    
    DownloadFileCluster *cluster = SafeRetain([_clusterDic valueForKey:url]);
    if (cluster == nil)
        return;
    
    [cluster removeNativeMessage:message];
    
    if ([cluster messagesCount] > 0) {
        SafeRelease(cluster);
        return;
    }
    
    [_clusterDic removeObjectForKey:url];
    [_waitingQueue removeObject:cluster];
    
    NeoHttpDownloadTask *task = [_connectionDic objectForKey:[NSValue valueWithPointer:(__bridge const void *)(cluster)]];
    if (task != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NeoNetTask_Failed object:task];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NeoNetTask_Finish object:task];
        [[NeoNetEngine getInstance] cancelTask:task];
        [task setSource:nil];
        [_connectionDic removeObjectForKey:[NSValue valueWithPointer:(__bridge const void *)(cluster)]];
    }
    SafeRelease(cluster);
    [self schedulerDownloadConnection];
}

-(void)dealloc {
    SafeRelease(_clusterDic);
    SafeRelease(_connectionDic);
    SafeSuperDealloc(super);
}

@end
