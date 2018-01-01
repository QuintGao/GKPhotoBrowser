//
//  GKCover.h
//  GKCoverDemo
//
//  Created by 高坤 on 16/8/24.
//  Copyright © 2016年 高坤. All rights reserved.
//  GKCover-一个简单的遮罩视图，让你的弹窗更easy，支持自定义遮罩弹窗
//  github:https://github.com/QuintGao/GKCover

#import <UIKit/UIKit.h>
#import "GKCoverEnum.h"
#import "UIView+GKExtension.h"

typedef void(^showBlock)(void);
typedef void(^hideBlock)(void);

@interface GKCover : UIView<CAAnimationDelegate>

+ (instancetype)cover;

#pragma mark - 自定义遮罩- (可实现固定遮罩的效果)
/**
 *  半透明遮罩构造方法
 */
+ (instancetype)translucentCoverWithTarget:(id)target
                                    action:(SEL)action;

/**
 *  全透明遮罩构造方法
 */
+ (instancetype)transparentCoverWithTarget:(id)target
                                    action:(SEL)action;


#pragma mark - 固定遮罩-屏幕底部弹窗
/**
 *  半透明遮罩，默认黑色，0.5
 */
+ (void)translucentCoverFrom:(UIView *)fromView
                     content:(UIView *)contentView
                    animated:(BOOL)animated;

/**
 *  改变透明度(仅用于半透明遮罩)
 */
+ (void)changeAlpha:(CGFloat)alpha;

/**
 *  全透明遮罩
 */
+ (void)transparentCoverFrom:(UIView *)fromView
                     content:(UIView *)contentView
                    animated:(BOOL)animated;

#pragma mark - 固定遮罩-屏幕中间弹窗
/**
 *  半透明遮罩，默认黑色，0.5
 *
 *  @param contentView 弹出的内容视图
 *  @param animated    是否动画
 */
+ (void)translucentWindowCenterCoverContent:(UIView *)contentView
                                   animated:(BOOL)animated;


/**
 *  全透明遮罩
 *
 *  @param contentView 弹出的内容视图
 *  @param animated    是否动画
 */
+ (void)transparentWindowCenterCoverContent:(UIView *)contentView
                                   animated:(BOOL)animated;

#pragma mark - v1.0.5 新增功能
#pragma makr - 新增弹窗显示和隐藏时的block

/**
 *  半透明遮罩-底部弹窗，添加显示和隐藏的block
 */
+ (void)translucentCoverFrom:(UIView *)fromView
                     content:(UIView *)contentView
                    animated:(BOOL)animated
                   showBlock:(showBlock)show
                   hideBlock:(hideBlock)hide;

/**
 *  全透明遮罩-底部弹窗，添加显示和隐藏的block
 */
+ (void)transparentCoverFrom:(UIView *)fromView
                     content:(UIView *)contentView
                    animated:(BOOL)animated
                   showBlock:(showBlock)show
                   hideBlock:(hideBlock)hide;

/**
 *  半透明遮罩-中间弹窗，添加显示和隐藏的block
 */
+ (void)translucentWindowCenterCoverContent:(UIView *)contentView
                                   animated:(BOOL)animated
                                  showBlock:(showBlock)show
                                  hideBlock:(hideBlock)hide;

/**
 *  全透明遮罩-中间弹窗，添加显示和隐藏的block
 */
+ (void)transparentWindowCenterCoverContent:(UIView *)contentView
                                   animated:(BOOL)animated
                                  showBlock:(showBlock)show
                                  hideBlock:(hideBlock)hide;

#pragma mark - v1.0.5 
#pragma mark - 增加外部调用显示和隐藏的方法
/**
 *  显示
 */
+ (void)show;
/**
 *  隐藏
 */
+ (void)hide;

#pragma mark - v2.0.0
#pragma makr - 新增功能：增加点击遮罩时是否消失的判断,notClick是否可以点击，默认是NO,代表能点击

+ (void)translucentCoverFrom:(UIView *)fromView
                     content:(UIView *)contentView
                    animated:(BOOL)animated
                    notClick:(BOOL)click;

+ (void)transparentCoverFrom:(UIView *)fromView
                     content:(UIView *)contentView
                    animated:(BOOL)animated
                    notClick:(BOOL)click;

+ (void)translucentWindowCenterCoverContent:(UIView *)contentView
                                   animated:(BOOL)animated
                                   notClick:(BOOL)click;

+ (void)transparentWindowCenterCoverContent:(UIView *)contentView
                                   animated:(BOOL)animated
                                   notClick:(BOOL)click;

#pragma mark - v2.1.0
#pragma mark - 新增毛玻璃遮罩效果

/**
 *  高斯模糊遮罩
 *
 *  @param contentView 弹窗的内容
 *  @param animated    是否动画
 *  @param notClick    是否能点击，默认为NO，可点
 *  @param style       高斯模糊类型
 */
+ (void)blurWindowCenterCoverContent:(UIView *)contentView
                            animated:(BOOL)animated
                            notClick:(BOOL)notClick
                               style:(UIBlurEffectStyle)style;


#pragma mark - v2.2.0
#pragma mark - 全新定义构造方法，根据不同类型，显示不同遮罩

// 常见遮罩
+ (void)topCover:(UIView *)fromView
     contentView:(UIView *)contentView
           style:(GKCoverStyle)style
        notClick:(BOOL)notClick
        animated:(BOOL)animated;

+ (void)bottomCoverFrom:(UIView *)fromView
            contentView:(UIView *)contentView
                  style:(GKCoverStyle)style
               notClick:(BOOL)notClick
               animated:(BOOL)animated;

+ (void)centerCover:(UIView *)contentView
              style:(GKCoverStyle)style
           notClick:(BOOL)notClick
           animated:(BOOL)animated;

/**
 显示遮罩

 @param fromView    显示的视图上
 @param contentView 显示的视图
 @param style       遮罩类型
 @param showStyle   显示类型
 @param animStyle   动画类型
 @param notClick    是否不可点击
 */
+ (void)coverFrom:(UIView *)fromView
      contentView:(UIView *)contentView
            style:(GKCoverStyle)style
        showStyle:(GKCoverShowStyle)showStyle
        animStyle:(GKCoverAnimStyle)animStyle
         notClick:(BOOL)notClick;

+ (void)coverFrom:(UIView *)fromView
      contentView:(UIView *)contentView
            style:(GKCoverStyle)style
        showStyle:(GKCoverShowStyle)showStyle
        animStyle:(GKCoverAnimStyle)animStyle
         notClick:(BOOL)notClick
        showBlock:(showBlock)showBlock
        hideBlock:(hideBlock)hideBlock;

+ (void)showView;
+ (void)hideView;

#pragma mark - v2.3.1
#pragma mark - 增加判断是否已经有cover的方法

+ (BOOL)hasCover;


#pragma mark - v2.4.0
#pragma mark - 分离弹出和隐藏时的动画
+ (void)coverFrom:(UIView *)fromView
      contentView:(UIView *)contentView
            style:(GKCoverStyle)style
        showStyle:(GKCoverShowStyle)showStyle
    showAnimStyle:(GKCoverShowAnimStyle)showAnimStyle
    hideAnimStyle:(GKCoverHideAnimStyle)hideAnimStyle
         notClick:(BOOL)notClick;

+ (void)coverFrom:(UIView *)fromView
      contentView:(UIView *)contentView
            style:(GKCoverStyle)style
        showStyle:(GKCoverShowStyle)showStyle
    showAnimStyle:(GKCoverShowAnimStyle)showAnimStyle
    hideAnimStyle:(GKCoverHideAnimStyle)hideAnimStyle
         notClick:(BOOL)notClick
        showBlock:(showBlock)showBlock
        hideBlock:(hideBlock)hideBlock;

+ (void)coverHideStatusBarWithContentView:(UIView *)contentView
                                    style:(GKCoverStyle)style
                                showStyle:(GKCoverShowStyle)showStyle
                            showAnimStyle:(GKCoverShowAnimStyle)showAnimStyle
                            hideAnimStyle:(GKCoverHideAnimStyle)hideAnimStyle
                                 notClick:(BOOL)notClick
                                showBlock:(showBlock)showBlock hideBlock:(hideBlock)hideBlock;

+ (void)showCover;
+ (void)hideCover;

+ (void)layoutSubViews;

@end
