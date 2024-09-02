//
//  UIDevice+GKPhotoBrowser.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2024/8/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (GKPhotoBrowser)

/// 安全区域
+ (UIEdgeInsets)gk_safeAreaInsets;

+ (CGFloat)gk_safeAreaTop;
+ (CGFloat)gk_safeAreaBottom;

/// 状态栏frame
+ (CGRect)gk_statusBarFrame;

/// 是否是Mac
+ (BOOL)isMac;

/// 判断是否是刘海屏
+ (BOOL)gk_isNotchedScreen;

/// 获取当前 window
+ (UIWindow *)getKeyWindow;

@end

NS_ASSUME_NONNULL_END
