//
//  LuaCore.m
//  Utility
//
//  Created by Ryou Zhang on 9/9/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import "LuaRT.h"
#import "LuaScriptManager.h"
#import "LuaBridgeHelper.h"
#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"
#import <Enviroment/Enviroment.h>
#import "SafeARC.h"

@interface LuaRT() {
@private
    lua_State *_L;
}
@end

@implementation LuaRT
@synthesize name = _name;

static LuaRT *_standardLuaRT_Instance = nil;
+ (LuaRT *)standardLuaRT {
    @synchronized(self) {
        if(_standardLuaRT_Instance == nil)
            _standardLuaRT_Instance = [LuaRT new];        
    }
    return _standardLuaRT_Instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _luaFiles = [NSMutableArray new];
        _funcDic = [NSMutableDictionary new];
        [self initLuaState];
    }
    return self;
}

- (void)initLuaState {
    _L = luaL_newstate();
    lua_gc(_L, LUA_GCSTOP, 0);
    luaL_openlibs(_L);
    
    if ([[AppEnvironment getInstance] getEnviroment] != App_Test) {
        lua_pushcfunction(_L, &requireEx);
        lua_setglobal(_L, "requireEx");
    } else {
        appendLuaPath(_L, [[LuaScriptManager getInstance] getLuaPath]);
    }
    lua_gc(_L, LUA_GCRESTART, 0);
}

- (void)registerFunction:(const void *)cFunc name:(NSString *)funcName {
    @synchronized(self) {
        [_funcDic setValue:[NSValue valueWithPointer:cFunc] forKey:funcName];
        lua_getglobal(_L, [funcName cStringUsingEncoding:NSUTF8StringEncoding]);
        int type = lua_type(_L, -1);
        if (type == LUA_TFUNCTION) {
            lua_pop(_L, -1);
            return;
        }
        lua_pop(_L, -1);
        lua_pushcfunction(_L, cFunc);
        lua_setglobal(_L, [funcName cStringUsingEncoding:NSUTF8StringEncoding]);
    }
}

- (BOOL)loadLuaScript:(NSString *)scriptName {
    @synchronized(self) {
        int luaFlag = LUA_OK;
        if (NO == [_luaFiles containsObject:scriptName]) {
            NSString *scriptData = [[LuaScriptManager getInstance] getLuaScript:scriptName];
            luaFlag = luaL_dostring(_L, [scriptData cStringUsingEncoding:NSUTF8StringEncoding]);
            if (luaFlag != LUA_OK) {
                NSString *error = [NSString stringWithUTF8String:lua_tostring(_L, -1)];
                lua_pop(_L, -1);
                [self trackLuaSript:scriptName method:@"" error:error];
                return NO;
            }
            [_luaFiles addObject:scriptName];
        }
    }
    return YES;
}

- (BOOL)callLuaScript:(NSString *)scriptName
               method:(NSString *)methodName
                 args:(NSArray *)args
           returnType:(LuaRT_ReturnType)returnType
            returnObj:(id*)returnObj {
    @synchronized(self) {
        int luaFlag = LUA_OK;
        
        *returnObj = NULL;
        
        if (NO == [_luaFiles containsObject:scriptName]) {
            NSString *scriptData = [[LuaScriptManager getInstance] getLuaScript:scriptName];
            luaFlag = luaL_dostring(_L, [scriptData cStringUsingEncoding:NSUTF8StringEncoding]);
            if (luaFlag != LUA_OK) {
                NSString *error = [NSString stringWithUTF8String:lua_tostring(_L, -1)];
                lua_pop(_L, -1);
                [self trackLuaSript:scriptName method:methodName error:error];
                *returnObj = error;
                return NO;
            }
            [_luaFiles addObject:scriptName];
        }
        lua_getglobal(_L, [methodName cStringUsingEncoding:NSUTF8StringEncoding]);
        for (id arg in args) {
            if ([arg isKindOfClass:[NSNumber class]]) {
                if(CFGetTypeID(arg) == CFBooleanGetTypeID()) {
                    lua_pushboolean(_L, [arg boolValue]);
                } else {
                    lua_pushnumber(_L, [arg doubleValue]);
                }
            } else if([arg isKindOfClass:[NSString class]]) {
                lua_pushstring(_L, [arg cStringUsingEncoding:NSUTF8StringEncoding]);
            } else if([arg isKindOfClass:[NSArray class]]) {
                pushArrayToLuaState(arg, _L);
            } else if([arg isKindOfClass:[NSDictionary class]]) {
                pushDictionaryToLuaState(arg, _L);
            } else if ([arg isKindOfClass:[NSNull class]]) {
                lua_pushnil(_L);
            }
        }
        
        luaFlag = lua_pcall(_L, (int)[args count], 1, 0);
        if(luaFlag != LUA_OK) {
            NSString *error = [NSString stringWithUTF8String:lua_tostring(_L, -1)];
            lua_pop(_L, -1);
            [self trackLuaSript:scriptName method:methodName error:error];
            *returnObj = error;
            return NO;
        }
        int type = lua_type(_L, -1);
        if (returnType == LuaRT_Boolean && type == LUA_TBOOLEAN) {
            *returnObj = [NSNumber numberWithBool:lua_toboolean(_L, -1)];
        } else if (returnType == LuaRT_Number && type == LUA_TNUMBER) {
            *returnObj = [NSNumber numberWithDouble:lua_tonumber(_L, -1)];
        } else if (returnType == LuaRT_String && type == LUA_TSTRING) {
            *returnObj = [NSString stringWithUTF8String:lua_tostring(_L, -1)];
        } else if (returnType == LuaRT_Table && type == LUA_TTABLE) {
            *returnObj = pullTableFromLuaState(_L);
        } else if(type == LUA_TNIL) {
            lua_pop(_L, -1);
            return NO;
        }
        
        if (*returnObj == NULL) {
            NSString *error = [NSString stringWithUTF8String:lua_tostring(_L, -1)];
            lua_pop(_L, -1);
            [self trackLuaSript:scriptName method:methodName error:error];
            *returnObj = error;
            return NO;
        }
        lua_pop(_L, -1);
    }
    return YES;
}

- (void)trackLuaSript:(NSString *)script
               method:(NSString *)method
                 error:(NSString *)error {
    trackLuaError(script, method, error);
}

- (void)reset {
    @synchronized(self) {
        lua_close(_L);
        _L = nil;
        [_luaFiles removeAllObjects];
        [self initLuaState];
        for (NSString *funcName in [_funcDic allKeys]) {
            [self registerFunction:[[_funcDic valueForKey:funcName] pointerValue]
                              name:funcName];
        }
    }
}

- (void)dealloc {
    SafeRelease(_name);
    SafeRelease(_funcDic);
    SafeRelease(_luaFiles);
    lua_close(_L);
    SafeSuperDealloc(super);
}
@end

NSDictionary* callLuaScript(NSString *scriptName, NSString* funcName, NSDictionary* args) {
    int luaFlag = LUA_OK;
    lua_State* L = luaL_newstate();
    lua_gc(L, LUA_GCSTOP, 0);
    luaL_openlibs(L);
    lua_gc(L, LUA_GCRESTART, 0);
    
    lua_setglobal(L, "requireEx");
    lua_pushcfunction(L, &requireEx);
    
    NSString* scriptData = [[LuaScriptManager getInstance] getLuaScript:scriptName];
    luaFlag = luaL_dostring(L, [scriptData cStringUsingEncoding:NSUTF8StringEncoding]);
    if(luaFlag != LUA_OK)
    {
        NSString *error = [[NSString alloc] initWithCString:lua_tostring(L, -1)
                                                   encoding:NSUTF8StringEncoding];
        trackLuaError(scriptName, funcName, error);
        SafeRelease(error);
        lua_close(L);
        return nil;
    }
    
    lua_getglobal(L, [funcName cStringUsingEncoding:NSUTF8StringEncoding]);
    pushDictionaryToLuaState(args, L);
    luaFlag = lua_pcall(L, 1, 1, 0);
    if(luaFlag != LUA_OK)
    {
        NSString *error = [[NSString alloc] initWithCString:lua_tostring(L, -1)
                                                   encoding:NSUTF8StringEncoding];
        trackLuaError(scriptName, funcName, error);
        SafeRelease(error);
        lua_close(L);
        return nil;
    }
    NSDictionary *result = pullTableFromLuaState(L);
    lua_close(L);
    return result;
}
