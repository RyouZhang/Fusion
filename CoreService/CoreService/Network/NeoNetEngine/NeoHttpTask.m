//
//  NeoHttpTask.m
//  TestLibuv
//
//  Created by Ryou Zhang on 6/11/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import "NeoHttpTask.h"
#import "SafeARC.h"


size_t http_task_write_data(void *buffer, size_t size, size_t nmemb, void *userp) {
    if (nmemb * size == 0) {
        return nmemb * size;
    }
    NeoHttpTask *task = (__bridge NeoHttpTask*)userp;
    [task appendResponseBody:[NSData dataWithBytes:buffer length:nmemb * size]];
    return nmemb * size;
}

size_t http_task_write_header(void *buffer, size_t size, size_t nmemb, void *userp) {
    if (nmemb * size == 0) {
        return nmemb * size;
    }
    
    NeoHttpTask *task = (__bridge NeoHttpTask*)userp;
    [task appendResponseHeader:[NSData dataWithBytes:buffer length:nmemb * size]];
    return nmemb * size;
}

@implementation NeoHttpTask
@synthesize headerDic = _headerDic, timeout = _timeout, connectTimeout = _connectTimeout, responseHeader = _responseHeader;
- (instancetype)init {
    self = [super init];
    if (self) {
        _timeout = 15;
        _connectTimeout = 10;
    }
    return self;
}

- (void)prepareHttpHeader {
    [self loadCookies];
    if (_headerDic) {
        for (NSString *key in [_headerDic allKeys]) {
            if ([key isEqualToString:@"User-Agent"]) {
                continue;
            }
            NSString *data = [NSString stringWithFormat:@"%@:%@", key, [_headerDic valueForKey:key]];
            _header_list = curl_slist_append(_header_list, [data cStringUsingEncoding:NSUTF8StringEncoding]);
        }
        {
            NSString *data = [NSString stringWithFormat:@"User-Agent:%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"UserAgent"]];
            _header_list = curl_slist_append(_header_list, [data cStringUsingEncoding:NSUTF8StringEncoding]);
        }
        curl_easy_setopt(_handle, CURLOPT_HTTPHEADER, _header_list);
    } else {
        NSString *data = [NSString stringWithFormat:@"User-Agent:%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"UserAgent"]];
        _header_list = curl_slist_append(_header_list, [data cStringUsingEncoding:NSUTF8StringEncoding]);
        curl_easy_setopt(_handle, CURLOPT_HTTPHEADER, _header_list);
    }
//    NSString *cookid_cache = [NSString stringWithFormat:@"%@/cookies.txt",[FileHelper getCacheDirectory]];
//    curl_easy_setopt(_handle, CURLOPT_COOKIEFILE, [cookid_cache cStringUsingEncoding:NSUTF8StringEncoding]);
//    curl_easy_setopt(_handle, CURLOPT_COOKIEJAR, [cookid_cache cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void)resetData {
    [super resetData];
    SafeRelease(_responseHeaderRaw);
}

- (void)prepareHandle {  
    curl_easy_setopt(_handle, CURLOPT_FOLLOWLOCATION, 0);
    curl_easy_setopt(_handle, CURLOPT_ACCEPT_ENCODING, "gzip,deflate,UTF-8");
    curl_easy_setopt(_handle, CURLOPT_URL, [[_url absoluteString] cStringUsingEncoding:NSUTF8StringEncoding]);
    curl_easy_setopt(_handle, CURLOPT_CONNECTTIMEOUT, _connectTimeout);
    curl_easy_setopt(_handle, CURLOPT_TIMEOUT, _timeout);
    
    [self prepareHttpHeader];

    curl_easy_setopt(_handle, CURLOPT_HEADERFUNCTION, http_task_write_header);
    curl_easy_setopt(_handle, CURLOPT_WRITEFUNCTION, http_task_write_data);
    curl_easy_setopt(_handle, CURLOPT_HEADERDATA, (void*)self);
    curl_easy_setopt(_handle, CURLOPT_WRITEDATA, (void*)self);
    
    [super prepareHandle];
    
    [self config:_handle Proxy:_url];
}

- (void)config:(CURL*)handle Proxy:(NSURL*)url {
    
    CFDictionaryRef setting = CFNetworkCopySystemProxySettings();
    
    CFArrayRef proxys = CFNetworkCopyProxiesForURL((CFURLRef)url,
                                                   setting);
    if (CFArrayGetCount(proxys) == 0) {
        CFRelease(setting);
        CFRelease(proxys);
        return;
    }
    NSDictionary *proxy = CFArrayGetValueAtIndex(proxys, 0);
    curl_easy_setopt(handle, CURLOPT_PROXY,
                     [[proxy valueForKey:(NSString *)kCFProxyHostNameKey] cStringUsingEncoding:NSUTF8StringEncoding]);
    curl_easy_setopt(handle, CURLOPT_PROXYPORT, [[proxy objectForKey:(NSString *)kCFProxyPortNumberKey] intValue]);
    if ([proxy valueForKey:(NSString*)kCFProxyUsernameKey]) {
        curl_easy_setopt(handle, CURLOPT_PROXYUSERNAME,
                         [[proxy valueForKey:(NSString*)kCFProxyUsernameKey] cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    if ([proxy valueForKey:(NSString*)kCFProxyPasswordKey]) {
        curl_easy_setopt(handle, CURLOPT_PROXYUSERPWD,
                         [[proxy valueForKey:(NSString*)kCFProxyPasswordKey] cStringUsingEncoding:NSUTF8StringEncoding]);
    }
     CFRelease(setting);
     CFRelease(proxys);
}

- (NSString *)generateUniqueKey {
    if ([_url port]) {
        return [NSString stringWithFormat:@"%@://%@:%@",[_url scheme],[_url host],[_url port]];
    }
    return [NSString stringWithFormat:@"%@://%@",[_url scheme],[_url host]];
}

- (void)appendResponseBody:(NSData*)data {
    if (_rawdata == nil) {
        _rawdata = [[NSMutableData alloc] initWithCapacity:Raw_Block_Size];
    }
    [_rawdata appendData:data];
}

- (void)appendResponseHeader:(NSData*)data {
    if (_responseHeaderRaw == nil) {
        _responseHeaderRaw = [[NSMutableData alloc] initWithCapacity:Raw_Block_Size];
    }
    [_responseHeaderRaw appendData:data];
}

- (NSDictionary *)responseHeader {
    @synchronized(self) {
        if (_responseHeader == nil) {
            _responseHeader = SafeRetain([self httpHeaderParse:_responseHeaderRaw]);
            SafeRelease(_responseHeaderRaw);
        }
    }
    return _responseHeader;
}

- (NSInteger)getResponseCode {
    NSInteger statusCode = 0;
    CURLcode res = curl_easy_getinfo(_handle, CURLINFO_RESPONSE_CODE, &statusCode);
    if (res == CURLE_OK) {
        return statusCode;
    }
    return statusCode;
}


- (NSDictionary*)httpHeaderParse:(NSData*)data{
    if(data==nil || ![data isKindOfClass:[NSData class]])
        return nil;
    NSString *headerString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *lineArray = [headerString componentsSeparatedByString:@"\r\n"];
    if(lineArray){
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:[lineArray count]];
        NSRange range;
        NSString *str, *key, *val;
        for(NSString *item in lineArray){
            if(item == nil) continue;
            str = [item stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(str == nil) continue;
            range = [str rangeOfString:@":"];
            if(range.location == NSNotFound) continue;
            key = [str substringToIndex:range.location];
            val = [str substringFromIndex:range.location+1];
            key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            val = [val stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([key isEqualToString:@"Set-Cookie"] && val) {
                [self saveCookie:val];
            } else if(key && val && [val isKindOfClass:[NSString class]]){
                [dic setObject:val forKey:key];
            }
        }
        SafeRelease(headerString);
        return SafeAutoRelease(dic);
    }
    SafeRelease(headerString);
    return nil;
}

- (void)loadCookies {
    NSMutableArray *cookies = [NSMutableArray new];
    NSArray *storeCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:self.url];
    [cookies addObjectsFromArray:storeCookies];
    __block NSMutableString *cookieData = [NSMutableString new];
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookieData length] == 0) {
            [cookieData appendFormat:@"%@=%@",cookie.name, cookie.value];
        } else {
            [cookieData appendFormat:@";%@=%@",cookie.name, cookie.value];
        }
    }
    SafeRelease(cookies);
    curl_easy_setopt(_handle, CURLOPT_COOKIE, [cookieData cStringUsingEncoding:NSUTF8StringEncoding]);
    SafeRelease(cookieData);
}

- (void)saveCookie:(NSString *)value {
    NSArray *cookies =  [NSHTTPCookie cookiesWithResponseHeaderFields:@{@"Set-Cookie":value}
                                                               forURL:self.url];
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
}

- (void)dealloc {
    curl_slist_free_all(_header_list);
    SafeRelease(_responseHeader);
    SafeRelease(_responseHeaderRaw);
    SafeRelease(_headerDic);
    SafeSuperDealloc(super);
}
@end
