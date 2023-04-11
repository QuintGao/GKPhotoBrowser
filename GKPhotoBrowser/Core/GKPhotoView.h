//
//  GKPhotoView.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/23.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKPhotoManager.h"
#import "GKWebImageProtocol.h"
#import "GKVideoPlayerProtocol.h"
#import "GKLoadingView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKScrollView : UIScrollView

@end

@class GKPhotoView;

@interface GKPhotoView : UIView<UIScrollViewDelegate>

@property (nonatomic, strong, readonly) GKScrollView *scrollView;

@property (nonatomic, strong, readonly) UIImageView  *imageView;

@property (nonatomic, strong, readonly) UIButton     *playBtn;

@property (nonatomic, strong, readonly) GKLoadingView *loadingView;

@property (nonatomic, strong, readonly) GKPhoto *photo;

@property (nonatomic, weak) id<GKVideoPlayerProtocol> player;

@property (nonatomic, copy) void(^zoomEnded)(GKPhotoView *photoView, CGFloat scale);
@property (nonatomic, copy) void(^loadFailed)(GKPhotoView *photoView);
@property (nonatomic, copy) void(^loadProgressBlock)(GKPhotoView *photoView, float progress, BOOL isOriginImage);

/** 横屏时是否充满屏幕宽度，默认YES，为NO时图片自动填充屏幕 */
@property (nonatomic, assign) BOOL isFullWidthForLandScape;

/// 是否适配安全区域，默认NO，为YES时图片会自动适配iPhone X的安全区域
@property (nonatomic, assign) BOOL isAdaptiveSafeArea;

/** 图片最大放大倍数 */
@property (nonatomic, assign) CGFloat maxZoomScale;

/** 双击放大倍数 */
@property (nonatomic, assign) CGFloat doubleZoomScale;

/** 是否重新布局 */
@property (nonatomic, assign) BOOL isLayoutSubViews;

@property (nonatomic, assign) GKPhotoBrowserLoadStyle loadStyle;
@property (nonatomic, assign) GKPhotoBrowserLoadStyle originLoadStyle;
@property (nonatomic, assign) GKPhotoBrowserFailStyle failStyle;

@property (nonatomic, copy) NSString    *failureText;
@property (nonatomic, strong) UIImage   *failureImage;

@property (nonatomic, assign) BOOL      showPlayImage;
@property (nonatomic, strong) UIImage   *videoPlayImage;

- (instancetype)initWithFrame:(CGRect)frame imageProtocol:(id<GKWebImageProtocol>)imageProtocol;

// 设置数据
- (void)setupPhoto:(GKPhoto *)photo;

// 设置放大倍数
- (void)setScrollMaxZoomScale:(CGFloat)scale;

// 加载原图（必须传originUrl）
- (void)loadOriginImage;

// 缩放
- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated;

// 调整布局
- (void)adjustFrame;
// 重新布局
- (void)resetFrame;

#pragma mark - **********处理视频播放**********
// 加载
- (void)showLoading;
- (void)hideLoading;
- (void)showFailure;
- (void)showPlayBtn;

// 左右滑动
- (void)didScrollAppear;
- (void)willScrollDisappear;
- (void)didScrollDisappear;

// 隐藏滑动
- (void)didDismissAppear;
- (void)willDismissDisappear;
- (void)didDismissDisappear;

- (void)updateFrame;

@end

NS_ASSUME_NONNULL_END
