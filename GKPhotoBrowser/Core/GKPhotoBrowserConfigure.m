//
//  GKPhotoBrowserConfigure.m
//  GKPhotoBrowser
//
//  Created by gaokun on 2020/10/19.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import "GKPhotoBrowserConfigure.h"

NSString *const GKPhotoBrowserBundleName = @"GKPhotoBrowser";

@implementation GKPhotoBrowserConfigure

+ (UIEdgeInsets)gk_safeAreaInsets {
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if ([GKPhotoBrowserConfigure gk_isNotchedScreen]) {
        UIWindow *keyWindow = [GKPhotoBrowserConfigure getKeyWindow];
        if (keyWindow) {
            if (@available(iOS 11.0, *)) {
                safeAreaInsets = keyWindow.safeAreaInsets;
            }
        }else { // 如果获取到的window是空
            // 对于刘海屏，当window没有创建的时候，可根据状态栏设置安全区域顶部高度
            // iOS14之后顶部安全区域不再是固定的44，所以修改为以下方式获取
            safeAreaInsets = UIEdgeInsetsMake([GKPhotoBrowserConfigure gk_statusBarFrame].size.height, 0, 34, 0);
        }
    }
    return safeAreaInsets;
}

+ (CGRect)gk_statusBarFrame {
    CGRect statusBarFrame = CGRectZero;
    if (@available(iOS 13.0, *)) {
        statusBarFrame = [GKPhotoBrowserConfigure getKeyWindow].windowScene.statusBarManager.statusBarFrame;
    }
    
    if (CGRectEqualToRect(statusBarFrame, CGRectZero)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
#pragma clang diagnostic pop
    }
    
    if (CGRectEqualToRect(statusBarFrame, CGRectZero)) {
        CGFloat statusBarH = [GKPhotoBrowserConfigure gk_isNotchedScreen] ? 44 : 20;
        statusBarFrame = CGRectMake(0, 0, GKScreenW, statusBarH);
    }
    
    return statusBarFrame;
}

static NSInteger isNotchedScreen = -1;
+ (BOOL)gk_isNotchedScreen {
    if (isNotchedScreen < 0) {
        if (@available(iOS 11.0, *)) {
            UIWindow *keyWindow = [self getKeyWindow];
            if (keyWindow) {
                isNotchedScreen = keyWindow.safeAreaInsets.bottom > 0 ? 1 : 0;
            }
        }
        
        // 当iOS11以下或获取不到keyWindow时用以下方案
        if (isNotchedScreen < 0) {
            CGSize screenSize = UIScreen.mainScreen.bounds.size;
            BOOL _isNotchedSize = (CGSizeEqualToSize(screenSize, CGSizeMake(375, 812)) ||
                                   CGSizeEqualToSize(screenSize, CGSizeMake(812, 375)) ||
                                   CGSizeEqualToSize(screenSize, CGSizeMake(414, 896)) ||
                                   CGSizeEqualToSize(screenSize, CGSizeMake(896, 414)) ||
                                   CGSizeEqualToSize(screenSize, CGSizeMake(390, 844)) ||
                                   CGSizeEqualToSize(screenSize, CGSizeMake(844, 390)) ||
                                   CGSizeEqualToSize(screenSize, CGSizeMake(428, 926)) ||
                                   CGSizeEqualToSize(screenSize, CGSizeMake(926, 428)));
            isNotchedScreen = _isNotchedSize ? 1 : 0;
        }
    }
    return isNotchedScreen > 0;
}

+ (UIWindow *)getKeyWindow {
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *w in windowScene.windows) {
                    if (window.isKeyWindow) {
                        window = w;
                        break;
                    }
                }
            }
        }
    }
    if (!window) {
        window = [UIApplication sharedApplication].windows.firstObject;
        if (!window.isKeyWindow) {
#pragma clang diagnostic push
#pragma clang disagnostic ignored "-Wdeprecated-declarations"
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
#pragma clang disagnostic pop
            if (CGRectEqualToRect(keyWindow.bounds, UIScreen.mainScreen.bounds)) {
                window = keyWindow;
            }
        }
    }
    return window;
}

+ (UIImage *)gk_imageWithName:(NSString *)name {
    static NSBundle *resourceBundle = nil;
    if (!resourceBundle) {
        NSBundle *mainBundle = [NSBundle bundleForClass:self];
        NSString *resourcePath = [mainBundle pathForResource:GKPhotoBrowserBundleName ofType:@"bundle"];
        resourceBundle = [NSBundle bundleWithPath:resourcePath] ?: mainBundle;
    }
    UIImage *image = [UIImage imageNamed:name inBundle:resourceBundle compatibleWithTraitCollection:nil];
    return image;
}

@end
