//
//  TestDPageController.m
//  TestApp
//
//  Created by Ryou Zhang on 1/15/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "TestDPageController.h"
#import "SafeARC.h"

@interface TestDPageController() {
}
@end

@implementation TestDPageController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor purpleColor]];
    
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SafeSuperDealloc(super);
}
@end
