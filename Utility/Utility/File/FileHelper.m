
//
//  FileHelper.m
//  MangaBook
//
//  Created by Ryou Zhang on 7/17/12.
//  Copyright (c) 2012  All rights reserved.
//

#import "FileHelper.h"
#import "FileKit.h"
#import "SignatureHelper.h"
#import "ZipFile.h"
#import "FileInZipInfo.h"
#import "ZipReadStream.h"
#import "SafeARC.h"
#import <Enviroment/Enviroment.h>

@implementation FileHelper
+ (NSString *)getTempDirectory {
    NSString *baseDir = [[FileKit getInstance] getAppDirectory:NSCachesDirectory];
    baseDir = [baseDir stringByAppendingPathComponent:@"temp"];
    if (NO == [[FileKit getInstance] isDirectoryExist:baseDir])
        [[FileKit getInstance] createDirectory:baseDir];
    return baseDir;
}

+ (NSString *)getTempPath:(NSString *)url {
    NSString *baseDir = [[FileKit getInstance] getAppDirectory:NSCachesDirectory];
    baseDir = [baseDir stringByAppendingPathComponent:@"temp"];
    if (NO == [[FileKit getInstance] isDirectoryExist:baseDir])
        [[FileKit getInstance] createDirectory:baseDir];
    
    return [NSString stringWithFormat:@"%@/%@",baseDir,GenerateMD5Key(url)];
}

+ (NSString *)getCacheDirectory {
    NSString *baseDir = [[FileKit getInstance] getAppDirectory:NSCachesDirectory];
    baseDir = [baseDir stringByAppendingPathComponent:@"cache"];
    if (NO == [[FileKit getInstance] isDirectoryExist:baseDir])
        [[FileKit getInstance] createDirectory:baseDir];
    return baseDir;
}

+ (NSString *)getCachePath:(NSString *)url {
    NSString *baseDir = [[FileKit getInstance] getAppDirectory:NSCachesDirectory];
    baseDir = [baseDir stringByAppendingPathComponent:@"cache"];
    if (NO == [[FileKit getInstance] isDirectoryExist:baseDir])
        [[FileKit getInstance] createDirectory:baseDir];
    
    NSString *ext = [[[NSURL URLWithString:url] relativePath] pathExtension];
    return [NSString stringWithFormat:@"%@/%@.%@",baseDir,GenerateMD5Key(url), ext];
}

+ (NSString *)getAppDataDirectory {
    NSString *baseDir = [[FileKit getInstance] getAppDirectory:NSLibraryDirectory];
    baseDir = [baseDir stringByAppendingPathComponent:@"data"];
    if (NO == [[FileKit getInstance] isDirectoryExist:baseDir]) {
        [[FileKit getInstance] createDirectory:baseDir];
        [[FileKit getInstance] disableFileBackup:baseDir];
    }
    return baseDir;
}

+ (NSString *)getAppLogDirectory {
    NSString *baseDir = [[FileKit getInstance] getAppDirectory:NSLibraryDirectory];
    baseDir = [baseDir stringByAppendingPathComponent:@"log"];
    if (NO == [[FileKit getInstance] isDirectoryExist:baseDir]) {
        [[FileKit getInstance] createDirectory:baseDir];
        [[FileKit getInstance] disableFileBackup:baseDir];
    }
    return baseDir;
}

+ (NSString *)getCoreDirectory:(id)coreVer {
    NSString *directory = [NSString stringWithFormat:@"core_%@",coreVer];
    NSString *path = [NSString stringWithFormat:@"%@/%@", [FileHelper getAppDataDirectory],directory];
    if (NO == [[FileKit getInstance] isDirectoryExist:path])
        [[FileKit getInstance] createDirectory:path];
    return path;
}

+ (NSString *)getCoreDirectory {
    return [FileHelper getCoreDirectory:[[AppUserDefault getInstance] getValueWithKey:@"core"]];
}

+ (NSString *)getConfigFilePath {
    NSString *path = [NSString stringWithFormat:@"%@/config.zip", [FileHelper getCoreDirectory]];
    if (NO == [[FileKit getInstance] isFileExist:path]) {
        [[AppUserDefault getInstance] setValue:@0 forKeyPath:@"core"];        
        path = [NSString stringWithFormat:@"%@/config.zip", [FileHelper getCoreDirectory]];
        [[FileKit getInstance] copyItemFrom:[[NSBundle mainBundle] pathForResource:@"config" ofType:@"zip"]
                                         to:path];
    }
    return path;
}

+ (NSString*)getHolidayPath
{
    NSString* path = [NSString stringWithFormat:@"%@/holiday.json",[FileHelper getAppResourceDirectory]];
    if (NO == [[FileKit getInstance] isFileExist:path])
    {
        [[FileKit getInstance] copyItemFrom:[[NSBundle mainBundle] pathForResource:@"holiday" ofType:@"json" inDirectory:@"Resource.bundle"]
                                         to:path];
    }
    return path;
}

+ (NSString *)getDatabasePath {
//    Environment env = [[AppEnvironment getInstance] getEnviroment];
//    if(env == App_Test || env == App_LiveUpdate) //非加密 {
//        NSString *path = [NSString stringWithFormat:@"%@/trip.db", [FileHelper getAppDataDirectory]];
//        if (NO == [[FileKit getInstance] isFileExist:path]) {
//            [NSUserDefaults tripSetObject:[NSNumber numberWithInt:0]
//                                   forKey:@"data"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            [[FileKit getInstance] copyItemFrom:[[NSBundle mainBundle] pathForResource:@"trip" ofType:@"db"]
//                                             to:path];
//            
//        }
//        return path;
//    }
    return nil;
}

+ (NSString *)getAppResourceDirectory {
    NSString *path = [NSString stringWithFormat:@"%@/resource",[FileHelper getAppDataDirectory]];
    if (NO == [[FileKit getInstance] isDirectoryExist:path])
        [[FileKit getInstance] createDirectory:path];
    return path;
}

+ (NSData *)loadDataFromCache:(NSString *)zipPath FileName:(NSString *)fileName {
    NSString* fullPath = [NSString stringWithFormat:@"%@/%@",zipPath,fileName];

    NSData* fileData = [NSData dataWithContentsOfFile:fullPath];
    
    if (fileData && [fileData length] > 0) {
        return fileData;
    }
    else{
      return  [FileHelper loadDataFromZip:zipPath
                           FileName:fileName
                           password:@"843be521ac514e81bd1c52982d36a8fc"];
    }
    
}

+ (NSData *)loadDataFromZip:(NSString *)zipPath
                   FileName:(NSString *)fileName
                   password:(NSString *)password {
    if(![[NSFileManager defaultManager]fileExistsAtPath:zipPath])
        return  nil;
    
    NSMutableData *data = nil;
    ZipFile *zip = nil;
    @try {
        zip = [[ZipFile alloc] initWithFileName:zipPath mode:ZipFileModeUnzip];
        [zip locateFileInZip:fileName];
        ZipReadStream *stream = nil;
        if (password) {
            stream = [zip readCurrentFileInZipWithPassword:password];
        } else {
            stream = [zip readCurrentFileInZip];
        }
        NSMutableData *buffer = [[NSMutableData alloc] initWithLength:4096];
        while (YES) {
            NSUInteger count = [stream readDataWithBuffer:buffer];
            if (data == nil) {
                data = [NSMutableData new];
            }
            [data appendBytes:[buffer bytes]
                       length:count];
            if (count < 4096)
                break;
        }
        SafeRelease(buffer);
        [stream finishedReading];
        [zip close];
        SafeRelease(zip);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
    
    return SafeAutoRelease(data);
}

+ (NSString *)loadDataFromZip:(NSString *)zipPath FileName:(NSString *)fileName {
    NSData *data = [FileHelper loadDataFromZip:zipPath FileName:fileName password:@"16ffcddaf14247ba931812977edd2d52"];    
    NSString *result = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
    SafeRelease(data);
    return SafeAutoRelease(result);
}

+ (BOOL)unzipFile:(NSString *)zipPath
      ToDirectory:(NSString *)directoryPath
         Password:(NSString*)password {
    ZipFile *unzip = nil;
    BOOL result = YES;
    @try {
        unzip = [[ZipFile alloc] initWithFileName:zipPath mode:ZipFileModeUnzip];
        [unzip goToFirstFileInZip];
        
        NSMutableData *buffer = [[NSMutableData alloc] initWithLength:1024];
        for(NSUInteger index=0; index<[unzip numFilesInZip]; index++) {
            FileInZipInfo *info = [unzip getCurrentFileInZipInfo];
            NSString *path = [NSString stringWithFormat:@"%@/%@",directoryPath,info.name];
            
            if (info.size == 0) {
                [[FileKit getInstance] createDirectory:path];
            } else {
                if ([[FileKit getInstance] isFileExist:path])
                    [[FileKit getInstance] deleteFile:path];
                
                CFWriteStreamRef outstream = CFWriteStreamCreateWithFile(kCFAllocatorDefault, (CFURLRef)[NSURL fileURLWithPath:path]);
                CFWriteStreamOpen(outstream);
                
                ZipReadStream *instream = nil;
                if (password == nil || [password length] == 0) {
                    instream = [unzip readCurrentFileInZip];
                } else {
                    instream = [unzip readCurrentFileInZipWithPassword:password];
                }
                while (YES) {
                    @try {
                        NSInteger count = [instream readDataWithBuffer:buffer];
                        if (count == 0)
                            break;
                        CFWriteStreamWrite(outstream, [buffer bytes], count);
                    }
                    @catch (NSException *exception) {
                        result = NO;
                        break;
                    }
                }
                [instream finishedReading];
                
                CFWriteStreamClose(outstream);
                CFRelease(outstream);
            }
            
            if (NO == result)
                break;
            [unzip goToNextFileInZip];
        };
        [unzip close];
        SafeRelease(unzip);
    }
    @catch (NSException *exception) {
        SafeRelease(unzip);
        return NO;
    }
    
    return result;
}



+ (BOOL)unzipFileCreateWholePath:(NSString *)zipPath
                     ToDirectory:(NSString *)directoryPath
                        Password:(NSString*)password {
    ZipFile *unzip = nil;
    BOOL result = YES;
    @try {
        unzip = [[ZipFile alloc] initWithFileName:zipPath mode:ZipFileModeUnzip];
        [unzip goToFirstFileInZip];
        
        NSMutableData *buffer = [[NSMutableData alloc] initWithLength:1024];
        for(NSUInteger index=0; index<[unzip numFilesInZip]; index++) {
            FileInZipInfo *info = [unzip getCurrentFileInZipInfo];
            NSString *path = [NSString stringWithFormat:@"%@/%@",directoryPath,info.name];
            
            NSArray* comppnents = [info.name pathComponents];
            
            if ([comppnents count] > 1) {
                
                NSString* deletLastpatch = [path stringByDeletingLastPathComponent];
                
                if (![[FileKit getInstance] isDirectoryExist:deletLastpatch]) {
                    
                    [[FileKit getInstance] createDirectory:deletLastpatch];
                }
                
            }
            
            if (info.size == 0) {
                [[FileKit getInstance] createDirectory:path];
            } else {
                if ([[FileKit getInstance] isFileExist:path])
                    [[FileKit getInstance] deleteFile:path];
                
                CFWriteStreamRef outstream = CFWriteStreamCreateWithFile(kCFAllocatorDefault, (CFURLRef)[NSURL fileURLWithPath:path]);
                CFWriteStreamOpen(outstream);
                
                ZipReadStream *instream = nil;
                if (password == nil || [password length] == 0) {
                    instream = [unzip readCurrentFileInZip];
                } else {
                    instream = [unzip readCurrentFileInZipWithPassword:password];
                }
                while (YES) {
                    @try {
                        NSInteger count = [instream readDataWithBuffer:buffer];
                        if (count == 0)
                            break;
                        CFWriteStreamWrite(outstream, [buffer bytes], count);
                    }
                    @catch (NSException *exception) {
                        result = NO;
                        break;
                    }
                }
                [instream finishedReading];
                
                CFWriteStreamClose(outstream);
                CFRelease(outstream);
            }
            
            if (NO == result)
                break;
            [unzip goToNextFileInZip];
        };
        [unzip close];
        SafeRelease(unzip);
    }
    @catch (NSException *exception) {
        SafeRelease(unzip);
        return NO;
    }
    
    return result;
}

+ (BOOL)unzipFile:(NSString *)zipPath ToDirectory:(NSString *)directoryPath {
    return [FileHelper unzipFile:zipPath ToDirectory:directoryPath Password:nil];
}

//for resource file
+ (NSString*)smartGetResourceFilePath:(NSString*)fileName {
    //优先检查资源文件和core文件目录
    NSString *temp = [NSString stringWithFormat:@"%@/%@",
                      [FileHelper getAppResourceDirectory],
                      fileName];
    if ([[FileKit getInstance] isFileExist:temp]) {
        return temp;
    }
    
    NSString *filePath = [fileName lastPathComponent];
    if (filePath == nil) {
        filePath = fileName;
    }
    
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *fullPath = [resourcePath stringByAppendingPathComponent:filePath];
    if ([[FileKit getInstance] isFileExist:fullPath]) {
        return fullPath;
    }
    return nil;
}
@end
