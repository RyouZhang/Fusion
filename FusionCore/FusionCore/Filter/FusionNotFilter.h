//
//  FusionNotFilter.h
//  FusionCore
//
//  Created by Ryou Zhang on 8/11/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FusionFilter.h"

@interface FusionNotFilter : FusionFilter {
@private
    FusionFilter *_filter;
}
@end
