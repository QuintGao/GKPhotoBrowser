//
//  GKNavigationBarConfigure.m
//  GKNavigationBarViewControllerDemo
//
//  Created by QuintGao on 2017/7/10.
//  Copyright © 2017年 高坤. All rights reserved.
//  https://github.com/QuintGao/GKNavigationBarViewController.git

#import "GKNavigationBarConfigure.h"
#import "UIBarButtonItem+GKCategory.h"
#import "UIViewController+GKCategory.h"

@implementation GKNavigationBarConfigure

static GKNavigationBarConfigure *instance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [GKNavigationBarConfigure new];
    });
    return instance;
}

// 设置默认的导航栏外观
- (void)setupDefaultConfigure {
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.titleColor      = [UIColor blackColor];
    
    self.titleFont       = [UIFont boldSystemFontOfSize:17.0];
    
    self.statusBarHidden = NO;
    
    self.statusBarStyle  = UIStatusBarStyleDefault;
    
    self.backStyle       = GKNavigationBarBackStyleBlack;
    
    self.navItem_space   = 0;
    
    // 待添加
}

- (void)setNavItem_space:(CGFloat)navItem_space {
    if (GKDeviceVersion >= 11.0) {
        _navItem_space = navItem_space;
    }else {
        _navItem_space = navItem_space + 4;
    }
}

- (void)setupCustomConfigure:(void (^)(GKNavigationBarConfigure *))block {
    [self setupDefaultConfigure];
    
    !block ? : block(self);
}

// 更新配置
- (void)updateConfigure:(void (^)(GKNavigationBarConfigure *configure))block {
    !block ? : block(self);
}

// 获取当前显示的控制器
- (UIViewController *)visibleController {
    return [[UIApplication sharedApplication].keyWindow.rootViewController gk_visibleViewControllerIfExist];
}

@end
