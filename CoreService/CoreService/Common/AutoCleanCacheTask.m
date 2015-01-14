//
//  AutoCleanCacheTask.m
//  Trip2013
//
//  Created by Ryou Zhang on 12/12/13.
//  Copyright (c) 2013 alibaba. All rights reserved.
//

#import "AutoCleanCacheTask.h"
#import <Utility/Utility.h>

#define Cache_Effective_Time 86400 * 7

@implementation AutoCleanCacheTask
- (void)doTask {
    NSString *dirPath = [FileHelper getCacheDirectory];
    NSArray *files = [[FileKit getInstance] getFilesInDirectory:dirPath byType:nil];
    
    NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
    
    for (NSString *file in files) {
        NSString *filePath = [dirPath stringByAppendingPathComponent:file];
        NSDictionary *attributes = [[FileKit getInstance] getAttributeInFile:filePath];
        if (attributes != nil) {
            NSTimeInterval fileLastTime = [[attributes valueForKey:NSFileModificationDate] timeIntervalSince1970];
            if(fileLastTime + Cache_Effective_Time < current)
                [[FileKit getInstance] deleteFile:filePath];
        }
    }
}
@end
