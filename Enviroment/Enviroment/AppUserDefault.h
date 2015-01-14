//
//  AppUserDefault.h
//  FusionApp
//
//  Created by Ryou Zhang on 1/10/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AppUserDefault : NSObject {
    
}
+ (AppUserDefault *)getInstance;

- (id)getValueWithKey:(NSString*)key;
- (void)setValue:(id)value withKey:(NSString *)key;
@end
