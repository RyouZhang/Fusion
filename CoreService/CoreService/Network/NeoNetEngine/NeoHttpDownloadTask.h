//
//  NeoHttpDownloadTask.h
//  TestLibuv
//
//  Created by Ryou Zhang on 6/13/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import "NeoHttpTask.h"

@interface NeoHttpDownloadTask : NeoHttpTask {
@private
    NSString    *_cachePath;
    NSString    *_targetPath;
    
    NSFileHandle    *_fileHandle;
    BOOL            _checkResume;
}
@property(retain, atomic)NSString   *cachePath;
@property(retain, atomic)NSString   *targetPath;
@end
