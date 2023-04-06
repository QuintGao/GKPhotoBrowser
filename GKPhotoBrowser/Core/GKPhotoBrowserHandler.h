//
//  GKPhotoBrowserHandler.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2023/3/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GKPhotoBrowser;

@interface GKPhotoBrowserHandler : NSObject

// 弱引用的浏览器类
@property (nonatomic, weak) GKPhotoBrowser *browser;

// 截图
@property (nonatomic, strong) UIImage *captureImage;

// 状态栏显示模式，根据info.plist文件中是否有UIViewControllerBasedStatusBarAppearance属性判断
@property (nonatomic, assign) BOOL statusBarAppearance;

// 原始状态栏样式
@property (nonatomic, assign) UIStatusBarStyle originStatusBarStyle;

// 状态栏显示隐藏处理
@property (nonatomic, assign) BOOL isStatusBarShowing;

// 记录browser是否显示
@property (nonatomic, assign) BOOL isShow;

// 记录browser是否走了viewWillAppear方法
@property (nonatomic, assign) BOOL isAppeared;

// 调用selectedPhoto方法是否需要动画
@property (nonatomic, assign) BOOL isAnimated;

@property (nonatomic, assign) BOOL isRecover;

// 显示
- (void)showFromVC:(UIViewController *)vc;

// 浏览器显示
- (void)browserShow;

// 浏览器消失
- (void)browserDismiss;

// 浏览器消失动画
- (void)browserZoomDismiss;
- (void)browserSlideDismiss:(CGPoint)point;

// 浏览器背景透明度改变
- (void)browserChangeAlpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
