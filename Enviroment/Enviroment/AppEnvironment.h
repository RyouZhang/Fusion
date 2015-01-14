//
//  AppEnvironment.h
//  FusionApp
//
//  Created by Ryou Zhang on 1/10/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    App_Test = 0,
    App_Prepare = 1,
    App_Release = 2,
    App_LiveUpdate = 3
}Environment;

@interface AppEnvironment : NSObject {
@private
    Environment  _env;
    NSString    *_identifer;
    NSString    *_ver;
    NSString    *_buildVer;
    NSString    *_channelId;
}
+ (AppEnvironment *)getInstance;

- (Environment)getEnviroment;
- (void)setEnviroment:(Environment)env;

- (void)setClientVersion:(NSString*)ver;
- (NSString *)getClientVersion;

- (void)setBuildVersion:(NSString*)ver;
- (NSString *)getBuildVersion;

- (void)setApplicationIdentifier:(NSString *)identifer;
- (NSString *)getApplicationIdentifier;

- (void)setChannelId:(NSString*)channelId;
@end
