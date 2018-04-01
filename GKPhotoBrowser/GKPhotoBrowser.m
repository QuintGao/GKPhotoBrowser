//
//  GKPhotoBrowser.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/20.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKPhotoBrowser.h"
#import "GKWebImageManager.h"

// 判断iPhone X
#define KIsiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)


static Class imageManagerClass = nil;

@interface GKPhotoBrowser()<UIScrollViewDelegate>
{
    UILabel  *_countLabel;
    CGPoint  _startLocation;
    BOOL     _isStatusBarShowing;
}

@property (nonatomic, strong, readwrite) UIView *contentView;

@property (nonatomic, strong, readwrite) NSArray *photos;
@property (nonatomic, assign, readwrite) NSInteger currentIndex;

@property (nonatomic, strong) UIScrollView *photoScrollView;

@property (nonatomic, strong) NSMutableArray *visiblePhotoViews;
@property (nonatomic, strong) NSMutableSet *reusablePhotoViews;

@property (nonatomic, strong) UIViewController *fromVC;

@property (nonatomic, assign) BOOL isShow;

@property (nonatomic, strong) NSArray *coverViews;
@property (nonatomic, copy) layoutBlock layoutBlock;

/** 记录上一次的设备方向 */
@property (nonatomic, assign) UIDeviceOrientation originalOrientation;

/** 正在发生屏幕旋转 */
@property (nonatomic, assign) BOOL isRotation;

/** 状态栏正在发生变化 */
@property (nonatomic, assign) BOOL isStatusBarChanged;

@property (nonatomic, assign) BOOL isPortraitToUp;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong) id<GKWebImageProtocol> imageProtocol;

@end

@implementation GKPhotoBrowser

#pragma mark - 懒加载
- (UIScrollView *)photoScrollView {
    if (!_photoScrollView) {
        CGRect frame = self.view.bounds;
        frame.origin.x   -= kPhotoViewPadding;
        frame.size.width += (2 * kPhotoViewPadding);
        _photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
        _photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _photoScrollView.pagingEnabled  = YES;
        _photoScrollView.delegate       = self;
        _photoScrollView.showsVerticalScrollIndicator   = NO;
        _photoScrollView.showsHorizontalScrollIndicator = NO;
        _photoScrollView.backgroundColor                = [UIColor clearColor];
        if (self.showStyle == GKPhotoBrowserShowStylePush) {
            _photoScrollView.gk_gestureHandleDisabled = NO;
        }else {
            _photoScrollView.gk_gestureHandleDisabled = YES;
        }
        
        if (@available(iOS 11.0, *)) {
            _photoScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _photoScrollView;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    }
    return _panGesture;
}

- (GKPhoto *)currentPhoto {
    return self.photos[self.currentIndex];
}

- (GKPhotoView *)currentPhotoView {
    return [self photoViewForIndex:self.currentIndex];
}

+ (instancetype)photoBrowserWithPhotos:(NSArray<GKPhoto *> *)photos currentIndex:(NSInteger)currentIndex {
    return [[self alloc] initWithPhotos:photos currentIndex:currentIndex];
}

- (instancetype)initWithPhotos:(NSArray<GKPhoto *> *)photos currentIndex:(NSInteger)currentIndex {
    if (self = [super init]) {
        
        self.photos       = photos;
        self.currentIndex = currentIndex;
        
        self.isStatusBarShow  = NO;
        self.isHideSourceView = YES;
        
        _visiblePhotoViews  = [NSMutableArray new];
        _reusablePhotoViews = [NSMutableSet new];
        
        if (!imageManagerClass) {
            imageManagerClass = [GKWebImageManager class];
        }
        self.imageProtocol = [imageManagerClass new];
    }
    return self;
}

- (instancetype)init {
    NSAssert(NO, @"Use initWithPhotos:currentIndex: instead.");
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置UI
    [self setupUI];
    
    // 手势和监听
    [self addGestureAndObserver];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    GKPhoto *photo          = [self currentPhoto];
    GKPhotoView *photoView  = [self currentPhotoView];
    
    if ([_imageProtocol imageFromMemoryForURL:photo.url] || photo.image) {
        [photoView setupPhoto:photo];
    }else {
        photoView.imageView.image = photo.placeholderImage;
        [photoView adjustFrame];
    }
    
    switch (self.showStyle) {
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
            
        default:
            break;
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (!self.isStatusBarChanged) {
        [self layoutSubviews];
    }
}

- (void)setupUI {
    
    [self.navigationController setNavigationBarHidden:YES];
    
    self.view.backgroundColor   = [UIColor blackColor];
    
    self.contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.contentView];
    
    [self.contentView addSubview:self.photoScrollView];
    
    if (self.coverViews) {
        [self.coverViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.contentView addSubview:obj];
        }];
    }else {
        _countLabel = [UILabel new];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.font = [UIFont systemFontOfSize:18.0];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_countLabel];
        _countLabel.bounds = CGRectMake(0, 0, 80, 30);
        
        CGFloat systemVersion = [UIDevice currentDevice].systemVersion.floatValue;
        CGFloat centerY = systemVersion >= 11.0f ? 50 : 30;
        
        UIDeviceOrientation currentOrientation = [UIDevice currentDevice].orientation;
        if (UIDeviceOrientationIsLandscape(currentOrientation)) {
            centerY = 30;
        }
        
        _countLabel.center = CGPointMake(self.contentView.bounds.size.width * 0.5, centerY);
        
        [self updateLabel];
    }
    
    CGRect frame = self.photoScrollView.bounds;
    
    CGSize contentSize = CGSizeMake(frame.size.width * self.photos.count, frame.size.height);
    self.photoScrollView.contentSize = contentSize;
    
    CGPoint contentOffset = CGPointMake(frame.size.width * self.currentIndex, 0);
    [self.photoScrollView setContentOffset:contentOffset animated:NO];
    
    if (self.photoScrollView.contentOffset.x == 0) {
        [self scrollViewDidScroll:self.photoScrollView];
    }
}

- (void)addGestureAndObserver {
    [self addGestureRecognizer];
    
    [self addDeviceOrientationObserver];
}

#pragma mark - Setter
- (void)setShowStyle:(GKPhotoBrowserShowStyle)showStyle {
    _showStyle = showStyle;
    
    if (showStyle == GKPhotoBrowserShowStylePush) {
        //        self.photoScrollView.gk_gestureHandleDisabled = NO;
    }else {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle   = UIModalTransitionStyleCoverVertical;
    }
}

- (void)setIsStatusBarShow:(BOOL)isStatusBarShow {
    _isStatusBarShow = isStatusBarShow;
    
    self.isStatusBarChanged = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isStatusBarChanged = NO;
    });
    
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - BrowserShow
- (void)browserNoneShow {
    GKPhotoView *photoView = [self currentPhotoView];
    GKPhoto *photo = [self currentPhoto];
    
    self.view.alpha = 0;
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.view.alpha = 1.0;
    }completion:^(BOOL finished) {
        self.isShow = YES;
        
        [photoView setupPhoto:photo];
        
        [self deviceOrientationDidChange];
    }];
}

- (void)browserPushShow {
    self.view.backgroundColor = [UIColor blackColor];
    self.isShow = YES;
    
    [[self currentPhotoView] setupPhoto:[self currentPhoto]];
    
    [self deviceOrientationDidChange];
}

- (void)browserZoomShow {
    GKPhoto *photo          = [self currentPhoto];
    GKPhotoView *photoView  = [self currentPhotoView];
    
    CGRect endRect    = photoView.imageView.frame;
    CGRect sourceRect = photo.sourceFrame;
    
    if (CGRectEqualToRect(sourceRect, CGRectZero)) {
        float systemVersion = [UIDevice currentDevice].systemVersion.floatValue;
        if (systemVersion >= 8.0 && systemVersion < 9.0) {
            sourceRect = [photo.sourceImageView.superview convertRect:photo.sourceImageView.frame toCoordinateSpace:photoView];
        }else {
            sourceRect = [photo.sourceImageView.superview convertRect:photo.sourceImageView.frame toView:photoView];
        }
    }
    
    photoView.imageView.frame = sourceRect;
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        photoView.imageView.frame = endRect;
        self.view.backgroundColor = [UIColor blackColor];
    }completion:^(BOOL finished) {
        self.isShow = YES;
        [photoView setupPhoto:photo];
        
        [self deviceOrientationDidChange];
    }];
}

- (void)updateLabel {
    _countLabel.text = [NSString stringWithFormat:@"%zd/%zd", self.currentIndex + 1, self.photos.count];
}

- (void)layoutSubviews {
    CGRect frame = self.contentView.bounds;
    
    frame.origin.x   -= kPhotoViewPadding;
    frame.size.width += kPhotoViewPadding * 2;
    
    CGFloat photoScrollW = frame.size.width;
    CGFloat photoScrollH = frame.size.height;
    
    self.photoScrollView.frame  = frame;
    self.photoScrollView.center = CGPointMake(photoScrollW * 0.5 - kPhotoViewPadding, photoScrollH * 0.5);
    
    self.photoScrollView.contentOffset = CGPointMake(self.currentIndex * photoScrollW, 0);
    
    self.photoScrollView.contentSize = CGSizeMake(photoScrollW * self.photos.count, 0);
    
    // 调整所有显示的photoView的frame
    CGFloat w = photoScrollW - kPhotoViewPadding * 2;
    CGFloat h = photoScrollH;
    CGFloat x = 0;
    CGFloat y = 0;
    
    for (GKPhotoView *photoView in _visiblePhotoViews) {
        x = kPhotoViewPadding + photoView.tag * (kPhotoViewPadding * 2 + w);
        
        photoView.frame = CGRectMake(x, y, w, h);
        
        [photoView resetFrame];
    }
    
    if (self.coverViews) {
        !self.layoutBlock ? : self.layoutBlock(self, self.contentView.bounds);
    }else {
        _countLabel.bounds = CGRectMake(0, 0, 80, 30);

        CGFloat centerY = KIsiPhoneX ? 50 : 30;
        
        UIDeviceOrientation currentOrientation = [UIDevice currentDevice].orientation;
        if (UIDeviceOrientationIsLandscape(currentOrientation)) {
            centerY = 30;
        }

        _countLabel.center = CGPointMake(frame.size.width * 0.5, centerY);
    }
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:willLayoutSubViews:)]) {
        [self.delegate photoBrowser:self willLayoutSubViews:self.currentIndex];
    }
}

- (void)dealloc {
    NSLog(@"browser dealloc");
    
    [self delDeviceOrientationObserver];
}

#pragma mark - 屏幕旋转
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - 状态栏
- (BOOL)prefersStatusBarHidden {
    return !self.isStatusBarShow;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.fromVC.preferredStatusBarStyle;
}

#pragma mark - Public Methods
+ (void)setImageManagerClass:(Class<GKWebImageProtocol>)cls {
    imageManagerClass = cls;
}

- (void)setupCoverViews:(NSArray *)coverViews layoutBlock:(layoutBlock)layoutBlock {
    
    self.coverViews  = coverViews;
    
    self.layoutBlock = layoutBlock;
}

- (void)showFromVC:(UIViewController *)vc {
    
    self.fromVC = vc;
    
    if (self.showStyle == GKPhotoBrowserShowStylePush) {
        [vc.navigationController pushViewController:self animated:YES];
    }else {
        self.modalPresentationCapturesStatusBarAppearance = YES;
        [vc presentViewController:self animated:NO completion:nil];
    }
}

- (void)dismissAnimated:(BOOL)animated {
    GKPhoto *photo = self.photos[self.currentIndex];
    if (animated) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            photo.sourceImageView.alpha = 1.0;
        }];
    }else {
        photo.sourceImageView.alpha = 1.0;
    }
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Private Methods

- (void)addGestureRecognizer {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.view addGestureRecognizer:longPress];
    
    // 拖拽手势
    [self addPanGesture:YES];
}

- (void)addPanGesture:(BOOL)isFirst {
    if (self.showStyle == GKPhotoBrowserShowStylePush) {
        [self removePanGesture];
    }else {
        if (isFirst) {
            [self.view addGestureRecognizer:self.panGesture];
        }else {
            UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
            
            if (UIDeviceOrientationIsPortrait(orientation) || self.isPortraitToUp) {
                [self.view addGestureRecognizer:self.panGesture];
            }
        }
    }
}

- (void)removePanGesture {
    if ([self.view.gestureRecognizers containsObject:self.panGesture]) {
        [self.view removeGestureRecognizer:self.panGesture];
    }
}

#pragma mark - Gesture Handle
- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    
    GKPhotoView *photoView = [self currentPhotoView];
    photoView.isLayoutSubViews = YES;
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:singleTapWithIndex:)]) {
        [self.delegate photoBrowser:self singleTapWithIndex:self.currentIndex];
    }
    
    if (self.isSingleTapDisabled) return;
    
    // 状态栏恢复到竖屏
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    
    if (self.showStyle == GKPhotoBrowserShowStylePush) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        // 显示状态栏
        self.isStatusBarShow = YES;
        
        // 防止返回时跳动
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self recoverAnimation];
        });
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    GKPhotoView *photoView = [self photoViewForIndex:self.currentIndex];
    GKPhoto *photo = self.photos[self.currentIndex];
    
    if (!photo.finished) return;
    
    if (photoView.scrollView.zoomScale > 1.0) {
        [photoView.scrollView setZoomScale:1.0 animated:YES];
        photo.isZooming = NO;
        
        // 默认情况下有滑动手势
        [self addPanGesture:YES];
    }else {
        CGPoint location = [tap locationInView:self.contentView];
        CGFloat wh       = 1.0;
        CGRect zoomRect  = [self frameWithWidth:wh height:wh center:location];
        
        [photoView zoomToRect:zoomRect animated:YES];
        
        photo.isZooming = YES;
        photo.zoomRect  = zoomRect;
        
        // 放大情况下移除滑动手势
        [self removePanGesture];
    }
}

- (CGRect)frameWithWidth:(CGFloat)width height:(CGFloat)height center:(CGPoint)center {
    CGFloat x = center.x - width * 0.5;
    CGFloat y = center.y - height * 0.5;
    
    return CGRectMake(x, y, width, height);
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress {
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:{
            if ([self.delegate respondsToSelector:@selector(photoBrowser:longPressWithIndex:)]) {
                [self.delegate photoBrowser:self longPressWithIndex:self.currentIndex];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
            
            break;
            
        default:
            break;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    
    // 放大时候禁止滑动返回
    GKPhotoView *photoView = [self currentPhotoView];
    if (photoView.scrollView.zoomScale > 1.0f) {
        return;
    }
    
    switch (self.hideStyle) {
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

- (void)handlePanZoomScale:(UIPanGestureRecognizer *)panGesture {
    CGPoint point       = [panGesture translationInView:self.view];
    CGPoint location    = [panGesture locationInView:self.view];
    CGPoint velocity    = [panGesture velocityInView:self.view];
    
    GKPhotoView *photoView = [self photoViewForIndex:self.currentIndex];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            _startLocation = location;
            [self handlePanBegin];
            break;
        case UIGestureRecognizerStateChanged: {
            double percent = 1 - fabs(point.y) / self.contentView.frame.size.height;
            percent  = MAX(percent, 0);
            double s = MAX(percent, 0.5);
            CGAffineTransform translation = CGAffineTransformMakeTranslation(point.x / s, point.y / s);
            CGAffineTransform scale = CGAffineTransformMakeScale(s, s);
            photoView.imageView.transform = CGAffineTransformConcat(translation, scale);
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:percent];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:{
            if (fabs(point.y) > 200 || fabs(velocity.y) > 500) {
                [self showDismissAnimation];
            }else {
                [self showCancelAnimation];
            }
        }
            break;
        default:
            break;
    }
}

- (void)handlePanZoomSlide:(UIPanGestureRecognizer *)panGesture {
    CGPoint point    = [panGesture translationInView:self.view];
    CGPoint location = [panGesture locationInView:self.view];
    CGPoint velocity = [panGesture velocityInView:self.view];
    
    GKPhotoView *photoView = [self currentPhotoView];
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            _startLocation = location;
            [self handlePanBegin];
            break;
        case UIGestureRecognizerStateChanged:{
            photoView.imageView.transform = CGAffineTransformMakeTranslation(0, point.y);
            double percent = 1 - fabs(point.y) / self.view.frame.size.height * 0.5;
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:percent];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (fabs(point.y) > 200 || fabs(velocity.y) > 500) {
                [self showSlideDismissAnimationWithPoint:point];
            }else {
                [self showCancelAnimation];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)handlePanBegin {
    GKPhoto *photo = [self currentPhoto];
    
    if (self.isHideSourceView) {
        photo.sourceImageView.alpha = 0;
    }
    
    _isStatusBarShowing = self.isStatusBarShow;
    
    // 显示状态栏
    self.isStatusBarShow = YES;
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:panBeginWithIndex:)]) {
        [self.delegate photoBrowser:self panBeginWithIndex:self.currentIndex];
    }
}

- (void)recoverAnimation {
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    if (UIDeviceOrientationIsLandscape(orientation)) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            // 旋转view
            self.contentView.transform = CGAffineTransformIdentity;
            
            // 设置frame
            self.contentView.bounds = CGRectMake(0, 0, MIN(screenBounds.size.width, screenBounds.size.height), MAX(screenBounds.size.width, screenBounds.size.height));
            
            self.contentView.center = [UIApplication sharedApplication].keyWindow.center;
            
            [self layoutSubviews];
            
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        }completion:^(BOOL finished) {
            [self showDismissAnimation];
        }];
    }else {
        [self showDismissAnimation];
    }
}

- (void)showDismissAnimation {
    
    GKPhotoView *photoView = [self photoViewForIndex:self.currentIndex];
    GKPhoto *photo = self.photos[self.currentIndex];
    
    CGRect sourceRect = photo.sourceFrame;
    
    if (CGRectEqualToRect(sourceRect, CGRectZero)) {
        if (photo.sourceImageView == nil) {
            [UIView animateWithDuration:kAnimationDuration animations:^{
                self.view.alpha = 0;
            }completion:^(BOOL finished) {
                [self dismissAnimated:NO];
            }];
            return;
        }
        
        if (self.isHideSourceView) {
            photo.sourceImageView.alpha = 0;
        }
        
        float systemVersion = [UIDevice currentDevice].systemVersion.floatValue;
        if (systemVersion >= 8.0 && systemVersion < 9.0) {
            sourceRect = [photo.sourceImageView.superview convertRect:photo.sourceImageView.frame toCoordinateSpace:photoView];
        }else {
            sourceRect = [photo.sourceImageView.superview convertRect:photo.sourceImageView.frame toView:photoView];
        }
    }else {
        if (self.isHideSourceView && photo.sourceImageView) {
            photo.sourceImageView.alpha = 0;
        }
    }
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        photoView.imageView.frame = sourceRect;
        self.view.backgroundColor = [UIColor clearColor];
    }completion:^(BOOL finished) {
        [self dismissAnimated:NO];
        
        [self panEndedWillDisappear:YES];
    }];
}

- (void)showSlideDismissAnimationWithPoint:(CGPoint)point {
    GKPhotoView *photoView = [self currentPhotoView];
    BOOL throwToTop = point.y < 0;
    CGFloat toTranslationY = 0;
    if (throwToTop) {
        toTranslationY = - self.view.frame.size.height;
    }else {
        toTranslationY = self.view.frame.size.height;
    }
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        photoView.imageView.transform = CGAffineTransformMakeTranslation(0, toTranslationY);
        self.view.backgroundColor = [UIColor clearColor];
    }completion:^(BOOL finished) {
        [self dismissAnimated:YES];
        
        [self panEndedWillDisappear:YES];
    }];
}

- (void)showCancelAnimation {
    GKPhotoView *photoView = [self photoViewForIndex:self.currentIndex];
    GKPhoto *photo = self.photos[self.currentIndex];
    photo.sourceImageView.alpha = 1.0;
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        photoView.imageView.transform = CGAffineTransformIdentity;
        self.view.backgroundColor = [UIColor blackColor];
    }completion:^(BOOL finished) {
        
        if (!_isStatusBarShowing) {
            // 隐藏状态栏
            self.isStatusBarShow = NO;
        }
        
        [self panEndedWillDisappear:NO];
    }];
}

- (void)panEndedWillDisappear:(BOOL)disappear {
    if ([self.delegate respondsToSelector:@selector(photoBrowser:panEndedWithIndex:willDisappear:)]) {
        [self.delegate photoBrowser:self panEndedWithIndex:self.currentIndex willDisappear:disappear];
    }
}

// 重用页面
- (GKPhotoView *)dequeueReusablePhotoView {
    GKPhotoView *photoView = [self.reusablePhotoViews anyObject];
    if (photoView) {
        [_reusablePhotoViews removeObject:photoView];
    }else {
        photoView = [[GKPhotoView alloc] initWithFrame:self.photoScrollView.bounds imageProtocol:_imageProtocol];
    }
    photoView.tag =  -1;
    return photoView;
}

#pragma mark - 屏幕旋转相关
- (void)addDeviceOrientationObserver {
    
    // 默认设备方向：竖屏
    self.originalOrientation = UIDeviceOrientationPortrait;
    
    //    [self deviceOrientationDidChange];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)delDeviceOrientationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)deviceOrientationDidChange {
    if (self.isFullScreenDisabled) return;
    
    self.isRotation = YES;
    
    // 恢复当前视图的缩放
    GKPhoto *photo  = [self currentPhoto];
    photo.isZooming = NO;
    photo.zoomRect  = CGRectZero;
    
    GKPhotoView *photoView = [self currentPhotoView];
    
    // 旋转之后当前的设备方向
    UIDeviceOrientation currentOrientation = [UIDevice currentDevice].orientation;
    
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
    
    self.isPortraitToUp = NO;
    
    if (UIDeviceOrientationIsPortrait(self.originalOrientation)) {
        if (currentOrientation == UIDeviceOrientationFaceUp) {
            self.isPortraitToUp = YES;
        }
    }
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    // 旋转之后是横屏
    if (UIDeviceOrientationIsLandscape(currentOrientation)) {
        // 横屏移除pan手势
        [self removePanGesture];
        
        NSTimeInterval duration = UIDeviceOrientationIsLandscape(self.originalOrientation) ? 2 * kAnimationDuration : kAnimationDuration;
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            // 旋转状态栏
            [[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)currentOrientation animated:YES];
            
            float rotation = currentOrientation == UIDeviceOrientationLandscapeRight ? 1.5 : 0.5;
            
            // 旋转contentView
            self.contentView.transform = CGAffineTransformMakeRotation(M_PI * rotation);
            
            // 设置frame
            self.contentView.bounds = CGRectMake(0, 0, MAX(screenBounds.size.width, screenBounds.size.height), MIN(screenBounds.size.width, screenBounds.size.height));
            
            self.contentView.center = [UIApplication sharedApplication].keyWindow.center;
            
            [self layoutSubviews];
            
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            // 记录设备方向
            self.originalOrientation = currentOrientation;
            self.isRotation = NO;
        }];
    }else if (currentOrientation == UIDeviceOrientationPortrait) {
        // 竖屏时添加pan手势
        [self addPanGesture:NO];
        
        NSTimeInterval duration = kAnimationDuration;
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            // 旋转状态栏
            [[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)currentOrientation animated:YES];
            
            // 旋转view
            self.contentView.transform = currentOrientation == UIDeviceOrientationPortrait ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(M_PI);
            
            // 设置frame
            self.contentView.bounds = CGRectMake(0, 0, MIN(screenBounds.size.width, screenBounds.size.height), MAX(screenBounds.size.width, screenBounds.size.height));
            self.contentView.center = [UIApplication sharedApplication].keyWindow.center;
            
            [self layoutSubviews];
            
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            // 记录设备方向
            self.originalOrientation = currentOrientation;
            self.isRotation = NO;
        }];
    }else {
        self.isRotation = NO;
    }
}

// 更新可复用的图片视图
- (void)updateReusableViews {
    NSMutableArray *viewsForRemove = [NSMutableArray new];
    for (GKPhotoView *photoView in _visiblePhotoViews) {
        if ((photoView.frame.origin.x + photoView.frame.size.width < self.photoScrollView.contentOffset.x - self.photoScrollView.frame.size.width) || (photoView.frame.origin.x > self.photoScrollView.contentOffset.x + 2 * self.photoScrollView.frame.size.width)) {
            [photoView removeFromSuperview];
            GKPhoto *photo = nil;
            
            [photoView setupPhoto:photo];
            
            [viewsForRemove addObject:photoView];
            [_reusablePhotoViews addObject:photoView];
        }
    }
    [_visiblePhotoViews removeObjectsInArray:viewsForRemove];
}

// 设置图片视图
- (void)setupPhotoViews {
    NSInteger index = self.photoScrollView.contentOffset.x / self.photoScrollView.frame.size.width + 0.5;
    
    for (NSInteger i = index - 1; i <= index + 1; i++) {
        if (i < 0 || i >= self.photos.count) {
            continue;
        }
        GKPhotoView *photoView = [self photoViewForIndex:i];
        if (photoView == nil) {
            photoView               = [self dequeueReusablePhotoView];
            photoView.loadStyle     = self.loadStyle;
            photoView.zoomEnded     = ^(NSInteger scale) {
                if (scale == 1.0f) {
                    [self addPanGesture:NO];
                }else {
                    [self removePanGesture];
                }
            };
            CGRect frame            = self.photoScrollView.bounds;
            
            CGFloat photoScrollW    = frame.size.width;
            CGFloat photoScrollH    = frame.size.height;
            // 调整当前显示的photoView的frame
            CGFloat w = photoScrollW - kPhotoViewPadding * 2;
            CGFloat h = photoScrollH;
            CGFloat x = kPhotoViewPadding + i * (kPhotoViewPadding * 2 + w);
            CGFloat y = 0;
            
            photoView.frame = CGRectMake(x, y, w, h);
            photoView.tag   = i;
            [self.photoScrollView addSubview:photoView];
            [_visiblePhotoViews addObject:photoView];
            
            [photoView resetFrame];
        }
        
        if (photoView.photo == nil && self.isShow) {
            [photoView setupPhoto:self.photos[i]];
        }
    }
    
    // 更换photoView
    if (index != self.currentIndex && self.isShow && (index >= 0 && index < self.photos.count)) {
        self.currentIndex = index;
        
        GKPhotoView *photoView = [self currentPhotoView];
        
        if (photoView.scrollView.zoomScale != 1.0) {
            [self removePanGesture];
        }else {
            [self addPanGesture:NO];
        }
        
        [self updateLabel];
        
        if ([self.delegate respondsToSelector:@selector(photoBrowser:didChangedIndex:)]) {
            [self.delegate photoBrowser:self didChangedIndex:self.currentIndex];
        }
    }
}

- (GKPhotoView *)photoViewForIndex:(NSInteger)index {
    for (GKPhotoView *photoView in _visiblePhotoViews) {
        if (photoView.tag == index) {
            return photoView;
        }
    }
    return nil;
}

#pragma mark - 代理
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.isRotation) return;
    
    [self updateReusableViews];
    
    [self setupPhotoViews];
}

// scrollView结束滚动时调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat scrollW = self.photoScrollView.frame.size.width;
    
    NSInteger index = (offsetX + scrollW * 0.5) / scrollW;
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:scrollEndedIndex:)]) {
        [self.delegate photoBrowser:self scrollEndedIndex:index];
    }
    
    if (self.isResumePhotoZoom) {
        [self.visiblePhotoViews enumerateObjectsUsingBlock:^(GKPhotoView *photoView, NSUInteger idx, BOOL * _Nonnull stop) {
            GKPhoto *photo = self.photos[idx];
            photo.isZooming = NO;
            
            [photoView.scrollView setZoomScale:1.0 animated:NO];
        }];
    }
    
    if ([self currentPhotoView].scrollView.zoomScale > 1.0) {
        [self removePanGesture];
    }else {
        [self addPanGesture:NO];
    }
}

@end
