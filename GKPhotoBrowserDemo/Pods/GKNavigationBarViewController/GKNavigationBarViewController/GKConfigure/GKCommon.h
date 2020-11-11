//
//  GKCommon.h
//  GKNavigationBarViewController
//
//  Created by QuintGao on 2017/10/13.
//  Copyright © 2017年 高坤. All rights reserved.
//  一些公共的方法、宏定义、枚举等

#ifndef GKCommon_h
#define GKCommon_h

#import <objc/runtime.h>

#define GKConfigure [GKNavigationBarConfigure sharedInstance]

// 判断是否是iPhoneX系列手机（带物理凹槽的刘海屏）
#define GK_IS_iPhoneX                   [GKConfigure gk_isNotchedScreen]

// 判断是否是iPad
#define GK_IS_iPad                      UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

// 屏幕相关
#define GK_SCREEN_WIDTH                 [UIScreen mainScreen].bounds.size.width
#define GK_SCREEN_HEIGHT                [UIScreen mainScreen].bounds.size.height
#define GK_SAFEAREA_TOP                 [GKConfigure gk_safeAreaInsets].top      // 顶部安全区域
#define GK_SAFEAREA_BTM                 [GKConfigure gk_safeAreaInsets].bottom   // 底部安全区域
#define GK_STATUSBAR_HEIGHT             [GKConfigure gk_statusBarFrame].size.height  // 状态栏高度
#define GK_NAVBAR_HEIGHT                44.0f   // 导航栏高度
#define GK_STATUSBAR_NAVBAR_HEIGHT      (GK_STATUSBAR_HEIGHT + GK_NAVBAR_HEIGHT) // 状态栏+导航栏高度
#define GK_TABBAR_HEIGHT                (GK_SAFEAREA_BTM + 49.0f)  //tabbar高度

// 导航栏间距，用于不同控制器之间的间距
static const CGFloat GKNavigationBarItemSpace = -1;

typedef NS_ENUM(NSUInteger, GKNavigationBarBackStyle) {
    GKNavigationBarBackStyleNone,    // 无返回按钮，可自行设置
    GKNavigationBarBackStyleBlack,   // 黑色返回按钮
    GKNavigationBarBackStyleWhite    // 白色返回按钮
};

// 使用static inline创建静态内联函数，方便调用
static inline void gk_swizzled_method(NSString *prefix, Class oldClass ,NSString *oldSelector, Class newClass) {
    NSString *newSelector = [NSString stringWithFormat:@"%@_%@", prefix, oldSelector];
    
    SEL originalSelector = NSSelectorFromString(oldSelector);
    SEL swizzledSelector = NSSelectorFromString(newSelector);
    
    Method originalMethod = class_getInstanceMethod(oldClass, NSSelectorFromString(oldSelector));
    Method swizzledMethod = class_getInstanceMethod(newClass, NSSelectorFromString(newSelector));
    
    BOOL isAdd = class_addMethod(oldClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (isAdd) {
        class_replaceMethod(newClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#endif /* GKCommon_h */
