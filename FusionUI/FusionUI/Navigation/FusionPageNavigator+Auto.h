//
//  FusionPageNavigator+Manual.h
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionPageNavigator.h"

@interface FusionPageNavigator(Auto)
- (void)openPage:(FusionPageMessage *)message;

- (void)gotoPage:(FusionPageMessage *)message;
- (void)poptoPage:(FusionPageMessage *)message;
@end
