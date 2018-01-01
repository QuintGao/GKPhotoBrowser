//
//  UINavigationBar+GKCategory.m
//  GKNavigationBarViewControllerTest
//
//  Created by QuintGao on 2017/10/13.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "UINavigationBar+GKCategory.h"
#import "GKCommon.h"
#import "GKNavigationBarConfigure.h"

@implementation UINavigationBar (GKCategory)

+ (void)load {
    // 保证其只执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        gk_swizzled_method(class, @selector(layoutSubviews), @selector(gk_layoutSubviews));
    });
}

- (void)gk_layoutSubviews {
    [self gk_layoutSubviews];
    
    if (GKDeviceVersion >= 11.0 && !gk_disableFixSpace) {
        self.layoutMargins = UIEdgeInsetsZero;
        CGFloat space = GKConfigure.navItem_space;
        
        for (UIView *subview in self.subviews) {
            if ([NSStringFromClass(subview.class) containsString:@"ContentView"]) {
                // 修复iOS11 之后的偏移
                subview.layoutMargins = UIEdgeInsetsMake(0, space, 0, space);
                break;
            }
        }
    }
}

@end
