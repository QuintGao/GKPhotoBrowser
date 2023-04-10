//
//  GKPhotoGestureHandler.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2023/3/2.
//

#import "GKPhotoGestureHandler.h"
#import "GKPhotoBrowser.h"

int const static kDirectionPanThreshold = 5;

@interface GKPanGestureRecognizer()

@property (nonatomic, assign) BOOL isDrag;

@property (nonatomic, assign) int   moveX;

@property (nonatomic, assign) int   moveY;

@end

@implementation GKPanGestureRecognizer

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint nowPoint = [[touches anyObject] locationInView:self.view];
    CGPoint prevPoint = [[touches anyObject] previousLocationInView:self.view];
    _moveX += prevPoint.x - nowPoint.x;
    _moveY += prevPoint.y - nowPoint.y;
    if (!self.isDrag) {
        if (abs(_moveX) > kDirectionPanThreshold) {
            if (_direction == GKPanGestureRecognizerDirectionVertical) {
                self.state = UIGestureRecognizerStateFailed;
            }else {
                _isDrag = YES;
            }
        }else if (abs(_moveY) > kDirectionPanThreshold) {
            if (_direction == GKPanGestureRecognizerDirectionHorizontal) {
                self.state = UIGestureRecognizerStateFailed;
            }else {
                _isDrag = YES;
            }
        }
    }
}

- (void)reset {
    [super reset];
    _isDrag = NO;
    _moveX = 0;
    _moveY = 0;
}

@end

@interface GKPhotoGestureHandler()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGPoint photoViewCenter;

@end

@implementation GKPhotoGestureHandler

- (instancetype)init {
    if (self = [super init]) {
        [self initGesture];
    }
    return self;
}

- (void)initGesture {
    // 单击手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delaysTouchesEnded = NO;
    singleTap.delegate = self;
    self.singleTapGesture = singleTap;
    
    // 双击手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.delaysTouchesEnded = NO;
    doubleTap.delegate = self;
    self.doubleTapGesture = doubleTap;
    
    // 长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    self.longPressGesture = longPress;
    
    // 拖拽手势
    GKPanGestureRecognizer *panGesture = [[GKPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.direction = GKPanGestureRecognizerDirectionVertical;
    self.panGesture = panGesture;
}

#pragma mark - Public Methods
- (void)addGestureRecognizer {
    // 单击手势
    [self.browser.photoScrollView addGestureRecognizer:self.singleTapGesture];
    
    // 双击手势
    if (!self.browser.isDoubleTapDisabled) {
        [self.singleTapGesture requireGestureRecognizerToFail:self.doubleTapGesture];
        [self.browser.photoScrollView addGestureRecognizer:self.doubleTapGesture];
    }
    
    // 长按手势
    [self.browser.photoScrollView addGestureRecognizer:self.longPressGesture];
    
    // 拖拽手势
    [self addPanGesture:YES];
}

- (void)addPanGesture:(BOOL)isFirst {
    if (isFirst || self.browser.isScreenRotateDisabled) { // 第一次进入或禁止处理屏幕旋转，直接添加手势
        [self addPanGesture];
    }else {
        if (self.browser.currentOrientation == UIDeviceOrientationPortrait) { // 竖屏
            [self addPanGesture];
        }
    }
}

- (void)addPanGesture {
    if (![self.browser.photoScrollView.gestureRecognizers containsObject:self.panGesture]) {
        [self.browser.photoScrollView addGestureRecognizer:self.panGesture];
    }
}

- (void)removePanGesture {
    if ([self.browser.photoScrollView.gestureRecognizers containsObject:self.panGesture]) {
        [self.browser.photoScrollView removeGestureRecognizer:self.panGesture];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:UIButton.class]) {
        return NO;
    }
    return YES;
}

#pragma mark - Gesture Handle
- (void)handleSingleTap:(UITapGestureRecognizer *)tapGesture {
    if ([self.browser.delegate respondsToSelector:@selector(photoBrowser:singleTapWithIndex:)]) {
        [self.browser.delegate photoBrowser:self.browser singleTapWithIndex:self.browser.currentIndex];
    }
    
    // 禁言默认单击事件
    if (self.browser.isSingleTapDisabled) return;
    [self browserDismiss];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tapGesture {
    GKPhotoView *photoView = self.browser.curPhotoView;
    if (!photoView) return;
    GKPhoto *photo = photoView.photo;
    if (!photo.finished) return;
    
    // 设置双击放大倍数
    [photoView setScrollMaxZoomScale:self.browser.doubleZoomScale];
    
    if (photoView.scrollView.zoomScale > 1.0) {
        [photoView.scrollView setZoomScale:1.0 animated:YES];
        photo.isZooming = NO;
        
        // 默认情况下有滑动手势
        [self addPanGesture:YES];
    }else {
        CGPoint location = [tapGesture locationInView:photoView.imageView];
        CGFloat wh       = 1.0;
        CGRect zoomRect  = [self frameWithWidth:wh height:wh center:location];
        [photoView zoomToRect:zoomRect animated:YES];
        
        photo.zoomScale = self.browser.doubleZoomScale;
        photo.isZooming = YES;
        photo.zoomRect  = zoomRect;
        
        // 放大情况下移除滑动手势
        [self removePanGesture];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGesture {
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        if ([self.browser.delegate respondsToSelector:@selector(photoBrowser:longPressWithIndex:)]) {
            [self.browser.delegate photoBrowser:self.browser longPressWithIndex:self.browser.currentIndex];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    // 放大时候禁止滑动返回
    GKPhotoView *photoView = self.browser.curPhotoView;
    if (!photoView) return;
    if (photoView.scrollView.zoomScale > 1.0f) return;
    
    switch (self.browser.hideStyle) {
        case GKPhotoBrowserHideStyleZoomScale:
            [self handlePanZoomScale:panGesture];
            break;
        case GKPhotoBrowserHideStyleZoomSlide:
            [self handlePanZoomSlide:panGesture];
            break;
            
        default:
            break;
    }
}

#pragma mark - Private Methods
- (CGRect)frameWithWidth:(CGFloat)width height:(CGFloat)height center:(CGPoint)center {
    CGFloat x = center.x - width * 0.5;
    CGFloat y = center.y - height * 0.5;
    return CGRectMake(x, y, width, height);
}

- (void)handlePanZoomScale:(UIPanGestureRecognizer *)panGesture {
    GKPhotoView *photoView = self.browser.curPhotoView;
    if (!photoView) return;
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            photoView.loadingView.hidden = YES;
            [self handlePanBegin];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat scale = [self panGestureScale:panGesture];
            CGPoint translation = [panGesture translationInView:panGesture.view];
            CGFloat imageViewScale = 1 - scale * 0.5;
            if (imageViewScale < 0.4) imageViewScale = 0.4;
            photoView.center = CGPointMake(self.photoViewCenter.x + translation.x, self.photoViewCenter.y + translation.y);
            photoView.transform = CGAffineTransformMakeScale(imageViewScale, imageViewScale);
            [self browserChangeAlpha:(1 - scale * scale)];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:{
            
            CGFloat scale = [self panGestureScale:panGesture];
            
            if (scale < 0.2) {
                [self browserCancelDismiss];
            }else {
                if ([self.delegate respondsToSelector:@selector(browserDidDisappear)]) {
                    [self.delegate browserDidDisappear];
                }
                [self browserZoomDismiss];
            }
        }
            break;
        default:
            break;
    }
}

- (CGFloat)panGestureScale:(UIPanGestureRecognizer *)panGesture {
    CGFloat scale = 0;
    CGPoint translation = [panGesture translationInView:panGesture.view];
    scale = translation.y / ((panGesture.view.frame.size.height - 50) / 2);
    if (scale > 1.0f) scale = 1.0f;
    if (scale < 0.0f) scale = 0.0f;
    return scale;
}

- (void)handlePanZoomSlide:(UIPanGestureRecognizer *)panGesture {
    GKPhotoView *photoView = self.browser.curPhotoView;
    if (!photoView) return;
    
    CGPoint point    = [panGesture translationInView:panGesture.view];
    CGPoint velocity = [panGesture velocityInView:panGesture.view];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            photoView.loadingView.hidden = YES;
            [self handlePanBegin];
        }
            break;
        case UIGestureRecognizerStateChanged:{
            photoView.transform = CGAffineTransformMakeTranslation(0, point.y);
            double percent = 1 - fabs(point.y) / panGesture.view.frame.size.height * 0.5;
            [self browserChangeAlpha:percent];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (fabs(point.y) > 200 || fabs(velocity.y) > 500) {
                if ([self.delegate respondsToSelector:@selector(browserDidDisappear)]) {
                    [self.delegate browserDidDisappear];
                }
                [self browserSlideDismiss:point];
            }else {
                [self browserCancelDismiss];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)handlePanBegin {
    GKPhotoView *photoView = self.browser.curPhotoView;
    if (!photoView) return;
    photoView.imageView.clipsToBounds = YES;
    
    GKPhoto *photo = photoView.photo;
    if (self.browser.isHideSourceView) {
        photo.sourceImageView.alpha = 0;
    }
    
    if ([self.delegate respondsToSelector:@selector(browserWillDisappear)]) {
        [self.delegate browserWillDisappear];
    }
    self.photoViewCenter = photoView.center;
    
    self.isStatusBarShowing = self.browser.isStatusBarShow;
    
    // 显示状态栏
    self.browser.isStatusBarShow = YES;
    
    if ([self.browser.delegate respondsToSelector:@selector(photoBrowser:panBeginWithIndex:)]) {
        [self.browser.delegate photoBrowser:self.browser panBeginWithIndex:self.browser.currentIndex];
    }
}

- (void)browserCancelDismiss {
    GKPhotoView *photoView = self.browser.curPhotoView;
    if (!photoView) return;
    
    GKPhoto *photo = photoView.photo;
    photo.sourceImageView.alpha = 1.0;
    
    [UIView animateWithDuration:self.browser.animDuration animations:^{
        if (self.browser.hideStyle == GKPhotoBrowserHideStyleZoomScale) {
            photoView.center = self.photoViewCenter;
        }
        photoView.transform = CGAffineTransformIdentity;
        [self browserChangeAlpha:1];
    }completion:^(BOOL finished) {
        photoView.loadingView.hidden = NO;
        photoView.imageView.clipsToBounds = NO;
        if ([self.delegate respondsToSelector:@selector(browserCancelDisappear)]) {
            [self.delegate browserCancelDisappear];
        }

        if (!self.isStatusBarShowing) {
            // 隐藏状态栏
            self.browser.isStatusBarShow = NO;
        }
        if ([self.browser.delegate respondsToSelector:@selector(photoBrowser:panEndedWithIndex:willDisappear:)]) {
            [self.browser.delegate photoBrowser:self.browser panEndedWithIndex:self.browser.currentIndex willDisappear:NO];
        }
    }];
}

@end
