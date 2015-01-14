//
//  DownloadFileCluster.h
//  Trip2013
//
//  Created by 淘中天 on 13-11-26.
//  Copyright (c) 2013年 alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FusionCore/FusionCore.h>

@interface DownloadFileCluster : NSObject {
@private
    NSMutableDictionary *_downloadParams;
    NSMutableArray *_messageList;
}
@property (atomic, strong) NSMutableDictionary *downloadParams;

- (void)pushNativeMessage:(FusionNativeMessage *)message;
- (void)removeNativeMessage:(FusionNativeMessage *)message;
- (void)removeAllMessages;

- (NSUInteger)messagesCount;
- (NSMutableArray *)getMessageList;

@end
