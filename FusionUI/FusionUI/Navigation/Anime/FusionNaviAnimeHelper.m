//
//  FusionNaviAnimeHelper.m
//  FusionUI
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "FusionNaviAnimeHelper.h"
#import "SafeARC.h"

@implementation FusionNaviAnimeHelper
+ (FusionNaviAnime*)createPageNaviAnime:(NSInteger)animeType
                         animeDirection:(FusionNaviAnimeDirection)direction;{
    FusionNaviAnime *anime = nil;
    switch (animeType) {
        case SlideR2L_NaviAnime:
            anime = [NSClassFromString(@"FusionSlideR2LAnime") new];
            break;
        case SlideL2R_NaviAnime:
            anime = [NSClassFromString(@"FusionSlideL2RAnime") new];
            break;
        case ScrollL2R_NaviAnime:
            anime = [NSClassFromString(@"FusionScrollL2RAnime") new];
            break;
        case ScrollR2L_NaviAnime:
            anime = [NSClassFromString(@"FusionScrollR2LAnime") new];
            break;
        case SlideB2T_NaviAnime:
            anime = [NSClassFromString(@"FusionSlideB2TAnime") new];
            break;
        case SlideT2B_NaviAnime:
            anime = [NSClassFromString(@"FusionSlideT2BAnime") new];
            break;
        case No_NaviAnime:
            return nil;
        default:
            return nil;
    }
    [anime setDirection:direction];
    return SafeAutoRelease(anime);
}
@end
