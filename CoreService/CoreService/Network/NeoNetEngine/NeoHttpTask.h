//
//  NeoHttpTask.h
//  TestLibuv
//
//  Created by Ryou Zhang on 6/11/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import "NeoNetTask.h"

//url
//header


@interface NeoHttpTask : NeoNetTask {
@protected
    NSMutableData       *_responseHeaderRaw;
    NSDictionary        *_responseHeader;
    struct curl_slist  *_header_list;    
    NSDictionary        *_headerDic;
@private
    NSTimeInterval      _timeout;
    NSTimeInterval      _connectTimeout;
}
@property(retain, atomic)NSDictionary   *headerDic;
@property(assign, atomic)NSTimeInterval timeout;
@property(assign, atomic)NSTimeInterval connectTimeout;

@property(retain, nonatomic, readonly)NSDictionary *responseHeader;

- (void)prepareHttpHeader;

- (void)appendResponseBody:(NSData*)data;
- (void)appendResponseHeader:(NSData*)data;

- (NSInteger)getResponseCode;
@end
