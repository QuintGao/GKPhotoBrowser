//
//  GKPhotoSwipeRightTransition.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2024/9/11.
//

#import "GKPhotoSwipeRightTransition.h"
#import <GKPhotoBrowser/GKPhotoBrowser.h>
#import "GKWBPlayerManager.h"

@interface GKPhotoSwipeRightTransition()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL interacting;

@property (nonatomic, weak) UIViewController *presentVC;

@property (nonatomic, assign) CGPoint viewCenter;

@property (nonatomic, weak) UIScrollView *scrollView;

@end

@implementation GKPhotoSwipeRightTransition

- (void)setBrowser:(GKPhotoBrowser *)browser {
    _browser = browser;
    
    UIViewController *presentVC = browser;
    if (browser.configure.showStyle != GKPhotoBrowserShowStylePush && browser.navigationController) {
        presentVC = browser.navigationController;
    }
    [self connectToViewController:presentVC];
}

- (void)connectToViewController:(UIViewController *)viewController {
    viewController.transitioningDelegate = self;
    self.presentVC = viewController;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    [viewController.view addGestureRecognizer:pan];
}

- (CGFloat)completionSpeed {
    return 1 - self.percentComplete;
}

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
            [self cancelInteractiveTransition];
        }];
    }else {
        self.interacting = NO;
        [self finishInteractiveTransition];
        
        GKWBPlayerManager *mgr = (GKWBPlayerManager *)self.browser.configure.player;
        [mgr willDismiss];
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

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.interacting ? self : nil;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (!self.scrollView) {
        self.scrollView = self.browser.photoScrollView;
    }
    
    GKPhoto *photo = self.browser.photos.firstObject;
    if (!photo.isVideo) return NO;
    
    if (self.scrollView && self.scrollView.contentOffset.x == 0) return YES;
    
    return NO;
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

@end
