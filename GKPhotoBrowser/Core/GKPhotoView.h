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
#import "GKLoadingView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKScrollView : UIScrollView

@end

@class GKPhotoView;

@interface GKPhotoView : UIView<UIScrollViewDelegate>

@property (nonatomic, strong, readonly) GKScrollView *scrollView;

@property (nonatomic, strong, readonly) UIImageView  *imageView;

@property (nonatomic, strong, readonly) GKLoadingView *loadingView;

@property (nonatomic, strong, readonly) GKPhoto *photo;

@property (nonatomic, copy) void(^zoomEnded)(GKPhotoView *photoView, CGFloat scale);
@property (nonatomic, copy) void(^loadFailed)(GKPhotoView *photoView);
@property (nonatomic, copy) void(^loadProgressBlock)(GKPhotoView *photoView, float progress, BOOL isOriginImage);

/** 横屏时是否充满屏幕宽度，默认YES，为NO时图片自动填充屏幕 */
@property (nonatomic, assign) BOOL isFullWidthForLandScape;

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

@end

NS_ASSUME_NONNULL_END
