//
//  FusionMessage.h
//  FusionBase
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FusionScheme @"AppName"

@interface FusionMessage : NSObject {
@protected
    NSString        *_scheme;
    NSString        *_host;
    NSString        *_relative;
    NSString        *_command;
    NSDictionary    *_args;
}
@property(readonly, atomic)NSString *scheme;
@property(readonly, atomic)NSString *host;
@property(readonly, atomic)NSString *relative;
@property(readonly, atomic)NSString *command;
@property(readonly, atomic)NSDictionary *args;

- (id)initWithHost:(NSString *)host
          relative:(NSString *)relative
           command:(NSString *)command
              args:(NSDictionary *)args;

- (id)initWithURL:(NSURL*)url;

- (NSURL *)generateURL;
@end