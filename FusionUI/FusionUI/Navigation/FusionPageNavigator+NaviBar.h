//
//  FusionPageNavigator+NaviBar.h
//  FusionUI
//
//  Created by ZhangRyou on 1/17/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionPageNavigator.h"

@interface FusionPageNavigator(NaviBar)<UINavigationBarDelegate>
- (void)recoverPushNavigationBar;

- (void)recoverPopNavigationBar;
@end
