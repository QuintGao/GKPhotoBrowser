//
//  GKPhotoRotationHandler.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2023/3/2.
//

#import "GKPhotoRotationHandler.h"
#import "GKPhotoBrowser.h"

@interface GKPhotoRotationHandler()

// 在浏览器显示前是否已经添加过屏幕旋转监测
@property (nonatomic, assign) BOOL isGeneratingDeviceOrientation;

// 是否添加过屏幕方向改变通知
@property (nonatomic, assign) BOOL isOrientationNotificationAdded;

@end

@implementation GKPhotoRotationHandler

- (instancetype)init {
    if (self = [super init]) {
        self.isGeneratingDeviceOrientation = [UIDevice currentDevice].isGeneratingDeviceOrientationNotifications;
    }
    return self;
}

- (void)addDeviceOrientationObserver {
    if (self.browser.isFollowSystemRotation) return;
    // 默认设备方向：竖屏
    self.originalOrientation = UIDeviceOrientationPortrait;
    self.currentOrientation = UIDeviceOrientationPortrait;
    
    if (!self.isOrientationNotificationAdded) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
        self.isOrientationNotificationAdded = YES;
    }
    
    if (self.isGeneratingDeviceOrientation) return;
    
    if (![UIDevice currentDevice].isGeneratingDeviceOrientationNotifications) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
}

- (void)delDeviceOrientationObserver {
    if (self.browser.isFollowSystemRotation) return;
    
    if (self.isOrientationNotificationAdded) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
        self.isOrientationNotificationAdded = NO;
    }
    
    if (self.isGeneratingDeviceOrientation) return;
    
    if ([UIDevice currentDevice].isGeneratingDeviceOrientationNotifications) {
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    }
}

- (void)deviceOrientationDidChange {
    if (self.browser.isFollowSystemRotation) return;
    if (self.browser.isScreenRotateDisabled) return;
    
    // 旋转之后当前的设备方向
    UIDeviceOrientation currentOrientation = [UIDevice currentDevice].orientation;
    
    if (currentOrientation == UIDeviceOrientationUnknown || currentOrientation == UIDeviceOrientationFaceUp) {
        if (self.originalOrientation == UIDeviceOrientationUnknown) {
            currentOrientation = UIDeviceOrientationPortrait;
        }else {
            currentOrientation = self.originalOrientation;
        }
    }
    
    // 修复bug #117，从后台进入前台会执行此方法 导致缩放变化，所以此处做下处理
    if (self.currentOrientation == currentOrientation) return;
    
    self.currentOrientation = currentOrientation;
    
    self.isRotation = YES;
    
    GKPhotoView *photoView = self.browser.curPhotoView;
    if (!photoView) return;
    
    // 恢复当前视图的缩放
    GKPhoto *photo = photoView.photo;
    photo.isZooming = NO;
    photo.zoomRect = CGRectZero;
    
    if (UIDeviceOrientationIsPortrait(self.originalOrientation)) {
        if (UIDeviceOrientationIsLandscape(currentOrientation)) {
            [photoView.scrollView setZoomScale:1.0 animated:YES];
        }
    }
    
    if (UIDeviceOrientationIsLandscape(self.originalOrientation)) {
        if (UIDeviceOrientationIsPortrait(currentOrientation)) {
            [photoView.scrollView setZoomScale:1.0 animated:YES];
        }
    }
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    // 旋转之后是横屏
    if (UIDeviceOrientationIsLandscape(currentOrientation)) {
        self.isLandscape = YES;
        [self deviceOrientationChangedDelegate];
        
        // 横屏移除pan手势
        if ([self.delegate respondsToSelector:@selector(willRotation:)]) {
            [self.delegate willRotation:YES];
        }
        
        NSTimeInterval duration = UIDeviceOrientationIsLandscape(self.originalOrientation) ? 2 * self.browser.animDuration : self.browser.animDuration;
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            // 旋转状态栏
            if (@available(iOS 13.0, *)) {} else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)currentOrientation animated:YES];
#pragma clang diagnostic pop
            }
            
            float rotation = currentOrientation == UIDeviceOrientationLandscapeRight ? 1.5 : 0.5;
            
            // 旋转contentView
            self.browser.contentView.transform = CGAffineTransformMakeRotation(M_PI * rotation);
            
            CGFloat width = MAX(screenBounds.size.width, screenBounds.size.height);
            // 设置frame
            self.browser.contentView.bounds = CGRectMake(0, 0, width, MIN(screenBounds.size.width, screenBounds.size.height));
            self.browser.contentView.center = self.browser.view.center;
            
            [self.browser.view setNeedsLayout];
            [self.browser.view layoutIfNeeded];
            [self.browser layoutSubviews];
        } completion:^(BOOL finished) {
            // 记录设备方向
            self.originalOrientation = currentOrientation;
            self.isRotation = NO;
            
            if ([self.delegate respondsToSelector:@selector(didRotation:)]) {
                [self.delegate didRotation:YES];
            }
        }];
    }else if (currentOrientation == UIDeviceOrientationPortrait) {
        self.isLandscape = NO;
        [self deviceOrientationChangedDelegate];
        
        // 竖屏时添加pan手势
        if ([self.delegate respondsToSelector:@selector(willRotation:)]) {
            [self.delegate willRotation:NO];
        }
        
        NSTimeInterval duration = self.browser.animDuration;
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            // 旋转状态栏
            if (@available(iOS 13.0, *)) {} else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)currentOrientation animated:YES];
#pragma clang diagnostic pop
            }
            
            // 旋转view
            self.browser.contentView.transform = currentOrientation == UIDeviceOrientationPortrait ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(M_PI);
            
            CGFloat height = MAX(screenBounds.size.width, screenBounds.size.height);
            // 设置frame
            self.browser.contentView.bounds = CGRectMake(0, 0, MIN(screenBounds.size.width, screenBounds.size.height), height);
            self.browser.contentView.center = self.browser.view.center;
            
            [self.browser.view setNeedsLayout];
            [self.browser.view layoutIfNeeded];
            [self.browser layoutSubviews];
            
        } completion:^(BOOL finished) {
            // 记录设备方向
            self.originalOrientation = currentOrientation;
            self.isRotation = NO;
            
            if ([self.delegate respondsToSelector:@selector(didRotation:)]) {
                [self.delegate didRotation:NO];
            }
        }];
    }else {
        self.isRotation     = NO;
        self.isLandscape    = NO;
        [self.browser.view setNeedsLayout];
        [self.browser.view layoutIfNeeded];
        [self.browser layoutSubviews];
        
        [self deviceOrientationChangedDelegate];
    }
}

- (void)handleSystemRotation {
    if (!self.browser.isFollowSystemRotation) return;
    
    self.isRotation = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            CGFloat width = self.browser.view.bounds.size.width;
            CGFloat height = self.browser.view.bounds.size.height;
            
            self.browser.contentView.bounds = CGRectMake(0, 0, width, height);
            self.browser.contentView.center = self.browser.view.center;
            
            [self.browser.view setNeedsLayout];
            [self.browser.view layoutIfNeeded];
            [self.browser layoutSubviews];
        } completion:^(BOOL finished) {
            self.isRotation = NO;
        }];
    });
}

- (void)deviceOrientationChangedDelegate {
    if ([self.browser.delegate respondsToSelector:@selector(photoBrowser:onDeciceChangedWithIndex:isLandscape:)]) {
        [self.browser.delegate photoBrowser:self.browser onDeciceChangedWithIndex:self.browser.currentIndex isLandscape:self.isLandscape];
    }
}

@end
