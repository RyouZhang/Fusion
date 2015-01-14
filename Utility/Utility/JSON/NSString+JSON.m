//
//  NSString+JSON.m
//  Trip2013
//
//  Created by Ryou Zhang on 7/22/13.
//  Copyright (c) 2013 alibaba. All rights reserved.
//

#import "NSString+JSON.h"

extern void dictionaryFilterNullNode(NSMutableDictionary*);
extern void arrayFilterNullNode(NSMutableArray*);

void inline dictionaryFilterNullNode(NSMutableDictionary *dic) {
    NSMutableArray *deleteKeys = [NSMutableArray new];
    [[dic allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = [dic objectForKey:obj];
        if ([value isKindOfClass:[NSNull class]]) {
            [deleteKeys addObject:obj];
        } else if([value isKindOfClass:[NSMutableArray class]]) {
            arrayFilterNullNode(value);
        } else if([value isKindOfClass:[NSMutableDictionary class]]) {
            dictionaryFilterNullNode(value);
        }
    }];
    [deleteKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [dic removeObjectForKey:obj];
    }];
}

void inline arrayFilterNullNode(NSMutableArray *array) {
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSMutableDictionary class]]) {
            dictionaryFilterNullNode(obj);
        }
    }];
}

@implementation NSString (JSON)
- (id)jsonObject {
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                                options:NSJSONReadingMutableContainers
                                                  error:&error];
    if (error || [NSJSONSerialization isValidJSONObject:result] == NO)
        return nil;
    
//    if ([result isKindOfClass:[NSMutableArray class]]) {
//        arrayFilterNullNode(result);
//    } else if([result isKindOfClass:[NSMutableDictionary class]]) {
//        dictionaryFilterNullNode(result);
//    }
    return result;
}
@end
