//
//  GKCover.h
//  GKCoverDemo
//
//  Created by QuintGao on 16/8/24.
//  Copyright © 2016年 QuintGao. All rights reserved.
//  GKCover-一个简单的遮罩视图，让你的弹窗更easy，支持自定义遮罩弹窗
//  github:https://github.com/QuintGao/GKCover

#import <UIKit/UIKit.h>
#import "GKCoverEnum.h"
#import "UIView+GKExtension.h"

typedef void(^showBlock)(void);
typedef void(^hideBlock)(void);

@interface GKCover : UIView<CAAnimationDelegate>

/// 快速创建遮罩
/// @param fromView 显示在此视图上
/// @param contentView 显示的内容视图
/// @param style 遮罩类型
/// @param showStyle 显示类型
/// @param showAnimStyle 显示动画类型
/// @param hideAnimStyle 隐藏动画类型
/// @param notClick 是否不可点击
+ (void)coverFrom:(UIView *)fromView
      contentView:(UIView *)contentView
            style:(GKCoverStyle)style
        showStyle:(GKCoverShowStyle)showStyle
    showAnimStyle:(GKCoverShowAnimStyle)showAnimStyle
    hideAnimStyle:(GKCoverHideAnimStyle)hideAnimStyle
         notClick:(BOOL)notClick;

/// 快速创建遮罩
/// @param fromView 显示在此视图上
/// @param contentView 显示的内容视图
/// @param style 遮罩类型
/// @param showStyle 显示类型
/// @param showAnimStyle 显示动画类型
/// @param hideAnimStyle 隐藏动画类型
/// @param notClick 是否不可点击
/// @param showBlock 显示后的回调
/// @param hideBlock 隐藏后的回调
+ (void)coverFrom:(UIView *)fromView
      contentView:(UIView *)contentView
            style:(GKCoverStyle)style
        showStyle:(GKCoverShowStyle)showStyle
    showAnimStyle:(GKCoverShowAnimStyle)showAnimStyle
    hideAnimStyle:(GKCoverHideAnimStyle)hideAnimStyle
         notClick:(BOOL)notClick
        showBlock:(showBlock)showBlock
        hideBlock:(hideBlock)hideBlock;

/// 快速创建遮罩
/// @param fromView 显示在此视图上
/// @param contentView 显示的内容视图
/// @param margin 遮罩与父视图的距离
/// @param style 遮罩类型
/// @param showStyle 显示类型
/// @param showAnimStyle 显示的动画类型
/// @param hideAnimStyle 隐藏的动画类型
/// @param notClick 是否不可点击
+ (void)coverFrom:(UIView *)fromView
      contentView:(UIView *)contentView
           margin:(CGFloat)margin
            style:(GKCoverStyle)style
        showStyle:(GKCoverShowStyle)showStyle
    showAnimStyle:(GKCoverShowAnimStyle)showAnimStyle
    hideAnimStyle:(GKCoverHideAnimStyle)hideAnimStyle
         notClick:(BOOL)notClick;

/// 快速创建遮罩
/// @param fromView 显示在此视图上
/// @param contentView 显示的内容视图
/// @param margin 遮罩与父视图的距离
/// @param style 遮罩类型
/// @param showStyle 显示类型
/// @param showAnimStyle 显示的动画类型
/// @param hideAnimStyle 隐藏的动画类型
/// @param notClick 是否不可点击
/// @param showBlock 显示后的回调
/// @param hideBlock 隐藏后的回调
+ (void)coverFrom:(UIView *)fromView
      contentView:(UIView *)contentView
           margin:(CGFloat)margin
            style:(GKCoverStyle)style
        showStyle:(GKCoverShowStyle)showStyle
    showAnimStyle:(GKCoverShowAnimStyle)showAnimStyle
    hideAnimStyle:(GKCoverHideAnimStyle)hideAnimStyle
         notClick:(BOOL)notClick
        showBlock:(showBlock)showBlock
        hideBlock:(hideBlock)hideBlock;


/**
 显示遮罩-隐藏状态栏

 @param contentView 显示的内容视图
 @param style 遮罩类型
 @param showStyle 显示方式
 @param showAnimStyle 显示动画类型
 @param hideAnimStyle 隐藏动画类型
 @param notClick 是否不可点击
 @param showBlock 显示后的block
 @param hideBlock 隐藏后的block
 */


/// 快速创建遮罩，遮盖状态栏
/// @param contentView 显示的内容视图
/// @param style 遮罩类型
/// @param showStyle 显示类型
/// @param showAnimStyle 显示的动画类型
/// @param hideAnimStyle 隐藏的动画类型
/// @param notClick 是否不可点击
/// @param showBlock 显示后的回调
/// @param hideBlock 隐藏后的回调
+ (void)coverHideStatusBarWithContentView:(UIView *)contentView
                                    style:(GKCoverStyle)style
                                showStyle:(GKCoverShowStyle)showStyle
                            showAnimStyle:(GKCoverShowAnimStyle)showAnimStyle
                            hideAnimStyle:(GKCoverHideAnimStyle)hideAnimStyle
                                 notClick:(BOOL)notClick
                                showBlock:(showBlock)showBlock
                                hideBlock:(hideBlock)hideBlock;


/// 快速创建中间遮罩
/// @param fromView 显示在此视图上
/// @param contentView 显示的内容视图
/// @param style 遮罩类型
/// @param animation 自定义动画
/// @param notClick 是否不可点击
+ (void)showAlertViewFrom:(UIView *)fromView
              contentView:(UIView *)contentView
                    style:(GKCoverStyle)style
                animation:(CAAnimation *)animation
                 notClick:(BOOL)notClick;

/// 快速创建中间遮罩
/// @param fromView 显示在此视图上
/// @param contentView 显示的内容视图
/// @param style 遮罩类型
/// @param animation 自定义动画
/// @param notClick 是否不可点击
/// @param showBlock 显示后的回调
/// @param hideBlock 隐藏后的回调
+ (void)showAlertViewFrom:(UIView *)fromView
              contentView:(UIView *)contentView
                    style:(GKCoverStyle)style
                animation:(CAAnimation *)animation
                 notClick:(BOOL)notClick
                showBlock:(showBlock)showBlock
                hideBlock:(hideBlock)hideBlock;

/// 判断是否已经存在cover
+ (BOOL)hasCover;

/// 改变遮罩透明度，只对半透明遮罩生效
/// @param alpha 透明度
+ (void)changeAlpha:(CGFloat)alpha;

/// 改变遮罩背景色
/// @param bgColor 背景色
+ (void)changeCoverBgColor:(UIColor *)bgColor;

/// 隐藏遮罩
+ (void)hideCover;

/// 隐藏遮罩并设置回调，调用此方法主方法中的hideBlock将不再起作用
/// @param hideBlock 隐藏成功后的回调
+ (void)hideCoverWithHideBlock:(hideBlock)hideBlock;

/// 无动画隐藏
+ (void)hideCoverWithoutAnimation;

/// 重新布局
+ (void)layoutSubViews;

@end
