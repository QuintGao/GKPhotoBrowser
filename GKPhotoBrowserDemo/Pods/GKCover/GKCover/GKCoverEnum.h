//
//  GKCoverEnum.h
//  GKCoverDemo
//
//  Created by 高坤 on 2016/11/2.
//  Copyright © 2016年 高坤. All rights reserved.
//

#ifndef GKCoverEnum_h
#define GKCoverEnum_h

#define KScreenW [UIScreen mainScreen].bounds.size.width
#define KScreenH [UIScreen mainScreen].bounds.size.height

/** 默认动画时间 */
#define kAnimDuration 0.25
/** 默认透明度 */
#define kAlpha 0.5

// 过期提醒
#define GKCoverDeprecated(instead) NS_DEPRECATED(2_0, 8_0, 2_0, 8_0, instead)

/** 遮罩类型 */
typedef NS_ENUM(NSUInteger, GKCoverStyle) {
    /** 半透明 */
    GKCoverStyleTranslucent,  // 半透明
    /** 全透明 */
    GKCoverStyleTransparent,  // 全透明
    /** 高斯模糊 */
    GKCoverStyleBlur          // 高斯模糊
};

/** 视图显示类型 */
typedef NS_ENUM(NSUInteger, GKCoverShowStyle) {
    /** 显示在上面 */
    GKCoverShowStyleTop,     // 显示在上面
    /** 显示在中间 */
    GKCoverShowStyleCenter,  // 显示在中间
    /** 显示在底部 */
    GKCoverShowStyleBottom,  // 显示在底部
    /** 显示在左侧 */
    GKCoverShowStyleLeft,    // 显示在左侧
    /** 显示在右侧 */
    GKCoverShowStyleRight    // 显示在右侧
};

/** 动画类型 */
typedef NS_ENUM(NSUInteger, GKCoverAnimStyle) {
    GKCoverAnimStyleTop,      // 从上弹出 (上，中可用)
    GKCoverAnimStyleCenter,   // 中间弹出 (中可用)
    GKCoverAnimStyleBottom,   // 底部弹出,底部消失 (中，下可用)
    GKCoverAnimStyleLeft,     // 左侧弹出,左侧消失
    GKCoverAnimStyleRight,    // 右侧弹出,右侧消失
    GKCoverAnimStyleNone      // 无动画
};


#pragma mark - v2.4.0新增
/** 弹窗显示时的动画类型 */
typedef NS_ENUM(NSUInteger, GKCoverShowAnimStyle) {
    /** 从上弹出 */
    GKCoverShowAnimStyleTop,     // 从上弹出
    /** 中间弹出 */
    GKCoverShowAnimStyleCenter,  // 中间弹出
    /** 底部弹出 */
    GKCoverShowAnimStyleBottom,  // 底部弹出
    /** 左侧弹出 */
    GKCoverShowAnimStyleLeft,    // 左侧弹出
    /** 右侧弹出 */
    GKCoverShowAnimStyleRight,   // 右侧弹出
    /** 无动画 */
    GKCoverShowAnimStyleNone     // 无动画
};

/** 弹窗隐藏时的动画类型 */
typedef NS_ENUM(NSUInteger, GKCoverHideAnimStyle) {
    /** 从上隐藏 */
    GKCoverHideAnimStyleTop,     // 从上隐藏
    /** 中间隐藏（直接消失） */
    GKCoverHideAnimStyleCenter,  // 中间隐藏（直接消失）
    /** 底部隐藏 */
    GKCoverHideAnimStyleBottom,  // 底部隐藏
    /** 左侧隐藏 */
    GKCoverHideAnimStyleLeft,    // 左侧弹出
    /** 右侧隐藏 */
    GKCoverHideAnimStyleRight,   // 右侧弹出
    /** 无动画 */
    GKCoverHideAnimStyleNone     // 无动画
};

#endif /* GKCoverEnum_h */
