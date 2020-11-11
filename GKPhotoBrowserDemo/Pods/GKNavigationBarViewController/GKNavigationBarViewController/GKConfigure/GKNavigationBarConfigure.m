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
    return [[GKConfigure getKeyWindow].rootViewController gk_visibleViewControllerIfExist];
}

- (UIEdgeInsets)gk_safeAreaInsets {
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        UIWindow *keyWindow = [GKConfigure getKeyWindow];
        if (keyWindow) {
            return keyWindow.safeAreaInsets;
        }else { // 如果获取到的window是空
            // 对于刘海屏，当window没有创建的时候，可根据状态栏设置安全区域顶部高度
            // iOS14之后顶部安全区域不再是固定的44，所以修改为以下方式获取
            if ([GKConfigure gk_isNotchedScreen]) {
                safeAreaInsets = UIEdgeInsetsMake([GKConfigure gk_statusBarFrame].size.height, 0, 34, 0);
            }
        }
    }
    return safeAreaInsets;
}

- (CGRect)gk_statusBarFrame {
    return [UIApplication sharedApplication].statusBarFrame;
}

- (BOOL)gk_isNotchedScreen {
    if (@available(iOS 11.0, *)) {
        UIWindow *keyWindow = [GKConfigure getKeyWindow];
        if (keyWindow) {
            return keyWindow.safeAreaInsets.bottom > 0;
        }
    }
    
    // 当iOS11以下或获取不到keyWindow时用以下方案
    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    return (CGSizeEqualToSize(screenSize, CGSizeMake(375, 812)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(812, 375)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(414, 896)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(896, 414)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(390, 844)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(844, 390)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(428, 926)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(926, 428)));
}

- (CGFloat)gk_fixedSpace {
    CGSize screentSize = [UIScreen mainScreen].bounds.size;
    return MIN(screentSize.width, screentSize.height) > 375 ? 20 : 16;
}

- (UIWindow *)getKeyWindow {
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *w in windowScene.windows) {
                    if (window.isKeyWindow) {
                        window = w;
                        break;
                    }
                }
            }
        }
    }
    // 没有获取到window
    if (!window) {
        for (UIWindow *w in [UIApplication sharedApplication].windows) {
            if (w.isKeyWindow) {
                window = w;
                break;
            }
        }
    }
    return window;
}

@end
