//
//  LuaCore.h
//  Utility
//
//  Created by Ryou Zhang on 9/9/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  {
    LuaRT_Boolean   = 0,
    LuaRT_String    = 1,
    LuaRT_Number    = 2,
    LuaRT_Table     = 3
}LuaRT_ReturnType;

@interface LuaRT : NSObject {
@private
    NSString            *_name;
    NSMutableDictionary *_funcDic;
    NSMutableArray      *_luaFiles;
}
@property(retain, atomic)NSString *name;

+ (LuaRT *)standardLuaRT;

- (void)registerFunction:(const void *)cFunc name:(NSString *)funcName;

- (BOOL)loadLuaScript:(NSString *)scriptName;

- (BOOL)callLuaScript:(NSString *)scriptName
               method:(NSString *)methodName
                 args:(NSArray *)args
           returnType:(LuaRT_ReturnType)returnType
            returnObj:(id*)returnObj;

- (void)reset;
@end


NSDictionary* callLuaScript(NSString *scriptName, NSString* funcName, NSDictionary* args);