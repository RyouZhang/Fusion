//
//  FusionPageNavigator+Internal.h
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FusionPageNavigator.h"

@class FusionPageController;

@interface FusionPageNavigator(Internal)
- (UIView*)createPageContentView:(UIViewController<IFusionPageProtocol>*)controller;
- (UIImage*)createContentViewSnapshot:(UIView*)contentView;

- (UIViewController<IFusionPageProtocol> *)findTargetPageController:(FusionPageMessage *)message;

- (void)refreshPageContentView:(UIView*)contentView
                pageController:(UIViewController<IFusionPageProtocol>*)controller;

- (void)garbageCollection;

- (void)processWaittingArray;
@end
