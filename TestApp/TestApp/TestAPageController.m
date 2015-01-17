//
//  TestAPageController.m
//  TestApp
//
//  Created by Ryou Zhang on 1/12/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "TestAPageController.h"
#import <FusionUI/FusionUI.h>

@interface TestAPageController() {
@private
    UIImageView *_bgImageView;
}
@end

@implementation TestAPageController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor yellowColor]];
    
    _bgImageView = [UIImageView new];
    [_bgImageView setImage:[UIImage imageNamed:@"1"]];
    [self.view addSubview:_bgImageView];
    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
//    [button setTitle:@"GO" forState:UIControlStateNormal];
//    [button.layer setBorderWidth:1.0];
//    [button.layer setBorderColor:[UIColor redColor].CGColor];
//    [button addTarget:self
//               action:@selector(onTapButton:)
//     forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Go"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(onTapButton:)];
    [self.navigationItem setLeftBarButtonItem:item];

    [self.navigationItem setTitle:@"DADSADA"];
//    UILabel *label = [UILabel new];
//    [label.layer setBorderWidth:1.0];
//    [label.layer setBorderColor:[UIColor grayColor].CGColor];
//    [label setFont:[UIFont systemFontOfSize:16]];
//    [label setTextColor:[UIColor whiteColor]];
//    [label setText:[self description]];
//    [label setTextAlignment:NSTextAlignmentCenter];
//    [_naviBar setCenterView:label];
}

- (void)updateSubviewsLayout {
    [super updateSubviewsLayout];
    
    [_bgImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
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
