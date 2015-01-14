//
//  LuaScriptManager.h
//  TestRotation
//
//  Created by RyouZhang on 12-12-9.
//  Copyright (c) 2012年 RyouZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LuaScriptManager : NSObject {
@private
    NSMutableDictionary*    _scriptDic;
}

+(LuaScriptManager*)getInstance;

-(NSString*)getLuaPath;

-(NSString*)getLuaScript:(NSString*)scriptName;
-(void)resetLuaScriptDic;
@end
