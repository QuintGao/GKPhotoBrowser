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
    if (@available(iOS 11.0, *)) {
        UIWindow *window = [self getKeyWindow];
        if (!window) {
            // keyWindow还没创建时，通过创建临时window获取安全区域
            window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
            if (window.safeAreaInsets.bottom <= 0) {
                UIViewController *viewController = [UIViewController new];
                window.rootViewController = viewController;
            }
        }
        safeAreaInsets = window.safeAreaInsets;
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
            isNotchedScreen = [GKPhotoBrowserConfigure gk_safeAreaInsets].bottom > 0 ? 1 : 0;
        }else {
            isNotchedScreen = 0;
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
