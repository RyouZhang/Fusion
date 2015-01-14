//
//  AppUserDefault.m
//  FusionApp
//
//  Created by Ryou Zhang on 1/10/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "AppUserDefault.h"
#import "SafeARC.h"

@interface AppUserDefault() {
@private
    NSUserDefaults *_userDefault;
}
@end

@implementation AppUserDefault
static AppUserDefault *_AppUserDefault_Instance = nil;
+ (AppUserDefault *)getInstance {
    @synchronized(self) {
        if (_AppUserDefault_Instance == nil) {
            _AppUserDefault_Instance = [AppUserDefault new];
        }
    }
    return _AppUserDefault_Instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _userDefault = SafeRetain([NSUserDefaults standardUserDefaults]);
    }
    return self;
}

- (id)getValueWithKey:(NSString*)key {
    return nil;
}

- (void)setValue:(id)value withKey:(NSString *)key {
    [_userDefault setValue:value forKeyPath:key];
    [_userDefault synchronize];
}

- (void)dealloc {
    SafeSuperDealloc(super);
}
@end
