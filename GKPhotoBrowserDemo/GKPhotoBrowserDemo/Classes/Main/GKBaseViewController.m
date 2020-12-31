//
//  GKBaseViewController.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/7.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKBaseViewController.h"

@interface GKBaseViewController ()

@end

@implementation GKBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_statusBarHidden = NO;
    self.gk_statusBarStyle  = UIStatusBarStyleLightContent;
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//
//    [self setNeedsStatusBarAppearanceUpdate];
//}

#pragma mark - 屏幕旋转相关
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - 状态栏
- (BOOL)prefersStatusBarHidden {
    return self.gk_statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.gk_statusBarStyle;
}

@end
