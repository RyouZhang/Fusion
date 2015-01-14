//
//  NSString+JSON.m
//  Trip2013
//
//  Created by Ryou Zhang on 7/22/13.
//  Copyright (c) 2013 alibaba. All rights reserved.
//

#import "NSString+JSON.h"
#import "NSDictionary+RemoveNSNull.h"
#import "NSArray+RemoveNSNull.h"

@implementation NSString (JSON)
- (id)jsonObject {
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                                options:NSJSONReadingMutableContainers
                                                  error:&error];
    if (error || [NSJSONSerialization isValidJSONObject:result] == NO)
        return nil;

    return [result RemoveNSNull];
}
@end
