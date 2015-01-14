//
//  FusionNativeMessage.h
//  TestNewCore
//
//  Created by Ryou Zhang on 6/30/13.
//  Copyright (c) 2013 Ryou Zhang. All rights reserved.
//

#import <FusionBase/FusionBase.h>

//schime:   native
//host:     模块的注册名称
//command:  模块下不同命令的注册名称

//message推荐使用状态机模型 所有自定义状态从3开始
#define FusionNativeMessageOrigin 0       //初始状态
#define FusionNativeMessageFinish 1       //完成状态
#define FusionNativeMessageFailed 2       //失败状态
#define FusionNativeMessageMaxNum 99999   //失败状态

#define FusionNativeMessageNotification @"FusionNativeMessageNotification"

@interface FusionNativeMessage : FusionMessage {
@private
//for delay send
    NSTimeInterval  _delay;
    NSTimeInterval  _triggerTime;
    NSUInteger      _state;
//for oring thread info
    NSThread        *_originThread;//only async valid
    NSString        *_workerNick;
//for result
    NSMutableDictionary *_dataTable;
    
//for submessage
    FusionNativeMessage *_parent;
    NSMutableArray      *_children;
}
@property(readwrite, atomic)NSTimeInterval  delay;
@property(readwrite, atomic)NSTimeInterval  triggerTime;

@property(readonly, atomic)NSString *service;
@property(readonly, atomic)NSString *actor;

@property(assign, nonatomic)NSUInteger state;
@property(retain, atomic)NSThread   *originThread;
@property(retain, atomic)NSString   *workerNick;
@property(readonly, atomic)FusionNativeMessage  *parent;
@property(retain, atomic)NSLock *locker;


- (id)initWithSerivice:(NSString *)service
                 actor:(NSString *)actor
                  args:(NSDictionary *)args;

- (NSArray *)getChildren;

- (NSInteger)getChildrenCount;

- (void)insertSubMessage:(FusionNativeMessage *)message;

- (void)removeSubMessage:(FusionNativeMessage *)message;

- (void)clearSubMessage;


-(id)getDataTable;

-(id)getValueFromDataTableWith:(NSString*)key;

-(void)setValue:(id)value ToDataTableWith:(NSString*)key;

-(void)removeValueFromDataTableWith:(NSString*)key;

-(void)clearDataTable;

-(void)importToDataTable:(NSDictionary*)params;
@end
