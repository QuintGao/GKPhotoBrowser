//
//  GKLoadingView.h
//  GKLoadingView
//
//  Created by QuintGao on 2017/11/23.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKPhotoBrowserConfigure.h"

typedef NS_ENUM(NSUInteger, GKLoadingStyle) {
    GKLoadingStyleIndeterminate,      // 不明确的加载方式
    GKLoadingStyleIndeterminateMask,  // 不明确的加载方式带阴影
    GKLoadingStyleDeterminate,        // 明确的加载方式--进度条
    GKLoadingStyleCustom              // 自定义
};

@interface GKLoadingView : UIView

+ (instancetype)loadingViewWithFrame:(CGRect)frame style:(GKLoadingStyle)style;

@property (nonatomic, assign) GKPhotoBrowserFailStyle  failStyle;

@property (nonatomic, strong) UIButton *centerButton;

/** 线条宽度：默认4 */
@property (nonatomic, assign) CGFloat lineWidth;

/** 圆弧半径：默认24 */
@property (nonatomic, assign) CGFloat radius;

/** 圆弧的背景颜色：默认半透明黑色 */
@property (nonatomic, strong) UIColor *bgColor;

/** 进度的颜色：默认白色 */
@property (nonatomic, strong) UIColor *strokeColor;

/** 进度，loadingStyle为GKLoadingStyleDeterminate时使用 */
@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, copy) NSString  *failText;
@property (nonatomic, strong) UIImage *failImage;

@property (nonatomic, copy) void (^progressChange)(GKLoadingView *loadingView, CGFloat progress);

@property (nonatomic, copy) void (^tapToReload)(void);

/**
 开始动画方法-loadingStyle为GKLoadingStyleIndeterminate，GKLoadingStyleIndeterminateMask时使用
 */
- (void)startLoading;

/**
 结束动画方法
 */
- (void)stopLoading;

- (void)showFailure;

- (void)hideFailure;

- (void)hideLoadingView;

- (void)removeAnimation;

// 在duration时间内加载，
- (void)startLoadingWithDuration:(NSTimeInterval)duration completion:(void (^)(GKLoadingView *loadingView, BOOL finished))completion;

@end
