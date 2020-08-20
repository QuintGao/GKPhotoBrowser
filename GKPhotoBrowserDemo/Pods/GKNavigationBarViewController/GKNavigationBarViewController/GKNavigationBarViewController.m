//
//  GKNavigationBarViewController.m
//  GKNavigationBarViewController
//
//  Created by QuintGao on 2017/7/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKNavigationBarViewController.h"
#import "GKNavigationBarConfigure.h"

@interface GKNavigationBarViewController ()

@property (nonatomic, strong) GKNavigationBar   *gk_navigationBar;

@property (nonatomic, strong) UINavigationItem  *gk_navigationItem;

@end

@implementation GKNavigationBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置自定义导航栏
    [self setupCustomNavBar];
    
    // 设置导航栏外观
    [self setupNavBarAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 隐藏系统导航栏
    [self.navigationController setNavigationBarHidden:YES];
    
    // 将自定义导航栏放置顶层
    if (self.gk_navigationBar && !self.gk_navigationBar.hidden) {
        [self.view bringSubviewToFront:self.gk_navigationBar];
    }
    
    // 获取状态
    self.gk_navigationBar.gk_statusBarHidden = self.gk_statusBarHidden;
    
    // 返回按钮样式
    if (self.gk_backStyle == GKNavigationBarBackStyleNone) {
        self.gk_backStyle = GKConfigure.backStyle;
    }
}

#pragma mark - Public Methods
- (void)showNavLine {
    self.gk_navLineHidden = NO;
}

- (void)hideNavLine {
    self.gk_navLineHidden = YES;
}

- (void)refreshNavBarFrame {
    [self setupNavBarFrame];
}

#pragma mark - private Methods
/**
 设置自定义导航条
 */
- (void)setupCustomNavBar {
    
    [self.view addSubview:self.gk_navigationBar];
    
    [self setupNavBarFrame];
    
    self.gk_navigationBar.items = @[self.gk_navigationItem];
}

/**
 设置导航栏外观
 */
- (void)setupNavBarAppearance {
    GKNavigationBarConfigure *configure = [GKNavigationBarConfigure sharedInstance];
    
    // 设置默认背景色
    if (configure.backgroundColor) {
        self.gk_navBackgroundColor = configure.backgroundColor;
    }
    
    // 设置默认标题颜色
    if (configure.titleColor) {
        self.gk_navTitleColor = configure.titleColor;
    }
    
    // 设置默认标题字体
    if (configure.titleFont) {
        self.gk_navTitleFont = configure.titleFont;
    }
    
    // 设置默认返回图片
    if (self.gk_backImage == nil) {
        self.gk_backImage = configure.backImage;
    }
    
    // 设置默认返回样式
    if (self.gk_backStyle == GKNavigationBarBackStyleNone) {
        self.gk_backStyle = configure.backStyle;
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self setupNavBarFrame];
}

- (void)setupNavBarFrame {
    CGFloat width  = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat navBarH = 0;
    if (width > height) { // 横屏
        if (GK_IS_iPad) {
            CGFloat statusBarH = [UIApplication sharedApplication].statusBarFrame.size.height;
            CGFloat navigaBarH = self.navigationController.navigationBar.frame.size.height;
            navBarH = statusBarH + navigaBarH;
        }else if (GK_IS_iPhoneX) {
            navBarH = GK_NAVBAR_HEIGHT;
        }else {
            if (width == 736.0f && height == 414.0f) { // plus横屏
                navBarH = self.gk_statusBarHidden ? GK_NAVBAR_HEIGHT : GK_STATUSBAR_NAVBAR_HEIGHT;
            }else { // 其他机型横屏
                navBarH = self.gk_statusBarHidden ? 32.0f : 52.0f;
            }
        }
    }else { // 竖屏
        navBarH = self.gk_statusBarHidden ? (GK_SAFEAREA_TOP + GK_NAVBAR_HEIGHT) : GK_STATUSBAR_NAVBAR_HEIGHT;
    }
    
    self.gk_navigationBar.frame = CGRectMake(0, 0, width, navBarH);
    self.gk_navigationBar.gk_statusBarHidden = self.gk_statusBarHidden;
    [self.gk_navigationBar layoutSubviews];
}

#pragma mark - 控制状态栏的方法
- (BOOL)prefersStatusBarHidden {
    return self.gk_statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.gk_statusBarStyle;
}

#pragma mark - 懒加载
- (GKNavigationBar *)gk_navigationBar {
    if (!_gk_navigationBar) {
        _gk_navigationBar = [[GKNavigationBar alloc] initWithFrame:CGRectZero];
    }
    return _gk_navigationBar;
}

- (UINavigationItem *)gk_navigationItem {
    if (!_gk_navigationItem) {
        _gk_navigationItem = [UINavigationItem new];
    }
    return _gk_navigationItem;
}

#pragma mark - setter
- (void)setGk_navTitle:(NSString *)gk_navTitle {
    _gk_navTitle = gk_navTitle;
    
    self.gk_navigationItem.title = gk_navTitle;
}

- (void)setGk_navBarTintColor:(UIColor *)gk_navBarTintColor {
    _gk_navBarTintColor = gk_navBarTintColor;
    
    self.gk_navigationBar.barTintColor = gk_navBarTintColor;
}

- (void)setGk_navBackgroundColor:(UIColor *)gk_navBackgroundColor {
    _gk_navBackgroundColor = gk_navBackgroundColor;
    
    [self.gk_navigationBar setBackgroundImage:[UIImage gk_imageWithColor:gk_navBackgroundColor] forBarMetrics:UIBarMetricsDefault];
}

- (void)setGk_navBackgroundImage:(UIImage *)gk_navBackgroundImage {
    _gk_navBackgroundImage = gk_navBackgroundImage;
    
    [self.gk_navigationBar setBackgroundImage:gk_navBackgroundImage forBarMetrics:UIBarMetricsDefault];
}

- (void)setGk_navShadowColor:(UIColor *)gk_navShadowColor {
    _gk_navShadowColor = gk_navShadowColor;
    
    self.gk_navigationBar.shadowImage = [UIImage gk_changeImage:[UIImage gk_imageNamed:@"nav_line"] color:gk_navShadowColor];
}

- (void)setGk_navShadowImage:(UIImage *)gk_navShadowImage {
    _gk_navShadowImage = gk_navShadowImage;
    
    self.gk_navigationBar.shadowImage = gk_navShadowImage;
}

- (void)setGk_navTintColor:(UIColor *)gk_navTintColor {
    _gk_navTintColor = gk_navTintColor;
    
    self.gk_navigationBar.tintColor = gk_navTintColor;
}

- (void)setGk_navTitleView:(UIView *)gk_navTitleView {
    _gk_navTitleView = gk_navTitleView;
    
    self.gk_navigationItem.titleView = gk_navTitleView;
}

- (void)setGk_navTitleColor:(UIColor *)gk_navTitleColor {
    _gk_navTitleColor = gk_navTitleColor;
    
    UIFont *titleFont = self.gk_navTitleFont ? self.gk_navTitleFont : GKConfigure.titleFont;
    
    self.gk_navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: gk_navTitleColor, NSFontAttributeName: titleFont};
}

- (void)setGk_navTitleFont:(UIFont *)gk_navTitleFont {
    _gk_navTitleFont = gk_navTitleFont;
    
    UIColor *titleColor = self.gk_navTitleColor ? self.gk_navTitleColor : GKConfigure.titleColor;
    
    self.gk_navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: titleColor, NSFontAttributeName: gk_navTitleFont};
}

- (void)setGk_navLeftBarButtonItem:(UIBarButtonItem *)gk_navLeftBarButtonItem {
    _gk_navLeftBarButtonItem = gk_navLeftBarButtonItem;
    
    self.gk_navigationItem.leftBarButtonItem = gk_navLeftBarButtonItem;
}

- (void)setGk_navLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)gk_navLeftBarButtonItems {
    _gk_navLeftBarButtonItems = gk_navLeftBarButtonItems;
    
    self.gk_navigationItem.leftBarButtonItems = gk_navLeftBarButtonItems;
}

- (void)setGk_navRightBarButtonItem:(UIBarButtonItem *)gk_navRightBarButtonItem {
    _gk_navRightBarButtonItem = gk_navRightBarButtonItem;
    
    self.gk_navigationItem.rightBarButtonItem = gk_navRightBarButtonItem;
}

- (void)setGk_navRightBarButtonItems:(NSArray<UIBarButtonItem *> *)gk_navRightBarButtonItems {
    _gk_navRightBarButtonItems = gk_navRightBarButtonItems;
    
    self.gk_navigationItem.rightBarButtonItems = gk_navRightBarButtonItems;
}

- (void)setGk_navLineHidden:(BOOL)gk_navLineHidden {
    _gk_navLineHidden = gk_navLineHidden;
    
    self.gk_navigationBar.gk_navLineHidden = gk_navLineHidden;
    
    if (@available(iOS 11.0, *)) {
        UIImage *shadowImage = nil;
        if (gk_navLineHidden) {
            shadowImage = [UIImage new];
        }else if (self.gk_navShadowImage) {
            shadowImage = self.gk_navShadowImage;
        }else if (self.gk_navShadowColor) {
            shadowImage = [UIImage gk_changeImage:[UIImage gk_imageNamed:@"nav_line"] color:self.gk_navShadowColor];
        }
        self.gk_navigationBar.shadowImage = shadowImage;
    }
    
    [self.gk_navigationBar layoutSubviews];
}

@end
