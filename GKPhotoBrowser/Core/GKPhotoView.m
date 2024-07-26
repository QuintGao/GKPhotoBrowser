//
//  GKPhotoView.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/23.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKPhotoView.h"
#import "GKPhotoView+Image.h"
#import "GKPhotoView+Video.h"
#import "GKPhotoView+LivePhoto.h"
#import "GKPhotoBrowser.h"

@implementation GKScrollView

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
            if ([self isScrollViewOnTopOrBottom]) {
                return NO;
            }
        }
    }
    return YES;
}

// 判断是否滑动到顶部或底部
- (BOOL)isScrollViewOnTopOrBottom {
    CGPoint translation = [self.panGestureRecognizer translationInView:self];
    if (translation.y > 0 && self.contentOffset.y <= 0) {
        return YES;
    }
    CGFloat maxOffsetY = floor(self.contentSize.height - self.bounds.size.height);
    if (translation.y < 0 && self.contentOffset.y >= maxOffsetY) {
        return YES;
    }
    return NO;
}

@end

@interface GKPhotoView()

@property (nonatomic, strong) GKScrollView   *scrollView;

@property (nonatomic, strong) UIImageView    *imageView;

@property (nonatomic, strong) UIButton       *playBtn;

@property (nonatomic, strong) GKLoadingView  *loadingView;

@property (nonatomic, strong) GKLoadingView  *videoLoadingView;

@property (nonatomic, strong) GKLoadingView  *liveLoadingView;
@property (nonatomic, strong) GKLivePhotoMarkView *liveMarkView;

@property (nonatomic, strong) GKPhoto        *photo;

@property (nonatomic, weak) id<GKWebImageProtocol>    imageProtocol;

@end

@implementation GKPhotoView

- (instancetype)initWithFrame:(CGRect)frame imageProtocol:(nonnull id<GKWebImageProtocol>)imageProtocol {
    if (self = [super initWithFrame:frame]) {
        NSAssert(imageProtocol != nil, @"请设置图片加载类并实现GKWebImageProtocol类");
        _imageProtocol = imageProtocol;
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.imageView];
    }
    return self;
}

- (void)dealloc {
    [self cancelImageLoad];
}

- (void)prepareForReuse {
    self.imageSize = CGSizeZero;
    [self.loadingView stopLoading];
    [self.loadingView removeFromSuperview];
    [self.playBtn removeFromSuperview];
    [self.videoLoadingView stopLoading];
    [self.videoLoadingView removeFromSuperview];
    [self.liveLoadingView stopLoading];
    [self.liveLoadingView removeFromSuperview];
    [self cancelImageLoad];
    if (self.browser.isClearMemoryWhenViewReuse && [self.imageProtocol respondsToSelector:@selector(clearMemoryForURL:)]) {
        [self.imageProtocol clearMemoryForURL:self.photo.url];
    }
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    [self.liveMarkView removeFromSuperview];
    self.liveMarkView = nil;
}

- (void)resetImageView {
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    [self.scrollView addSubview:self.imageView];
}

- (void)setBrowser:(GKPhotoBrowser *)browser {
    _browser = browser;
    
    self.player = browser.player;
    self.livePhoto = browser.livePhoto;
}

- (void)setupPhoto:(GKPhoto *)photo {
    _photo = photo;
    
    [self loadImageWithPhoto:photo isOrigin:NO];
}

- (void)setScrollMaxZoomScale:(CGFloat)scale {
    if (self.scrollView.maximumZoomScale != scale) {
        self.scrollView.maximumZoomScale = scale;
    }
}

- (void)showLoading {
    if (self.photo.isLivePhoto) {
        [self showLiveLoading];
    }else {
        [self showVideoLoading];
    }
}

- (void)hideLoading {
    if (self.photo.isLivePhoto) {
        [self hideLiveLoading];
    }else{
        [self hideVideoLoading];
    }
}

- (void)showFailure:(NSError *)error {
    if (self.photo.isLivePhoto) {
        [self showLiveFailure:error];
    }else {
        [self showVideoFailure:error];
    }
}

- (void)showPlayBtn {
    [self showVideoPlayBtn];
}

- (void)didScrollAppear {
    if (self.photo.isLivePhoto) {
        [self liveDidScrollAppear];
    }else {
        [self videoDidScrollAppear];
    }
}

- (void)willScrollDisappear {
    if (self.photo.isLivePhoto) {
        [self liveWillScrollDisappear];
    }else {
        [self videoWillScrollDisappear];
    }
}

- (void)didScrollDisappear {
    if (self.photo.isLivePhoto) {
        [self liveDidScrollDisappear];
    }else {
        [self videoDidScrollDisappear];
    }
}

- (void)didDismissAppear {
    if (self.photo.isLivePhoto) {
        [self liveDidDismissAppear];
    }else {
        [self videoDidDismissAppear];
    }
}

- (void)willDismissDisappear {
    if (self.photo.isLivePhoto) {
        [self liveWillDismissDisappear];
    }else {
        [self videoWillDismissDisappear];
    }
}

- (void)didDismissDisappear {
    if (self.photo.isLivePhoto) {
        [self liveDidDismissDisappear];
    }else {
        [self videoDidDismissDisappear];
    }
}

- (void)updateFrame {
    if (self.photo.isLivePhoto) {
        [self liveUpdateFrame];
    }else {
        [self videoUpdateFrame];
    }
}

- (void)playAction {
    [self videoPlay];
}

- (void)pauseAction {
    [self videoPause];
}

- (void)resetFrame {
    CGFloat width  = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    BOOL isLandscape = width > height;
    
    if (self.browser.isAdaptiveSafeArea) {
        if (isLandscape) {
            if (self.browser.isFollowSystemRotation) {
                CGFloat safeAreaLeft = GKPhotoBrowserConfigure.gk_safeAreaInsets.left;
                CGFloat safeAreaRight = GKPhotoBrowserConfigure.gk_safeAreaInsets.right;
                width -= (safeAreaLeft + safeAreaRight);
            }else {
                width -= (kSafeTopSpace + kSafeBottomSpace);
            }
        }else {
            height -= (kSafeTopSpace + kSafeBottomSpace);
        }
    }
    self.scrollView.bounds = CGRectMake(0, 0, width, height);
    self.scrollView.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    self.loadingView.frame = self.bounds;
    self.videoLoadingView.frame = self.bounds;
    self.liveLoadingView.frame = self.bounds;
    
    if (self.photo) {
        [self adjustFrame];
    }
}

#pragma mark - 调整frame
- (void)adjustFrame {
    [self adjustImageFrame];
}

- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}

- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated {
    [self.scrollView zoomToRect:rect animated:animated];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.photo.isZooming && scrollView.zoomScale != 1.0f && (scrollView.isDragging || scrollView.isDecelerating)) {
        CGPoint offset = scrollView.contentOffset;
        if (offset.x < 0) offset.x = 0; // 处理快速滑动时的bug
        self.photo.zoomOffset = offset;
    }
    
    if (scrollView.zoomScale == 1.0f) {
        self.photo.offset = scrollView.contentOffset;
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.imageView.center = [self centerOfScrollViewContent:scrollView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    self.photo.zoomScale = scale;
    self.photo.isZooming = scale != 1;
    [self zoomEndedWithScale:scale];
    [self setScrollMaxZoomScale:self.realZoomScale];
}

#pragma mark - Private
- (void)zoomEndedWithScale:(CGFloat)scale {
    if ([self.delegate respondsToSelector:@selector(photoView:zoomEndedWithScale:)]) {
        [self.delegate photoView:self zoomEndedWithScale:scale];
    }
}

- (void)loadFailedWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(photoView:loadFailedWithError:)]) {
        [self.delegate photoView:self loadFailedWithError:error];
    }
}

#pragma mark - 懒加载
- (GKScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView                      = [GKScrollView new];
        _scrollView.backgroundColor      = [UIColor clearColor];
        _scrollView.delegate             = self;
        _scrollView.clipsToBounds        = NO;
        _scrollView.multipleTouchEnabled = YES; // 多点触摸开启
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _scrollView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [_imageProtocol.imageViewClass new];
        _imageView.frame = self.scrollView.bounds;
    }
    return _imageView;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] init];
        [_playBtn setImage:self.browser.videoPlayImage ?: GKPhotoBrowserImage(@"gk_video_play") forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
        _playBtn.hidden = YES;
        [_playBtn sizeToFit];
        _playBtn.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    }
    return _playBtn;
}

- (GKLoadingView *)loadingView {
    if (!_loadingView) {
        _loadingView = [GKLoadingView loadingViewWithFrame:self.bounds style:(GKLoadingStyle)self.browser.loadStyle];
        _loadingView.failStyle   = self.browser.failStyle;
        _loadingView.lineWidth   = 3;
        _loadingView.radius      = 12;
        _loadingView.bgColor     = [UIColor blackColor];
        _loadingView.strokeColor = [UIColor whiteColor];
    }
    return _loadingView;
}

- (GKLoadingView *)videoLoadingView {
    if (!_videoLoadingView) {
        _videoLoadingView = [GKLoadingView loadingViewWithFrame:self.bounds style:(GKLoadingStyle)self.browser.videoLoadStyle];
        _videoLoadingView.failStyle = self.browser.videoFailStyle;
        _videoLoadingView.lineWidth = 3;
        _videoLoadingView.radius = 12;
        _videoLoadingView.bgColor = UIColor.blackColor;
        _videoLoadingView.strokeColor = UIColor.whiteColor;
    }
    return _videoLoadingView;
}

- (GKLoadingView *)liveLoadingView {
    if (!_liveLoadingView) {
        _liveLoadingView = [GKLoadingView loadingViewWithFrame:self.bounds style:(GKLoadingStyle)self.browser.liveLoadStyle];
        _liveLoadingView.radius = 30;
        _liveLoadingView.lineWidth = 1;
        _liveLoadingView.bgColor = [UIColor whiteColor];
        _liveLoadingView.strokeColor = [UIColor whiteColor];
    }
    return _liveLoadingView;
}

- (UIView *)liveMarkView {
    if (!_liveMarkView) {
        _liveMarkView = [[GKLivePhotoMarkView alloc] init];
        _liveMarkView.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.5];
        _liveMarkView.hidden = YES;
        _liveMarkView.layer.cornerRadius = 2;
        _liveMarkView.layer.masksToBounds = YES;
    }
    return _liveMarkView;
}

@end
