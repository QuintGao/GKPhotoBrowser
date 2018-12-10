//
//  UIScrollView+GKGestureHandle.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/10.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "UIScrollView+GKGestureHandle.h"
#import <objc/runtime.h>

static const void* GKGestureHandleEnabled = @"GKGestureHandleEnabled";

@implementation UIScrollView (GKGestureHandle)

- (void)setGk_gestureHandleEnabled:(BOOL)gk_gestureHandleEnabled {
    objc_setAssociatedObject(self, GKGestureHandleEnabled, @(gk_gestureHandleEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gk_gestureHandleEnabled {
    return [objc_getAssociatedObject(self, GKGestureHandleEnabled) boolValue];
}

#pragma mark - 解决全屏滑动
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if (!self.gk_gestureHandleEnabled) return YES;
    
    if ([self panBack:gestureRecognizer]) return NO;
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if (!self.gk_gestureHandleEnabled) return NO;
    
    if ([self panBack:gestureRecognizer]) return YES;
    
    return NO;
}

- (BOOL)panBack:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        CGPoint point = [self.panGestureRecognizer translationInView:self];
        UIGestureRecognizerState state = gestureRecognizer.state;
        
        // 设置手势滑动的位置距屏幕左边的区域
        CGFloat locationDistance = [UIScreen mainScreen].bounds.size.width;
        
        if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStatePossible) {
            CGPoint location = [gestureRecognizer locationInView:self];
            if (point.x > 0 && location.x < locationDistance && self.contentOffset.x <= 0) {
                return YES;
            }
        }
    }
    return NO;
}

@end
