//
//  NSArray+JSON.m
//  Utility
//
//  Created by Deng Liujun on 8/7/14.
//

#import "NSArray+JSON.h"

@implementation NSArray (JSON)
- (NSString *)jsonString {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:0
                                                         error:&error];
    if (error)
        return nil;
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;        
}

+ (NSArray *)dictionaryWithContentsOfJsonFile:(NSString *)path {
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:path];
    if (!jsonData) {
        return nil;
    }
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:jsonData
                                             options:0
                                               error:&error];
    if (error || !obj || ![obj isKindOfClass:[NSArray class]]) {
        return nil;
    }
    return obj;
}

- (BOOL)writeToJsonFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:0
                                                         error:&error];
    if (error)
        return NO;
    
    return [jsonData writeToFile:path atomically:useAuxiliaryFile];
}

@end
