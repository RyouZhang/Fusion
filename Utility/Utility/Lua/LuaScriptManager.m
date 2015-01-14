//
//  LuaScriptManager.m
//  TestRotation
//
//  Created by RyouZhang on 12-12-9.
//  Copyright (c) 2012年 RyouZhang. All rights reserved.
//

#import "LuaScriptManager.h"
#import "../File/FileHelper.h"
#import "CommonNotification.h"
#import "SafeARC.h"
#import <Enviroment/Enviroment.h>

@implementation LuaScriptManager
static LuaScriptManager* _LuaScriptManager_Instance;
+(LuaScriptManager*)getInstance {
    @synchronized(self) {
        if(_LuaScriptManager_Instance == nil)
            _LuaScriptManager_Instance = [LuaScriptManager new];
        
    }
    return _LuaScriptManager_Instance;
}

- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resetload)
                                                     name:CoreResetNotification
                                                   object:nil];
    }
    return self;
}

-(NSString*)loadLuaScript:(NSString*)scriptName {
    NSError* error = nil;
    NSString* rawData = nil;
    if ([[AppEnvironment getInstance] getEnviroment] != App_Test) {
        NSString *filename = [NSString stringWithFormat:@"%@.lua", scriptName];
        rawData = [FileHelper loadDataFromZip:[FileHelper getConfigFilePath]
                                     FileName:filename];
    } else {
        rawData = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:
                                                      [NSString stringWithFormat:@"Script.bundle/%@", scriptName]
                                                                                     ofType:@"lua"]
                                            encoding:NSUTF8StringEncoding
                                               error:&error];
    }
    if(error == nil) {
        [_scriptDic setObject:rawData forKey:scriptName];
        return rawData;
    }
    return nil;
}

-(NSString*)getLuaPath {
    if ([[AppEnvironment getInstance] getEnviroment] != App_Test) {
        return nil;
    } else {
        return [NSString stringWithFormat:@"%@/Script.bundle", [[NSBundle mainBundle] bundlePath]];
    }
}

-(NSString*)getLuaScript:(NSString*)scriptName {
    id rawscript =[_scriptDic objectForKey:scriptName];
    if(rawscript)
        return rawscript;
    return [self loadLuaScript:scriptName];
}

-(void)resetLuaScriptDic {
    [_scriptDic removeAllObjects];
}

- (void)resetload {
    [self resetLuaScriptDic];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SafeRelease(_scriptDic);
    SafeSuperDealloc(super);
}
@end
