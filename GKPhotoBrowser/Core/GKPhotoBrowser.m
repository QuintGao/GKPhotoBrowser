//
//  GKPhotoBrowser.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/20.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKPhotoBrowser.h"
#import "GKPanGestureRecognizer.h"

#if __has_include(<GKYYWebImageManager.h>)
#import "GKYYWebImageManager.h"
#elif __has_include(<GKSDWebImageManager.h>)
#import "GKSDWebImageManager.h"
#endif

static Class imageManagerClass = nil;

@interface GKPhotoBrowser()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong, readwrite) UIView         *contentView;

@property (nonatomic, strong, readwrite) NSArray        *photos;
@property (nonatomic, assign, readwrite) NSInteger      currentIndex;
@property (nonatomic, strong, readwrite) GKPhotoView    *curPhotoView;
@property (nonatomic, assign, readwrite) BOOL           isLandscape;

@property (nonatomic, strong) UIScrollView *photoScrollView;

@property (nonatomic, strong) NSMutableArray *visiblePhotoViews;
@property (nonatomic, strong) NSMutableSet *reusablePhotoViews;

@property (nonatomic, assign) BOOL isShow;

@property (nonatomic, strong) NSArray *coverViews;
@property (nonatomic, copy) layoutBlock layoutBlock;

/** 当前设备方向 */
@property (nonatomic, assign, readwrite) UIDeviceOrientation currentOrientation;
/** 上一次的设备方向 */
@property (nonatomic, assign) UIDeviceOrientation originalOrientation;

/** 正在发生屏幕旋转 */
@property (nonatomic, assign) BOOL isRotation;

/** 状态栏是否显示 */
@property (nonatomic, assign) BOOL isStatusBarShowing;

/// 原始状态栏
@property (nonatomic, assign) UIStatusBarStyle originStatusBarStyle;

/** 正在滑动缩放隐藏 */
@property (nonatomic, assign) BOOL isZoomScale;

// 是否已经显示
@property (nonatomic, assign) BOOL isAppeared;

@property (nonatomic, strong) GKPanGestureRecognizer *panGesture;

@property (nonatomic, assign) CGPoint   firstMovePoint;
@property (nonatomic, assign) CGPoint   startLocation;
@property (nonatomic, assign) CGRect    startFrame;

@property (nonatomic, strong) id<GKWebImageProtocol> imageProtocol;

/** 20200312 是否已经开始开始监听屏幕旋转,用于修复issue 67 和 issue 71
 添加本参数的原因说明：
 (1).iOS 13.x要求
 endGeneratingDeviceOrientationNotifications 和
 beginGeneratingDeviceOrientationNotifications 需要成对调用，如果已经调用过beginGeneratingDeviceOrientationNotifications，再次调用的话，会导致crash。
 报错：NSInternalInconsistencyException原因：threading violation: expected the main thread
 (2).解决GKPhotoBrowser可能在endGeneratingDeviceOrientationNotifications时影响了App本身的屏幕旋转监听的问题。
 **/
@property(nonatomic, assign) BOOL isGeneratingDeviceOrientationNotificationsBegunBeforePhotoBrowserAppeared;

/// 20200312 用于防止多次addObserver，添加监听UIDeviceOrientationDidChangeNotification通知的flag
@property(nonatomic, assign) BOOL isOrientationNotiObserverAdded;

/// 状态栏处理
@property (nonatomic, assign) BOOL statusBarAppearance;

@end

@implementation GKPhotoBrowser

+ (instancetype)photoBrowserWithPhotos:(NSArray<GKPhoto *> *)photos currentIndex:(NSInteger)currentIndex {
    return [[self alloc] initWithPhotos:photos currentIndex:currentIndex];
}

- (instancetype)initWithPhotos:(NSArray<GKPhoto *> *)photos currentIndex:(NSInteger)currentIndex {
    if (self = [super init]) {
        self.photos       = photos;
        self.currentIndex = currentIndex;
        
        // 初始化
        self.originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        
        self.isStatusBarShow         = NO;
        self.isHideSourceView        = YES;
        self.statusBarStyle          = UIStatusBarStyleLightContent;
        self.isFullWidthForLandScape = YES;
        self.maxZoomScale            = kMaxZoomScale;
        self.doubleZoomScale         = self.maxZoomScale;
        self.animDuration            = kAnimationDuration;
        // 20200312
        self.isGeneratingDeviceOrientationNotificationsBegunBeforePhotoBrowserAppeared = [UIDevice currentDevice].isGeneratingDeviceOrientationNotifications;
        
        _visiblePhotoViews  = [NSMutableArray new];
        _reusablePhotoViews = [NSMutableSet new];
        
        imageManagerClass = NSClassFromString(@"GKSDWebImageManager");
        if (!imageManagerClass) {
            imageManagerClass = NSClassFromString(@"GKYYWebImageManager");
        }
        if (imageManagerClass) {
            self.imageProtocol = [imageManagerClass new];
        }
        
        // 状态栏外观处理
        NSDictionary *infoDict = [NSBundle mainBundle].infoDictionary;
        BOOL hasKey = [infoDict.allKeys containsObject:@"UIViewControllerBasedStatusBarAppearance"];
        BOOL appearance = [[infoDict objectForKey:@"UIViewControllerBasedStatusBarAppearance"] boolValue];
        self.statusBarAppearance = (hasKey && appearance) || !hasKey;
    }
    return self;
}

- (void)setupWebImageProtocol:(id<GKWebImageProtocol>)protocol {
    self.imageProtocol = protocol;
}

- (instancetype)init {
    NSAssert(NO, @"Use initWithPhotos:currentIndex: instead.");
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置UI
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isAppeared) return;
    self.isAppeared = YES;
    // 手势和监听
    [self addGestureAndObserver];
    
    GKPhoto *photo          = [self currentPhoto];
    GKPhotoView *photoView  = [self currentPhotoView];
    self.curPhotoView = photoView;
    
    if ([_imageProtocol imageFromMemoryForURL:photo.url] || photo.image) {
        [photoView setupPhoto:photo];
    }else {
        photoView.imageView.image = photo.placeholderImage ? photo.placeholderImage : photo.sourceImageView.image;
        [photoView adjustFrame];
    }
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didSelectAtIndex:)]) {
        [self.delegate photoBrowser:self didSelectAtIndex:self.currentIndex];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    if ([self.imageProtocol respondsToSelector:@selector(clearMemory)]) {
        [self.imageProtocol clearMemory];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didDisappearAtIndex:)]) {
        [self.delegate photoBrowser:self didDisappearAtIndex:self.currentIndex];
    }
}

- (void)setupUI {
    if (!self.navigationController.navigationBarHidden && !self.navigationController.navigationBar.hidden) {
        [self.navigationController setNavigationBarHidden:YES];
    }
    
    self.view.backgroundColor = self.bgColor ? : [UIColor blackColor];
    
    CGFloat width  = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    BOOL isLandscape = width > height;
    
    if (self.isAdaptiveSafeArea) {
        if (isLandscape) {
            width  -= (kSafeTopSpace + kSafeBottomSpace);
        }else {
            height -= (kSafeTopSpace + kSafeBottomSpace);
        }
    }
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.contentView.center = self.view.center;
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.contentView];
    
    [self.contentView addSubview:self.photoScrollView];
    
    if (self.coverViews) {
        [self.coverViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.contentView addSubview:obj];
        }];
    }else {
        [self setupDefaultCovers];
    }
    [self layoutSubviews];
    
    CGRect frame = self.photoScrollView.bounds;
    CGSize contentSize = CGSizeMake(frame.size.width * self.photos.count, frame.size.height);
    self.photoScrollView.contentSize = contentSize;
    
    CGPoint contentOffset = CGPointMake(frame.size.width * self.currentIndex, 0);
    [self.photoScrollView setContentOffset:contentOffset animated:NO];
    
    if (self.photoScrollView.contentOffset.x == 0) {
        [self scrollViewDidScroll:self.photoScrollView];
    }
}

- (void)setupDefaultCovers {
    [self.contentView addSubview:self.countLabel];
    [self.contentView addSubview:self.pageControl];
    [self.contentView addSubview:self.saveBtn];
    
    if (self.hidesCountLabel) {
        self.countLabel.hidden = YES;
    }else {
        self.countLabel.hidden = self.photos.count == 1;
    }
    self.pageControl.numberOfPages = self.photos.count;
    if (self.pageControl.hidesForSinglePage) {
        self.pageControl.hidden = self.photos.count <= 1;
    }
    CGSize size = [self.pageControl sizeForNumberOfPages:self.photos.count];
    self.pageControl.bounds = CGRectMake(0, 0, size.width, size.height);
    [self updateViewIndex];
}

- (void)addGestureAndObserver {
    [self addGestureRecognizer];
    
    if (self.isFollowSystemRotation) return;
    if (!self.isScreenRotateDisabled) {
        [self addDeviceOrientationObserver];
    }
}

#pragma mark - Setter
- (void)setShowStyle:(GKPhotoBrowserShowStyle)showStyle {
    _showStyle = showStyle;
    
    if (showStyle != GKPhotoBrowserShowStylePush) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle   = UIModalTransitionStyleCoverVertical;
    }
}

- (void)setIsStatusBarShow:(BOOL)isStatusBarShow {
    _isStatusBarShow = isStatusBarShow;
    
    if (self.statusBarAppearance) {
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self prefersStatusBarHidden];
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        }
    }else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] setStatusBarHidden:!isStatusBarShow];
#pragma clang diagnostic pop
    }
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    _statusBarStyle = statusBarStyle;
    
    if (self.statusBarAppearance) {
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self prefersStatusBarHidden];
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        }
    }else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle];
#pragma clang diagnostic pop
    }
}

- (void)setIsScreenRotateDisabled:(BOOL)isScreenRotateDisabled {
    _isScreenRotateDisabled = isScreenRotateDisabled;
    
    if (isScreenRotateDisabled) {
        [self delDeviceOrientationObserver];
    }else {
        [self addDeviceOrientationObserver];
    }
}

- (void)setDoubleZoomScale:(CGFloat)doubleZoomScale {
    if (doubleZoomScale > self.maxZoomScale) {
        _doubleZoomScale = self.maxZoomScale;
    }else {
        _doubleZoomScale = doubleZoomScale;
    }
}

#pragma mark - BrowserShow
- (void)browserNoneShow {
    GKPhotoView *photoView = [self currentPhotoView];
    GKPhoto *photo = [self currentPhoto];
    
    self.view.alpha = 0;
    
    [UIView animateWithDuration:self.animDuration animations:^{
        self.view.alpha = 1.0;
    }completion:^(BOOL finished) {
        self.isShow = YES;
        
        [photoView setupPhoto:photo];
        
        [self deviceOrientationDidChange];
    }];
}

- (void)browserPushShow {
    self.view.backgroundColor = self.bgColor ? : [UIColor blackColor];
    self.isShow = YES;
    
    [[self currentPhotoView] setupPhoto:[self currentPhoto]];
    
    [self deviceOrientationDidChange];
}

- (void)browserZoomShow {
    GKPhoto *photo          = [self currentPhoto];
    GKPhotoView *photoView  = [self currentPhotoView];
    
    CGRect endRect = CGRectZero;
    if (photoView.imageView.image) {
        endRect = photoView.imageView.frame;
    }else {
        if (CGRectEqualToRect(photo.sourceFrame, CGRectZero)) {
            endRect = photoView.imageView.frame;
        }else {
            CGFloat w = GKScreenW;
            // bug fixed：#43 CALayer position contains NaN: [nan nan]
            CGFloat h = (photo.sourceFrame.size.width == 0) ? GKScreenH : (w * photo.sourceFrame.size.height / photo.sourceFrame.size.width);
            CGFloat x = 0;
            CGFloat y = (GKScreenH - h) / 2;
            endRect = CGRectMake(x, y, w, h);
        }
    }
    
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
    
    [UIView animateWithDuration:self.animDuration animations:^{
        photoView.imageView.frame = endRect;
        self.view.backgroundColor = self.bgColor ? : [UIColor blackColor];
    }completion:^(BOOL finished) {
        self.isShow = YES;
        [photoView setupPhoto:photo];
        
        [self deviceOrientationDidChange];
    }];
}

- (void)updateViewIndex {
    self.countLabel.text = [NSString stringWithFormat:@"%zd/%zd", (long)(self.currentIndex + 1), (long)self.photos.count];
    self.pageControl.currentPage = self.currentIndex;
}

- (void)layoutSubviews {
    CGRect frame = self.contentView.bounds;
    frame.origin.x   -= kPhotoViewPadding;
    frame.size.width += kPhotoViewPadding * 2;
    
    CGFloat photoScrollW = frame.size.width;
    CGFloat photoScrollH = frame.size.height;
    CGFloat pointX = photoScrollW * 0.5 - kPhotoViewPadding;
    
    self.photoScrollView.frame  = frame;
    self.photoScrollView.center = CGPointMake(pointX, photoScrollH * 0.5);
    self.photoScrollView.contentOffset = CGPointMake(self.currentIndex * photoScrollW, 0);
    self.photoScrollView.contentSize = CGSizeMake(photoScrollW * self.photos.count, 0);
    
    // 调整所有显示的photoView的frame
    CGFloat w = photoScrollW - kPhotoViewPadding * 2;
    CGFloat h = photoScrollH;
    __block CGFloat x = 0;
    CGFloat y = 0;
    
    [_visiblePhotoViews enumerateObjectsUsingBlock:^(GKPhotoView *photoView, NSUInteger idx, BOOL * _Nonnull stop) {
        x = kPhotoViewPadding + photoView.tag * (kPhotoViewPadding * 2 + w);
        photoView.frame = CGRectMake(x, y, w, h);
        [photoView resetFrame];
    }];
    
    if (self.coverViews) {
        !self.layoutBlock ? : self.layoutBlock(self, self.contentView.bounds);
    }else {
        CGFloat centerX = self.contentView.bounds.size.width * 0.5f;
        
        self.countLabel.center = CGPointMake(centerX, (KIsiPhoneX && !self.isLandscape) ? 50 : 30);
        CGFloat pointY = 0;
        if (self.isLandscape) {
            pointY = self.contentView.bounds.size.height - 20;
        }else {
            pointY = self.contentView.bounds.size.height - 20 - (self.isAdaptiveSafeArea ? 0 : kSafeBottomSpace);
        }
        self.pageControl.center = CGPointMake(centerX, pointY);
        self.saveBtn.center = CGPointMake(self.contentView.bounds.size.width - 50, pointY);
    }
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:willLayoutSubViews:)]) {
        [self.delegate photoBrowser:self willLayoutSubViews:self.currentIndex];
    }
}

- (void)dealloc {
    [self delDeviceOrientationObserver];
}

#pragma mark - 屏幕旋转
- (BOOL)shouldAutorotate {
    return self.isFollowSystemRotation ? YES : NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.isFollowSystemRotation ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
}

#pragma mark - 状态栏
- (BOOL)prefersStatusBarHidden {
    return !self.isStatusBarShow;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusBarStyle;
}

#pragma mark - Public Methods
- (void)setupCoverViews:(NSArray *)coverViews layoutBlock:(layoutBlock)layoutBlock {
    self.coverViews  = coverViews;
    self.layoutBlock = layoutBlock;
}

- (void)showFromVC:(UIViewController *)vc {
    if (self.showStyle == GKPhotoBrowserShowStylePush) {
        [vc.navigationController pushViewController:self animated:YES];
    }else {
        self.modalPresentationCapturesStatusBarAppearance = YES;
        [vc presentViewController:self animated:NO completion:nil];
    }
}

- (void)dismiss {
    GKPhotoView *photoView = [self currentPhotoView];
    photoView.isLayoutSubViews = YES;
    
    if (!self.isFollowSystemRotation) {
        // 状态栏恢复到竖屏
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if (@available(iOS 13.0, *)) {} else {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
        }
#pragma clang diagnostic pop
    }
    
    if (self.showStyle == GKPhotoBrowserShowStylePush) {
        [self delDeviceOrientationObserver];
        
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

- (void)selectedPhotoWithIndex:(NSInteger)index animated:(BOOL)animated{
    if (index < 0 || index >= self.photos.count) return;
    
    CGPoint offset = CGPointMake(self.photoScrollView.frame.size.width * index, 0);
    [self.photoScrollView setContentOffset:offset animated:animated];
}

- (void)removePhotoAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.photos.count) return;
    
    NSMutableArray *photos = [NSMutableArray arrayWithArray:self.photos];
    [photos removeObjectAtIndex:index];
    
    [self resetPhotoBrowserWithPhotos:photos];
}

- (void)resetPhotoBrowserWithPhotos:(NSArray *)photos {
    if (photos.count == 0) {
        [self dismiss];
        return;
    }
    
    self.photos = photos;
    
    [self.visiblePhotoViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.reusablePhotoViews removeAllObjects];
    [self.visiblePhotoViews removeAllObjects];
    
    [self updateReusableViews];
    [self setupPhotoViews];
    [self updateViewIndex];
    [self layoutSubviews];
}

- (void)loadCurrentPhotoImage {
    [self.curPhotoView loadOriginImage];
}

#pragma mark - Private Methods
- (void)addGestureRecognizer {
    // 单击手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
	singleTap.delaysTouchesEnded = NO;
	singleTap.delegate = self;
    [self.photoScrollView addGestureRecognizer:singleTap];
    
    // 双击手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
	doubleTap.delaysTouchesEnded = NO;
	doubleTap.delegate = self;
    [self.photoScrollView addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    // 长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.photoScrollView addGestureRecognizer:longPress];
    
    // 拖拽手势
    [self addPanGesture:YES];
}

- (void)addPanGesture:(BOOL)isFirst {
    if (self.showStyle == GKPhotoBrowserShowStylePush) {
        [self removePanGesture];
    }else {
        if (isFirst || self.isScreenRotateDisabled) { // 第一次进入或禁止处理屏幕旋转，直接添加手势
            [self.photoScrollView addGestureRecognizer:self.panGesture];
        }else {
            if (self.currentOrientation == UIDeviceOrientationPortrait) {
                [self.photoScrollView addGestureRecognizer:self.panGesture];
            }
        }
    }
}

- (void)removePanGesture {
    if ([self.photoScrollView.gestureRecognizers containsObject:self.panGesture]) {
        [self.photoScrollView removeGestureRecognizer:self.panGesture];
    }
}

- (void)dismissAnimated:(BOOL)animated {
    GKPhoto *photo = [self currentPhoto];
    
    if (animated) {
        [UIView animateWithDuration:self.animDuration animations:^{
            photo.sourceImageView.alpha = 1.0;
        }];
    }else {
        photo.sourceImageView.alpha = 1.0;
    }
    
    if (!self.isFollowSystemRotation) {
        if (@available(iOS 13.0, *)) {} else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
#pragma clang diagnostic pop
        }
    }
    
    // 移除屏幕旋转监听
    [self delDeviceOrientationObserver];
    if (!self.statusBarAppearance) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] setStatusBarStyle:self.originStatusBarStyle];
#pragma clang diagnostic pop
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)saveBtnClick:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(photoBrowser:onSaveBtnClick:image:)]) {
        [self.delegate photoBrowser:self onSaveBtnClick:self.currentIndex image:self.curPhotoView.imageView.image];
    }
}

- (void)setupCoverViewsWithAlpha:(CGFloat)alpha {
    for (UIView *view in self.coverViews) {
        view.alpha = alpha;
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
- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(photoBrowser:singleTapWithIndex:)]) {
        [self.delegate photoBrowser:self singleTapWithIndex:self.currentIndex];
    }
    
    // 禁言默认单击事件
    if (self.isSingleTapDisabled) return;
    [self dismiss];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    GKPhotoView *photoView = [self currentPhotoView];
    GKPhoto *photo = [self currentPhoto];
    if (!photo.finished) return;
    
    // 设置双击放大倍数
    [photoView setScrollMaxZoomScale:self.doubleZoomScale];
    
    if (photoView.scrollView.zoomScale > 1.0) {
        [photoView.scrollView setZoomScale:1.0 animated:YES];
        photo.isZooming = NO;
        
        // 默认情况下有滑动手势
        [self addPanGesture:YES];
    }else {
        CGPoint location = [tap locationInView:photoView.imageView];
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
        default:
            break;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    // 放大时候禁止滑动返回
    GKPhotoView *photoView = [self currentPhotoView];
    if (photoView.scrollView.zoomScale > 1.0f) return;
    
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
    GKPhotoView *photoView = [self photoViewForIndex:self.currentIndex];
    CGPoint point       = [panGesture translationInView:self.view];
    CGPoint location    = [panGesture locationInView:photoView.scrollView];
    CGPoint velocity    = [panGesture velocityInView:self.view];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            self.startLocation = location;
            self.startFrame = photoView.imageView.frame;
            self.isZoomScale = YES;
            photoView.loadingView.hidden = YES;
            [self handlePanBegin];
            break;
        case UIGestureRecognizerStateChanged: {
            if (self.view.frame.size.height == 0) return;
            double percent = 1 - fabs(point.y) / self.view.frame.size.height;
            double s = MAX(percent, 0.3);
            if (self.startFrame.size.width == 0 || self.startFrame.size.height == 0) return;
            
            CGFloat width = self.startFrame.size.width * s;
            CGFloat height = self.startFrame.size.height * s;
            
            CGFloat rateX = (self.startLocation.x - self.startFrame.origin.x) / self.startFrame.size.width;
            CGFloat x = location.x - width * rateX;
            
            CGFloat rateY = (self.startLocation.y - self.startFrame.origin.y) / self.startFrame.size.height;
            CGFloat y = location.y - height * rateY;
            
            photoView.imageView.frame = CGRectMake(x, y, width, height);

            self.view.backgroundColor = self.bgColor ? [self.bgColor colorWithAlphaComponent:percent] : [[UIColor blackColor] colorWithAlphaComponent:percent];
            
            [self setupCoverViewsWithAlpha:percent];
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
            photoView.loadingView.hidden = YES;
            [self handlePanBegin];
            break;
        case UIGestureRecognizerStateChanged:{
            photoView.imageView.transform = CGAffineTransformMakeTranslation(0, point.y);
            if (self.view.frame.size.height == 0) return;
            double percent = 1 - fabs(point.y) / self.view.frame.size.height * 0.5;
            
            self.view.backgroundColor = self.bgColor ? [self.bgColor colorWithAlphaComponent:percent] : [[UIColor blackColor] colorWithAlphaComponent:percent];
            
            [self setupCoverViewsWithAlpha:percent];
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
    
    if (!self.isFollowSystemRotation && UIDeviceOrientationIsLandscape(orientation)) {
        [UIView animateWithDuration:self.animDuration animations:^{
            // 旋转view
            self.contentView.transform = CGAffineTransformIdentity;
            
            CGFloat height = MAX(screenBounds.size.width, screenBounds.size.height);
            
            if (self.isAdaptiveSafeArea) {
                height -= (kSafeTopSpace + kSafeBottomSpace);
            }
            // 设置frame
            self.contentView.bounds = CGRectMake(0, 0, MIN(screenBounds.size.width, screenBounds.size.height), height);
            self.contentView.center = self.view.center;
            
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
            [self layoutSubviews];
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
            [UIView animateWithDuration:self.animDuration animations:^{
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
    
    if (photoView.scrollView.zoomScale > 1.0f) {
        [photoView.scrollView setZoomScale:1.0f animated:NO];
    }
    
    if (photo.sourceImageView) {
        photoView.imageView.image = photo.sourceImageView.image;
    }
    
    // Fix bug：解决长图点击隐藏时可能出现的闪动bug
    UIViewContentMode mode = photo.sourceImageView ? photo.sourceImageView.contentMode : UIViewContentModeScaleAspectFill;
    
    photoView.imageView.contentMode = mode;
    sourceRect.origin.x -= photoView.scrollView.contentOffset.x;
    sourceRect.origin.y += photoView.scrollView.contentOffset.y;
    
    [UIView animateWithDuration:self.animDuration animations:^{
        [self setupCoverViewsWithAlpha:0];
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
    
    [UIView animateWithDuration:self.animDuration animations:^{
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
    
    [UIView animateWithDuration:self.animDuration animations:^{
        if (self.hideStyle == GKPhotoBrowserHideStyleZoomScale) {
            photoView.imageView.frame = self.startFrame;
        }else {
            photoView.imageView.transform = CGAffineTransformIdentity;
        }
        self.view.backgroundColor = self.bgColor ? : [UIColor blackColor];
    }completion:^(BOOL finished) {
        
        if (!self.isStatusBarShowing) {
            // 隐藏状态栏
            self.isStatusBarShow = NO;
        }
        photoView.loadingView.hidden = NO;
        
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
    if (self.isFollowSystemRotation) return;
    // 默认设备方向：竖屏
    self.originalOrientation = UIDeviceOrientationPortrait;
    self.currentOrientation = [UIDevice currentDevice].orientation;
    // 未知或者朝上都认为是竖屏
    if (self.currentOrientation == UIDeviceOrientationUnknown || self.currentOrientation == UIDeviceOrientationFaceUp) {
        self.currentOrientation = UIDeviceOrientationPortrait;
    }
    // 20200312 尚未添加observer的情况下才添加，防止多次重复添加
    if(!_isOrientationNotiObserverAdded)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
        _isOrientationNotiObserverAdded = YES;
    }
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)delDeviceOrientationObserver {
    if (self.isFollowSystemRotation) return;
    // 20200312 如果在唤起GKPhotoBrowser前，app已经开启屏幕旋转通知GeneratingDeviceOrientationNotifications，那么无需停止，否则会影响全局的其他监听屏幕旋转的功能。
    if(self.isGeneratingDeviceOrientationNotificationsBegunBeforePhotoBrowserAppeared)
        return;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    if([UIDevice currentDevice].isGeneratingDeviceOrientationNotifications)
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)deviceOrientationDidChange {
    if (self.isFollowSystemRotation) return;
    if (self.isScreenRotateDisabled) return;
    
    // 旋转之后当前的设备方向
    UIDeviceOrientation currentOrientation = [UIDevice currentDevice].orientation;
    
    // 未知或者朝上都认为是竖屏
    if (currentOrientation == UIDeviceOrientationUnknown || currentOrientation == UIDeviceOrientationFaceUp) {
        currentOrientation = UIDeviceOrientationPortrait;
    }
    
    // 修复bug #117，从后台进入前台会执行此方法 导致缩放变化，所以此处做下处理
    if (self.currentOrientation == currentOrientation) return;
    
    self.currentOrientation = currentOrientation;
    
    self.isRotation = YES;
    
    // 恢复当前视图的缩放
    GKPhoto *photo  = [self currentPhoto];
    photo.isZooming = NO;
    photo.zoomRect  = CGRectZero;
    
    GKPhotoView *photoView = [self currentPhotoView];
    
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
        [self removePanGesture];
        
        NSTimeInterval duration = UIDeviceOrientationIsLandscape(self.originalOrientation) ? 2 * self.animDuration : self.animDuration;
        
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
            self.contentView.transform = CGAffineTransformMakeRotation(M_PI * rotation);
            
            CGFloat width = MAX(screenBounds.size.width, screenBounds.size.height);
            if (self.isAdaptiveSafeArea) {
                width -= (kSafeTopSpace + kSafeBottomSpace);
            }
            // 设置frame
            self.contentView.bounds = CGRectMake(0, 0, width, MIN(screenBounds.size.width, screenBounds.size.height));
            self.contentView.center = self.view.center;
            
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
            [self layoutSubviews];
        } completion:^(BOOL finished) {
            // 记录设备方向
            self.originalOrientation = currentOrientation;
            self.isRotation = NO;
            
            // 横屏时隐藏状态栏，这里为了解决一个bug，iPhone X中横屏状态栏隐藏后不能再次显示，暂时的解决办法是这样，如果有更好的方法可随时修改
            if (self.isStatusBarShow) { // 状态栏是显示状态
                self.isStatusBarShowing = self.isStatusBarShow;  // 记录状态栏显隐状态
                self.isStatusBarShow = NO;
            }
        }];
    }else if (currentOrientation == UIDeviceOrientationPortrait) {
        self.isLandscape = NO;
        [self deviceOrientationChangedDelegate];
        
        // 竖屏时添加pan手势
        [self addPanGesture:NO];
        
        NSTimeInterval duration = self.animDuration;
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            // 旋转状态栏
            if (@available(iOS 13.0, *)) {} else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)currentOrientation animated:YES];
#pragma clang diagnostic pop
            }
            
            // 旋转view
            self.contentView.transform = currentOrientation == UIDeviceOrientationPortrait ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(M_PI);
            
            CGFloat height = MAX(screenBounds.size.width, screenBounds.size.height);
            if (self.isAdaptiveSafeArea) {
                height -= (kSafeTopSpace + kSafeBottomSpace);
            }
            // 设置frame
            self.contentView.bounds = CGRectMake(0, 0, MIN(screenBounds.size.width, screenBounds.size.height), height);
            self.contentView.center = self.view.center;
            
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
            [self layoutSubviews];
            
        } completion:^(BOOL finished) {
            // 记录设备方向
            self.originalOrientation = currentOrientation;
            self.isRotation = NO;
            
            // 切换到竖屏后，如果原来状态栏是显示状态，就再次显示状态栏
            if (self.isStatusBarShowing) {
                self.isStatusBarShow    = YES;
                self.isStatusBarShowing = NO;
            }
        }];
    }else {
        self.isRotation     = NO;
        self.isLandscape    = NO;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        [self layoutSubviews];
        
        [self deviceOrientationChangedDelegate];
    }
}

- (void)deviceOrientationChangedDelegate {
    if ([self.delegate respondsToSelector:@selector(photoBrowser:onDeciceChangedWithIndex:isLandscape:)]) {
        [self.delegate photoBrowser:self onDeciceChangedWithIndex:self.currentIndex isLandscape:self.isLandscape];
    }
}

// 更新可复用的图片视图
- (void)updateReusableViews {
    NSMutableArray *viewsForRemove = [NSMutableArray new];
    [self.visiblePhotoViews enumerateObjectsUsingBlock:^(GKPhotoView *photoView, NSUInteger idx, BOOL * _Nonnull stop) {
        if ((photoView.frame.origin.x + photoView.frame.size.width < self.photoScrollView.contentOffset.x - self.photoScrollView.frame.size.width) || (photoView.frame.origin.x > self.photoScrollView.contentOffset.x + 2 * self.photoScrollView.frame.size.width)) {
            [photoView removeFromSuperview];
            GKPhoto *photo = nil;
            
            [photoView setupPhoto:photo];
            
            [viewsForRemove addObject:photoView];
            [self.reusablePhotoViews addObject:photoView];
        }
    }];
    [self.visiblePhotoViews removeObjectsInArray:viewsForRemove];
}

// 设置图片视图
- (void)setupPhotoViews {
    NSInteger index = self.photoScrollView.contentOffset.x / self.photoScrollView.frame.size.width + 0.5;
    for (NSInteger i = index - 1; i <= index + 1; i++) {
        if (i < 0 || i >= self.photos.count) continue;
        
        GKPhotoView *photoView = [self photoViewForIndex:i];
        if (photoView == nil) {
            photoView                 = [self dequeueReusablePhotoView];
            photoView.loadStyle       = self.loadStyle;
            photoView.originLoadStyle = self.originLoadStyle;
            photoView.failStyle       = self.failStyle;
            photoView.isFullWidthForLandScape = self.isFullWidthForLandScape;
            photoView.failureText     = self.failureText;
            photoView.failureImage    = self.failureImage;
            photoView.maxZoomScale    = self.maxZoomScale;
            photoView.doubleZoomScale = self.doubleZoomScale;
            
            __typeof(self) __weak weakSelf = self;
            __typeof(photoView) __weak weakPhotoView = photoView;
            photoView.zoomEnded = ^(GKPhotoView * _Nonnull curPhotoView, CGFloat scale) {
                if (curPhotoView.tag == weakPhotoView.tag) {
                    if (scale == 1.0f) {
                        [weakSelf addPanGesture:NO];
                    }else {
                        [weakSelf removePanGesture];
                    }
                }
            };
            
            photoView.loadFailed = ^(GKPhotoView * _Nonnull curPhotoView) {
                if (curPhotoView.tag == weakPhotoView.tag) {
                    if ([weakSelf.delegate respondsToSelector:@selector(photoBrowser:loadFailedAtIndex:)]) {
                        [weakSelf.delegate photoBrowser:weakSelf loadFailedAtIndex:weakSelf.currentIndex];
                    }
                }
            };
            
            photoView.loadProgressBlock = ^(GKPhotoView * _Nonnull curPhotoView, float progress, BOOL isOriginImage) {
                if (curPhotoView.tag == weakPhotoView.tag) {
                    if ([weakSelf.delegate respondsToSelector:@selector(photoBrowser:loadImageAtIndex:progress:isOriginImage:)]) {
                        [weakSelf.delegate photoBrowser:weakSelf loadImageAtIndex:weakSelf.currentIndex progress:progress isOriginImage:isOriginImage];
                    }
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
        self.curPhotoView = photoView;
        
        GKPhoto *photo = [self currentPhoto];
        if (photo.failed) {
            [photoView setupPhoto:photo];
        }
        
        if (photoView.scrollView.zoomScale != 1.0) {
            [self removePanGesture];
        }else {
            [self addPanGesture:NO];
        }
        
        [self updateViewIndex];
        
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
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:scrollViewDidScroll:)]) {
        [self.delegate photoBrowser:self scrollViewDidScroll:scrollView];
    }
}

// scrollView结束滚动时调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat scrollW = self.photoScrollView.frame.size.width;
    if (scrollW == 0) return;
    
    NSInteger index = (offsetX + scrollW * 0.5) / scrollW;
    
    self.curPhotoView = [self currentPhotoView];
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didSelectAtIndex:)]) {
        [self.delegate photoBrowser:self didSelectAtIndex:index];
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
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:scrollViewDidEndDecelerating:)]) {
        [self.delegate photoBrowser:self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.delegate respondsToSelector:@selector(photoBrowser:scrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate photoBrowser:self scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (!self.isFollowSystemRotation) return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            CGFloat width = self.view.bounds.size.width;
            CGFloat height = self.view.bounds.size.height;
            if (self.isAdaptiveSafeArea) {
                if (width > height) {
                    width -= (kSafeTopSpace + kSafeBottomSpace);
                }else {
                    height -= (kSafeTopSpace + kSafeBottomSpace);
                }
            }
            
            self.contentView.bounds = CGRectMake(0, 0, width, height);
            self.contentView.center = self.view.center;
            
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
            [self layoutSubviews];
        }];
    });
}

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
        _photoScrollView.alwaysBounceHorizontal         = YES;
        _photoScrollView.backgroundColor                = [UIColor clearColor];
        if (self.showStyle == GKPhotoBrowserShowStylePush) {
            if (self.isPopGestureEnabled) {
                _photoScrollView.gk_gestureHandleEnabled = YES;
            }
        }
        
        if (@available(iOS 11.0, *)) {
            _photoScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _photoScrollView;
}

- (GKPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[GKPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _panGesture.direction = GKPanGestureRecognizerDirectionVertical;
    }
    return _panGesture;
}

- (GKPhoto *)currentPhoto {
    if (self.currentIndex >= self.photos.count) {
        return nil;
    }
    return self.photos[self.currentIndex];
}

- (GKPhotoView *)currentPhotoView {
    return [self photoViewForIndex:self.currentIndex];
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        UILabel *countLabel = [UILabel new];
        countLabel.textColor = UIColor.whiteColor;
        countLabel.font = [UIFont systemFontOfSize:16.0f];
        countLabel.textAlignment = NSTextAlignmentCenter;
        countLabel.bounds = CGRectMake(0, 0, 80, 30);
        _countLabel = countLabel;
    }
    return _countLabel;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        UIPageControl *pageControl = [UIPageControl new];
        pageControl.numberOfPages = self.photos.count;
        pageControl.currentPage = self.currentIndex;
        pageControl.hidesForSinglePage = YES;
        pageControl.hidden = YES;
        _pageControl = pageControl;
    }
    return _pageControl;
}

- (UIButton *)saveBtn {
    if (!_saveBtn) {
        UIButton *saveBtn = [UIButton new];
        saveBtn.bounds = CGRectMake(0, 0, 50, 30);
        [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [saveBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        saveBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        saveBtn.layer.cornerRadius = 5;
        saveBtn.layer.masksToBounds = YES;
        saveBtn.layer.borderColor = UIColor.whiteColor.CGColor;
        saveBtn.layer.borderWidth = 1;
        saveBtn.hidden = YES;
        [saveBtn addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _saveBtn = saveBtn;
    }
    return _saveBtn;
}

@end
