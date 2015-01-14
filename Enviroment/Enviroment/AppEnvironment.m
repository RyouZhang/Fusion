//
//  AppEnvironment.m
//  FusionApp
//
//  Created by Ryou Zhang on 1/10/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "AppEnvironment.h"
#import "SafeARC.h"

@implementation AppEnvironment
static AppEnvironment *_AppEnvironment_Instance = nil;
+ (AppEnvironment *)getInstance {
    @synchronized(self) {
        if (_AppEnvironment_Instance == nil) {
            _AppEnvironment_Instance = [AppEnvironment new];
        }
    }
    return _AppEnvironment_Instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _env = App_Release;
    }
    return self;
}

- (Environment)getEnviroment {
    return _env;
}
- (void)setEnviroment:(Environment)env {
    _env = env;
}

- (void)setClientVersion:(NSString*)ver {
    if (_ver == nil)
        _ver = SafeRetain(ver);
}

- (NSString *)getClientVersion {
    return _ver;
}

- (void)setBuildVersion:(NSString*)ver {
    if (_buildVer == nil) {
        _buildVer = SafeRetain(ver);
    }
}

- (NSString *)getBuildVersion {
    return _buildVer;
}

- (void)setApplicationIdentifier:(NSString *)identifer {
    if (_identifer == nil) {
        _identifer = SafeRetain(identifer);
    }
}

- (NSString *)getApplicationIdentifier {
    return _identifer;
}

- (void)setChannelId:(NSString*)channelId {
    if (_channelId == nil)
        _channelId = SafeRetain(channelId);
}
- (void)dealloc {
    SafeRelease(_identifer);
    SafeRelease(_ver);
    SafeRelease(_buildVer);
    SafeRelease(_channelId);
    SafeSuperDealloc(super);
}
@end