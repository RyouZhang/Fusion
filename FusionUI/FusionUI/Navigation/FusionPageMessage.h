//
//  FusionPageMessage.h
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import <FusionBase/FusionBase.h>

#define FusionPageHost    @"pagehost"

@interface FusionPageMessage : FusionMessage {
@private
    NSString    *_pageNick;
    NSURL       *_callbackUrl;
    
    NSUInteger  _naviAnimeType;
    NSUInteger  _naviAnimeDirection;
    
    BOOL        _isDestory;
}
@property(readonly)NSString *pageName;
@property(readonly)NSString *command;
@property(retain, atomic)NSString   *pageNick;
@property(retain, readonly, atomic)NSURL    *callbackUrl;
@property(assign, atomic)NSUInteger naviAnimeType;
@property(assign, atomic)NSUInteger naviAnimeDirection;
@property(assign, atomic)BOOL   isDestory;

- (id)initWithPageName:(NSString *)pageName
              pageNick:(NSString *)pageNick
               command:(NSString *)command
                  args:(NSDictionary *)args
              callback:(NSURL *)callback;

- (id)initWithURL:(NSURL *)url
             args:(NSDictionary*)args;
@end
