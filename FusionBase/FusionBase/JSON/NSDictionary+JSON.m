//
//  NSDictionary+JSON.m
//  Utility
//
//  Created by Deng Liujun on 8/7/14.
//

#import "NSDictionary+JSON.h"
#import "NSDictionary+RemoveNSNull.h"
#import "SafeARC.h"

@implementation NSDictionary (JSON)
- (NSString *)jsonString {
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self RemoveNSNull]
                                                           options:0
                                                             error:&error];
        if (error)
            return nil;
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return SafeAutoRelease(jsonString);
    } else {
        return nil;
    }
}

+ (NSDictionary *)dictionaryWithContentsOfJsonFile:(NSString *)path {
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:path];
    if (!jsonData) {
        return nil;
    }
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:jsonData
                                             options:0
                                               error:&error];
    SafeRelease(jsonData);
    if (error || !obj || ![obj isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSDictionary *result = [obj RemoveNSNull];
    SafeRelease(obj);
    return result;
}

- (BOOL)writeToJsonFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self RemoveNSNull]
                                                       options:0
                                                         error:&error];
    if (error)
        return NO;
    
    return [jsonData writeToFile:path atomically:useAuxiliaryFile];
}
@end
