//
//  FileHelper.h
//  FileKit
//
//  Created by Ryou Zhang on 9/18/11.
//  Copyright (c) 2011  All rights reserved.
//
#import <Foundation/Foundation.h>


@interface FileKit : NSObject
{
@package
    NSFileManager           *_fileManager;
    NSMutableDictionary     *_appDirectoryDic;
}
+ (FileKit *)getInstance;
//NSDocumentDirectory,NSCachesDirectory
- (NSString *)getAppDirectory:(NSSearchPathDirectory)directoryType;

- (BOOL)isFileExist:(NSString *)filePath;
- (BOOL)isDirectoryExist:(NSString *)directoryPath;

- (NSArray *)getFilesInDirectory:(NSString *)directoryPath byType:(NSString *)fileType;
- (NSDictionary *)getAttributeInFile:(NSString *)filePath;

- (void)setFile:(NSString *)filePath  attribute:(NSDictionary *)attribute;
- (void)createDirectory:(NSString *)directoryPath;
- (void)deleteDirectory:(NSString *)directoryPath;
- (void)deleteFile:(NSString *)filePath;
- (void)copyItemFrom:(NSString *)sourcePath to:(NSString *)targetPath;
- (void)moveItemFrom:(NSString *)sourcePath to:(NSString *)targetPath;

- (void)clearDirectory:(NSString *)directoryPath;

//for icloud backup
- (BOOL)disableFileBackup:(NSString *)filePath;

//use with cache cleanup
- (void)updateFileModifyTime:(NSString *)filePath;

- (double)getDirectorySizeForPath:(NSString *)path;
- (double)getFileSystemFreeSize;
- (double)getApplicationSize;
- (double)getFileSystemTotalSize;

//use for webview optimize
- (void)updateFileAvailableTime:(NSDate*)date to:(NSString *)targetPath;
@end
