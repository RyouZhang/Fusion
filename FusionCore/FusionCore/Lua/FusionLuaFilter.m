//
//  FusionLuaFilter.m
//  TestNewCore
//
//  Created by Ryou Zhang on 7/5/13.
//  Copyright (c) 2013 Ryou Zhang. All rights reserved.
//

#import "FusionLuaFilter.h"
#import "FusionLuaBridge.h"
#import "../FusionNativeMessage.h"
#import "../FusionThread.h"
#import <Utility/Utility.h>
#import "SafeARC.h"

@implementation FusionLuaFilter
-(BOOL)filterFusionNativeMessage:(FusionNativeMessage *)message {
    assert([[NSThread currentThread] isKindOfClass:[FusionThread class]]);
    lua_State *L = NULL;
    
    FusionThread *thread = (FusionThread*)[NSThread currentThread];
    if (thread->L != NULL) {
        L = thread->L;
    } else {
        L = luaL_newstate();
        lua_gc(L, LUA_GCSTOP, 0);
        luaL_openlibs(L);
        luaRegisterFusionMessageFunctions(L);
        lua_gc(L, LUA_GCRESTART, 0);
        thread->L = L;
    }
    
    int luaFlag = LUA_OK;
    
    lua_State *subL = nil;
    int count = lua_checkstack(L, 1);
    if (count == 0) {
        return YES;
    }
    
    subL = lua_newthread(L);
    NSString* scriptData = [[LuaScriptManager getInstance] getLuaScript:[_config valueForKey:@"script"]];
    luaFlag = luaL_dostring(subL, [scriptData cStringUsingEncoding:NSUTF8StringEncoding]);
    if(luaFlag != LUA_OK) {
        NSString *error = [[NSString alloc] initWithCString:lua_tostring(subL, -1)
                                                   encoding:NSUTF8StringEncoding];
        trackLuaError([_config valueForKey:@"script"], [_config valueForKey:@"entry"], error);
        SafeRelease(error);
        lua_pop(L, -1);
        return YES;
    }
    [message setValue:[NSValue valueWithPointer:subL] ToDataTableWith:Actor_Lua_State];
    
    lua_getglobal(subL, [[_config valueForKey:@"entry"] cStringUsingEncoding:NSUTF8StringEncoding]);
    lua_pushlightuserdata(subL, &message);
    pushDictionaryToLuaState(_config, subL);
    luaFlag = lua_resume(subL, 2);
    if(luaFlag != LUA_OK) {
        NSString *error = [[NSString alloc] initWithCString:lua_tostring(subL, -1)
                                                   encoding:NSUTF8StringEncoding];
        trackLuaError([_config valueForKey:@"script"], [_config valueForKey:@"entry"], error);
        SafeRelease(error);
        lua_pop(L, -1);
        return YES;
    }
    BOOL result = lua_toboolean(subL, 1);
    lua_pop(L, -1);
    return result;
}
@end
