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
@private
    NSDictionary    *_pageConfig;
    NSString        *_pageName;
    NSString        *_pageNick;
    NSURL           *_callbackUrl;
    NSUInteger      _naviAnimeType;
    
    __unsafe_unretained FusionPageNavigator *_naviagtor;
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

#pragma IFusionPageProtocol
- (id)initWithConfig:(NSDictionary *)pageConfig {
    self = [super init];
    if (self) {
        _pageConfig = SafeRetain(pageConfig);
    }
    return self;
}

- (NSDictionary *)getPageConfig {
    return _pageConfig;
}

- (void)setNaviAnimeType:(NSUInteger)animeType {
    _naviAnimeType = animeType;
}

- (NSUInteger)getNaviAnimeType {
    return _naviAnimeType;
}

- (void)setPageName:(NSString *)pageName {
    SafeRelease(_pageName);
    _pageName = SafeRetain(pageName);
}

- (NSString *)getPageName {
    return _pageName;
}

- (void)setPageNick:(NSString *)pageNick {
    SafeRelease(_pageNick);
    _pageNick = pageNick;
}

- (NSString *)getPageNick {
    return _pageNick;
}

- (void)setCallbackUrl:(NSURL *)callbackUrl {
    SafeRelease(_callbackUrl);
    _callbackUrl = SafeRetain(callbackUrl);
}

- (NSURL*)getCallbackUrl {
    return _callbackUrl;
}

- (void)setNavigator:(FusionPageNavigator *)navigator {
    _naviagtor = navigator;
}

- (FusionPageNavigator *)getNavigator {
    return _naviagtor;
}

- (void)processPageCommand:(NSString *)command args:(NSDictionary *)args {
    
}

- (void)setTabBar:(FusionTabBar *)tabBar {
    assert(NO);
}

- (FusionTabBar *)getTabBar {
    return nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _naviagtor = nil;
    SafeRelease(_pageNick);
    SafeRelease(_pageName);
    SafeRelease(_callbackUrl);
    SafeRelease(_pageConfig);
    SafeSuperDealloc(super);
}
@end
