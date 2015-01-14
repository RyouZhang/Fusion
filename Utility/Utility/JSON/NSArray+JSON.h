//
//  NSArray+JSON.h
//  Utility
//
//  Created by Deng Liujun on 8/7/14.
//

#import <Foundation/Foundation.h>

@interface NSArray (JSON)

- (NSString *)jsonString;

+ (NSArray *)dictionaryWithContentsOfJsonFile:(NSString *)path;
- (BOOL)writeToJsonFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;

@end
