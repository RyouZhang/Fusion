//
//  EasyActionLuaSlot.m
//  TestRotation
//
//  Created by RyouZhang on 12-12-8.
//  Copyright (c) 2012年 RyouZhang. All rights reserved.
//

#import "FusionLuaActor.h"
#import "FusionLuaBridge.h"
#import "../FusionThread.h"
#import <Utility/Utility.h>
#import "SafeARC.h"

@implementation FusionLuaActor
- (void)closeLuaThread:(lua_State*)subL {
    assert([[NSThread currentThread] isKindOfClass:[FusionThread class]]);
    FusionThread *thread = (FusionThread*)[NSThread currentThread];
    lua_State *L = thread->L;
    assert(L != NULL);
    int top = lua_gettop(L);
    for (int i = 1; i <= top; i++) {
        lua_State *ptr = lua_tothread(L, i);
        if (ptr != NULL && ptr == subL) {
            lua_remove(L, i);
            return;
        }
    }
}

-(void)processFusionNativeMessage:(FusionNativeMessage *)message {
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
        [message setState:FusionNativeMessageFailed];
        return;
    }
    subL = lua_newthread(L);
    [message setValue:[NSValue valueWithPointer:subL] forUndefinedKey:Actor_Lua_State];
    NSString* scriptData = [[LuaScriptManager getInstance] getLuaScript:[_config valueForKey:@"script"]];
    luaFlag = luaL_dostring(subL, [scriptData cStringUsingEncoding:NSUTF8StringEncoding]);
    if(luaFlag != LUA_OK) {
        NSString *error = [[NSString alloc] initWithCString:lua_tostring(subL, -1)
                                                   encoding:NSUTF8StringEncoding];
        trackLuaError([_config valueForKey:@"script"], [_config valueForKey:@"enter"], error);
        SafeRelease(error);
        [self closeLuaThread:subL];
        [message setState:FusionNativeMessageFailed];
        return;
    }
    
    lua_getglobal(subL, [[_config valueForKey:@"enter"] cStringUsingEncoding:NSUTF8StringEncoding]);
    lua_pushlightuserdata(subL, &message);
    luaFlag = lua_resume(subL, 1);
    
    if(luaFlag != LUA_OK && luaFlag != LUA_YIELD) {
        NSString *error = [[NSString alloc] initWithCString:lua_tostring(subL, -1)
                                                   encoding:NSUTF8StringEncoding];
        trackLuaError([_config valueForKey:@"script"], [_config valueForKey:@"enter"], error);
        SafeRelease(error);
        
        [message setValue:nil forUndefinedKey:Actor_Lua_State];
        [self closeLuaThread:subL];
        [message setState:FusionNativeMessageFailed];
        return;
    }
    
    if([message state] == FusionNativeMessageFinish ||
       [message state] == FusionNativeMessageFailed) {
        [message setValue:nil forUndefinedKey:Actor_Lua_State];
        [self closeLuaThread:subL];
    }
}

-(void)processCallbackMessage:(FusionNativeMessage *)message
                ParentMessage:(FusionNativeMessage *)parent {
    lua_State* subL = (lua_State*)[[parent valueForKey:Actor_Lua_State] pointerValue];
    int luaFlag = LUA_ERRERR;
    
    lua_pushlightuserdata(subL, &parent);
    lua_pushlightuserdata(subL, &message);
    luaFlag = lua_resume(subL, 2);
    
    if(luaFlag != LUA_OK) {
        NSString *error = [[NSString alloc] initWithCString:lua_tostring(subL, -1)
                                                   encoding:NSUTF8StringEncoding];
        trackLuaError([_config valueForKey:@"script"], [_config valueForKey:@"enter"], error);
        SafeRelease(error);
        
        [parent setValue:nil forUndefinedKey:Actor_Lua_State];
        [self closeLuaThread:subL];
        [parent setState:FusionNativeMessageFailed];
        return;
    }
    
    if([parent state] == FusionNativeMessageFinish ||
       [parent state] == FusionNativeMessageFailed) {
        [parent removeValueFromDataTableWith:Actor_Lua_State];
        [self closeLuaThread:subL];
    }
}

-(void)cancelFusionNativeMessage:(FusionNativeMessage *)message {
    lua_State* subL = (lua_State*)[[message getValueFromDataTableWith:Actor_Lua_State] pointerValue];
    [message removeValueFromDataTableWith:Actor_Lua_State];
    [self closeLuaThread:subL];
    [super cancelFusionNativeMessage:message];
}

-(void)dealloc {
    SafeSuperDealloc(super);
}
@end
