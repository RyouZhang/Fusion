//
//  FusionNativeMessage.m
//  TestNewCore
//
//  Created by Ryou Zhang on 6/30/13.
//  Copyright (c) 2013 Ryou Zhang. All rights reserved.
//

#import "FusionNativeMessage.h"
#import "FusionCore.h"
#import "SafeARC.h"
#import <Utility/Utility.h>

@implementation FusionNativeMessage
@synthesize state = _state;
@synthesize parent = _parent;
@synthesize originThread = _originThread;
@synthesize workerNick = _workerNick;
@synthesize delay = _delay;
@synthesize triggerTime = _triggerTime;
@dynamic service;
@dynamic actor;

- (id)initWithSerivice:(NSString *)service
                 actor:(NSString *)actor
                  args:(NSDictionary *)args {
    self = [super initWithHost:service relative:actor command:nil args:args];
    if (self) {
        _delay = 0;
        _triggerTime = 0;
        
        _state = FusionNativeMessageOrigin;
        
        _dataTable = [NSMutableDictionary new];
        
        _parent = nil;
        _children = [NSMutableArray new];
    }
    return self;
}

- (NSString *)service {
    return _host;
}

-(NSString *)actor {
    return _relative;
}


- (NSArray *)getChildren {
    @synchronized(_children) {
        return _children;
    }
}

- (NSInteger)getChildrenCount {
    @synchronized(_children) {
        return [_children count];
    }
}

- (void)insertSubMessage:(FusionNativeMessage *)message {
    @synchronized(_children) {
        assert(message.parent == nil);
        if ([_children containsObject:message])
            return;
        message->_parent = SafeRetain(self);
        [_children addObject:message];
    }
}

- (void)removeSubMessage:(FusionNativeMessage *)message {
    @synchronized(_children) {
        if (NO == [_children containsObject:message])
            return;
        [_children removeObject:message];
        SafeRelease(message->_parent);
    }
}

- (void)clearSubMessage {
    @synchronized(_children) {
        [_children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SafeRelease(((FusionNativeMessage*)obj)->_parent);
        }];
        [_children removeAllObjects];
    }
}

- (id)getValueFromDataTableWith:(NSString *)key {
    @synchronized(_dataTable) {
        return [_dataTable valueForKey:key];
    }
}

- (void)setValue:(id)value ToDataTableWith:(NSString *)key {
    @synchronized(_dataTable) {
        [_dataTable setValue:value forKey:key];
    }
}

- (void)removeValueFromDataTableWith:(NSString *)key {
    @synchronized(_dataTable) {
        [_dataTable removeObjectForKey:key];
    }
}

- (id)getDataTable {
    @synchronized(_dataTable) {
        return _dataTable;
    }
}

- (void)clearDataTable {
    @synchronized(_dataTable) {
        [_dataTable removeAllObjects];
    }
}

- (void)importToDataTable:(NSDictionary *)params {
    @synchronized(_dataTable) {
        [[params allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
           [_dataTable setValue:[params valueForKey:obj]
                         forKey:obj];
        }];
    }
}

- (void)setState:(NSUInteger)state {
    if (_state == state) {
        return;
    }
    _state = state;
    if (_state == FusionNativeMessageFinish ||
        _state == FusionNativeMessageFailed) {
        if ([self getChildrenCount] != 0) {
            [[FusionCore getInstance] dispatchCancelMessageArray:[self getChildren]];
            [self clearSubMessage];
        }
    }
    switch (_state) {
        case FusionNativeMessageFinish: {
            if (_parent == nil) {
                if (_originThread)
                    [self performSelector:@selector(processFusionNativeMessageCallback:)
                                 onThread:_originThread
                               withObject:self
                            waitUntilDone:NO];
            } else {
                [[FusionCore getInstance] dispatchCallbackFusionNativeMessage:self];
            }
        }
            break;
        case FusionNativeMessageFailed: {
            if (_parent == nil) {
                if (_originThread)
                    [self performSelector:@selector(processFusionNativeMessageCallback:)
                                 onThread:_originThread
                               withObject:self
                            waitUntilDone:NO];
            } else {
                [[FusionCore getInstance] dispatchCallbackFusionNativeMessage:self];
            }
        }
            break;
        default:
            break;
    }
}

- (void)processFusionNativeMessageCallback:(FusionNativeMessage *)message {
    [[NSNotificationCenter defaultCenter] postNotificationName:FusionNativeMessageNotification
                                                        object:message];
}

- (void)dealloc {
    SafeRelease(_workerNick);
    SafeRelease(_originThread);
    SafeRelease(_dataTable);
    SafeRelease(_children);
    SafeRelease(_parent);
    SafeSuperDealloc(super);
}
@end
