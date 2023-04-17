//
//  GKPhotoBrowser.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/20.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKPhotoBrowser.h"
#import "GKPhotoGestureHandler.h"
#import "GKPhotoRotationHandler.h"

#if __has_include(<GKYYWebImageManager.h>)
#import "GKYYWebImageManager.h"
#elif __has_include(<GKSDWebImageManager.h>)
#import "GKSDWebImageManager.h"
#endif
#if __has_include(<GKAVPlayerManager.h>)
#import "GKAVPlayerManager.h"
#endif

#import "GKProgressView.h"

static Class imageManagerClass = nil;
static Class videoManagerClass = nil;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface GKPhotoBrowser()<UIScrollViewDelegate, GKPhotoGestureDelegate, GKPhotoRotationDelegate>

@property (nonatomic, strong) UIView         *contentView;

@property (nonatomic, strong) UIScrollView   *photoScrollView;

@property (nonatomic, strong) GKProgressView *progressView;

@property (nonatomic, strong) NSArray        *photos;
@property (nonatomic, assign) NSInteger      currentIndex;
@property (nonatomic, strong) GKPhotoView    *curPhotoView;

@property (nonatomic, strong) NSMutableArray *visiblePhotoViews;
@property (nonatomic, strong) NSMutableSet   *reusablePhotoViews;

@property (nonatomic, strong) NSArray *coverViews;
@property (nonatomic, copy) layoutBlock layoutBlock;

// 基础处理类
@property (nonatomic, strong) GKPhotoBrowserHandler *handler;

// 手势处理
@property (nonatomic, strong) GKPhotoGestureHandler *gestureHandler;

// 旋转处理
@property (nonatomic, strong) GKPhotoRotationHandler *rotationHandler;

// 图片处理
@property (nonatomic, strong) id<GKWebImageProtocol> imageProtocol;

// 播放器处理
@property (nonatomic, strong) id<GKVideoPlayerProtocol> player;

@end

@implementation GKPhotoBrowser

+ (instancetype)photoBrowserWithPhotos:(NSArray<GKPhoto *> *)photos currentIndex:(NSInteger)currentIndex {
    return [[self alloc] initWithPhotos:photos currentIndex:currentIndex];
}

- (instancetype)initWithPhotos:(NSArray<GKPhoto *> *)photos currentIndex:(NSInteger)currentIndex {
    if (self = [super init]) {
        self.photos       = photos;
        self.currentIndex = currentIndex;
        self.isStatusBarShow         = NO;
        self.isHideSourceView        = YES;
        self.statusBarStyle          = UIStatusBarStyleLightContent;
        self.isFullWidthForLandScape = YES;
        self.maxZoomScale            = kMaxZoomScale;
        self.doubleZoomScale         = self.maxZoomScale;
        self.animDuration            = kAnimationDuration;
        self.photoViewPadding        = kPhotoViewPadding;
        self.hidesSavedBtn           = YES;
        self.showPlayImage           = YES;
        self.isVideoReplay           = YES;
        
        _visiblePhotoViews  = [NSMutableArray new];
        _reusablePhotoViews = [NSMutableSet new];
        
        imageManagerClass = NSClassFromString(@"GKSDWebImageManager");
        if (!imageManagerClass) {
            imageManagerClass = NSClassFromString(@"GKYYWebImageManager");
        }
        if (imageManagerClass) {
            [self setupWebImageProtocol:[imageManagerClass new]];
        }
        videoManagerClass = NSClassFromString(@"GKAVPlayerManager");
        if (videoManagerClass) {
            [self setupVideoPlayerProtocol:[videoManagerClass new]];
        }
    }
    return self;
}

- (void)setupWebImageProtocol:(id<GKWebImageProtocol>)protocol {
    self.imageProtocol = protocol;
}

- (void)setupVideoPlayerProtocol:(id<GKVideoPlayerProtocol>)protocol {
    self.player = protocol;
    self.progressView.player = protocol;
    
    __weak __typeof(self) weakSelf = self;
    self.player.playerStatusChange = ^(id<GKVideoPlayerProtocol> _Nonnull mgr, GKVideoPlayerStatus status) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (!self || !self.player) return;
        if (!self.curPhotoView.photo.isVideo) return;
        if (![self.curPhoto.videoUrl isEqual:mgr.assetURL]) return;
        switch (status) {
            case GKVideoPlayerStatusPrepared:
            case GKVideoPlayerStatusBuffering: {
                [self.curPhotoView showLoading];
            } break;
            case GKVideoPlayerStatusPlaying: {
                [self.curPhotoView hideLoading];
            } break;
            case GKVideoPlayerStatusEnded: {
                if (self.isVideoReplay) {
                    [self.player gk_replay];
                } else {
                    [self.curPhotoView showPlayBtn];
                }
            } break;
            case GKVideoPlayerStatusFailed: {
                [self.curPhotoView showFailure];
            } break;
                
            default:
                break;
        }
    };
    
    self.player.playerPlayTimeChange = ^(id<GKVideoPlayerProtocol>  _Nonnull mgr, NSTimeInterval currentTime, NSTimeInterval totalTime) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (!self || !self.player) return;
        [self.progressView updateCurrentTime:currentTime totalTime:totalTime];
    };
    
    self.player.playerGetVideoSize = ^(id<GKVideoPlayerProtocol>  _Nonnull mgr, CGSize size) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (!self || !self.player) return;
        [self.photos enumerateObjectsUsingBlock:^(GKPhoto *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.videoUrl isEqual:mgr.assetURL]) {
                obj.videoSize = size;
                *stop = YES;
            }
        }];
        if ([self.curPhoto.videoUrl isEqual:mgr.assetURL]) {
            [self.curPhotoView adjustFrame];
        }
    };
}

- (instancetype)init {
    NSAssert(NO, @"Use initWithPhotos:currentIndex: instead.");
    return nil;
}

- (void)dealloc {
    [self.rotationHandler delDeviceOrientationObserver];
}

- (void)loadView {
    if (self.handler.captureImage) {
        self.view = [[UIImageView alloc] initWithImage:self.handler.captureImage];
    }else {
        self.view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    }
    self.view.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置UI
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.handler.isAppeared) return;
    self.handler.isAppeared = YES;
    
    GKPhoto *photo          = [self currentPhoto];
    GKPhotoView *photoView  = [self currentPhotoView];
    self.curPhotoView = photoView;
    
    if ([_imageProtocol imageFromMemoryForURL:photo.url] || photo.image) {
        [photoView setupPhoto:photo];
    }else {
        photoView.imageView.image = photo.placeholderImage ? photo.placeholderImage : photo.sourceImageView.image;
        [photoView adjustFrame];
    }
    
    [self.handler browserShow];
    
    // 手势和监听
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addGestureAndObserver];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    if ([self.imageProtocol respondsToSelector:@selector(clearMemory)]) {
        [self.imageProtocol clearMemory];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.curPhotoView didDismissDisappear];
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didDisappearAtIndex:)]) {
        [self.delegate photoBrowser:self didDisappearAtIndex:self.currentIndex];
    }
}

- (void)setupUI {
    if (!self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:YES];
    }
    
    if (self.showStyle == GKPhotoBrowserShowStylePush) {
        _containerView = [[UIView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_containerView];
    }
    
    self.contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.contentView.center = self.view.center;
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.contentView];
    
    [self.contentView addSubview:self.photoScrollView];
    
    [self setupCoverViews];
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

- (void)addGestureAndObserver {
    [self.gestureHandler addGestureRecognizer];
    
    if (self.isFollowSystemRotation) return;
    
    if (!self.isScreenRotateDisabled) {
        [self.rotationHandler addDeviceOrientationObserver];
    }
}

#pragma mark - Setter
- (void)setIsStatusBarShow:(BOOL)isStatusBarShow {
    _isStatusBarShow = isStatusBarShow;
    
    if (self.handler.statusBarAppearance) {
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self prefersStatusBarHidden];
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        }
    }else {
        [[UIApplication sharedApplication] setStatusBarHidden:!isStatusBarShow];
    }
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    _statusBarStyle = statusBarStyle;
    
    if (self.handler.statusBarAppearance) {
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self preferredStatusBarStyle];
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        }
    }else {
        [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle];
    }
}

- (void)setIsScreenRotateDisabled:(BOOL)isScreenRotateDisabled {
    _isScreenRotateDisabled = isScreenRotateDisabled;
    
    if (isScreenRotateDisabled) {
        [self.rotationHandler delDeviceOrientationObserver];
    }else {
        [self.rotationHandler addDeviceOrientationObserver];
    }
}

- (void)setDoubleZoomScale:(CGFloat)doubleZoomScale {
    if (doubleZoomScale > self.maxZoomScale) {
        _doubleZoomScale = self.maxZoomScale;
    }else {
        _doubleZoomScale = doubleZoomScale;
    }
}

#pragma mark - Getter
- (BOOL)isLandscape {
    return self.rotationHandler.isLandscape;
}

- (UIDeviceOrientation)currentOrientation {
    return self.rotationHandler.currentOrientation;
}

- (GKPhoto *)curPhoto {
    return [self currentPhoto];
}

- (void)updateViewIndex {
    self.countLabel.text = [NSString stringWithFormat:@"%zd/%zd", (long)(self.currentIndex + 1), (long)self.photos.count];
    self.pageControl.currentPage = self.currentIndex;
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

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

#pragma mark - Public Methods
- (void)setupCoverViews:(NSArray *)coverViews layoutBlock:(layoutBlock)layoutBlock {
    self.coverViews  = coverViews;
    self.layoutBlock = layoutBlock;
}

- (void)showFromVC:(UIViewController *)vc {
    [self.handler showFromVC:vc];
}

- (void)dismiss {
    [self.handler browserDismiss];
}

- (void)selectedPhotoWithIndex:(NSInteger)index animated:(BOOL)animated{
    if (index < 0 || index >= self.photos.count) return;
    if (self.currentIndex == index) return;
    
    [self.curPhotoView willScrollDisappear];
    self.handler.isAnimated = animated;
    CGPoint offset = CGPointMake(self.photoScrollView.frame.size.width * index, 0);
    [self.photoScrollView setContentOffset:offset animated:animated];
    if (!animated) {
        [self updateCurrentPhotoView];
    }
}

- (void)removePhotoAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.photos.count) return;
    
    if (self.currentIndex == index) {
        [self.curPhotoView didDismissDisappear];
    }
    
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
    [self updateCurrentPhotoView];
}

- (void)loadCurrentPhotoImage {
    [self.curPhotoView loadOriginImage];
}

#pragma mark - Private Methods
- (void)setupCoverViews {
    if (self.coverViews) {
        [self.coverViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.contentView addSubview:obj];
        }];
    }else {
        [self.contentView addSubview:self.countLabel];
        [self.contentView addSubview:self.pageControl];
        [self.contentView addSubview:self.saveBtn];
        [self.contentView addSubview:self.progressView];
        
        self.pageControl.numberOfPages = self.photos.count;
        CGSize size = [self.pageControl sizeForNumberOfPages:self.photos.count];
        self.pageControl.bounds = CGRectMake(0, 0, size.width, size.height);
        [self updateViewIndex];
    }
}

- (void)updateCoverViews {
    if (self.coverViews) return;
    GKPhoto *photo = [self currentPhoto];
    if (photo.isVideo) {
        self.progressView.hidden = self.hidesVideoSlider;
        self.countLabel.hidden = YES;
        self.pageControl.hidden = YES;
        self.saveBtn.hidden = YES;
    }else {
        self.progressView.hidden = YES;
        
        if (self.hidesCountLabel) {
            self.countLabel.hidden = YES;
        }else {
            self.countLabel.hidden = self.photos.count <= 1;
        }
        
        if (self.hidesPageControl) {
            self.pageControl.hidden = YES;
        }else {
            if (self.pageControl.hidesForSinglePage) {
                self.pageControl.hidden = self.photos.count <= 1;
            }
        }
        self.saveBtn.hidden = self.hidesSavedBtn;
    }
}

- (void)saveBtnClick:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(photoBrowser:onSaveBtnClick:image:)]) {
        [self.delegate photoBrowser:self onSaveBtnClick:self.currentIndex image:self.curPhotoView.imageView.image];
    }
}

- (void)photoViewDidSelected {
    self.curPhotoView = [self currentPhotoView];
    [self.curPhotoView didScrollAppear];
    
    [self updateCoverViews];
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didSelectAtIndex:)]) {
        [self.delegate photoBrowser:self didSelectAtIndex:self.currentIndex];
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
            photoView.player          = self.player;
            photoView.loadStyle       = self.loadStyle;
            photoView.originLoadStyle = self.originLoadStyle;
            photoView.failStyle       = self.failStyle;
            photoView.isFullWidthForLandScape = self.isFullWidthForLandScape;
            photoView.isAdaptiveSafeArea = self.isAdaptiveSafeArea;
            photoView.failureText     = self.failureText;
            photoView.failureImage    = self.failureImage;
            photoView.maxZoomScale    = self.maxZoomScale;
            photoView.doubleZoomScale = self.doubleZoomScale;
            photoView.showPlayImage   = self.showPlayImage;
            photoView.videoPlayImage  = self.videoPlayImage;
            
            __typeof(self) __weak weakSelf = self;
            __typeof(photoView) __weak weakPhotoView = photoView;
            photoView.zoomEnded = ^(GKPhotoView * _Nonnull curPhotoView, CGFloat scale) {
                if (curPhotoView.tag == weakPhotoView.tag) {
                    if (scale == 1.0f) {
                        weakPhotoView.scrollView.clipsToBounds = YES;
                        [weakSelf.gestureHandler addPanGesture:NO];
                    }else {
                        weakPhotoView.scrollView.clipsToBounds = YES;
                        [weakSelf.gestureHandler removePanGesture];
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
            CGFloat w = photoScrollW - self.photoViewPadding * 2;
            CGFloat h = photoScrollH;
            CGFloat x = self.photoViewPadding + i * (self.photoViewPadding * 2 + w);
            CGFloat y = 0;
            
            photoView.frame = CGRectMake(x, y, w, h);
            photoView.tag   = i;
            [self.photoScrollView addSubview:photoView];
            [_visiblePhotoViews addObject:photoView];
            
            [photoView resetFrame];
        }
        
        if (photoView.photo == nil && self.handler.isShow) {
            [photoView setupPhoto:self.photos[i]];
        }
    }
    
    // 更换photoView
    if (index != self.currentIndex && self.handler.isShow && (index >= 0 && index < self.photos.count)) {
        self.currentIndex = index;
        
        GKPhotoView *photoView = [self currentPhotoView];
        self.curPhotoView = photoView;
        
        GKPhoto *photo = [self currentPhoto];
        if (photo.failed) {
            [photoView setupPhoto:photo];
        }
        
        if (photoView.scrollView.zoomScale != 1.0) {
            [self.gestureHandler removePanGesture];
        }else {
            [self.gestureHandler addPanGesture:NO];
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

- (void)updateCurrentPhotoView {
    [self photoViewDidSelected];
    
    [self.visiblePhotoViews enumerateObjectsUsingBlock:^(GKPhotoView *photoView, NSUInteger idx, BOOL * _Nonnull stop) {
        if (photoView != self.curPhotoView) {
            [photoView didScrollDisappear];
        }
    }];
    
    if (self.isResumePhotoZoom) {
        [self.visiblePhotoViews enumerateObjectsUsingBlock:^(GKPhotoView *photoView, NSUInteger idx, BOOL * _Nonnull stop) {
            GKPhoto *photo = self.photos[idx];
            photo.isZooming = NO;
            
            [photoView.scrollView setZoomScale:1.0 animated:NO];
        }];
    }
    
    if ([self currentPhotoView].scrollView.zoomScale > 1.0) {
        [self.gestureHandler removePanGesture];
    }else {
        [self.gestureHandler addPanGesture:NO];
    }
}

#pragma mark - 代理
#pragma mark - GKPhotoGestureDelegate
- (void)browserWillDisappear {
    [self.curPhotoView willDismissDisappear];
    if (self.curPhoto.isVideo) {
        self.progressView.hidden = YES;
    }
}

- (void)browserCancelDisappear {
    [self.curPhotoView didDismissAppear];
    [self updateCoverViews];
}

- (void)browserDidDisappear {
    if (self.curPhoto.isVideo) {
        self.progressView.hidden = YES;
    }
}

#pragma mark - GKPhotoRotationDelegate
- (void)willRotation:(BOOL)isLandscape {
    if (isLandscape) {
        [self.gestureHandler removePanGesture];
    }else {
        [self.gestureHandler addPanGesture:NO];
    }
}

- (void)didRotation:(BOOL)isLandscape {
    if (isLandscape) {
        // 横屏时隐藏状态栏，这里为了解决一个bug，iPhone X中横屏状态栏隐藏后不能再次显示，暂时的解决办法是这样，如果有更好的方法可随时修改
        if (self.isStatusBarShow) { // 状态栏是显示状态
            self.gestureHandler.isStatusBarShowing = self.isStatusBarShow;  // 记录状态栏显隐状态
            self.isStatusBarShow = NO;
        }
    }else {
        // 切换到竖屏后，如果原来状态栏是显示状态，就再次显示状态栏
        if (self.gestureHandler.isStatusBarShowing) {
            self.isStatusBarShow    = YES;
            self.gestureHandler.isStatusBarShowing = NO;
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.curPhotoView willScrollDisappear];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.rotationHandler.isRotation) return;
    if (self.handler.isRecover) return;
    
    [self updateReusableViews];
    
    [self setupPhotoViews];
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:scrollViewDidScroll:)]) {
        [self.delegate photoBrowser:self scrollViewDidScroll:scrollView];
    }
}

// scrollView结束滚动时调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateCurrentPhotoView];
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:scrollViewDidEndDecelerating:)]) {
        [self.delegate photoBrowser:self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.delegate respondsToSelector:@selector(photoBrowser:scrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate photoBrowser:self scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.handler.isAnimated) {
        self.handler.isAnimated = NO;
        [self updateCurrentPhotoView];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.rotationHandler handleSystemRotation];
}

#pragma mark - 懒加载
- (UIScrollView *)photoScrollView {
    if (!_photoScrollView) {
        CGRect frame = self.view.bounds;
        frame.origin.x   -= self.photoViewPadding;
        frame.size.width += (2 * self.photoViewPadding);
        _photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
        _photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _photoScrollView.pagingEnabled  = YES;
        _photoScrollView.delegate       = self;
        _photoScrollView.showsVerticalScrollIndicator   = NO;
        _photoScrollView.showsHorizontalScrollIndicator = NO;
        _photoScrollView.alwaysBounceHorizontal         = YES;
        _photoScrollView.backgroundColor                = [UIColor clearColor];
        _photoScrollView.clipsToBounds                  = NO;
        if (self.showStyle == GKPhotoBrowserShowStylePush) {
            if (self.isPopGestureEnabled) {
                _photoScrollView.gk_gestureHandleEnabled = YES;
            }
        }
        
        if (@available(iOS 11.0, *)) {
            _photoScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _photoScrollView;
}

- (GKPhotoBrowserHandler *)handler {
    if (!_handler) {
        _handler = [[GKPhotoBrowserHandler alloc] init];
        _handler.browser = self;
    }
    return _handler;
}

- (GKPhotoGestureHandler *)gestureHandler {
    if (!_gestureHandler) {
        _gestureHandler = [[GKPhotoGestureHandler alloc] init];
        _gestureHandler.delegate = self;
        _gestureHandler.browser = self;
    }
    return _gestureHandler;
}

- (GKPhotoRotationHandler *)rotationHandler {
    if (!_rotationHandler) {
        _rotationHandler = [[GKPhotoRotationHandler alloc] init];
        _rotationHandler.delegate = self;
        _rotationHandler.browser = self;
    }
    return _rotationHandler;
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
        countLabel.hidden = YES;
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
        if (@available(iOS 14.0, *)) {
            pageControl.backgroundStyle = UIPageControlBackgroundStyleMinimal;
        }
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

- (GKProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[GKProgressView alloc] init];
        _progressView.hidden = YES;
    }
    return _progressView;
}

@end

@implementation GKPhotoBrowser (Private)

// 更新布局
- (void)layoutSubviews {
    CGRect frame = self.contentView.bounds;
    frame.origin.x   -= self.photoViewPadding;
    frame.size.width += self.photoViewPadding * 2;
    
    CGFloat photoScrollW = frame.size.width;
    CGFloat photoScrollH = frame.size.height;
    CGFloat pointX = photoScrollW * 0.5 - self.photoViewPadding;
    
    self.photoScrollView.frame  = frame;
    self.photoScrollView.center = CGPointMake(pointX, photoScrollH * 0.5);
    self.photoScrollView.contentOffset = CGPointMake(self.currentIndex * photoScrollW, 0);
    self.photoScrollView.contentSize = CGSizeMake(photoScrollW * self.photos.count, 0);
    
    // 调整所有显示的photoView的frame
    CGFloat w = photoScrollW - self.photoViewPadding * 2;
    CGFloat h = photoScrollH;
    __block CGFloat x = 0;
    CGFloat y = 0;
    
    [_visiblePhotoViews enumerateObjectsUsingBlock:^(GKPhotoView *photoView, NSUInteger idx, BOOL * _Nonnull stop) {
        x = self.photoViewPadding + photoView.tag * (self.photoViewPadding * 2 + w);
        photoView.frame = CGRectMake(x, y, w, h);
        [photoView resetFrame];
    }];
    
    if (self.coverViews) {
        !self.layoutBlock ? : self.layoutBlock(self, self.contentView.bounds);
    }else {
        CGFloat width = self.contentView.bounds.size.width;
        CGFloat height = self.contentView.bounds.size.height;
        
        CGFloat centerX = width * 0.5f;
        
        self.countLabel.center = CGPointMake(centerX, (KIsiPhoneX && !self.rotationHandler.isLandscape) ? (kSafeTopSpace + 10) : 30);
        self.progressView.bounds = CGRectMake(0, 0, width - 60, 20);
        
        CGFloat centerY = 0;
        if (self.rotationHandler.isLandscape) {
            centerY = height - 20;
        }else {
            centerY = height - 20 - (self.isAdaptiveSafeArea ? kSafeBottomSpace : 0);
        }
        self.pageControl.center = CGPointMake(centerX, centerY);
        self.saveBtn.center = CGPointMake(width - 60, centerY);
        self.progressView.center = CGPointMake(centerX, centerY);
    }
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:willLayoutSubViews:)]) {
        [self.delegate photoBrowser:self willLayoutSubViews:self.currentIndex];
    }
}

- (void)browserFirstAppear {
    GKPhotoView *photoView = self.curPhotoView;
    GKPhoto *photo = self.curPhoto;
    [photoView setupPhoto:photo];
    
    // 更新首次显示的内容
    [self photoViewDidSelected];
    
    [self.rotationHandler deviceOrientationDidChange];
}

- (void)removeRotationObserver {
    [self.rotationHandler delDeviceOrientationObserver];
}

@end

#pragma clang diagnostic pop
