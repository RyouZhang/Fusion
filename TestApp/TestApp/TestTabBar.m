//
//  TestTabBar.m
//  TestApp
//
//  Created by ZhangRyou on 1/14/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import "TestTabBar.h"
#import "SafeARC.h"

@interface TestTabBar() {
@private
    NSMutableArray  *_buttonArray;
    NSUInteger      _currentIndex;
}
@end

@implementation TestTabBar
- (id)initWithConfig:(NSDictionary *)config {
    self = [super initWithConfig:config];
    if (self) {
        [self setBackgroundColor:[UIColor redColor]];
        
        _currentIndex = 0;
        
        _buttonArray = [NSMutableArray new];
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            [button setTitle:@"Go A" forState:UIControlStateNormal];
            [button setFrame:CGRectZero];
            [button addTarget:self
                       action:@selector(onTapButtonA:)
             forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            [_buttonArray addObject:button];
        }
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            [button setTitle:@"Go B" forState:UIControlStateNormal];
            [button setFrame:CGRectZero];
            [button addTarget:self
                       action:@selector(onTapButtonB:)
             forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            [_buttonArray addObject:button];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([_buttonArray count] == 0) {
        return;
    }
    
    CGFloat buttonWidth = self.frame.size.width / [_buttonArray count];
    for (UIButton *button in _buttonArray) {
        NSInteger index = [_buttonArray indexOfObject:button];
        [button setFrame:CGRectMake(index * buttonWidth,
                                    0,
                                    buttonWidth,
                                    self.frame.size.height)];
    }
}

- (void)onTapButtonA:(id)sender {
    NSUInteger index = [_buttonArray indexOfObject:sender];
    
    FusionPageMessage *message = [[FusionPageMessage alloc] initWithPageName:@"TestPageA"
                                                                    pageNick:nil
                                                                     command:nil
                                                                        args:nil
                                                                    callback:nil];
    if (_currentIndex > index) {
        [message setNaviAnimeType:ScrollL2R_NaviAnime];
    } else {
        [message setNaviAnimeType:ScrollR2L_NaviAnime];
    }
    _currentIndex = index;
    [[self navigator] gotoPage:message];
}

- (void)onTapButtonB:(id)sender {
    NSUInteger index = [_buttonArray indexOfObject:sender];
    
    FusionPageMessage *message = [[FusionPageMessage alloc] initWithPageName:@"TestPageB"
                                                                    pageNick:nil
                                                                     command:nil
                                                                        args:nil
                                                                    callback:nil];
    if (_currentIndex > index) {
        [message setNaviAnimeType:ScrollL2R_NaviAnime];
    } else {
        [message setNaviAnimeType:ScrollR2L_NaviAnime];
    }
    _currentIndex = index;
    [[self navigator] gotoPage:message];
}

- (void)dealloc {
    SafeSuperDealloc(super);
}
@end
