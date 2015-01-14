//
//  DownloadFileActor.h
//  Trip2013
//
//  Created by 淘中天 on 13-11-26.
//  Copyright (c) 2013年 alibaba. All rights reserved.
//

#import <FusionCore/FusionCore.h>

@interface DownloadFileActor : FusionActor {
@protected
    NSMutableArray *_waitingQueue;
    NSUInteger _concurrency;
    NSMutableDictionary *_connectionDic;
    NSMutableDictionary *_clusterDic;
}

@end
