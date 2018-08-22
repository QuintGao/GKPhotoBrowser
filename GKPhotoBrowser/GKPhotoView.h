//
//  GKPhotoView.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/23.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKPhoto.h"
#import "GKScrollView.h"
#import "GKWebImageProtocol.h"
#import "GKLoadingView.h"

NS_ASSUME_NONNULL_BEGIN

@class GKPhotoView;

@interface GKPhotoView : UIView<UIScrollViewDelegate>

@property (nonatomic, strong, readonly) GKScrollView *scrollView;

@property (nonatomic, strong, readonly) UIImageView  *imageView;

@property (nonatomic, strong, readonly) GKLoadingView *loadingView;

@property (nonatomic, strong, readonly) GKPhoto *photo;

@property (nonatomic, copy) void(^zoomEnded)(NSInteger scale);

/** 横屏时是否充满屏幕宽度，默认YES，为NO时图片自动填充屏幕 */
@property (nonatomic, assign) BOOL isFullWidthForLandSpace;

/**
 开启这个选项后 在加载gif的时候 会大大的降低内存.与YYImage对gif的内存优化思路一样 default is NO
 */
@property (nonatomic, assign) BOOL isLowGifMemory;

/** 是否重新布局 */
@property (nonatomic, assign) BOOL isLayoutSubViews;

@property (nonatomic, assign) GKPhotoBrowserLoadStyle loadStyle;

- (instancetype)initWithFrame:(CGRect)frame imageProtocol:(id<GKWebImageProtocol>)imageProtocol;

// 设置数据
- (void)setupPhoto:(GKPhoto *)photo;

- (void)adjustFrame;

// 缩放
- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated;

// 重新布局
- (void)resetFrame;

- (void)startGifAnimation;
- (void)stopGifAnimation;

@end

NS_ASSUME_NONNULL_END
