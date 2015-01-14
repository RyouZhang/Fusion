//
//  TestAPageController.m
//  TestApp
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "TestAPageController.h"
#import <FusionUI/FusionUI.h>

@implementation TestAPageController
- (void)viewDidLoad {
    [super viewDidLoad];
    [_naviBar setBackgroundColor:[UIColor blueColor]];
    [self.view setBackgroundColor:[UIColor yellowColor]];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"GO" forState:UIControlStateNormal];
    [button.layer setBorderWidth:1.0];
    [button.layer setBorderColor:[UIColor redColor].CGColor];
    [button addTarget:self
               action:@selector(onTapButton:)
     forControlEvents:UIControlEventTouchUpInside];
    [_naviBar setLeftView:button];
    
    UILabel *label = [UILabel new];
    [label.layer setBorderWidth:1.0];
    [label.layer setBorderColor:[UIColor grayColor].CGColor];
    [label setFont:[UIFont systemFontOfSize:16]];
    [label setTextColor:[UIColor whiteColor]];
    [label setText:[self description]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [_naviBar setCenterView:label];
}

- (void)processPageCommand:(NSString *)command args:(NSDictionary *)args {
    if (command == nil || [command isEqualToString:@"init"]) {
        NSLog(@"%@:%@:%@", [self getPageNick], command, args);
    } else if([command isEqualToString:@"back"]) {
        NSLog(@"%@:%@:%@", [self getPageNick], command, args);
    }
}

- (void)onTapButton:(id)sender {
    NSURL *callbackUrl = [FusionPageNavigator generateCallbackUrl:self];
    NSString *temp = [NSURL mergeUrl:[callbackUrl absoluteString]
                          withParams:@{@"args": [@{@"a":@1} jsonString]}];
    callbackUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@#back",temp]];
    
    FusionPageMessage *message = [[FusionPageMessage alloc] initWithPageName:@"TestPageB"
                                                                  pageNick:nil
                                                                   command:nil
                                                                      args:[self getPageConfig]
                                                                  callback:callbackUrl];
    [message setNaviAnimeType:SlideR2L_NaviAnime];
    [[self getNavigator] gotoPage:message];
}
@end
