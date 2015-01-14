//
//  EasyActionLuaHelper.m
//  TestRotation
//
//  Created by RyouZhang on 12-12-9.
//  Copyright (c) 2012年 RyouZhang. All rights reserved.
//

#import "FusionLuaBridge.h"
#import "../FusionCore.h"

//FusionNativeMessage Bridge
int createSubMessage(lua_State* L) {
    FusionNativeMessage* parent = nil;
    if(lua_isuserdata(L,1))
        parent = *(PFusionNativeMessage*)lua_touserdata(L,1);
    
    [parent createSubMessageWithScheme:[NSString stringWithUTF8String:lua_tostring(L, 2)]
                               Service:[NSString stringWithUTF8String:lua_tostring(L, 3)]
                                 Actor:[NSString stringWithUTF8String:lua_tostring(L, 4)]
                                Params:pullTableFromLuaState(L)];
    return 1;
}

int clearSubMessage(lua_State* L) {
    FusionNativeMessage* parent = nil;
    if(lua_isuserdata(L,1))
        parent = *(PFusionNativeMessage*)lua_touserdata(L,1);
    [parent clearSubMessage];
    return 1;
}

int dispatchFusionNativeMessage(lua_State* L) {
    FusionNativeMessage* message = *((PFusionNativeMessage*)lua_topointer(L, 1));
    [[FusionCore getInstance] dispatchMessageArray:[message getChildren]];
    return 1;
}

int getMessageParams(lua_State* L) {
    FusionNativeMessage* message = *((PFusionNativeMessage*)lua_topointer(L, 1));
    NSDictionary* args = generateArgsLuaTable([message params]);
    pushTableToLuaState(args, L);
    return 1;
}

int setValueToDataTable(lua_State* L) {
    FusionNativeMessage* message = *((PFusionNativeMessage*)lua_topointer(L, 1));
    
    id args = pullTableFromLuaState(L);
    [message importToDataTable:args];
    return 1;
}

int removeValueFromDataTable(lua_State* L) {
    FusionNativeMessage* message = *((PFusionNativeMessage*)lua_topointer(L, 1));
    
    id keys = pullTableFromLuaState(L);
    for(NSString* key in keys)
        [message removeValueFromDataTableWith:key];
    return 1;
}

int setFusionMessageState(lua_State* L) {
    FusionNativeMessage* message = *((PFusionNativeMessage*)lua_topointer(L, 1));
    [message setState:lua_tointeger(L, 2)];
    return 1;
}

int getDataTable(lua_State* L) {
    FusionNativeMessage* message = *((PFusionNativeMessage*)lua_topointer(L, 1));
    NSDictionary* dataTable = generateArgsLuaTable([message getDataTable]);
    pushTableToLuaState(dataTable, L);
    return 1;
}

void luaRegisterFusionMessageFunctions(lua_State* L) {
    lua_pushcfunction(L, &createSubMessage);
    lua_setglobal(L,"createSubMessage");
    lua_pushcfunction(L, &clearSubMessage);
    lua_setglobal(L, "clearSubMessage");
    lua_pushcfunction(L, &dispatchFusionNativeMessage);
    lua_setglobal(L,"dispatchFusionNativeMessage");
    lua_pushcfunction(L, &getDataTable);
    lua_setglobal(L, "getDataTable");
    lua_pushcfunction(L, &setValueToDataTable);
    lua_setglobal(L,"setValueToDataTable");
    lua_pushcfunction(L, &getMessageParams);
    lua_setglobal(L,"getMessageParams");
    lua_pushcfunction(L, &removeValueFromDataTable);
    lua_setglobal(L,"removeValueFromDataTable");
    lua_pushcfunction(L, &setFusionMessageState);
    lua_setglobal(L,"setFusionMessageState");
}