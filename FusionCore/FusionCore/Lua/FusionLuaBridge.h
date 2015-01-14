//
//  EasyActionLuaHelper.h
//  TestRotation
//
//  Created by RyouZhang on 12-12-9.
//  Copyright (c) 2012年 RyouZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../FusionNativeMessage.h"
#import <Utility/Utility.h>

#define Actor_Lua_State         @"Actor_Lua_State"

typedef FusionNativeMessage* PFusionNativeMessage;

//FusionNativeMessage
int getMessageParams(lua_State* L);

int createSubMessage(lua_State* L);
int clearSubMessage(lua_State* L);

int dispatchFusionNativeMessage(lua_State* L);

int setValueToDataTable(lua_State* L);
int getDataTable(lua_State* L);
int removeValueFromDataTable(lua_State* L);

int setFusionMessageState(lua_State* L);

void luaRegisterFusionMessageFunctions(lua_State* L);