//
//  NSSet+RemoveNSNULL.m
//  Trip2013
//
//  Created by hongye.hxm on 14-5-29.
//  Copyright (c) 2014年 alibaba. All rights reserved.
//

#import "NSSet+RemoveNSNULL.h"
#import "NSDictionary+RemoveNSNULL.h"
#import "NSArray+RemoveNSNULL.h"
#import "SafeARC.h"

@implementation NSSet (RemoveNSNULL)
- (NSMutableSet *)RemoveNSNull{
    NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:[self count]];
    for (id obj in [set allObjects]) {
        id tmp = nil;
        if(![obj isKindOfClass:[NSNull class]]){
            if([obj isKindOfClass:[NSDictionary class]]){
                tmp = [(NSDictionary*)obj RemoveNSNull];
                if(tmp){
                    [set addObject:tmp];
                }
            }else if([obj isKindOfClass:[NSArray class]]){
                tmp = [(NSArray*)obj RemoveNSNull];
                if(tmp){
                    [set addObject:tmp];
                }
            }else if([obj isKindOfClass:[NSSet class]]){
                tmp = [(NSSet*)obj RemoveNSNull];
                if(tmp){
                    [set addObject:tmp];
                }
            }else{
                [set addObject:obj];
            }
        }
    }
    return SafeAutoRelease(set);
}
@end
