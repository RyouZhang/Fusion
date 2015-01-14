//
//  DownloadFileCluster.m
//  Trip2013
//
//  Created by 淘中天 on 13-11-26.
//  Copyright (c) 2013年 alibaba. All rights reserved.
//

#import "DownloadFileCluster.h"
#import "SafeARC.h"

@implementation DownloadFileCluster
@synthesize downloadParams = _downloadParams;

- (id)init {
    self = [super init];
    if (self) {
        _downloadParams = [NSMutableDictionary new];
        _messageList = [NSMutableArray new];
    }
    return self;
}

- (void)pushNativeMessage:(FusionNativeMessage *)message {
    [_messageList addObject:message];
}

- (void)removeNativeMessage:(FusionNativeMessage *)message {
    [_messageList removeObject:message];
}

- (NSUInteger)messagesCount {
    return _messageList.count;
}

- (void)removeAllMessages {
    [_messageList removeAllObjects];
}

- (NSMutableArray *)getMessageList {
    return _messageList;
}

- (void)dealloc {
    SafeRelease(_messageList);
    SafeRelease(_downloadParams);
    SafeSuperDealloc(super);
}

@end
