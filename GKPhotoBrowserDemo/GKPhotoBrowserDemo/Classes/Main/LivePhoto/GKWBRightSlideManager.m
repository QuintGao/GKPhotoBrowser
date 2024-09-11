//
//  GKWBRightSlideManager.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2024/9/11.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import "GKWBRightSlideManager.h"
#import <GKPhotoBrowser/GKPhotoBrowser.h>
#import "GKWBPlayerManager.h"

@interface GKWBRightSlideManager()<UIGestureRecognizerDelegate>

// 添加手势的控制器
@property (nonatomic, weak) UIViewController *presentVC;

// 中心点
@property (nonatomic, assign) CGPoint viewCenter;

// 是否开始滑动
@property (nonatomic, assign) BOOL interacting;

// 左右滑动的UIScrollView
@property (nonatomic, weak) UIScrollView *scrollView;

@end

@implementation GKWBRightSlideManager

- (void)setBrowser:(GKPhotoBrowser *)browser {
    _browser = browser;
    
    // 查找需要添加手势的控制器
    UIViewController *presentVC = browser;
    if (browser.configure.showStyle != GKPhotoBrowserShowStylePush && browser.navigationController) {
        presentVC = browser.navigationController;
        presentVC.view.clipsToBounds = NO;
    }
    self.presentVC = presentVC;
    
    // 添加手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    [presentVC.view addGestureRecognizer:pan];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveEvent:(UIEvent *)event {
    
    // 获取scrollView
    if (!self.scrollView) {
        self.scrollView = self.browser.photoScrollView;
    }
    
    // 当前显示的不是第一个，不做处理
    if (self.scrollView && self.scrollView.contentOffset.x != 0) {
        return NO;
    }
    
    // 第一个不是视频不做处理
    GKPhoto *photo = self.browser.photos.firstObject;
    if (photo && !photo.isVideo) {
        return NO;
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] ||
        [otherGestureRecognizer isKindOfClass:UIPanGestureRecognizer.class]) {
        if (otherGestureRecognizer.view == self.scrollView) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - HandlePan
- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:pan.view.superview];
    if (!_interacting && (translation.x < 0 || translation.y < 0 || translation.x < translation.y)) {
        return;
    }
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            [self handlePanBegan:pan];
            break;
        case UIGestureRecognizerStateChanged:
            [self handlePanChange:pan];
            return;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            [self handlePanEnded:pan];
            return;
        default:
            break;
    }
}

- (void)handlePanBegan:(UIPanGestureRecognizer *)pan {
    // 修复当从右侧向左侧滑动时的bug，避免开始的时候从右向左滑动
    CGPoint vel = [pan velocityInView:pan.view];
    if (!_interacting && vel.x < 0) {
        _interacting = NO;
        return;
    }
    self.interacting = YES;
    self.viewCenter = self.presentVC.view.center;
    self.scrollView.panGestureRecognizer.enabled = NO;
}

- (void)handlePanChange:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:pan.view.superview];
    CGFloat progress = [self progressForPanGesture:pan];
    CGFloat ratio = 1 - progress * 0.5;
    self.presentVC.view.center = CGPointMake(self.viewCenter.x + translation.x * ratio, self.viewCenter.y + translation.y * ratio);
    self.presentVC.view.transform = CGAffineTransformMakeScale(ratio, ratio);
}

- (void)handlePanEnded:(UIPanGestureRecognizer *)pan {
    CGFloat progress = [self progressForPanGesture:pan];
    if (progress < 0.2) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.presentVC.view.center = self.viewCenter;
            self.presentVC.view.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.interacting = NO;
        }];
    }else {
        self.interacting = NO;
        
        [self.manager willDismiss];
        [self.browser dismiss];
    }
    self.scrollView.panGestureRecognizer.enabled = YES;
}

- (CGFloat)progressForPanGesture:(UIPanGestureRecognizer *)pan {
    UIView *superview = pan.view.superview;
    CGPoint translation = [pan translationInView:superview];
    CGFloat progress = translation.x / superview.bounds.size.width;
    progress = fminf(fmaxf(progress, 0.0), 1.0);
    return progress;
}

@end
