//
//  FileHelper.m
//  FileKit
//
//  Created by Ryou Zhang on 9/18/11.
//  Copyright (c) 2011 All rights reserved.
//

#import "FileKit.h"
#import <sys/xattr.h>
#import "SafeARC.h"

@implementation FileKit
static FileKit *_FileKit_Instance = nil;
+ (FileKit *)getInstance {
    @synchronized(self) {
        if (_FileKit_Instance == nil)
            _FileKit_Instance = [FileKit new];
    }
    return _FileKit_Instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _fileManager = [NSFileManager new];
        _appDirectoryDic = [NSMutableDictionary new];
        
        {
			NSArray *dirArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
            [_appDirectoryDic setObject:[dirArray objectAtIndex:0]
                                 forKey:[NSNumber numberWithUnsignedInteger:NSDocumentDirectory]];
		}
		{
			NSArray *dirArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
            [_appDirectoryDic setObject:[dirArray objectAtIndex:0]
                                 forKey:[NSNumber numberWithUnsignedInteger:NSCachesDirectory]];
		}
        {
			NSArray *dirArray = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES);
            [_appDirectoryDic setObject:[dirArray objectAtIndex:0]
                                 forKey:[NSNumber numberWithUnsignedInteger:NSLibraryDirectory]];
		}
    }
    return self;
}

- (NSString *)getAppDirectory:(NSSearchPathDirectory)directoryType {
    return [_appDirectoryDic objectForKey:[NSNumber numberWithUnsignedInteger:directoryType]];
}


- (NSArray *)getFilesInDirectory:(NSString *)directoryPath byType:(NSString *)fileType {
    if (!directoryPath) return nil;
    
    BOOL bDirectory = NO;
    
    BOOL bpathExists =  [_fileManager fileExistsAtPath:directoryPath isDirectory:&bDirectory];
    
    if (!bpathExists || !bDirectory) {
        
        return nil;
    }
    
    
    NSError *error = nil;
	NSArray *files = [_fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
	
    if (error != nil)
        return nil;
	
	NSMutableArray *resultArray = [NSMutableArray new];
	
	for (NSInteger index=0; index < [files count]; index++) {
		NSString *fileName = [files objectAtIndex:index];
		NSString *extType = [fileName pathExtension];
		if (fileType != nil && NO == [extType isEqualToString:fileType])
			continue;
		[resultArray addObject:fileName];
	}
	return SafeAutoRelease(resultArray);
}

- (NSDictionary *)getAttributeInFile:(NSString *)filePath {
    NSError *error = nil;
    NSDictionary *result = [_fileManager attributesOfItemAtPath:filePath
                                                         error:&error];
    if (error != nil)
        return nil;
    
    return result;
}

- (void)updateFileModifyTime:(NSString *)filePath {
    NSDictionary *attribute = [NSDictionary dictionaryWithObject:[NSDate date]
                                                          forKey:NSFileModificationDate];
    [self setFile:filePath attribute:attribute];
}

- (void)updateFileAvailableTime:(NSDate*)date to:(NSString *)targetPath
{
    
    NSDictionary *attribute = [NSDictionary dictionaryWithObject:date
                                                          forKey:NSFileModificationDate];
    [self setFile:targetPath attribute:attribute];
}


- (void)setFile:(NSString *)filePath  attribute:(NSDictionary *)attribute {
    NSError *error = nil;
    if (NO == [self isFileExist:filePath])
        return;
    
    [_fileManager setAttributes:attribute ofItemAtPath:filePath error:&error];
}

- (BOOL)isFileExist:(NSString *)filePath {
	BOOL isDirectory = NO;
	BOOL result = [_fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
	return result&!isDirectory;	
}

- (BOOL)isDirectoryExist:(NSString *)directoryPath {
	BOOL isDirectory = NO;
	BOOL result = [_fileManager fileExistsAtPath:directoryPath isDirectory:&isDirectory];
	return result&isDirectory;
}

- (void)createDirectory:(NSString *)directoryPath {
    NSError *error = nil;
    [_fileManager createDirectoryAtPath:directoryPath
            withIntermediateDirectories:YES
                             attributes:nil
                                  error:&error];
}

- (void)deleteDirectory:(NSString *)directoryPath {
    NSError *error = nil;
	if (NO == [self isDirectoryExist:directoryPath])
		return;
	
	[_fileManager removeItemAtPath:directoryPath error:&error];
}

- (void)clearDirectory:(NSString *)directoryPath {
    NSError *error = nil;
   	NSArray *files = [_fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
	
    if (error != nil)
        return;
    for(NSString *file in files) {
        [_fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@",directoryPath,file]
                                 error:&error];
    }
}

- (void)deleteFile:(NSString *)filePath {
    NSError *error = nil;
	if (NO == [self isFileExist:filePath])
        return;
    
	[_fileManager removeItemAtPath:filePath error:&error];
}

- (void)copyDirectoryFrom:(NSString*)sourcePath to:(NSString*)targetPath {
    NSError *error = nil;
    NSArray *items = [_fileManager contentsOfDirectoryAtPath:sourcePath error:&error];
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *tempPath = [sourcePath stringByAppendingPathComponent:obj];
        if ([self isDirectoryExist:tempPath]) {
            [self copyDirectoryFrom:tempPath
                                 to:[NSString stringWithFormat:@"%@/%@",targetPath,obj]];
        } else if([self isFileExist:tempPath]) {
            [self copyFileFrom:tempPath
                            to:[NSString stringWithFormat:@"%@/%@",targetPath,obj]];
        }
    }];
}

- (void)copyFileFrom:(NSString*)sourcePath to:(NSString*)targetPath {
    NSError *error = nil;
    NSString *temp = [targetPath stringByDeletingLastPathComponent];
    if ([self isDirectoryExist:temp] == NO) {
        [self createDirectory:temp];
    }
    if ([self isFileExist:targetPath]) {
        [self deleteFile:targetPath];
    }
    [_fileManager copyItemAtPath:sourcePath toPath:targetPath error:&error];
}

- (void)copyItemFrom:(NSString *)sourcePath to:(NSString *)targetPath {
    if ([self isDirectoryExist:sourcePath]) {
        [self copyDirectoryFrom:sourcePath to:targetPath];
    } else if ([self isFileExist:sourcePath]) {
        [self copyFileFrom:sourcePath to:targetPath];
    }
}

- (void)moveItemFrom:(NSString *)sourcePath to:(NSString *)targetPath {
    NSError *error = nil;
    [_fileManager moveItemAtPath:sourcePath toPath:targetPath error:&error];
}

- (double)getDirectorySizeForPath:(NSString *)directoryPath {
    if (NO == [self isDirectoryExist:directoryPath])
        return -1;

    NSDirectoryEnumerator *e = [_fileManager enumeratorAtPath:directoryPath];
    
    if (e == NULL)
        return -1;

	double totalSize = 0;
	while ([e nextObject]) {
		NSDictionary *attributes = [e fileAttributes];
		
		NSNumber *fileSize = [attributes objectForKey:NSFileSize];
		
		totalSize += [fileSize longLongValue];
	}
	
	return totalSize; 
}

- (double)getFileSystemFreeSize {
    NSError *error = nil;
	
	NSDictionary *attribute = [_fileManager attributesOfFileSystemForPath:[_appDirectoryDic objectForKey:[NSNumber numberWithUnsignedInteger:NSDocumentDirectory]]
                                                                   error:&error];
    if (error != nil)
        return -1;
	
	NSNumber *size = [attribute objectForKey:NSFileSystemFreeSize];
	
	return 	[size doubleValue];
}

- (double)getApplicationSize {
    NSString *appPath = [[_appDirectoryDic objectForKey:[NSNumber numberWithUnsignedInteger:NSDocumentDirectory]] stringByDeletingLastPathComponent];
	
	NSDirectoryEnumerator *e = [_fileManager enumeratorAtPath:appPath];
    
    if (e == NULL)
        return -1;
	
	double totalSize = 0;
	while ([e nextObject]) {
		NSDictionary *attributes = [e fileAttributes];
		
		NSNumber *fileSize = [attributes objectForKey:NSFileSize];
		
		totalSize += [fileSize longLongValue];
	}
	
	return totalSize;
    
}

- (double)getFileSystemTotalSize {
    NSError *error = nil;
	
	NSDictionary *attribute = [_fileManager attributesOfFileSystemForPath:[_appDirectoryDic objectForKey:[NSNumber numberWithUnsignedInteger:NSDocumentDirectory]] error:&error];
    
    if (error != nil)
        return -1;
	
	NSNumber *size = [attribute objectForKey:NSFileSystemSize];
	
	return 	[size doubleValue];	
}

- (BOOL)disableFileBackup:(NSString *)filePath {
    NSString *sv = [[UIDevice currentDevice] systemVersion];
    if ([sv compare:@"5.0"] == NSOrderedAscending)
        return YES;
    
    if ([sv compare:@"5.1"] != NSOrderedAscending) {
        BOOL flag = NO;
        NSError *error = nil;
        NSURL *url = [NSURL fileURLWithPath:filePath];
        [url setResourceValue:[NSNumber numberWithBool: YES]
                       forKey:NSURLIsExcludedFromBackupKey
                        error:&error];
        return flag;
    } else {
        u_int8_t attrValue = 1;
        int result = setxattr([filePath UTF8String], "com.apple.MobileBackup", &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    }
}

- (void)dealloc {
    SafeRelease(_appDirectoryDic);
    SafeRelease(_fileManager);
    SafeSuperDealloc(super);
}
@end
