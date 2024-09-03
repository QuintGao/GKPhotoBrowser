//
//  GKPhotoBrowser.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/20.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKPhotoView.h"
#import "GKPhotoBrowserDelegate.h"
#import "GKPhotoBrowserConfigure.h"

#if __has_include(<GKPhotoBrowser/GKPhotoBrowser-Swift.h>)
#import <GKPhotoBrowser/GKPhotoBrowser-Swift.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface GKPhotoBrowser : UIViewController
/// 底部容器
@property (nonatomic, strong, readonly) UIView *containerView;
/// 底部内容视图
@property (nonatomic, strong, readonly) UIView *contentView;
/// 滑动容器视图
@property (nonatomic, strong, readonly) UIScrollView *photoScrollView;
/// 图片模型数组
@property (nonatomic, strong, readonly) NSArray *photos;
/// 当前索引
@property (nonatomic, assign, readonly) NSInteger currentIndex;
/// 当前显示的photoView
@property (nonatomic, strong, readonly) GKPhotoView *curPhotoView;
/// 当前模型数组
@property (nonatomic, strong, readonly) GKPhoto *curPhoto;
/// 自定义遮罩视图数组
@property (nonatomic, strong, readonly) NSArray *coverViews;
/// 当前是否横屏
@property (nonatomic, assign, readonly) BOOL isLandscape;
/// 当前设备方向
@property (nonatomic, assign, readonly) UIDeviceOrientation currentOrientation;

/// 是否显示状态栏，默认NO：不显示状态栏
@property (nonatomic, assign) BOOL isStatusBarShow;

/// 状态栏样式，默认Light
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

/// 数量Label，默认显示，若要隐藏需设置hidesCountLabel为YES
@property (nonatomic, strong) UILabel *countLabel;

/// 页码，默认显示，若要隐藏需设置hidesPageControl为YES
@property (nonatomic, strong) UIPageControl *pageControl;

/// 保存按钮，默认隐藏
@property (nonatomic, strong) UIButton *saveBtn;

/// 视频进度视图
@property (nonatomic, weak, readonly, nullable) UIView *progressView;

/// 代理
@property (nonatomic, weak) id<GKPhotoBrowserDelegate> delegate;

/// 浏览器配置
@property (nonatomic, strong) GKPhotoBrowserConfigure *configure;

/// 创建图片浏览器
+ (instancetype)photoBrowserWithPhotos:(NSArray<GKPhoto *> *)photos currentIndex:(NSInteger)index;

/// 创建图片浏览器
- (instancetype)initWithPhotos:(NSArray<GKPhoto *> *)photos currentIndex:(NSInteger)index;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 显示图片浏览器
- (void)showFromVC:(UIViewController *)vc;

/// 隐藏图片浏览器
- (void)dismiss;

/// 为浏览器添加自定义遮罩视图
- (void)setupCoverViews:(NSArray *)coverViews layoutBlock:(void(^_Nullable)(GKPhotoBrowser *, CGRect))layoutBlock;

/// 选中指定位置的内容
- (void)selectedPhotoWithIndex:(NSInteger)index animated:(BOOL)animated;

/// 移除指定位置的内容
- (void)removePhotoAtIndex:(NSInteger)index;

/// 重置浏览器数据源
- (void)resetPhotoBrowserWithPhotos:(NSArray *)photos;

/// 重置某个索引对于的数据
- (void)resetPhotoBrowserWithPhoto:(GKPhoto *)photo index:(NSInteger)index;

/// 加载原图方法，外部调用
- (void)loadCurrentPhotoImage;

@end

// 内部方法，无需关心
@interface GKPhotoBrowser (Private)

// 更新布局
- (void)layoutSubviews;

// 浏览器第一次显示
- (void)browserFirstAppear;

// 移除旋转监听
- (void)removeRotationObserver;

@end

NS_ASSUME_NONNULL_END
