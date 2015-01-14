//
//  FusionService.m
//  TestNewCore
//
//  Created by Ryou Zhang on 6/30/13.
//  Copyright (c) 2013 Ryou Zhang. All rights reserved.
//

#import "FusionService.h"
#import "FusionNativeMessage.h"
#import "FusionActor.h"
#import "FusionCore.h"
#import "FusionFilter.h"
#import "SafeARC.h"

@implementation FusionService
@synthesize name = _name, threadType = _threadType;
- (id)initWithConfig:(NSDictionary *)config {
    self = [super init];
    if (self) {
        if([config valueForKey:@"thread_type"])
            _threadType = (FusionServiceThreadType)[[config valueForKey:@"thread_type"] unsignedIntegerValue];
        else
            _threadType = FusionService_Default;
        
        _config = SafeRetain(config);
        
        _actorDic = [NSMutableDictionary new];
        
        NSDictionary *filterConfig = [_config valueForKey:@"filter"];
        if (filterConfig && [filterConfig isKindOfClass:[NSNull class]] == NO) {
            _filter = [[NSClassFromString([filterConfig valueForKey:@"class"]) alloc] initWithConfig:filterConfig];
        }
    }
    return self;
}

- (BOOL)checkFusionActorValid:(FusionNativeMessage *)message {
    id target = [_actorDic objectForKey:[message actor]];
    if (target != nil)
        return YES;
    
    NSDictionary *config = [[_config valueForKey:@"actors"] valueForKey:[message actor]];
    if (config == nil)
        return NO;
    
    Class actorClass = NSClassFromString([config valueForKey:@"class"]);
    if ([actorClass isSubclassOfClass:[FusionActor class]] == NO)
        return NO;
    FusionActor *actor = [[actorClass alloc] initWithConfig:config];
    [actor setName:[message actor]];
    [_actorDic setValue:actor forKey:[actor name]];
    SafeRelease(actor);
    return YES;
}

-(BOOL)filterFusionNativeMessage:(FusionNativeMessage *)message {
    BOOL flag = YES;
    if (_filter) {
        flag = [_filter filterFusionNativeMessage:message];
    }
    return !flag;
}

- (BOOL)canConcurrentExecute:(FusionNativeMessage*)message {
    return YES;
}

- (void)processFusionNativeMessage:(FusionNativeMessage *)message {
    SafeAutoReleasePoolStart
    FusionActor *actor = [_actorDic valueForKey:[message actor]];
    if ([actor filterFusionNativeMessage:message])
        [actor processFusionNativeMessage:message];
    else
        [message setState:FusionNativeMessageFailed];
    SafeAutoReleasePoolEnd
}

- (void)processCallbackFusionNativeMessage:(FusionNativeMessage *)message {
    SafeAutoReleasePoolStart
    FusionNativeMessage *parent = SafeRetain(message.parent);
    if (parent != nil) {
        FusionActor *actor = [_actorDic valueForKey:[parent actor]];
        message = SafeRetain(message);
        [parent removeSubMessage:message];
        [actor processCallbackMessage:message ParentMessage:parent];
        SafeRelease(message);
        SafeRelease(parent);
    }
    SafeAutoReleasePoolEnd
}

- (void)processCancelFusionNativeMessage:(FusionNativeMessage *)message {
    SafeAutoReleasePoolStart
    FusionActor *actor = [_actorDic valueForKey:[message actor]];
    [actor cancelFusionNativeMessage:message];
    SafeAutoReleasePoolEnd
}

-(void)dealloc {
    SafeRelease(_filter);
    SafeRelease(_actorDic);
    SafeRelease(_config);
    SafeRelease(_name);
    SafeSuperDealloc(super);
}
@end
