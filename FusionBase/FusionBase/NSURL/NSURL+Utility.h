//
//  NSURL+Parser.h
//  TestPageNavi
//
//  Created by Ryou Zhang on 6/19/13.
//  Copyright (c) 2013 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Utility)
+(NSString *)urlEncodedString:(NSString *)sourceText;
+(NSString *)urlDecodingString:(NSString *)sourceText;

+(NSMutableDictionary *)parserQueryText:(NSString *)queryText;
+(NSString *)generateQueryText:(NSDictionary *)params;

+(NSString *)mergeUrl:(NSString *)urlPath withParams:(NSDictionary *)params;
+(NSString *)relativePathFrom:(NSURL *)baseUrl to:(NSURL *)target;
+(NSString *)mergeRelativePath:(NSString *)source to:(NSString *)target;
@end
