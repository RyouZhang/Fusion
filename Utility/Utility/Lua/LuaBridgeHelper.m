//
//  LuaBridgeHelper.m
//  Utility
//
//  Created by Ryou Zhang on 8/12/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import "LuaBridgeHelper.h"
#import "LuaScriptManager.h"
#import "SafeARC.h"

int appendLuaPath( lua_State *L, NSString* path ) {
    lua_getglobal( L, "package" );
    lua_getfield( L, -1, "path" ); // get field "path" from table at top of stack (-1)
    NSString * cur_path = [NSString stringWithUTF8String:lua_tostring( L, -1 )]; // grab path string from top of stack
    cur_path = [cur_path stringByAppendingString:@";"]; // do your path magic here
    cur_path = [cur_path stringByAppendingString:path];
    cur_path = [cur_path stringByAppendingString:@"/?.lua"];
    lua_pop( L, 1 ); // get rid of the string on the stack we just pushed on line 5
    lua_pushstring( L, [cur_path UTF8String]); // push the new one
    lua_setfield( L, -2, "path" ); // set the field "path" in table at -2 with value at top of stack
    lua_pop( L, 1 ); // get rid of package table from top of stack
    return 0; // all done!
}

NSDictionary* generateArgsLuaTable(NSDictionary* source) {
    NSMutableDictionary* target = [NSMutableDictionary new];
    for(NSString* key in [source allKeys])
        [target setValue:[source valueForKey:key]
                  forKey:key];
    return SafeAutoRelease(target);
}

void pushArrayToLuaState(NSArray* data, lua_State* L) {
    lua_newtable(L);
    for(NSUInteger index=0; index<[data count]; index++) {
        id value = [data objectAtIndex:index];
        if([value isKindOfClass:[NSNumber class]]) {
            if(CFGetTypeID(value) == CFBooleanGetTypeID()) {
                lua_pushnumber(L, index+1);
                lua_pushboolean(L, [value boolValue]);
                lua_settable(L, -3);
            } else {
                lua_pushnumber(L, index+1);
                lua_pushnumber(L, [value doubleValue]);
                lua_settable(L, -3);
            }
        } else if([value isKindOfClass:[NSString class]]) {
            lua_pushnumber(L, index+1);
            lua_pushstring(L, [value cStringUsingEncoding:NSUTF8StringEncoding]);
            lua_settable(L, -3);
        } else if([value isKindOfClass:[NSDictionary class]]) {
            lua_pushnumber(L, index+1);
            pushDictionaryToLuaState(value, L);
            lua_settable(L, -3);
        } else if([value isKindOfClass:[NSArray class]]) {
            lua_pushnumber(L, index+1);
            pushArrayToLuaState(value, L);
            lua_settable(L, -3);
        }
    }
}

void pushDictionaryToLuaState(NSDictionary* data, lua_State* L) {
    lua_newtable(L);
    if ([[data allKeys] count] == 0) {
        lua_pushstring(L, "__JsonType");
        lua_pushstring(L, "JObject");
        lua_settable(L, -3);
        return;
    }
    for(NSString* key in [data allKeys]) {
        id value = [data valueForKey:key];
        if([value isKindOfClass:[NSNumber class]]) {
            if(CFGetTypeID(value) == CFBooleanGetTypeID()) {
                lua_pushstring(L, [key cStringUsingEncoding:NSUTF8StringEncoding]);
                lua_pushboolean(L, [value boolValue]);
                lua_settable(L, -3);
            } else {
                lua_pushstring(L, [key cStringUsingEncoding:NSUTF8StringEncoding]);
                lua_pushnumber(L, [value doubleValue]);
                lua_settable(L, -3);
            }
        } else if([value isKindOfClass:[NSString class]]) {
            lua_pushstring(L, [key cStringUsingEncoding:NSUTF8StringEncoding]);
            lua_pushstring(L, [value cStringUsingEncoding:NSUTF8StringEncoding]);
            lua_settable(L, -3);
        } else if([value isKindOfClass:[NSDictionary class]]) {
            lua_pushstring(L, [key cStringUsingEncoding:NSUTF8StringEncoding]);
            pushDictionaryToLuaState(value, L);
            lua_settable(L, -3);
        } else if([value isKindOfClass:[NSArray class]]) {
            lua_pushstring(L, [key cStringUsingEncoding:NSUTF8StringEncoding]);
            pushArrayToLuaState(value, L);
            lua_settable(L, -3);
        } else if([value isKindOfClass:[NSValue class]]) {
            lua_pushstring(L, [key cStringUsingEncoding:NSUTF8StringEncoding]);
            lua_pushlightuserdata(L, [value pointerValue]);
            lua_settable(L, -3);
        }
    }
}

void pushTableToLuaState(id data, lua_State* L) {
    if([data isKindOfClass:[NSArray class]])
        pushArrayToLuaState(data, L);
    else if([data isKindOfClass:[NSDictionary class]])
        pushDictionaryToLuaState(data, L);
}

id pullTableFromLuaState(lua_State* L) {
    NSMutableArray *keys = [NSMutableArray new];
    NSMutableArray *values = [NSMutableArray new];
    
    BOOL isArray = YES;
    
    lua_pushnil(L);
    while (lua_next(L, -2)) {
        int type = lua_type(L, -2);
        if (type == LUA_TSTRING) {
            NSString* key = [NSString stringWithCString:lua_tostring(L, -2)
                                               encoding:NSUTF8StringEncoding];
            [keys addObject:key];
            isArray = NO;
        } else if(type == LUA_TNUMBER){
            [keys addObject:[NSNumber numberWithInteger:lua_tointeger(L, -2)]];
        } else {
            assert(NO);
        }
        type = lua_type(L, -1);
        switch(type) {
            case LUA_TBOOLEAN: {
                [values addObject:[NSNumber numberWithBool:lua_toboolean(L, -1)]];
            }
                break;
            case LUA_TNUMBER: {
                [values addObject:[NSNumber numberWithDouble:lua_tonumber(L, -1)]];
            }
                break;
            case LUA_TSTRING: {
                NSString* value = [NSString stringWithCString:lua_tostring(L, -1)
                                                     encoding:NSUTF8StringEncoding];
                [values addObject:value];
                break;
            }
            case LUA_TTABLE: {
                id temp = pullTableFromLuaState(L);
                if ([temp isKindOfClass:[NSDictionary class]] &&
                    [[temp allKeys] count] == 0 ) {
                        [values addObject:[NSArray array]];
                } else {
                    [temp setValue:nil forKey:@"__JsonType"];
                    [values addObject:temp];
                }
                break;
            }
            case LUA_TFUNCTION: {
                [values addObject:[NSValue valueWithPointer:lua_topointer(L, -1)]];
                break;
            }
            case LUA_TTHREAD: {
                [values addObject:[NSValue valueWithPointer:lua_topointer(L, -1)]];
                break;
            }
            case LUA_TNIL: {
                [values addObject:[NSNull null]];
                break;
            }
        }
        lua_pop(L, 1);
    }
    if (isArray) {
        SafeRelease(keys);
        return SafeAutoRelease(values);
    } else {
        NSMutableArray *temp = [NSMutableArray new];
        for (id key in keys) {
            [temp addObject:[NSString stringWithFormat:@"%@", key]];
        }
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithObjects:values
                                                                         forKeys:temp];
        SafeRelease(temp);
        SafeRelease(keys);
        SafeRelease(values);
        return result;
    }
}

void trackLuaError(NSString *scriptName, NSString *funcName, NSString *error) {
    NSMutableDictionary *args = [NSMutableDictionary new];
    [args setValue:scriptName forKey:@"script"];
    [args setValue:funcName forKey:@"func"];
    [args setValue:error forKey:@"error"];
//TODO track
    SafeRelease(args);
}

int requireEx(lua_State *L) {
    NSString *scriptName = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    NSString* scriptData = [[LuaScriptManager getInstance] getLuaScript:scriptName];
    luaL_dostring(L, [scriptData cStringUsingEncoding:NSUTF8StringEncoding]);
    return 1;
}
