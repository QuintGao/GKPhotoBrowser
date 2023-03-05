//
//  GKPhotoBrowserConfigure.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2020/10/19.
//  Copyright © 2020年 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+GKPhotoBrowser.h"

#define GKScreenW           [UIScreen mainScreen].bounds.size.width
#define GKScreenH           [UIScreen mainScreen].bounds.size.height
// 判断iPhone X
#define KIsiPhoneX          [GKPhotoBrowserConfigure gk_isNotchedScreen]
// 底部安全区域高度
#define kSafeTopSpace       [GKPhotoBrowserConfigure gk_safeAreaInsets].top
#define kSafeBottomSpace    [GKPhotoBrowserConfigure gk_safeAreaInsets].bottom

// 默认最大缩放程度
#define kMaxZoomScale               2.0f
// 默认图片间距
#define kPhotoViewPadding           10
// 默认动画时间
#define kAnimationDuration          0.3f

// 加载本地图片
#define GKPhotoBrowserImage(name)  [GKPhotoBrowserConfigure gk_imageWithName:name]

// 图片浏览器的显示方式
typedef NS_ENUM(NSUInteger, GKPhotoBrowserShowStyle) {
    GKPhotoBrowserShowStyleNone,       // 直接显示，默认方式
    GKPhotoBrowserShowStyleZoom,       // 缩放显示，动画效果
    GKPhotoBrowserShowStylePush        // push方式展示
};

// 图片浏览器的隐藏方式
typedef NS_ENUM(NSUInteger, GKPhotoBrowserHideStyle) {
    GKPhotoBrowserHideStyleZoom,           // 点击缩放消失
    GKPhotoBrowserHideStyleZoomScale,      // 点击缩放消失、滑动缩小后消失
    GKPhotoBrowserHideStyleZoomSlide       // 点击缩放消失、滑动平移后消失
};

// 图片浏览器的加载方式
typedef NS_ENUM(NSUInteger, GKPhotoBrowserLoadStyle) {
    GKPhotoBrowserLoadStyleIndeterminate,        // 不明确的加载方式
    GKPhotoBrowserLoadStyleIndeterminateMask,    // 不明确的加载方式带阴影
    GKPhotoBrowserLoadStyleDeterminate,          // 明确的加载方式带进度条
    GKPhotoBrowserLoadStyleCustom                // 自定义加载方式
};

// 图片加载失败的显示方式
typedef NS_ENUM(NSUInteger, GKPhotoBrowserFailStyle) {
    GKPhotoBrowserFailStyleOnlyText,           // 显示文字
    GKPhotoBrowserFailStyleOnlyImage,          // 显示图片
    GKPhotoBrowserFailStyleImageAndText,       // 显示图片+文字
    GKPhotoBrowserFailStyleCustom              // 自定义（如：显示HUD）
};

@interface GKPhotoBrowserConfigure : NSObject

/// 安全区域
+ (UIEdgeInsets)gk_safeAreaInsets;

/// 状态栏frame
+ (CGRect)gk_statusBarFrame;

/// 判断是否是刘海屏
+ (BOOL)gk_isNotchedScreen;

/// 根据图片名字获取图片
/// @param name 图片名字
+ (UIImage *)gk_imageWithName:(NSString *)name;

@end
