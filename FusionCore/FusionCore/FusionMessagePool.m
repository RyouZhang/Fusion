//
//  FusionMessagePool.m
//  FusionCore
//
//  Created by Ryou Zhang on 12/26/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import "FusionMessagePool.h"
#import "FusionNativeMessage.h"
#import "FusionCore.h"
#import "FusionService.h"
#import "SafeARC.h"

@interface FusionMessagePool(){
@private
    NSMutableArray      *_messageRing;
    NSMutableDictionary *_messageDic;
    
    NSMutableDictionary *_callbackDic;
    NSMutableDictionary *_cancelDic;
}
@end


@implementation FusionMessagePool
- (instancetype)init {
    self = [super init];
    if (self) {
        _messageDic = [NSMutableDictionary new];
        _messageRing = [NSMutableArray new];
        
        _callbackDic = [NSMutableDictionary new];
        _cancelDic = [NSMutableDictionary new];
    }
    return self;
}

- (void)sendMessage:(FusionNativeMessage*)message {    
    NSString *key = [NSString stringWithFormat:@"%@::%@", message.service, message.actor];
    NSMutableArray *target = [_messageDic valueForKey:key];
    if (target) {
        [target addObject:message];
    } else {
        target = [NSMutableArray arrayWithObject:message];
        [_messageDic setValue:target forKey:key];
        [_messageRing addObject:key];
    }
}

- (void)sendMessageArray:(NSArray*)messageArray {
    for (FusionNativeMessage *message in messageArray) {
        [self sendMessage:message];
    }
}

- (void)callbackMessage:(FusionNativeMessage *)message {
    assert(message.parent.workerNick);
    NSMutableArray *target = [_callbackDic valueForKey:message.parent.workerNick];
    if (target) {
        [target addObject:message];
    } else {
        target = [NSMutableArray arrayWithObject:message];
        [_callbackDic setValue:target forKey:message.parent.workerNick];
    }
}

- (void)callbackMessageArray:(NSArray *)messageArray {
    for (FusionNativeMessage *message in messageArray) {
        [self callbackMessage:message];
    }
}

- (void)cancelMessage:(FusionNativeMessage *)message {
    NSString *key = [NSString stringWithFormat:@"%@::%@", message.service, message.actor];
    NSMutableArray *target = [_messageDic valueForKey:key];
    if (target) {
        [target removeObject:message];
        if ([target count] == 0) {
            [_messageDic removeObjectForKey:key];
            [_messageRing removeObject:key];
            return;
        }
    }
    
    target = [_cancelDic valueForKey:message.workerNick];
    if (target) {
        [target addObject:message];
    } else {
        target = [NSMutableArray arrayWithObject:message];
        [_cancelDic setValue:target forKey:message.workerNick];
    }
}

- (void)cancelMessageArray:(NSArray *)messageArray {
    for (FusionNativeMessage *message in messageArray) {
        [self cancelMessage:message];
    }
}

- (FusionNativeMessage *)fetchMessageForWorker:(NSString *)nickName messageLevel:(NSUInteger*)level {
    //cancel
    NSUInteger index = 0;
    NSMutableArray *target = [_cancelDic valueForKey:nickName];
    while (target && [target count] > 0 && index < [target count]) {
        FusionNativeMessage *message = SafeRetain([target objectAtIndex:index]);
        FusionService *service = [[FusionCore getInstance] checkFusionServiceValid:message];
        if (service == nil) {
            [target removeObject:message];
            SafeRelease(message);
            continue;
        }
        if(NO == [service canConcurrentExecute:message]) {
            SafeRelease(message);
            index++;
            continue;
        }
        [target removeObject:message];
        *level = Cancel_FusionCore_Level;
        return SafeAutoRelease(message);
    }
    
    //callback
    index = 0;
    target = [_callbackDic valueForKey:nickName];
    while (target && [target count] > 0 && index < [target count]) {
        FusionNativeMessage *message = SafeRetain([target objectAtIndex:index]);
        if (message.parent == nil) {
            [target removeObject:message];
            SafeRelease(message);
            continue;
        }
        FusionService *service = [[FusionCore getInstance] checkFusionServiceValid:message.parent];
        if (service == nil) {
            [target removeObject:message];
            SafeRelease(message);
            continue;
        }
        if(NO == [service canConcurrentExecute:message.parent]) {
            SafeRelease(message);
            index++;
            continue;
        }
        [target removeObject:message];
        *level = Callback_FusionCore_Level;
        return SafeAutoRelease(message);
    }
    
    //normal
    for (NSString *key in _messageRing) {
        target = [_messageDic valueForKey:key];
        index = 0;
        while ([target count] > 0 && index < [target count]) {
            FusionNativeMessage *message = SafeRetain([target objectAtIndex:index]);
            FusionService *service = [[FusionCore getInstance] checkFusionServiceValid:message];
            if (service == nil) {
                [target removeObject:message];
                [message setState:FusionNativeMessageFailed];
                SafeRelease(message);
                continue;
            }
            if(NO == [service canConcurrentExecute:message]) {
                SafeRelease(message);
                index++;
                continue;
            }
            [target removeObject:message];
            if ([target count] == 0) {
                [_messageDic removeObjectForKey:key];
                [_messageRing removeObject:key];
            } else {
                [_messageRing removeObject:key];
                [_messageRing addObject:key];
            }            
            *level = Normal_FusionCore_Level;            
            return SafeAutoRelease(message);
        }
    }
    return nil;
}

- (void)dealloc {
    SafeRelease(_callbackDic);
    SafeRelease(_cancelDic);
    SafeRelease(_messageRing);
    SafeRelease(_messageDic);
    SafeSuperDealloc(super);
}
@end
