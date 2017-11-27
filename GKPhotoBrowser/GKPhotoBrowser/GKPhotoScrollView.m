//
//  GKPhotoScrollView.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/7.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKPhotoScrollView.h"

@interface GKPhotoScrollView()<UIGestureRecognizerDelegate>

@end

@implementation GKPhotoScrollView

//- (BOOL)isScrollToTopOrBottom {
//    if (self.zoomScale > 1.0) {
//        return YES;
//    }
//    CGPoint translation = [self.panGestureRecognizer translationInView:self];
//    if (translation.y > 0 && self.contentOffset.y <= 0) {
//        return YES;
//    }
//    CGFloat maxOffsetY = floor(self.contentSize.height - self.bounds.size.height);
//    if (translation.y < 0 && self.contentOffset.y >= maxOffsetY) {
//        return YES;
//    }
//    return NO;
//}
//
//#pragma mark - UIGestureRecognizerDelegate
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    if (gestureRecognizer == self.panGestureRecognizer) {
//        if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
//            if ([self isScrollToTopOrBottom]) {
//                return NO;
//            }
//        }
//    }
//    return YES;
//}

@end
