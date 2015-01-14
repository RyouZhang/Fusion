//
//  FusionPageMessage.m
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionPageMessage.h"
#import "FusionNaviAnimeHelper.h"
#import "SafeARC.h"

@implementation FusionPageMessage
@synthesize callbackUrl = _callbackUrl;
@synthesize naviAnimeDirection = _naviAnimeDirection, naviAnimeType = _naviAnimeType;
@dynamic pageName;

- (id)initWithPageName:(NSString *)pageName
            pageNick:(NSString *)pageNick
             command:(NSString *)command
                args:(NSDictionary *)args
            callback:(NSURL *)callback {
    self = [super initWithHost:FusionPageHost relative:pageName command:command args:args];
    if (self) {
        if (pageNick) {
            _pageNick = SafeRetain(pageNick);
        } else {
            NSString *temp = [NSString stringWithFormat:@"%@_%.0f",_relative, [[NSDate date] timeIntervalSince1970] * 1000];
            _pageNick = SafeRetain(temp);
        }
        _callbackUrl = SafeRetain(callback);
    }
    return self;
}

- (id)initWithURL:(NSURL *)url
             args:(NSDictionary*)args {
    self = [super init];
    if (self) {
        _host = SafeRetain([url host]);
        _relative = SafeRetain([[url relativePath] substringFromIndex:1]);
        
        if ([url query] && [[url query] length] > 0) {
            NSDictionary *queryDic = [NSURL parserQueryText:[url query]];
            if ([queryDic valueForKey:@"args"]) {
                _args = SafeRetain([[queryDic valueForKey:@"args"] jsonObject]);
            }
            if ([queryDic valueForKey:@"anime_type"]) {
                _naviAnimeType = [[queryDic valueForKey:@"anime_type"] unsignedIntegerValue];
            } else {
                _naviAnimeType = SlideR2L_NaviAnime;
            }
            if ([queryDic valueForKey:@"anime_direction"]) {
                _naviAnimeDirection = [[queryDic valueForKey:@"anime_direction"] unsignedIntegerValue];
            } else {
                _naviAnimeDirection = FusionNaviAnimeForward;
            }
            if ([queryDic valueForKey:@"destory"]) {
                _isDestory = [[queryDic valueForKey:@"destory"] boolValue];
            } else {
                _isDestory = NO;
            }
            if ([queryDic valueForKey:@"callback"]) {
                _callbackUrl = [NSURL URLWithString:[queryDic valueForKey:@"callback"]];
            } else {
                _callbackUrl = nil;
            }
            if ([queryDic valueForKey:@"nick"]) {
                _pageNick = SafeRetain([queryDic valueForKey:@"nick"]);
            } else {
                _pageNick = SafeRetain(_relative);
            }
        } else {
            _args = nil;
            _naviAnimeType = SlideR2L_NaviAnime;
            _naviAnimeDirection = FusionNaviAnimeForward;
            _isDestory = NO;
            _callbackUrl = nil;
            _pageNick = SafeRetain(_relative);
        }
        
        if ([url fragment]) {
            _command = SafeRetain([url fragment]);
        } else {
            _command = nil;
        }
        
        if (args) {
            if (_args) {
                NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:_args];
                SafeRelease(_args);
                [temp addEntriesFromDictionary:args];
                _args = SafeRetain(temp);
            } else {
                _args = SafeRetain(args);
            }
        }
    }
    return self;
}

- (NSString *)pageName {
    return _relative;
}

- (NSURL *)generateURL {
    NSString *path = nil;
    NSMutableDictionary *queryDic = [NSMutableDictionary new];
    [queryDic setValue:[_args jsonString] forKey:@"args"];
    [queryDic setValue:[NSString stringWithFormat:@"%u", _naviAnimeType] forKey:@"anime_type"];
    [queryDic setValue:[NSString stringWithFormat:@"%u", _naviAnimeDirection] forKey:@"anime_direction"];
    [queryDic setValue:[NSString stringWithFormat:@"%d", _isDestory] forKey:@"destory"];
    [queryDic setValue:_callbackUrl forKey:@"callback"];
    if (NO == [_pageNick isEqualToString:_relative]) {
        [queryDic setValue:_pageNick forKey:@"nick"];
    }
    NSString *queryText = [NSURL generateQueryText:queryDic];
    SafeRelease(queryDic);
    if (_command) {
        path = [NSString stringWithFormat:@"%@?%@#%@", _relative, queryText, _command];
    } else {
        path = [NSString stringWithFormat:@"%@?%@",_relative, queryText];
    }
    NSURL *url = [[NSURL alloc] initWithScheme:_scheme host:_host path:path];
    return SafeAutoRelease(url);
}

- (void)dealloc {
    SafeRelease(_pageNick);
    SafeRelease(_callbackUrl);
    SafeSuperDealloc(super);
}
@end
