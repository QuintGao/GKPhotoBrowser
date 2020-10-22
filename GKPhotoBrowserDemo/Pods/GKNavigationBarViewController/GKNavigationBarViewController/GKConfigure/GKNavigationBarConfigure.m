//
//  GKNavigationBarConfigure.m
//  GKNavigationBarViewController
//
//  Created by QuintGao on 2017/7/10.
//  Copyright © 2017年 高坤. All rights reserved.
//  https://github.com/QuintGao/GKNavigationBarViewController.git

#import "GKNavigationBarConfigure.h"
#import "UIViewController+GKCategory.h"

@interface GKNavigationBarConfigure()

@property (nonatomic, assign) CGFloat navItemLeftSpace;
@property (nonatomic, assign) CGFloat navItemRightSpace;

@end

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
    
    self.gk_navItemLeftSpace    = 0;
    self.gk_navItemRightSpace   = 0;
    
    self.navItemLeftSpace       = 0;
    self.navItemRightSpace      = 0;
    
    self.gk_pushTransitionCriticalValue = 0.3;
    self.gk_popTransitionCriticalValue  = 0.5;
    
    self.gk_translationX = 5.0f;
    self.gk_translationY = 5.0f;
    self.gk_scaleX = 0.95;
    self.gk_scaleY = 0.97;
}

- (void)setGk_navItemLeftSpace:(CGFloat)gk_navItemLeftSpace {
    _gk_navItemLeftSpace = gk_navItemLeftSpace;
}

- (void)setGk_navItemRightSpace:(CGFloat)gk_navItemRightSpace {
    _gk_navItemRightSpace = gk_navItemRightSpace;
}

- (void)setupCustomConfigure:(void (^)(GKNavigationBarConfigure *))block {
    [self setupDefaultConfigure];
    
    !block ? : block(self);
    
    self.navItemLeftSpace  = self.gk_navItemLeftSpace;
    self.navItemRightSpace = self.gk_navItemRightSpace;
}

// 更新配置
- (void)updateConfigure:(void (^)(GKNavigationBarConfigure *configure))block {
    !block ? : block(self);
}

- (UIViewController *)visibleViewController {
    UIViewController *rootViewController = UIApplication.sharedApplication.delegate.window.rootViewController;
    return [rootViewController gk_visibleViewControllerIfExist];
}

- (UIEdgeInsets)gk_safeAreaInsets {
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    if (![window isKeyWindow]) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (CGRectEqualToRect(keyWindow.bounds, UIScreen.mainScreen.bounds)) {
            window = keyWindow;
        }
    }
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets insets = [window safeAreaInsets];
        return insets;
    }
    return UIEdgeInsetsZero;
}

- (BOOL)gk_isNotchedScreen {
    if ([UIWindow instancesRespondToSelector:@selector(safeAreaInsets)]) {
        return [self gk_safeAreaInsets].bottom > 0;
    }
    return (CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 812)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(812, 375)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(414, 896)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(896, 414)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(390, 844)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(844, 390)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(428, 926)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(926, 428)));
}

- (CGFloat)gk_fixedSpace {
    CGSize screentSize = [UIScreen mainScreen].bounds.size;
    return MIN(screentSize.width, screentSize.height) > 375 ? 20 : 16;
}

@end
