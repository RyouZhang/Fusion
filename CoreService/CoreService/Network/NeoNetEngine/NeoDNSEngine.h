//
//  NeoDNSEngine.h
//  CoreService
//
//  Created by Ryou Zhang on 12/4/14.
//  Copyright (c) 2014 trip.taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NeoNetTask;

#define NeoDNSEngineLookupFinsih    @"NeoDNSEngineLookupFinsih"

@interface NeoDNSEngine : NSObject {
    
}
+ (NeoDNSEngine*)getInstance;

- (NSString *)findResolveInfo:(NSString *)host;

- (void)asyncStartLookup:(NeoNetTask *)task;
- (void)asyncCancelLookup:(NeoNetTask *)task;
@end
