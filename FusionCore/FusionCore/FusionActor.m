//
//  FusionActor.m
//  TestNewCore
//
//  Created by Ryou Zhang on 6/30/13.
//  Copyright (c) 2013 Ryou Zhang. All rights reserved.
//

#import "FusionActor.h"
#import "FusionNativeMessage.h"
#import "FusionCore.h"
#import "Filter/FusionFilter.h"
#import "../../Workspace/CommonHeader/SafeARC.h"

@implementation FusionActor
@synthesize name = _name;

-(id)initWithConfig:(NSDictionary *)config {
    self = [super init];
    if (self) {
        _config = SafeRetain(config);
        
        NSDictionary *filterConfig = [_config valueForKey:@"filter"];
        if (filterConfig && [filterConfig isKindOfClass:[NSNull class]] == NO) {
            _filter = [[NSClassFromString([filterConfig valueForKey:@"class"]) alloc] initWithConfig:filterConfig];
        }
    }
    return self;
}

- (BOOL)filterFusionNativeMessage:(FusionNativeMessage *)message {
    if (_filter) {
        return [_filter filterFusionNativeMessage:message];
    }
    return YES;
}

- (void)processFusionNativeMessage:(FusionNativeMessage *)message {
    
}

- (void)processCallbackMessage:(FusionNativeMessage *)message
                 ParentMessage:(FusionNativeMessage *)parent {
    if ([parent getChildrenCount] == 0)
        [parent setState:FusionNativeMessageFinish];
}

- (void)cancelFusionNativeMessage:(FusionNativeMessage *)message {
    if ([message getChildrenCount] != 0) {
        [[FusionCore getInstance] dispatchCancelMessageArray:[message getChildren]];
        [message clearSubMessage];
    }
}

-(void)dealloc {
    SafeRelease(_filter);
    SafeRelease(_config);
    SafeRelease(_name);
    SafeSuperDealloc(super);
}
@end
