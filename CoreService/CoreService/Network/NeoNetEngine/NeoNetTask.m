//
//  NeoNetTask.m
//  TestLibuv
//
//  Created by Ryou Zhang on 6/11/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import "NeoNetTask.h"
#import "SafeARC.h"

@implementation NeoNetTask
@synthesize handle = _handle, rawData = _rawdata, code = _code,url = _url;
@synthesize source = _source;
@synthesize resolveArray = _resolveArray;
- (instancetype)init {
    self = [super init];
    if (self) {
        _code = CURLE_OK;
        _error[0] = '\0';
        _handle = curl_easy_init();
    }
    return self;
}

- (void)resetData {
    socket = 0;
    timeStamp = 0;
    SafeRelease(_rawdata);
    curl_easy_cleanup(_handle);
    _handle = curl_easy_init();
    _error[0] = '\0';
}

- (BOOL)checkError {
    if (_error[0] == '\0') {
        return NO;
    }
    return YES;
}

- (void)prepareHandle {
    curl_easy_setopt(_handle, CURLOPT_ERRORBUFFER, &_error);
    
    for (NSString *resolve in _resolveArray) {
        _reslove_list = curl_slist_append(_reslove_list, [resolve cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    if ([_resolveArray count] > 0) {
        curl_easy_setopt(_handle, CURLOPT_RESOLVE, _reslove_list);
    }
}

- (NSString*)generateUniqueKey {
    return nil;
}

- (void)taskFinish {
    [[NSNotificationCenter defaultCenter] postNotificationName:NeoNetTask_Finish
                                                        object:self];
}

- (void)taskFailed {
    [[NSNotificationCenter defaultCenter] postNotificationName:NeoNetTask_Failed
                                                        object:self];
}

- (NSString *)errorMsg {
    if (_code == CURLE_OK) {
        return nil;
    }
    return [NSString stringWithCString:curl_easy_strerror(_code)
                              encoding:NSUTF8StringEncoding];
}

- (void)dealloc {
    curl_slist_free_all(_reslove_list);
    curl_easy_cleanup(_handle);
    SafeRelease(_resolveArray);
    SafeRelease(_rawdata);
    SafeRelease(_source);
    SafeRelease(_url);
    SafeSuperDealloc(super);
}
@end
