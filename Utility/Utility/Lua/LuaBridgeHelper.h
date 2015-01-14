//
//  LuaBridgeHelper.h
//  Utility
//
//  Created by Ryou Zhang on 8/12/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "lua.h"
#import "lauxlib.h"
#import "lualib.h"

int requireEx(lua_State *L);

int appendLuaPath(lua_State *L, NSString *path);

NSDictionary* generateArgsLuaTable(NSDictionary* source);

void pushArrayToLuaState(NSArray* data, lua_State* L);
void pushDictionaryToLuaState(NSDictionary* data, lua_State* L);
void pushTableToLuaState(id data, lua_State* L);

id pullTableFromLuaState(lua_State* L);

void trackLuaError(NSString *scriptName, NSString *funcName, NSString *error);
