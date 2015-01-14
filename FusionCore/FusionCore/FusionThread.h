//
//  FusionThread.h
//  TestNewCore
//
//  Created by Ryou Zhang on 6/30/13.
//  Copyright (c) 2013 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Utility/Utility.h>

@protocol FusionThreadDelegate <NSObject>
- (void)onFusionThreadUpdate;
@end


@interface FusionThread : NSThread {
@private
    NSTimeInterval  _interval;
    NSString        *_nickName;
    __unsafe_unretained id<FusionThreadDelegate> _delegate;
@public
    lua_State       *L;
}
@property(retain, atomic)NSString *nickName;
@property(readwrite, atomic)NSTimeInterval interval;
@property(assign, atomic)id<FusionThreadDelegate> delegate;
@end
