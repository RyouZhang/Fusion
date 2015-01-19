//
//  TestBPageController.m
//  TestApp
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "TestBPageController.h"

@implementation TestBPageController
- (void)viewDidLoad {
    [super viewDidLoad];
//    [_naviBar setBackgroundColor:[UIColor blueColor]];
    [self.view setBackgroundColor:[UIColor greenColor]];
    
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
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setFrame:CGRectMake(100, 200, 100, 100)];
        [button setTitle:@"GO" forState:UIControlStateNormal];
        [button.layer setBorderWidth:1.0];
        [button.layer setBorderColor:[UIColor redColor].CGColor];
        [button addTarget:self
                   action:@selector(onTapGoButton:)
         forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setFrame:CGRectMake(200, 200, 100, 100)];
        [button setTitle:@"Hide" forState:UIControlStateNormal];
        [button.layer setBorderWidth:1.0];
        [button.layer setBorderColor:[UIColor redColor].CGColor];
        [button addTarget:self
                   action:@selector(onTapHideButton:)
         forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setFrame:CGRectMake(200, 100, 100, 100)];
        [button setTitle:@"Hide" forState:UIControlStateNormal];
        [button.layer setBorderWidth:1.0];
        [button.layer setBorderColor:[UIColor redColor].CGColor];
        [button addTarget:self
                   action:@selector(onTapPrevButton:)
         forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

- (void)onTapPrevButton:(id)sender {
    FusionPageMessage *message = [[FusionPageMessage alloc] initWithPageName:@"imagePicker"
                                                                    pageNick:nil
                                                                     command:nil
                                                                        args:nil
                                                                    callback:nil];
    [message setNaviAnimeType:SlideT2B_NaviAnime];
    [[self getNavigator] gotoPage:message];
}

- (void)onTapButton:(id)sender {
    FusionPageMessage *message = [[FusionPageMessage alloc] initWithURL:[self getCallbackUrl] args:@{@"b":@2}];
    [message setNaviAnimeType:[self getNaviAnimeType]];
    [message setNaviAnimeDirection:FusionNaviAnimeBackward];
    [[self getNavigator] poptoPage:message];
}

- (void)onTapGoButton:(id)sender {
    FusionPageMessage *message = [[FusionPageMessage alloc] initWithPageName:@"TestPageC"
                                                                    pageNick:nil
                                                                     command:nil
                                                                        args:nil
                                                                    callback:nil];
    [message setNaviAnimeType:SlideR2L_NaviAnime];
    [message setIsDestory:YES];    
    [[self getNavigator] gotoPage:message];
}

- (void)onTapHideButton:(id)sender {
    if (_tabBar) {
        if ([_tabBar isHidden] == NO)
            [_tabBar hideTabbar:YES];
        else
            [_tabBar showTabbar:YES];
    }
}
@end
