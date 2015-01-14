//
//  NeoHttpPostTask.h
//  TestLibuv
//
//  Created by Ryou Zhang on 6/14/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import "NeoHttpTask.h"

@interface NeoHttpPostTask : NeoHttpTask {
@private
    NSDictionary    *_postFields;
}
@property(retain, atomic)NSDictionary   *postFields;
@end
