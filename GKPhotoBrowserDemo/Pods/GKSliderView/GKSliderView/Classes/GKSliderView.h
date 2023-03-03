//
//  GKSliderView.h
//  GKSliderView
//
//  Created by QuintGao on 2017/9/6.
//  Copyright © 2017年 高坤. All rights reserved.
//  自定义的一个slider

#import <UIKit/UIKit.h>

// 过期提醒
#define GKSliderViewDeprecated(DESCRIPTION) __attribute__((deprecated(DESCRIPTION)))

@class GKSliderView;

@protocol GKSliderViewPreviewDelegate <NSObject>

/// 设置预览视图，预览视图与sliderView同级
/// @param sliderView sliderView
- (UIView *)sliderViewSetupPreview:(GKSliderView *)sliderView;

@optional
/// 预览视图与滑块的间距，默认10
/// @param sliderView sliderView
- (CGFloat)sliderViewPreviewMargin:(GKSliderView *)sliderView;

/// 预览视图值改变代理
/// @param sliderView sliderView
/// @param preview 预览视图
/// @param value 进度值
- (void)sliderView:(GKSliderView *)sliderView preview:(UIView *)preview valueChanged:(float)value;

@end

@protocol GKSliderViewDelegate <NSObject>

@optional
// 滑块滑动开始
- (void)sliderTouchBegan:(float)value GKSliderViewDeprecated("使用sliderView:(GKSliderView *)sliderView touchBegan:(float)value代替");
// 滑块滑动中
- (void)sliderValueChanged:(float)value GKSliderViewDeprecated("使用sliderView:(GKSliderView *)sliderView valueChanged:(float)value代替");
// 滑块滑动结束
- (void)sliderTouchEnded:(float)value GKSliderViewDeprecated("使用sliderView:(GKSliderView *)sliderView touchEnded:(float)value代替");
// 滑杆点击
- (void)sliderTapped:(float)value GKSliderViewDeprecated("使用sliderView:(GKSliderView *)sliderView tapped:(float)value代替");

/// 滑块滑动开始
- (void)sliderView:(GKSliderView *)sliderView touchBegan:(float)value;
/// 滑块滑动结束
- (void)sliderView:(GKSliderView *)sliderView touchEnded:(float)value;
/// 滑块滑动中
- (void)sliderView:(GKSliderView *)sliderView valueChanged:(float)value;
/// 滑杆点击
- (void)sliderView:(GKSliderView *)sliderView tapped:(float)value;

@end

@interface GKSliderButton : UIButton

// 是否扩大点击范围，默认NO
@property (nonatomic, assign) BOOL enlargeClickRange;

@end

@interface GKSliderView : UIView

@property (nonatomic, weak) id<GKSliderViewDelegate> delegate;

/// 预览视图代理
@property (nonatomic, weak) id<GKSliderViewPreviewDelegate> previewDelegate;

#pragma mark - 滑杆相关属性及方法
/** 默认滑杆的颜色 */
@property (nonatomic, strong) UIColor *maximumTrackTintColor;
/** 滑杆进度颜色 */
@property (nonatomic, strong) UIColor *minimumTrackTintColor;
/** 缓存进度颜色 */
@property (nonatomic, strong) UIColor *bufferTrackTintColor;

/** 默认滑杆的图片 */
@property (nonatomic, strong) UIImage *maximumTrackImage;
/** 滑杆进度的图片 */
@property (nonatomic, strong) UIImage *minimumTrackImage;
/** 缓存进度的图片 */
@property (nonatomic, strong) UIImage *bufferTrackImage;

/** 滑杆进度 */
@property (nonatomic, assign) float value;
/** 缓存进度 */
@property (nonatomic, assign) float bufferValue;

/** 滑杆是否允许点击，默认是YES */
@property (nonatomic, assign) BOOL isSliderAllowTapped;

/** 设置滑杆的高度,默认3 */
@property (nonatomic, assign) CGFloat sliderHeight;

/** 滑杆圆角半径 */
@property (nonatomic, assign) CGFloat cornerRadius;

/** 滑杆背景圆角半径，设置此属性滑杆进度和缓冲进度不为1时只会左边切圆角，为1时左右都切圆角 */
@property (nonatomic, assign) CGFloat bgCornerRadius;

/** 忽略间距，设置此属性，滑杆左右会有相应的距离不计入滑杆的进度，默认0 */
@property (nonatomic, assign) CGFloat ignoreMargin;

#pragma mark - 滑块相关属性及方法
/** 滑块中心点的Y值，默认0：表示GKSliderView的中心 */
@property (nonatomic, assign) CGFloat sliderBlockCenterY;

/** 是否隐藏滑块（默认为NO） */
@property (nonatomic, assign) BOOL isHideSliderBlock;

/** 滑块是否允许点击，默认YES */
@property (nonatomic, assign) BOOL isSliderBlockAllowTapped;

/** 滑块 */
@property (nonatomic, strong, readonly) GKSliderButton *sliderBtn;

/// 预览视图
@property (nonatomic, strong, readonly) UIView *preview;

// 设置滑块背景色
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state;
// 设置滑块图片
- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state;

// 显示菊花动画
- (void)showLoading;
// 隐藏菊花动画
- (void)hideLoading;

@end

@interface UIView (GKFrame)

@property (nonatomic, assign) CGFloat gk_top;
@property (nonatomic, assign) CGFloat gk_left;
@property (nonatomic, assign) CGFloat gk_right;
@property (nonatomic, assign) CGFloat gk_bottom;
@property (nonatomic, assign) CGFloat gk_width;
@property (nonatomic, assign) CGFloat gk_height;
@property (nonatomic, assign) CGFloat gk_centerX;
@property (nonatomic, assign) CGFloat gk_centerY;

@end
