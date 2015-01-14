//
//  NeoHttpDownloadTask.m
//  TestLibuv
//
//  Created by Ryou Zhang on 6/13/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import "NeoHttpDownloadTask.h"
#import <Utility/Utility.h>
#import "SafeARC.h"

#define Max_Buffer_Size Raw_Block_Size * 2

@implementation NeoHttpDownloadTask
- (void)prepareHttpHeader {
    if ([[FileKit getInstance] isFileExist:_cachePath]) {
        _fileHandle = SafeRetain([NSFileHandle fileHandleForReadingAtPath:_cachePath]);
        long long size = [_fileHandle seekToEndOfFile];
        [_fileHandle closeFile];
        SafeRelease(_fileHandle);
        
        NSString *data = [NSString stringWithFormat:@"Content-Range:%lld-", size];
        _header_list = curl_slist_append(_header_list, [data cStringUsingEncoding:NSUTF8StringEncoding]);
        
        _checkResume = YES;
    } else {
        _checkResume = NO;
    }
    [super prepareHttpHeader];
}

- (void)appendResponseBody:(NSData *)data {
    if (_checkResume) {
        int code = 0;
        CURLcode res = curl_easy_getinfo(_handle, CURLINFO_RESPONSE_CODE, &code);
        if (res != CURLE_OK || code != 206) {
            [[FileKit getInstance] deleteFile:_cachePath];
        }
        _checkResume = NO;
    }
    
//    if (_fileHandle == nil) {
//        [[NSFileManager defaultManager] createFileAtPath:_cachePath contents:nil attributes:nil] ;
//        _fileHandle = SafeRetain([NSFileHandle fileHandleForWritingAtPath:_cachePath]);
//    }
//    [_fileHandle seekToEndOfFile];
//    [_fileHandle writeData:data];
    if (_rawdata == nil) {
        _rawdata = [[NSMutableData alloc] initWithCapacity:Raw_Block_Size];
    }
    [_rawdata appendData:data];
    
    if ([_rawdata length] > Max_Buffer_Size) {
        [self writeToCacheFile];
    }
}

- (void)writeToCacheFile {
    if (_fileHandle == nil) {
        if ([[FileKit getInstance] isFileExist:_cachePath] == NO) {
            [[NSFileManager defaultManager] createFileAtPath:_cachePath contents:nil attributes:nil] ;
        }
        _fileHandle = SafeRetain([NSFileHandle fileHandleForWritingAtPath:_cachePath]);
    }
    [_fileHandle seekToEndOfFile];
    [_fileHandle writeData:_rawdata];
    [_fileHandle synchronizeFile];
//    [_fileHandle closeFile];
//    SafeRelease(_fileHandle);
    SafeRelease(_rawdata);
}

- (void)taskFinish {
    int code = 0;
    CURLcode res = curl_easy_getinfo(_handle, CURLINFO_RESPONSE_CODE, &code);
    if (res == CURLE_OK && code < 400) {
        if (_rawdata) {
            [self writeToCacheFile];
        }
        if (code == 302) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NeoNetTask_Finish
                                                                object:self];
            return;
        }
        
        NSString *length = [self.responseHeader valueForKey:@"Content-Length"];        
        if (length && [length longLongValue] < [_fileHandle seekToEndOfFile]) {
            [_fileHandle closeFile];
            SafeRelease(_fileHandle);
            [[NSNotificationCenter defaultCenter] postNotificationName:NeoNetTask_Failed
                                                                object:self];
            return;
        } else if(length && [length longLongValue] > [_fileHandle seekToEndOfFile]) {
            [_fileHandle closeFile];
            SafeRelease(_fileHandle);
            
            [[FileKit getInstance] deleteFile:_cachePath];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NeoNetTask_Failed
                                                                object:self];
            return;
        } else if (length && [length longLongValue] == 0) {
            if (_fileHandle) {
                [_fileHandle closeFile];
                SafeRelease(_fileHandle);
            }
            
            [[FileKit getInstance] deleteFile:_cachePath];
            [[NSNotificationCenter defaultCenter] postNotificationName:NeoNetTask_Failed
                                                                object:self];
            return;
        }
        [_fileHandle closeFile];
        SafeRelease(_fileHandle);
        
        [[FileKit getInstance] copyItemFrom:_cachePath to:_targetPath];
        [[FileKit getInstance] deleteFile:_cachePath];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NeoNetTask_Finish
                                                            object:self];
        return;
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:NeoNetTask_Failed
                                                            object:self];
    }
}

- (void)dealloc {
    SafeRelease(_fileHandle);
    SafeRelease(_cachePath);
    SafeRelease(_targetPath);
    SafeSuperDealloc(super);
}
@end
