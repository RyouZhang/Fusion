//
//  NSURL+Parser.m
//  TestPageNavi
//
//  Created by Ryou Zhang on 6/19/13.
//  Copyright (c) 2013 Ryou Zhang. All rights reserved.
//

#import "NSURL+Parser.h"
#import "../File/FileHelper.h"
#import "../File/FileKit.h"
#import "SafeARC.h"
#import "../JSON/NSArray+JSON.h"
#import "../JSON/NSDictionary+JSON.h"


@implementation NSURL(Parser)
+ (NSString *)urlEncodedString:(NSString *)sourceText {
	NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)sourceText,
                                                                           NULL,
																		   CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8));
    return SafeAutoRelease(result);
}

+ (NSString *)urlDecodingString:(NSString *)sourceText {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                               (CFStringRef) sourceText,
                                                                               CFSTR(""),
                                                                               kCFStringEncodingUTF8));
}

+ (NSMutableDictionary *)parserQueryText:(NSString *)queryText {
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    const char *queryPtr = [queryText UTF8String];
    NSString *name = nil;
    NSString *value = nil;
    NSInteger start = -1;
    NSInteger length = 0;
    NSNumberFormatter *formater = [NSNumberFormatter new];
       
    for(NSInteger index = 0; index < [queryText length]; index++,queryPtr++) {
        switch ((*queryPtr)) {
            case '=': {
                if (start != -1) {
                    name = [queryText substringWithRange:NSMakeRange(start, length)];
                    start = -1;
                }
            }
                break;
            case '&': {
                if (start != -1) {
                    value = [queryText substringWithRange:NSMakeRange(start, length)];
                    start = -1;
                }
                if (name != nil && value != nil) {
                    [paramDic setValue:[NSURL urlDecodingString:value] forKey:name];
                }
                name = nil;
                value = nil;
            }
                break;
            default: {
                if (start == -1) {
                    start = index;
                    length = 0;
                }
                length++;
            }
                break;
        }
    }
    if (name != nil && start != -1) {
        value = [queryText substringWithRange:NSMakeRange(start, length)];
        [paramDic setValue:[NSURL urlDecodingString:value] forKey:name];
    }
    queryPtr = NULL;
    SafeRelease(formater);
    return SafeAutoRelease(paramDic);
}

+ (NSString *)generateQueryText:(NSDictionary *)params {
    __block NSMutableString *queryText = [NSMutableString new];
    NSArray *keys = [[params allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = [params valueForKey:obj];
        if ([value isKindOfClass:[NSArray class]])
            value = [(NSArray*)value jsonString];
        else if ([value isKindOfClass:[NSDictionary class]])
            value = [(NSDictionary*)value jsonString];
        
        if ([queryText length] == 0) {
            [queryText appendFormat:@"%@=%@",
             [NSURL urlEncodedString:obj],
             [NSURL urlEncodedString:[NSString stringWithFormat:@"%@",value]]];
        } else {
            [queryText appendFormat:@"&%@=%@",
             [NSURL urlEncodedString:obj],
             [NSURL urlEncodedString:[NSString stringWithFormat:@"%@",value]]];
        }
    }];
    return SafeAutoRelease(queryText);
}

+ (NSString *)mergeUrl:(NSString *)urlPath withParams:(NSDictionary *)params {
	NSURL *url = [NSURL URLWithString:urlPath];
    if (url == nil) return urlPath;

	NSMutableDictionary *args = [NSMutableDictionary dictionaryWithDictionary:[NSURL parserQueryText:[url query]]];
	for(NSString *key in [params allKeys]) {
        if ([args valueForKey:key] == nil) {
            [args setValue:[params valueForKey:key]
                    forKey:key];
        }
	}
	NSMutableString *result = [NSMutableString new];
	[result appendFormat:@"%@://",[url scheme]];
	if([url user] && [url password]) {
		[result appendFormat:@"%@:%@",
						[NSURL urlEncodedString:[url user]],
						[NSURL urlEncodedString:[url password]]];
	}
    if ([url host]) {
        [result appendString:[url host]];
    }
	if([url port]) {
		[result appendFormat:@":%@",[url port]];
	}
	[result appendString:[url path]];

	if([args count] != 0) {
		[result appendFormat:@"?%@",[NSURL generateQueryText:args]];
	}
    if ([url fragment]) {
        [result appendFormat:@"#%@",[url fragment]];
    }
    
	return SafeAutoRelease(result);
}

+ (NSURL *)URLWithStringOrFilePath:(NSString *)stringOfFilePath {
    if (stringOfFilePath == nil || stringOfFilePath.length == 0) return nil;
    
    NSURL *url = nil;
    if ([stringOfFilePath rangeOfString:@"://"].location != NSNotFound) {
        url = [NSURL URLWithString:stringOfFilePath];
    } else {
        //优先检查资源文件和core文件目录
        NSString *temp = [NSString stringWithFormat:@"%@/%@",
                          [FileHelper getAppResourceDirectory],
                          stringOfFilePath];
        if ([[FileKit getInstance] isFileExist:temp]) {
            return [NSURL fileURLWithPath:temp];
        }
        temp = [NSString stringWithFormat:@"%@/%@",
                [FileHelper getCoreDirectory],
                stringOfFilePath];
        if ([[FileKit getInstance] isFileExist:temp]) {
            return [NSURL fileURLWithPath:temp];
        }
        
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        if ([stringOfFilePath hasPrefix:resourcePath]) {
            url = [NSURL fileURLWithPath:stringOfFilePath];
        } else {
            NSString *fullPath = [resourcePath stringByAppendingPathComponent:stringOfFilePath];
            url = [NSURL fileURLWithPath:fullPath];
            if (url == nil) {
                NSLog(@"file: '%@' was not found.",stringOfFilePath);
            }
        }
    }
    return url;
}

+(NSString *)relativePathFrom:(NSURL *)baseUrl to:(NSURL *)target {
    if ([[baseUrl host] isEqualToString:[target host]] == NO) {
        return nil;
    }
    
    NSArray *baseNodes = [[baseUrl relativePath] componentsSeparatedByString:@"/"];
    NSArray *targetNodes = [[target relativePath] componentsSeparatedByString:@"/"];
    
    NSInteger base_index = 1;
    NSInteger target_index = 1;
    for (NSInteger index = 1; index < [targetNodes count]; index++) {
        NSString *target_node = [targetNodes objectAtIndex:index];
        NSString *base_node = [baseNodes objectAtIndex:base_index];
        if ([base_node isEqualToString:target_node]) {
            base_index++;
            target_index++;
            continue;
        } else {
            break;
        }
    }
    NSMutableArray *result = [NSMutableArray new];
    for (NSInteger index = base_index; index < [baseNodes count] - 1; index++) {
        [result addObject:@".."];
    }
    for (NSInteger index = target_index; index < [targetNodes count]; index++) {
        [result addObject:[targetNodes objectAtIndex:index]];
    }
    if ([result count] == 0) {
        SafeRelease(result);
        return @"";
    }
    NSString *temp = [result componentsJoinedByString:@"/"];
    SafeRelease(result);
    return temp;
}

+(NSString *)mergeRelativePath:(NSString *)source to:(NSString *)target {
    NSArray *source_nodes = [source componentsSeparatedByString:@"/"];
    NSArray *target_nodes = [target componentsSeparatedByString:@"/"];
    
    NSInteger source_index = 0;
    NSInteger target_index = [target_nodes count] - 1;
    for (NSInteger index = 0; index < [source_nodes count]; index++) {
        source_index = index;
        NSString *source_node = [source_nodes objectAtIndex:index];
        if ([source_node isEqualToString:@".."]) {
            target_index--;
        } else {
            break;
        }
    }
    
    NSMutableArray *result = [NSMutableArray new];
    for (NSInteger index = 0; index < target_index; index++) {
        [result addObject:[target_nodes objectAtIndex:index]];
    }
    for (NSInteger index = source_index; index < [source_nodes count]; index++) {
        [result addObject:[source_nodes objectAtIndex:index]];
    }
    
    NSString *temp = [result componentsJoinedByString:@"/"];
    return temp;
}
@end
