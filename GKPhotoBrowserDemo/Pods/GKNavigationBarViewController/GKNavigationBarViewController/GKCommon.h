//
//  GKCommon.h
//  GKNavigationBarViewControllerTest
//
//  Created by QuintGao on 2017/10/13.
//  Copyright © 2017年 高坤. All rights reserved.
//  一些公共的方法、宏定义、枚举等

#ifndef GKCommon_h
#define GKCommon_h

#import <objc/runtime.h>

// 图片路径
#define GKSrcName(file) [@"GKNavigationBarViewController.bundle" stringByAppendingPathComponent:file]

#define GKFrameworkSrcName(file) [@"Frameworks/GKNavigationBarViewController.framework/GKNavigationBarViewController.bundle" stringByAppendingPathComponent:file]

#define GKImage(file)  [UIImage imageNamed:GKSrcName(file)] ? : [UIImage imageNamed:GKFrameworkSrcName(file)]

#define GKConfigure [GKNavigationBarConfigure sharedInstance]

#define GKDeviceVersion [[[UIDevice currentDevice] systemVersion] floatValue]

//#define GK_DefultFixSpace GKDeviceVersion >= 11.0 ? 0 : 4

typedef NS_ENUM(NSUInteger, GKNavigationBarBackStyle) {
    GKNavigationBarBackStyleNone,    // 无返回按钮，可自行设置
    GKNavigationBarBackStyleBlack,   // 黑色返回按钮
    GKNavigationBarBackStyleWhite    // 白色返回按钮
};

//static CGFloat gk_tempFixSpace = 0;
static BOOL gk_disableFixSpace = NO;

// 使用static inline创建静态内联函数，方便调用
static inline void gk_swizzled_method(Class cls ,SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    
    BOOL isAdd = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (isAdd) {
        class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#endif /* GKCommon_h */
