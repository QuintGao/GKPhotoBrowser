//
//  UIViewController+GKCategory.m
//  GKNavigationBarViewController
//
//  Created by QuintGao on 2017/7/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "UIViewController+GKCategory.h"
#import "GKNavigationBarViewController.h"
#import <objc/runtime.h>

NSString *const GKViewControllerPropertyChangedNotification = @"GKViewControllerPropertyChangedNotification";

static const void* GKInteractivePopKey      = @"GKInteractivePopKey";
static const void* GKFullScreenPopKey       = @"GKFullScreenPopKey";
static const void* GKPopMaxDistanceKey      = @"GKPopMaxDistanceKey";
static const void* GKNavBarAlphaKey         = @"GKNavBarAlphaKey";
static const void* GKStatusBarStyleKey      = @"GKStatusBarStyleKey";
static const void* GKStatusBarHiddenKey     = @"GKStatusBarHiddenKey";
static const void* GKBackImageKey           = @"GKBackImageKey";
static const void* GKBackStyleKey           = @"GKBackStyleKey";
static const void* GKPushDelegateKey        = @"GKPushDelegateKey";
static const void* GKPopDelegateKey         = @"GKPopDelegateKey";
static const void* GKNavItemLeftSpaceKey    = @"GKNavItemLeftSpaceKey";
static const void* GKNavItemRightSpaceKey   = @"GKNavItemRightSpaceKey";

@implementation UIViewController (GKCategory)

// 方法交换
+ (void)load {
    // 保证其只执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray <NSString *> *oriSels = @[@"viewDidLoad",
                                          @"viewWillAppear:",
                                          @"viewDidAppear:"];
        
        [oriSels enumerateObjectsUsingBlock:^(NSString * _Nonnull oriSel, NSUInteger idx, BOOL * _Nonnull stop) {
            gk_swizzled_method(@"gk", self, oriSel, self);
        }];
    });
}

- (void)gk_viewDidLoad {
    // 初始化导航栏间距
    self.gk_navItemLeftSpace    = GKNavigationBarItemSpace;
    self.gk_navItemRightSpace   = GKNavigationBarItemSpace;
    
    [self gk_viewDidLoad];
}

- (void)gk_viewDidAppear:(BOOL)animated {
    [self postPropertyChangeNotification];
    
    [self gk_viewDidAppear:animated];
}

- (void)gk_viewWillAppear:(BOOL)animated {
    if ([self isKindOfClass:[UINavigationController class]]) return;
    if ([self isKindOfClass:[UITabBarController class]]) return;
    if ([self isKindOfClass:[UIAlertController class]]) return;
    if ([self isKindOfClass:[UIImagePickerController class]]) return;
    if ([self isKindOfClass:[UIVideoEditorController class]]) return;
    if ([NSStringFromClass(self.class) isEqualToString:@"PUPhotoPickerHostViewController"]) return;
    if (!self.navigationController) return;
    
    __block BOOL exist = NO;
    [GKConfigure.shiledItemSpaceVCs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIViewController class]]) {
            if ([self isKindOfClass:[obj class]]) {
                exist = YES;
                *stop = YES;
            }
        }else if ([obj isKindOfClass:[NSString class]]) {
            if ([NSStringFromClass(self.class) isEqualToString:obj]) {
                exist = YES;
                *stop = YES;
            }
        }
    }];
    if (exist) return;
    
    // bug fix：#41
    // 每次控制器出现的时候重置导航栏间距
    if (self.gk_navItemLeftSpace == GKNavigationBarItemSpace) {
        self.gk_navItemLeftSpace = GKConfigure.navItemLeftSpace;
    }
    
    if (self.gk_navItemRightSpace == GKNavigationBarItemSpace) {
        self.gk_navItemRightSpace = GKConfigure.navItemRightSpace;
    }
    
    // 重置navitem_space
    [GKConfigure updateConfigure:^(GKNavigationBarConfigure *configure) {
        configure.gk_navItemLeftSpace   = self.gk_navItemLeftSpace;
        configure.gk_navItemRightSpace  = self.gk_navItemRightSpace;
    }];
    
    [self gk_viewWillAppear:animated];
}

#pragma mark - StatusBar
- (BOOL)prefersStatusBarHidden {
    return self.gk_statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.gk_statusBarStyle;
}

#pragma mark - Added Property
- (BOOL)gk_interactivePopDisabled {
    return [objc_getAssociatedObject(self, GKInteractivePopKey) boolValue];
}

- (void)setGk_interactivePopDisabled:(BOOL)gk_interactivePopDisabled {
    objc_setAssociatedObject(self, GKInteractivePopKey, @(gk_interactivePopDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self postPropertyChangeNotification];
}

- (BOOL)gk_fullScreenPopDisabled {
    return [objc_getAssociatedObject(self, GKFullScreenPopKey) boolValue];
}

- (void)setGk_fullScreenPopDisabled:(BOOL)gk_fullScreenPopDisabled {
    objc_setAssociatedObject(self, GKFullScreenPopKey, @(gk_fullScreenPopDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self postPropertyChangeNotification];
}

- (CGFloat)gk_popMaxAllowedDistanceToLeftEdge {
    return [objc_getAssociatedObject(self, GKPopMaxDistanceKey) floatValue];
}

- (void)setGk_popMaxAllowedDistanceToLeftEdge:(CGFloat)gk_popMaxAllowedDistanceToLeftEdge {
    objc_setAssociatedObject(self, GKPopMaxDistanceKey, @(gk_popMaxAllowedDistanceToLeftEdge), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self postPropertyChangeNotification];
}

- (CGFloat)gk_navBarAlpha {
    id obj = objc_getAssociatedObject(self, GKNavBarAlphaKey);
    return obj ? [obj floatValue] : 1.0f;
}

- (void)setGk_navBarAlpha:(CGFloat)gk_navBarAlpha {
    objc_setAssociatedObject(self, GKNavBarAlphaKey, @(gk_navBarAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setNavBarAlpha:gk_navBarAlpha];
}

- (UIStatusBarStyle)gk_statusBarStyle {
    id style = objc_getAssociatedObject(self, GKStatusBarStyleKey);
    return (style != nil) ? [style integerValue] : GKConfigure.statusBarStyle;
}

- (void)setGk_statusBarStyle:(UIStatusBarStyle)gk_statusBarStyle {
    objc_setAssociatedObject(self, GKStatusBarStyleKey, @(gk_statusBarStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)gk_statusBarHidden {
    id objc = objc_getAssociatedObject(self, GKStatusBarHiddenKey);
    return (objc != nil) ? [objc boolValue] : GKConfigure.statusBarHidden;
}

- (void)setGk_statusBarHidden:(BOOL)gk_statusBarHidden {
    objc_setAssociatedObject(self, GKStatusBarHiddenKey, @(gk_statusBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (GKNavigationBarBackStyle)gk_backStyle {
    id style = objc_getAssociatedObject(self, GKBackStyleKey);
    
    return (style != nil) ? [style integerValue] : GKConfigure.backStyle;
}

- (void)setGk_backStyle:(GKNavigationBarBackStyle)gk_backStyle {
    objc_setAssociatedObject(self, GKBackStyleKey, @(gk_backStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setBackItemImage:self.gk_backImage];
}

- (UIImage *)gk_backImage {
    return objc_getAssociatedObject(self, GKBackImageKey);
}

- (void)setGk_backImage:(UIImage *)gk_backImage {
    objc_setAssociatedObject(self, GKBackImageKey, gk_backImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setBackItemImage:gk_backImage];
}

- (id<GKViewControllerPushDelegate>)gk_pushDelegate {
    return objc_getAssociatedObject(self, GKPushDelegateKey);
}

- (void)setGk_pushDelegate:(id<GKViewControllerPushDelegate>)gk_pushDelegate {
    objc_setAssociatedObject(self, GKPushDelegateKey, gk_pushDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self postPropertyChangeNotification];
}

- (id<GKViewControllerPopDelegate>)gk_popDelegate {
    return objc_getAssociatedObject(self, GKPopDelegateKey);
}

- (void)setGk_popDelegate:(id<GKViewControllerPopDelegate>)gk_popDelegate {
    objc_setAssociatedObject(self, GKPopDelegateKey, gk_popDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self postPropertyChangeNotification];
}

- (CGFloat)gk_navItemLeftSpace {
    return [objc_getAssociatedObject(self, GKNavItemLeftSpaceKey) floatValue];
}

- (void)setGk_navItemLeftSpace:(CGFloat)gk_navItemLeftSpace {
    objc_setAssociatedObject(self, GKNavItemLeftSpaceKey, @(gk_navItemLeftSpace), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (gk_navItemLeftSpace == GKNavigationBarItemSpace) return;
    
    [GKConfigure updateConfigure:^(GKNavigationBarConfigure * _Nonnull configure) {
        configure.gk_navItemLeftSpace = gk_navItemLeftSpace;
    }];
}

- (CGFloat)gk_navItemRightSpace {
    return [objc_getAssociatedObject(self, GKNavItemRightSpaceKey) floatValue];
}

- (void)setGk_navItemRightSpace:(CGFloat)gk_navItemRightSpace {
    objc_setAssociatedObject(self, GKNavItemRightSpaceKey, @(gk_navItemRightSpace), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (gk_navItemRightSpace == GKNavigationBarItemSpace) return;
    
    [GKConfigure updateConfigure:^(GKNavigationBarConfigure *configure) {
        configure.gk_navItemRightSpace = gk_navItemRightSpace;
    }];
}

- (void)setNavBarAlpha:(CGFloat)alpha {
    
    UINavigationBar *navBar = nil;
    
    if ([self isKindOfClass:[GKNavigationBarViewController class]]) {
        GKNavigationBarViewController *vc = (GKNavigationBarViewController *)self;
        
        vc.gk_navigationBar.gk_navBarBackgroundAlpha = alpha;
    }else {
        navBar = self.navigationController.navigationBar;
        
        UIView *barBackgroundView = [navBar.subviews objectAtIndex:0]; // _UIBarBackground
        UIImageView *backgroundImageView = [barBackgroundView.subviews objectAtIndex:0]; // UIImageView
        
        if (navBar.isTranslucent) {
            if (backgroundImageView != nil && backgroundImageView.image != nil) {
                barBackgroundView.alpha = alpha;
            }else {
                UIView *backgroundEffectView = [barBackgroundView.subviews objectAtIndex:1]; // UIVisualEffectView
                if (backgroundEffectView != nil) {
                    backgroundEffectView.alpha = alpha;
                }
            }
        }else {
            barBackgroundView.alpha = alpha;
        }
    }
    // 底部分割线
    navBar.clipsToBounds = alpha == 0.0;
}

- (void)setBackItemImage:(UIImage *)image {
    // 根控制器不作处理
    if (self.navigationController.childViewControllers.count <= 1) return;
    
    // 非GKNavigationBarViewController不作处理
    if (![self isKindOfClass:[GKNavigationBarViewController class]]) return;
    
    if (!image) {
        if (self.gk_backStyle != GKNavigationBarBackStyleNone) {
            NSString *imageName = self.gk_backStyle == GKNavigationBarBackStyleBlack ? @"btn_back_black" : @"btn_back_white";
            image = [UIImage gk_imageNamed:imageName];
        }
    }
    
    // 没有image
    if (!image) return;
    
    GKNavigationBarViewController *vc = (GKNavigationBarViewController *)self;
    vc.gk_navLeftBarButtonItem = [UIBarButtonItem itemWithTitle:nil image:image target:self action:@selector(backItemClick:)];
}

- (void)backItemClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)postPropertyChangeNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:GKViewControllerPropertyChangedNotification object:@{@"viewController": self}];
}

@end
