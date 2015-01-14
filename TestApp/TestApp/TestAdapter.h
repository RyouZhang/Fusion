//
//  TestAdapter.h
//  TestApp
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FusionUI/FusionUI.h>

@interface TestAdapter : NSObject<IFusionPageAdapterProtocol> {
}
+ (TestAdapter *)getInstance;
@end
