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
    UIImageView         *_blurImageView;
    UIScrollView        *_scrollView;
    
    UIImage             *_blurImage;
    
    UIVibrancyEffect    *_vibrancyEffect;
    UIVisualEffectView  *_vibrancylView;
    
    UIBlurEffect        *_blurEffect;
    UIVisualEffectView  *_visualView;
    
    NSTimer             *_timer;
    CGFloat             _blurData;
}
@end

@implementation TestAPageController
+ (UIImage *)createBlurView:(UIView *)view blur:(CGFloat)blur {
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.frame.size.width * scale,
                                                      view.frame.size.height * scale),
                                           NO,
                                           1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == nil) {
        return nil;
    }
    
    CGContextSaveGState(context);
    CGRect rect = [view.layer convertRect:CGRectMake(0.0,
                                                     0.0,
                                                     view.layer.bounds.size.width,
                                                     view.layer.bounds.size.height)
                                         toLayer:view.layer];
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformMakeScale(rect.size.width/view.layer.bounds.size.width * scale,
                                           rect.size.height/view.layer.bounds.size.height * scale);
    transform = CGAffineTransformTranslate(transform,
                                           rect.origin.x/(rect.size.width/view.layer.bounds.size.width),
                                           rect.origin.y/(rect.size.height/view.layer.bounds.size.height));
    CGContextConcatCTM(context, transform);
    [view.layer renderInContext:context];
    CGContextRestoreGState(context);
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [TestAPageController createBlurImage:image blur:blur];
}

+ (UIImage *)createBlurImage:(UIImage*)image blur:(CGFloat)blur {
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *ci_image = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];//定义CIFilter的类型
    [filter setValue:ci_image forKey:kCIInputImageKey];//设置filter的属性
    [filter setValue:[NSNumber numberWithFloat:blur] forKey:kCIInputRadiusKey];
//    return [UIImage imageWithCIImage:filter.outputImage];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
    return [UIImage imageWithCGImage:cgImage scale:[UIScreen mainScreen].scale orientation:image.imageOrientation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    _bgImageView = [UIImageView new];
    [_bgImageView setImage:[UIImage imageNamed:@"1"]];
    [self.view addSubview:_bgImageView];
    
    _blurImageView = [UIImageView new];
    [_blurImageView setClipsToBounds:YES];
    [_blurImageView setContentMode:UIViewContentModeTop];
    
    _scrollView = [UIScrollView new];
    [_scrollView setUserInteractionEnabled:NO];
    [self.view addSubview:_scrollView];
    
    [self.view addGestureRecognizer:_scrollView.panGestureRecognizer];
    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
//    [button setTitle:@"GO" forState:UIControlStateNormal];
//    [button.layer setBorderWidth:1.0];
//    [button.layer setBorderColor:[UIColor redColor].CGColor];
//    [button addTarget:self
//               action:@selector(onTapButton:)
//     forControlEvents:UIControlEventTouchUpInside];
    {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Go"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(onTapButton:)];
        [self.navigationItem setLeftBarButtonItem:item];
    }
    {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Show"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(onShowBlurAnime:)];
        [self.navigationItem setRightBarButtonItem:item];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        _blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        
        _vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:_blurEffect];
        _vibrancylView = [[UIVisualEffectView alloc] initWithEffect:_vibrancyEffect];
        
        _visualView = [[UIVisualEffectView alloc] initWithEffect:_blurEffect];
        [_scrollView addSubview:_visualView];
    }

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

- (void)blur:(NSTimer *)timer {
    NSLog(@"start blur");
    _blurImage = [TestAPageController createBlurView:_bgImageView blur:_blurData];
    NSLog(@"finish");
    [_blurImageView setImage:_blurImage];
    [_blurImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:_blurImageView];
    
    _blurData = _blurData + 0.2;
    if (_blurData >= 10.0) {
        [_timer invalidate];
    }
}

- (void)onShowBlurAnime:(id)sender {
//    _blurData = 0.0;
//    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01
//                                     target:self
//                                   selector:@selector(blur:)
//                                   userInfo:nil
//                                    repeats:YES];
    _blurImage = [TestAPageController createBlurView:_bgImageView blur:6.0];
    [_blurImageView setImage:_blurImage];
    [_blurImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [_blurImageView setAlpha:0.0];
    [self.view addSubview:_blurImageView];
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         [_blurImageView setAlpha:1.0];
                     } completion:^(BOOL finished) {
                         
                     }];
    [UIView animateWithDuration:0.4
                     animations:^{
                         [_visualView setAlpha:0.75];
                     } completion:^(BOOL finished) {
                     }];
}

- (void)updateSubviewsLayout {
    [super updateSubviewsLayout];
    
    [_bgImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [_scrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    [_vibrancylView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [_visualView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height * 2.0)];
    [_scrollView setContentOffset:CGPointMake(0, self.view.frame.size.height)];
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
