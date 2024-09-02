//
//  GKPhotoView.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/23.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKPhoto.h"
#import "GKWebImageProtocol.h"
#import "GKVideoPlayerProtocol.h"
#import "GKLivePhotoProtocol.h"
#import "GKProgressViewProtocol.h"
#import "GKLoadingView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKScrollView : UIScrollView

@end

@class GKPhotoView;

@protocol GKPhotoViewDelegate <NSObject>

// 缩放结束
- (void)photoView:(GKPhotoView *)photoView zoomEndedWithScale:(CGFloat)scale;

// 加载失败
- (void)photoView:(GKPhotoView *)photoView loadFailedWithError:(NSError *)error;

// 加载进度，isOriginImage：是否是原图
- (void)photoView:(GKPhotoView *)photoView loadProgress:(float)progress isOriginImage:(BOOL)isOriginImage;

// 视频加载
- (void)photoView:(GKPhotoView *)photoView loadStart:(BOOL)isStart success:(BOOL)success;

@end

@class GKPhotoBrowser;

@interface GKPhotoView : UIView<UIScrollViewDelegate>

@property (nonatomic, strong, readonly) GKScrollView *scrollView;

@property (nonatomic, strong, readonly) UIImageView  *imageView;

@property (nonatomic, strong, readonly) UIButton     *playBtn;

@property (nonatomic, strong, readonly) GKLoadingView *loadingView;

@property (nonatomic, strong, readonly) GKLoadingView *videoLoadingView;

@property (nonatomic, strong, readonly) GKLoadingView *liveLoadingView;
@property (nonatomic, strong, readonly) UIView *liveMarkView;

@property (nonatomic, strong, readonly) GKPhoto *photo;

@property (nonatomic, strong) GKPhotoBrowserConfigure *configure;

@property (nonatomic, weak) id<GKWebImageProtocol> imager;

@property (nonatomic, weak) id<GKVideoPlayerProtocol> player;

@property (nonatomic, weak) id<GKLivePhotoProtocol> livePhoto;

@property (nonatomic, weak) id<GKPhotoViewDelegate> delegate;

@property (nonatomic, assign) CGSize imageSize;

/** 双击放大倍数 */
@property (nonatomic, assign) CGFloat doubleZoomScale;

@property (nonatomic, assign) CGFloat realZoomScale;

- (instancetype)initWithFrame:(CGRect)frame configure:(GKPhotoBrowserConfigure *)configure;

// 准备复用
- (void)prepareForReuse;

- (void)resetImageView;

// 设置数据
- (void)setupPhoto:(GKPhoto *)photo;

// 设置放大倍数
- (void)setScrollMaxZoomScale:(CGFloat)scale;

// 缩放
- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated;

// 调整布局
- (void)adjustFrame;
// 重新布局
- (void)resetFrame;

#pragma mark - **********处理视频播放**********
- (void)playAction;
- (void)pauseAction;

// 加载
- (void)showLoading;
- (void)hideLoading;
- (void)showFailure:(NSError *)error;
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

- (void)loadFailedWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
