//
//  GKNavigationBar.m
//  GKNavigationBarViewControllerTest
//
//  Created by QuintGao on 2017/9/20.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKNavigationBar.h"

@implementation GKNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 设置默认透明度
        self.gk_navBarBackgroundAlpha = 1.0;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 这里为了适配iOS11，需要遍历所有的子控件，并向下移动状态栏的高度
    CGFloat systemVersion = [UIDevice currentDevice].systemVersion.floatValue;
    
    if (systemVersion >= 11.0) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {
                CGRect frame = obj.frame;
                frame.size.height = self.frame.size.height;
                obj.frame = frame;
            }else {
                
                CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
        
                CGRect frame   = obj.frame;
                frame.origin.y += statusBarFrame.size.height;
                obj.frame      = frame;
            }
        }];
    }
    
    // 重新设置透明度，解决iOS11的bug
    self.gk_navBarBackgroundAlpha = self.gk_navBarBackgroundAlpha;
}

- (void)setGk_navBarBackgroundAlpha:(CGFloat)gk_navBarBackgroundAlpha {
    _gk_navBarBackgroundAlpha = gk_navBarBackgroundAlpha;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                obj.alpha = gk_navBarBackgroundAlpha;
            });
        }
    }];
    
    self.clipsToBounds = gk_navBarBackgroundAlpha == 0.0;
}

@end
