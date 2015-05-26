//
//  KCLaunchImageViewController.h
//  FakeZhiHuDailyLaunchImageTransition
//
//  Created by kavi chen on 14-4-15.
//  Copyright (c) 2014年 kavi chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#define TRANSITION_DURATION 1.66
#define ANIMATION_DURATION 4.0
#define XSCALE 1.15
#define YSCALE 1.15
#define STATUS_BAR_HIDDEN 1


@interface KCLaunchImageViewController : UIViewController

+ (instancetype)addTransitionToViewController:(id)viewController
                         modalTransitionStyle:(UIModalTransitionStyle)theStyle
                                    withImage:(NSString *)imageName
                                    taskBlock:(void (^)(void))block;

@end
