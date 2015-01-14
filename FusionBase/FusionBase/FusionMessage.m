//
//  FusionMessage.m
//  FusionBase
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionMessage.h"
#import "NSDictionary+JSON.h"
#import "NSURL+Utility.h"
#import "SafeARC.h"

@implementation FusionMessage
@synthesize host = _host, args = _args, relative = _relative, command = _command;
- (instancetype)init {
    self = [super init];
    if (self) {
        _scheme = SafeRetain(FusionScheme);
    }
    return self;
}


- (instancetype)initWithHost:(NSString *)host
                    relative:(NSString *)relative
                     command:(NSString *)command
                        args:(NSDictionary *)args {
    self = [super init];
    if (self) {
        _scheme = SafeRetain(FusionScheme);
        _host = SafeRetain(host);
        _relative = SafeRetain(relative);
        _args = SafeRetain(args);
        _command = SafeRetain(command);
    }
    return self;
}

- (id)initWithURL:(NSURL*)url {
    self = [super init];
    if (self) {
        assert([[url scheme] isEqualToString:FusionScheme]);
        
        _scheme = SafeRetain(FusionScheme);
        _host = SafeRetain([url host]);
        _relative = SafeRetain([[url relativePath] substringFromIndex:1]);
        
        if ([url query] && [[url query] length] > 0) {
            NSDictionary *queryDic = [NSURL parserQueryText:[url query]];
            _args = SafeRetain([queryDic valueForKey:@"args"]);
        } else {
            _args = nil;
        }
        
        if ([url fragment]) {
            _command = SafeRetain([url fragment]);
        } else {
            _command = nil;
        }
    }
    return self;
}

- (NSURL *)generateURL {
    NSString *path =  nil;
    if (_args) {
        path = [NSString stringWithFormat:@"%@?args=%@#%@",_relative,[NSURL urlEncodedString:[_args jsonString]], _command];
    } else {
        path = [NSString stringWithFormat:@"%@#%@", _relative, _command];
    }
    NSURL *url = [[NSURL alloc] initWithScheme:_scheme host:_host path:path];
    return SafeAutoRelease(url);
}

- (void)dealloc {
    SafeRelease(_host);
    SafeRelease(_args);
    SafeRelease(_scheme);
    SafeRelease(_command);
    SafeRelease(_relative);
    SafeSuperDealloc(super);
}
@end
