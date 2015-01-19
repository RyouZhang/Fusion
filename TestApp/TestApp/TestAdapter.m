//
//  TestAdapter.m
//  TestApp
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "TestAdapter.h"
#import "SafeARC.h"

@implementation TestAdapter
static TestAdapter *_TestAdapter_Instance = nil;
+ (TestAdapter *)getInstance {
    _TestAdapter_Instance = [TestAdapter new];
    return _TestAdapter_Instance;
}

- (UIViewController<IFusionPageProtocol> *)generateFusionPageController:(NSDictionary *)pageConfig {
    UIViewController<IFusionPageProtocol> *target = [[NSClassFromString([pageConfig valueForKey:@"class"]) alloc] initWithConfig:pageConfig];
    return SafeAutoRelease(target);
}

- (NSDictionary *)getPageConfig:(NSString *)pageName {
    if ([pageName isEqualToString:@"TestPageA"]) {
        return @{
                 @"pageName": @"TestPageA",
                 @"class": @"TestAPageController",
                 @"title": @"Hello world",
                 @"tabbar_name": @"TestTabBar",
                 @"singleton": @YES
                 };
    } else if ([pageName isEqualToString:@"TestPageB"]) {
        return @{
                 @"pageName": @"TestPageB",
                 @"class": @"TestBPageController",
                 @"title": @"Hello world",
                 @"tabbar_name": @"TestTabBar",
                 @"singleton": @YES
                 };
    } else if ([pageName isEqualToString:@"TestPageC"]) {
        return @{
                 @"pageName": @"TestPageC",
                 @"class": @"TestCPageController",
                 @"title": @"Hello world"
                 };
    } else if ([pageName isEqualToString:@"TestPageD"]) {
        return @{
                 @"pageName": @"TestPageD",
                 @"class": @"TestDPageController"
                 };
    } else if([pageName isEqualToString:@"imagePicker"]) {        
        return @{
                 @"pageName": @"imagePicker",
                 @"class": @"UITableViewController"
                 };
    }
    return nil;
}

- (FusionTabBar *)generateFusionTabbar:(NSString *)tabbarName {
    //todo
    FusionTabBar *tabBar = [[NSClassFromString(tabbarName) alloc] initWithConfig:@{@"tabbar_name": tabbarName}];
    return SafeAutoRelease(tabBar);
}
@end
