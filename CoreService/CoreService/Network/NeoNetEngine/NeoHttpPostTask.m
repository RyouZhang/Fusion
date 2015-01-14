//
//  NeoHttpPostTask.m
//  TestLibuv
//
//  Created by Ryou Zhang on 6/14/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import "NeoHttpPostTask.h"
#import "SafeARC.h"

@implementation NeoHttpPostTask
@synthesize postFields = _postFields;
- (void)prepareHandle {
    
    NSMutableString *postData = [NSMutableString new];
    for (NSString *key in [_postFields allKeys]) {
        if ([postData length] == 0) {
            [postData appendFormat:@"%@=%@", key, [_postFields valueForKey:key]];
        } else {
            [postData appendFormat:@"&%@=%@", key, [_postFields valueForKey:key]];
        }
    }
    curl_easy_setopt(_handle, CURLOPT_COPYPOSTFIELDS, [postData cStringUsingEncoding:NSUTF8StringEncoding]);
    
    SafeRelease(postData);
    [super prepareHandle];
}

- (void)prepareHttpHeader {
    if (_headerDic) {
        for (NSString *key in [_headerDic allKeys]) {
            NSString *data = [NSString stringWithFormat:@"%@:%@", key, [_headerDic valueForKey:key]];
            _header_list = curl_slist_append(_header_list, [data cStringUsingEncoding:NSUTF8StringEncoding]);
        }
        curl_slist_append(_header_list, "Expect:");
        curl_easy_setopt(_handle, CURLOPT_HTTPHEADER, _header_list);
    }
}

- (void)dealloc {
    SafeRelease(_postFields);
    SafeSuperDealloc(super);
}
@end
