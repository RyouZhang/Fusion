//
//  FusionPageNavigator+Manual.h
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionPageNavigator.h"

@class FusionNaviAnime;

@interface FusionPageNavigator(Manual)
- (FusionNaviAnime *)manualOpenPage:(FusionPageMessage *)message;

- (FusionNaviAnime *)manualGotoPage:(FusionPageMessage *)message;
- (FusionNaviAnime *)manualPoptoPage:(FusionPageMessage *)message;
@end
