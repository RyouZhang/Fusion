//
//  NeoNetTask.h
//  TestLibuv
//
//  Created by Ryou Zhang on 6/11/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "curl.h"

#define Raw_Block_Size  65536

#define NeoNetTask_Finish   @"NeoNetTask_Finish"
#define NeoNetTask_Failed   @"NeoNetTask_Failed"

@interface NeoNetTask : NSObject {
@protected
    NSURL               *_url;
    CURL                *_handle;
    NSMutableData       *_rawdata;
    CURLcode            _code;
    char                _error[CURL_ERROR_SIZE];
    id                  _source;
    NSArray             *_resolveArray;
@private
    struct curl_slist   *_reslove_list;
@public
    socklen_t           socket;
    NSTimeInterval      timeStamp;
}
@property(retain, atomic)NSURL   *url;
@property(assign, atomic, readonly)CURL   *handle;
@property(assign, atomic)CURLcode       code;
@property(retain, atomic, readonly)NSData *rawData;
@property(retain, atomic) id source;;
@property(retain, atomic)NSArray    *resolveArray;

- (void)resetData;

- (void)prepareHandle;

- (BOOL)checkError;

- (NSString*)generateUniqueKey;

- (void)taskFinish;

- (void)taskFailed;

- (NSString *)errorMsg;
@end
