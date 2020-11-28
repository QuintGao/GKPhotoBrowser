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
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    if (![window isKeyWindow]) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (CGRectEqualToRect(keyWindow.bounds, [UIScreen mainScreen].bounds)) {
            window = keyWindow;
        }
    }
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets insets = [window safeAreaInsets];
        return insets;
    }
    return UIEdgeInsetsZero;
}

+ (BOOL)gk_isIPhoneXSeries {
    if ([UIWindow instancesRespondToSelector:@selector(safeAreaInsets)]) {
        return [GKPhotoBrowserConfigure gk_safeAreaInsets].bottom > 0;
    }
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    return (CGSizeEqualToSize(screenSize, CGSizeMake(375, 812)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(812, 375)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(414, 896)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(896, 414)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(390, 844)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(844, 390)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(428, 926)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(926, 428)));
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
