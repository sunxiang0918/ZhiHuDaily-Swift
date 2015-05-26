//
//  KCLaunchImageViewController.m
//  FakeZhiHuDailyLaunchImageTransition
//
//  Created by kavi chen on 14-4-15.
//  Copyright (c) 2014年 kavi chen. All rights reserved.
//

#import "KCLaunchImageViewController.h"

@interface KCLaunchImageViewController ()
@property (nonatomic,strong) UIImage * myImage;
@property (nonatomic,strong) id viewController;
@property (nonatomic,strong) UIImageView *fromImageView;
@property (nonatomic,strong) UIImageView *toImageView;
@property (nonatomic,strong) UIImageView *maskImageView;
@property (nonatomic,strong) UILabel * sourceLabel;

@end

@implementation KCLaunchImageViewController
@synthesize myImage = _myImage;
@synthesize sourceLabel = _sourceLabel;

+ (instancetype)addTransitionToViewController:(id)viewController
                         modalTransitionStyle:(UIModalTransitionStyle)theStyle
                                    withImage:(NSString *)imageName
                                    taskBlock:(void (^)(void))block
{
    return [[self alloc] initWithViewController:viewController
                           modalTransitionStyle:theStyle
                                          image:imageName
                                      taskBlock:block];
}

+ (instancetype)addTransitionToViewController:(id)viewController
                         modalTransitionStyle:(UIModalTransitionStyle)theStyle
                                withImageData:(UIImage *)image
                                withSourceName:(NSString *)name
                                    taskBlock:(void (^)(void))block
{
    return [[self alloc] initWithViewController:viewController
                           modalTransitionStyle:theStyle
                                          imageData:image
                                          sourceName:name
                                      taskBlock:block];
}

- (instancetype)initWithViewController:(id)viewController
                  modalTransitionStyle:(UIModalTransitionStyle)theStyle
                                 image:(NSString *)imageName
                             taskBlock:(void (^)(void))block

{
    self = [super init];
    if (self) {
        [viewController setModalTransitionStyle:theStyle];
        self.myImage = [UIImage imageNamed:imageName];
        self.viewController = viewController;
        block();
    }
    return self;
}

- (instancetype)initWithViewController:(id)viewController
                  modalTransitionStyle:(UIModalTransitionStyle)theStyle
                                 imageData:(UIImage *)image
                                 sourceName:(NSString *)name
                             taskBlock:(void (^)(void))block

{
    self = [super init];
    if (self) {
        [viewController setModalTransitionStyle:theStyle];
        self.myImage = image;
        
        //获取目标viewController,也就是屏幕的大小
        CGRect rect = ((UIViewController *)viewController).view.frame;

        //通过屏幕的大小,计算出sourceLabel的大小与位置
        self.sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake((rect.size.width-200)/2, (rect.size.height-50), 200, 50)];
        //设置显示值
        self.sourceLabel.text = name;
        //设置文字水平居中
        self.sourceLabel.textAlignment = NSTextAlignmentCenter;
        //设置文字的颜色为白色
        self.sourceLabel.textColor = [UIColor whiteColor];
        //设置背景透明
        self.sourceLabel.backgroundColor = [UIColor clearColor];
        
        self.viewController = viewController;
        block();
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return STATUS_BAR_HIDDEN;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    self.fromImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.toImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.maskImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.fromImageView.image = [UIImage imageNamed:@"FakeLaunchImage"];
    [self.view addSubview:self.fromImageView];
    
    [self.view insertSubview:self.sourceLabel aboveSubview:self.fromImageView];
    
    self.maskImageView.image = [UIImage imageNamed:@"MaskImage"];
    [self.view insertSubview:self.maskImageView belowSubview:self.fromImageView];
    
    self.toImageView.image = self.myImage;
    [self.view insertSubview:self.toImageView belowSubview:self.maskImageView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:6];
    [self.sourceLabel setAlpha:0.0f];
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:TRANSITION_DURATION];
    [self.fromImageView setAlpha:0.0f];
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:ANIMATION_DURATION];
    CGAffineTransform transform = CGAffineTransformMakeScale(XSCALE, YSCALE);
    self.toImageView.transform = transform;
    [UIView commitAnimations];
    
    [NSTimer scheduledTimerWithTimeInterval:ANIMATION_DURATION
                                     target:self
                                   selector:@selector(presentNextViewController:)
                                   userInfo:self.viewController
                                    repeats:NO];
    
}

- (void)presentNextViewController:(NSTimer *)timer
{
    [self presentViewController:[timer userInfo]
                       animated:YES
                     completion:nil];
}


@end
