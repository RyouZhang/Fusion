//
//  FusionNaviAnimeHelper.h
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FusionNaviAnime.h"

typedef enum {
    No_NaviAnime        = 0,
    SlideR2L_NaviAnime  = 1,
    SlideL2R_NaviAnime  = 2,
    SlideB2T_NaviAnime  = 3,
    SlideT2B_NaviAnime  = 4,
    ScrollL2R_NaviAnime = 5,
    ScrollR2L_NaviAnime = 6
}NaviAnimeType;


@interface FusionNaviAnimeHelper : NSObject
+ (FusionNaviAnime*)createPageNaviAnime:(NSInteger)animeType
                         animeDirection:(FusionNaviAnimeDirection)direction;
@end
