//
//  FusionOrFilter.h
//  FusionCore
//
//  Created by Ryou Zhang on 8/11/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FusionFilter.h"

@interface FusionOrFilter : FusionFilter {
@private
    NSMutableArray *_filterArray;
}
@end
