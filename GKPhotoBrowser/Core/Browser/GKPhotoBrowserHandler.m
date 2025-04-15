//
//  GKPhotoBrowserHandler.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2023/3/2.
//

#import "GKPhotoBrowserHandler.h"
#import "GKPhotoBrowser.h"
#import "GKPhotoBrowserConfigure.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface GKPhotoBrowserHandler()

@property (nonatomic, assign) BOOL hasPlayBtn;
@property (nonatomic, assign) BOOL hasLiveMarkView;

@end

@implementation GKPhotoBrowserHandler

- (instancetype)init {
    if (self = [super init]) {
        [self initValue];
    }
    return self;
}

- (void)initValue {
    // 原始状态栏样式
    self.originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    
    // 状态栏外观处理
    NSDictionary *infoDict = [NSBundle mainBundle].infoDictionary;
    BOOL hasKey = [infoDict.allKeys containsObject:@"UIViewControllerBasedStatusBarAppearance"];
    BOOL appearance = [[infoDict objectForKey:@"UIViewControllerBasedStatusBarAppearance"] boolValue];
    self.statusBarAppearance = (hasKey && appearance) || !hasKey;
}

- (void)setBrowser:(GKPhotoBrowser *)browser {
    _browser = browser;
    self.configure = browser.configure;
}

- (void)showFromVC:(UIViewController *)vc {
    self.configure.fromVC = vc;
    if (self.configure.isPush) {
        self.browser.hidesBottomBarWhenPushed = YES;
        if (self.configure.showStyle == GKPhotoBrowserShowStylePushZoom) {
            [vc.navigationController pushViewController:self.browser animated:NO];
        }else {
            [vc.navigationController pushViewController:self.browser animated:YES];
        }
    }else {
        UIViewController *presentVC = self.browser;
        if (self.configure.isNeedNavigationController) {
            presentVC = [[UINavigationController alloc] initWithRootViewController:self.browser];
        }
        
        presentVC.modalPresentationCapturesStatusBarAppearance = YES;
        presentVC.modalPresentationStyle = UIModalPresentationCustom;
        presentVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [vc presentViewController:presentVC animated:NO completion:nil];
    }
}

#pragma mark - BrowserShow
- (void)browserShow {
    switch (self.configure.showStyle) {
        case GKPhotoBrowserShowStyleNone:
            [self browserNoneShow];
            break;
        case GKPhotoBrowserShowStylePush:
            [self browserPushShow];
            break;
        case GKPhotoBrowserShowStyleZoom:{
            [self browserZoomShow];
        }
            break;
        case GKPhotoBrowserShowStylePushZoom:{
            [self browserPushZoomShow];
        }
            break;
        default:
            break;
    }
}

- (void)browserNoneShow {
    self.browser.view.alpha = 0;
    [self browserChangeAlpha:1];
    [UIView animateWithDuration:self.configure.animDuration animations:^{
        self.browser.view.alpha = 1.0;
    }completion:^(BOOL finished) {
        self.isShow = YES;
        [self.browser browserFirstAppear];
    }];
}

- (void)browserPushShow {
    [self browserChangeAlpha:1];
    self.isShow = YES;
    [self.browser browserFirstAppear];
}

- (void)browserPushZoomShow {
    [self browserZoomShow];
}

- (void)browserZoomShow {
    GKPhotoView *photoView = self.browser.curPhotoView;
    GKPhoto *photo = self.browser.curPhoto;
    
    CGRect endRect = CGRectZero;
    if (photoView.imageView.image) {
        endRect = photoView.imageView.frame;
    }else {
        if (CGRectEqualToRect(photo.sourceFrame, CGRectZero)) {
            endRect = photoView.imageView.frame;
        }else {
            CGFloat viewW = self.browser.view.bounds.size.width;
            CGFloat viewH = self.browser.view.bounds.size.height;
            
            CGFloat w = viewW;
            // bug fixed：#43 CALayer position contains NaN: [nan nan]
            CGFloat h = (photo.sourceFrame.size.width == 0) ? viewH : (w * photo.sourceFrame.size.height / photo.sourceFrame.size.width);
            CGFloat x = 0;
            CGFloat y = (viewH - h) / 2;
            endRect = CGRectMake(x, y, w, h);
        }
    }
    
    CGRect sourceRect = photo.sourceFrame;
    
    if (CGRectEqualToRect(sourceRect, CGRectZero)) {
        if (photo.sourceImageView) {
            sourceRect = [photo.sourceImageView.superview convertRect:photo.sourceImageView.frame toView:photoView];
        }else {
            CGFloat width = self.browser.view.frame.size.width;
            CGFloat height = self.browser.view.frame.size.height;
            sourceRect = CGRectMake((width - 1)/2, (height - 1)/2, 1, 1);
        }
    }
    if (self.configure.isAdaptiveSafeArea) {
        sourceRect.origin.y -= (kSafeTopSpace + kSafeBottomSpace) * 0.5;
    }
    
    photoView.imageView.frame = sourceRect;
    photoView.imageView.clipsToBounds = YES;
    [photoView updateFrame];
    [self browserChangeAlpha:0];
    if (photo.isVideo && photoView.playBtn.hidden == NO) {
        photoView.playBtn.hidden = YES;
        self.hasPlayBtn = YES;
    }
    if (photo.isLivePhoto && photoView.liveMarkView.hidden == NO) {
        photoView.liveMarkView.hidden = YES;
        self.hasLiveMarkView = YES;
    }
    
    [UIView animateWithDuration:self.configure.animDuration animations:^{
        photoView.imageView.frame = endRect;
        [photoView updateFrame];
        [self browserChangeAlpha:1];
    }completion:^(BOOL finished) {
        photoView.imageView.clipsToBounds = NO;
        self.isShow = YES;
        if (self.hasPlayBtn) {
            photoView.playBtn.hidden = NO;
        }
        if (self.hasLiveMarkView) {
            photoView.liveMarkView.hidden = NO;
        }
        [self.browser browserFirstAppear];
    }];
}

#pragma mark - BrowserDismiss
- (void)browserDismiss {
    if (!self.configure.isFollowSystemRotation) {
        // 状态栏恢复到竖屏
        if (@available(iOS 13.0, *)) {} else {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
        }
    }
    
    GKPhotoView *photoView = self.browser.curPhotoView;
    if (photoView) {
        if (photoView.photo.isLivePhoto) {
            photoView.liveMarkView.hidden = YES;
        }
        if (photoView.photo.isVideo) {
            photoView.playBtn.hidden = YES;
            if (self.browser.progressView) {
                self.browser.progressView.hidden = YES;
            }
        }
    }
    
    if (self.configure.isPush) {
        [self.browser removeRotationObserver];
        self.browser.photoScrollView.clipsToBounds = YES;
        [self.browser.navigationController popViewControllerAnimated:YES];
    }else {
        // 显示状态栏
        [self.browser setStatusBarShow:YES];
        if (self.configure.hideStyle == GKPhotoBrowserHideStyleNone) {
            [self browserDismissNone];
        }else {
            // 防止返回时跳动
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self recoverAnimation];
            });
        }
    }
}

// 恢复动画，如果是横屏先恢复到竖屏再消失
- (void)recoverAnimation {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    if (!self.configure.isFollowSystemRotation && self.browser.supportedInterfaceOrientations == UIInterfaceOrientationMaskPortrait && UIDeviceOrientationIsLandscape(orientation)) {
        self.isRecover = YES;
        [UIView animateWithDuration:self.configure.animDuration animations:^{
            // 旋转view
            self.browser.contentView.transform = CGAffineTransformIdentity;
            
            CGFloat width = MIN(screenBounds.size.width, screenBounds.size.height);
            CGFloat height = MAX(screenBounds.size.width, screenBounds.size.height);
            // 设置frame
            self.browser.contentView.bounds = CGRectMake(0, 0, width, height);
            self.browser.contentView.center = self.browser.view.center;
            
            [self.browser.view setNeedsLayout];
            [self.browser.view layoutIfNeeded];
            [self.browser layoutSubviews];
        }completion:^(BOOL finished) {
            self.isRecover = NO;
            [self browserZoomDismiss];
        }];
    }else {
        [self browserZoomDismiss];
    }
}

- (void)browserZoomDismiss {
    GKPhotoView *photoView = self.browser.curPhotoView;
    if (!photoView) return;
    
    // 超出裁剪
    photoView.imageView.clipsToBounds = YES;
    photoView.scrollView.clipsToBounds = NO;
    photoView.clipsToBounds = NO;
    
    GKPhoto *photo = photoView.photo;
    
    // 判断是否可以恢复到原位置
    BOOL hasOrigin = YES;
    if (!photo.sourceImageView) {
        hasOrigin = NO;
    }else {
        // 判断是否超出屏幕
        CGRect screenBounds = UIScreen.mainScreen.bounds;
        CGRect originRect = photo.sourceFrame;
        if (CGRectEqualToRect(originRect, CGRectZero)) {
            originRect = [photo.sourceImageView.superview convertRect:photo.sourceImageView.frame toView:nil];
        }
        
        if (!CGRectIntersectsRect(screenBounds, originRect)) {
            hasOrigin = NO;
        }
    }
    if (!hasOrigin) {
        [self browserDismissNone];
        return;
    }
    
    // 隐藏原图
    if (self.configure.isHideSourceView && photo.sourceImageView) {
        photo.sourceImageView.alpha = 0;
    }
    
    CGRect sourceRect = photo.sourceFrame;
    if (CGRectEqualToRect(sourceRect, CGRectZero)) {
        sourceRect = [photo.sourceImageView.superview convertRect:photo.sourceImageView.frame toView:photoView];
    }
    
    if (self.configure.isAdaptiveSafeArea) {
        sourceRect.origin.y -= (kSafeTopSpace + kSafeBottomSpace) * 0.5;
    }
    
    // 修复放大时缩放的bug
    sourceRect.origin.x += photoView.scrollView.contentOffset.x;
    sourceRect.origin.y += photoView.scrollView.contentOffset.y;
    
    if (photo.sourceImageView.image) {
        photoView.imageView.image = photo.sourceImageView.image;
    }
    
    // Fix bug：解决长图点击隐藏时可能出现的闪动bug
    UIViewContentMode mode = photo.sourceImageView ? photo.sourceImageView.contentMode : UIViewContentModeScaleAspectFill;
    photoView.imageView.contentMode = mode;
    photoView.playBtn.hidden = YES;
    photoView.liveMarkView.hidden = YES;
    [UIView animateWithDuration:self.configure.animDuration animations:^{
        photoView.player.videoPlayView.alpha = 0;
        photoView.imageView.frame = sourceRect;
        [photoView updateFrame];
        [self browserChangeAlpha:0];
    }completion:^(BOOL finished) {
        [self dismissAnimated:NO];
    }];
}

- (void)browserSlideDismiss:(CGPoint)point {
    GKPhotoView *photoView = self.browser.curPhotoView;
    if (!photoView) return;
    
    BOOL throwToTop = point.y < 0;
    CGFloat toTranslationY = 0;
    if (throwToTop) {
        toTranslationY = - photoView.superview.frame.size.height;
    }else {
        toTranslationY = photoView.superview.frame.size.height;
    }
    
    photoView.playBtn.hidden = YES;
    photoView.liveMarkView.hidden = YES;
    [UIView animateWithDuration:self.configure.animDuration animations:^{
        photoView.imageView.transform = CGAffineTransformMakeTranslation(0, toTranslationY);
        [self browserChangeAlpha:0];
    }completion:^(BOOL finished) {
        [self dismissAnimated:self.configure.hideStyle == GKPhotoBrowserHideStyleZoomSlide];
    }];
}

- (void)browserDismissNone {
    GKPhotoView *photoView = self.browser.curPhotoView;
    if (!photoView) return;
    
    GKPhoto *photo = photoView.photo;
    if (self.configure.isHideSourceView && photo.sourceImageView) {
        photo.sourceImageView.alpha = 0;
    }
    
    photoView.playBtn.hidden = YES;
    photoView.liveMarkView.hidden = YES;
    [UIView animateWithDuration:self.configure.animDuration animations:^{
        photoView.imageView.alpha = 0;
        [self browserChangeAlpha:0];
    }completion:^(BOOL finished) {
        [self dismissAnimated:self.configure.hideStyle == GKPhotoBrowserHideStyleZoomSlide];
    }];
}

- (void)dismissAnimated:(BOOL)animated {
    GKPhoto *photo = self.browser.curPhotoView.photo;
    
    if (animated && !self.configure.isPush) {
        [UIView animateWithDuration:self.configure.animDuration animations:^{
            photo.sourceImageView.alpha = 1.0;
        }];
    }else {
        photo.sourceImageView.alpha = 1.0;
    }
    
    if (!self.configure.isFollowSystemRotation) {
        if (@available(iOS 13.0, *)) {} else {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
        }
    }
    
    // 移除屏幕旋转监听
    [self.browser removeRotationObserver];
    
    if (!self.statusBarAppearance) {
        [[UIApplication sharedApplication] setStatusBarStyle:self.originStatusBarStyle];
    }
    
    self.isDismiss = YES;
    
    if (self.configure.isPush) {
        [self.browser.navigationController popViewControllerAnimated:NO];
    }else {
        [self.browser dismissViewControllerAnimated:NO completion:nil];
    }
    
    if ([self.browser.delegate respondsToSelector:@selector(photoBrowser:panEndedWithIndex:willDisappear:)]) {
        [self.browser.delegate photoBrowser:self.browser panEndedWithIndex:self.browser.currentIndex willDisappear:YES];
    }
}

- (void)browserChangeAlpha:(CGFloat)alpha {
    if (alpha != 0 && alpha != 1) {
        if ([self.browser.delegate respondsToSelector:@selector(photoBrowser:panChangeWithIndex:progress:)]) {
            [self.browser.delegate photoBrowser:self.browser panChangeWithIndex:self.browser.currentIndex progress:alpha];
        }
    }
    
    UIColor *bgColor = self.configure.bgColor ?: UIColor.blackColor;
    
    UIView *view = self.browser.view;
    view.backgroundColor = [bgColor colorWithAlphaComponent:alpha];
    for (UIView *subview in self.browser.coverViews) {
        subview.alpha = alpha;
    }
}

@end

#pragma clang diagnostic pop
