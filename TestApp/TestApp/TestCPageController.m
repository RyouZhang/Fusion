//
//  TestCPageController.m
//  TestApp
//
//  Created by ZhangRyou on 1/13/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "TestCPageController.h"

@implementation TestCPageController
- (void)viewDidLoad {
    [super viewDidLoad];
    [_naviBar setBackgroundColor:[UIColor blueColor]];    
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setFrame:CGRectMake(100, 100, 100, 100)];
        [button setTitle:@"BACK" forState:UIControlStateNormal];
        [button.layer setBorderWidth:1.0];
        [button.layer setBorderColor:[UIColor redColor].CGColor];
        [button addTarget:self
                   action:@selector(onTapButton:)
         forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

- (void)onTapButton:(id)sender {
    FusionPageMessage *message = [[FusionPageMessage alloc] initWithURL:[self getCallbackUrl] args:@{@"b":@2}];
    [message setNaviAnimeType:[self getNaviAnimeType]];
    [message setNaviAnimeDirection:FusionNaviAnimeBackward];
    [[self getNavigator] poptoPage:message];
}
@end
