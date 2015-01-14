//
//  NSDictionary+RemoveNSNull.m
//  Trip2013
//
//  Created by hongye.hxm on 14-5-29.
//  Copyright (c) 2014年 alibaba. All rights reserved.
//

#import "NSDictionary+RemoveNSNULL.h"
#import "NSArray+RemoveNSNULL.h"
#import "NSSet+RemoveNSNULL.h"
#import "SafeARC.h"

@implementation NSDictionary (RemoveNSNull)
- (NSMutableDictionary *)RemoveNSNull{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
    for (NSString *key in [self allKeys]) {
        id obj = [self valueForKey:key];
        id tmp = nil;
        if(![obj isKindOfClass:[NSNull class]]){
            if([obj isKindOfClass:[NSDictionary class]]){
                tmp = [(NSDictionary*)obj RemoveNSNull];
                if(tmp){
                    [dic setValue:tmp forKeyPath:key];
                }
            }else if([obj isKindOfClass:[NSArray class]]){
                tmp = [(NSArray*)obj RemoveNSNull];
                if(tmp){
                    [dic setValue:tmp forKeyPath:key];
                }
            }else if([obj isKindOfClass:[NSSet class]]){
                tmp = [(NSSet*)obj RemoveNSNull];
                if(tmp){
                    [dic setValue:tmp forKeyPath:key];
                }
            }else{
                [dic setValue:obj forKeyPath:key];
            }
        }
    }
    return SafeAutoRelease(dic);
}
@end
