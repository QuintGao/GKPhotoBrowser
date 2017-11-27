//
//  UIScrollView+GKCategory.m
//  GKNavigationBarViewControllerDemo
//
//  Created by QuintGao on 2017/7/11.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "UIScrollView+GKCategory.h"
#import <objc/runtime.h>

static const void* GKGestureHandleDisabled = @"GKGestureHandleDisabled";

@implementation UIScrollView (GKCategory)

- (void)setGk_gestureHandleDisabled:(BOOL)gk_gestureHandleDisabled {
    objc_setAssociatedObject(self, GKGestureHandleDisabled, @(gk_gestureHandleDisabled), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)gk_gestureHandleDisabled {
    return [objc_getAssociatedObject(self, GKGestureHandleDisabled) boolValue];
}

#pragma mark - 解决全屏滑动时的手势冲突
// 当UIScrollView在水平方向滑动到第一个时，默认是不能全屏滑动返回的，通过下面的方法可实现其滑动返回。
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if (self.gk_gestureHandleDisabled) {
        return YES;
    }
    
    if ([self panBack:gestureRecognizer]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (self.gk_gestureHandleDisabled) {
        return NO;
    }
    
    if ([self panBack:gestureRecognizer]) {
        return YES;
    }
    
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
                NSLog(@"point====%@", NSStringFromCGPoint(point));
                
                NSLog(@"location====%@", NSStringFromCGPoint(location));
                
                return YES;
            }
        }
    }
    return NO;
}

@end
