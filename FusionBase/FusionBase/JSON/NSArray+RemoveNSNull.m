//
//  NSArray+RemoveNSNULL.m
//  Trip2013
//
//  Created by hongye.hxm on 14-5-29.
//  Copyright (c) 2014年 alibaba. All rights reserved.
//

#import "NSArray+RemoveNSNULL.h"
#import "NSDictionary+RemoveNSNULL.h"
#import "NSSet+RemoveNSNULL.h"
#import "SafeARC.h"

@implementation NSArray (RemoveNSNULL)
- (NSMutableArray *)RemoveNSNull{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[self count]];
    for (id obj in self) {
        id tmp = nil;
        if(![obj isKindOfClass:[NSNull class]]){
            if([obj isKindOfClass:[NSDictionary class]]){
                tmp = [(NSDictionary*)obj RemoveNSNull];
                if(tmp){
                    [array addObject:tmp];
                }
            }else if([obj isKindOfClass:[NSArray class]]){
                tmp = [(NSArray*)obj RemoveNSNull];
                if(tmp){
                    [array addObject:tmp];
                }
            }else if([obj isKindOfClass:[NSSet class]]){
                tmp = [(NSSet*)obj RemoveNSNull];
                if(tmp){
                    [array addObject:tmp];
                }
            }else{
                [array addObject:obj];
            }
        }
    }
    return SafeAutoRelease(array);
}
@end
