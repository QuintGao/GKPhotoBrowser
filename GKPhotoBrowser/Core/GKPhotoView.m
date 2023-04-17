//
//  GKPhotoView.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/23.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKPhotoView.h"

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

@property (nonatomic, strong, readwrite) GKScrollView   *scrollView;

@property (nonatomic, strong, readwrite) UIImageView    *imageView;

@property (nonatomic, strong, readwrite) UIButton       *playBtn;

@property (nonatomic, strong, readwrite) GKLoadingView  *loadingView;

@property (nonatomic, strong, readwrite) GKLoadingView  *videoLoadingView;

@property (nonatomic, strong, readwrite) GKPhoto        *photo;

@property (nonatomic, strong) id<GKWebImageProtocol>    imageProtocol;

@property (nonatomic, assign) CGFloat realZoomScale;

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

- (void)setupPhoto:(GKPhoto *)photo {
    _photo = photo;
    
    [self loadImageWithPhoto:photo isOrigin:NO];
}

- (void)setScrollMaxZoomScale:(CGFloat)scale {
    if (self.scrollView.maximumZoomScale != scale) {
        self.scrollView.maximumZoomScale = scale;
    }
}

- (void)loadOriginImage {
    // 恢复数据
    self.photo.image    = nil;
    self.photo.finished = NO;
    self.photo.failed   = NO;
    
    [self loadImageWithPhoto:self.photo isOrigin:YES];
}

- (void)showLoading {
    if (!self.photo.isVideo) return;
    if (!self.player) return;
    if (self.player.assetURL != self.photo.videoUrl) return;
    self.videoLoadingView.frame = self.bounds;
    [self addSubview:self.videoLoadingView];
    [self.videoLoadingView startLoading];
}

- (void)hideLoading {
    if (!self.photo.isVideo) return;
    if (!self.player) return;
    if (self.player.assetURL != self.photo.videoUrl) return;
    [self.videoLoadingView stopLoading];
}

- (void)showFailure {
    if (!self.photo.isVideo) return;
    if (!self.player) return;
    if (self.player.assetURL != self.photo.videoUrl) return;
    [self.videoLoadingView showFailure];
}

- (void)showPlayBtn {
    if (!self.photo.isVideo) return;
    if (!self.player) return;
    if (self.player.assetURL != self.photo.videoUrl) return;
    if (!self.showPlayImage) return;
    self.playBtn.hidden = NO;
}

- (void)didScrollAppear {
    if (!self.photo.isVideo) return;
    if (!self.player) return;
    
    // 如果没有设置，则设置播放内容
    if (!self.player.assetURL || self.player.assetURL != self.photo.videoUrl) {
        __weak __typeof(self) weakSelf = self;
        [self.photo getVideo:^(NSURL * _Nonnull url) {
            __strong __typeof(weakSelf) self = weakSelf;
            if (!self) return;
            if (!self.player) return;
            self.player.coverImage = self.imageView.image;
            self.player.assetURL = url;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.player gk_prepareToPlay];
                [self updateFrame];
                [self.player gk_play];
            });
        }];
    }else {
        [self.player gk_play];
    }
    
    if (!self.showPlayImage) return;
    if (!self.playBtn.superview) {
        [self addSubview:self.playBtn];
    }
    self.playBtn.hidden = YES;
}

- (void)willScrollDisappear {
    if (!self.photo.isVideo) return;
    if (!self.player) return;
    [self.player gk_pause];
}

- (void)didScrollDisappear {
    if (!self.photo.isVideo) return;
    if (!self.player) return;
    if (!self.showPlayImage) return;
    self.playBtn.hidden = NO;
}

- (void)didDismissAppear {
    if (!self.photo.isVideo) return;
    if (!self.player) return;
    if (self.player.status == GKVideoPlayerStatusEnded) {
        [self.player gk_replay];
    }else {
        [self.player gk_play];
    }
    if (!self.showPlayImage) return;
    self.playBtn.hidden = YES;
}

- (void)willDismissDisappear {
    if (!self.photo.isVideo) return;
    if (!self.player) return;
    if (self.player.status == GKVideoPlayerStatusEnded) {
        if (!self.showPlayImage) return;
        self.playBtn.hidden = YES;
    }else {
        [self.player gk_pause];
    }
}

- (void)didDismissDisappear {
    if (!self.photo.isVideo) return;
    if (!self.player) return;
    [self.player gk_stop];
}

- (void)updateFrame {
    if (!self.photo.isVideo) return;
    if (!self.player) return;
    if (self.player.assetURL != self.photo.videoUrl) return;
    if (self.player.videoPlayView.superview != self.imageView) {
        [self.imageView addSubview:self.player.videoPlayView];
    }
    [self.player gk_updateFrame:self.imageView.bounds];
}

#pragma mark - 加载图片
- (void)loadImageWithPhoto:(GKPhoto *)photo isOrigin:(BOOL)isOrigin {
    // 取消以前的加载
    [_imageProtocol cancelImageRequestWithImageView:self.imageView];
    
    if (photo) {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
        [self.scrollView addSubview:self.imageView];
        if (!photo.isVideo && self.showPlayImage) {
            self.playBtn.hidden = YES;
        }
        
        // 每次设置数据时，恢复缩放
        [self.scrollView setZoomScale:1.0 animated:NO];
        
        // 优先加载缓存图片
        UIImage *placeholderImage = nil;
        UIImage *image = [_imageProtocol imageFromMemoryForURL:photo.url];
        if (image) {
            photo.finished = YES;
            placeholderImage = image;
        }
        
        UIImage *originImage = [_imageProtocol imageFromMemoryForURL:photo.originUrl];
        if (originImage) {
            photo.originFinished = YES;
            placeholderImage = originImage;
            isOrigin = YES;
        }
        
        // 如果没有就加载sourceImageView的image
        if (!placeholderImage) {
            placeholderImage = photo.sourceImageView.image;
        }
        // 如果还没有就加载传入的站位图
        if (!placeholderImage) {
            placeholderImage = photo.placeholderImage;
        }
        
        self.imageView.image          = placeholderImage;
        self.imageView.contentMode    = photo.sourceImageView.contentMode;
        self.scrollView.scrollEnabled = NO;
        
        if (photo.image) {
            [self setupImageView:photo.image];
            return;
        }else if (photo.imageAsset) {
            [self addSubview:self.loadingView];
            if (!photo.failed) {
                [self.loadingView hideFailure];
            }
            [self adjustFrame];
            
            if (!photo.failed && !placeholderImage) {
                if (isOrigin && self.originLoadStyle != GKPhotoBrowserLoadStyleCustom) {
                    [self.loadingView startLoading];
                }else if (!isOrigin && self.loadStyle != GKPhotoBrowserLoadStyleCustom) {
                    [self.loadingView startLoading];
                }
            }
            
            __weak __typeof(self) weakSelf = self;
            [photo getImage:^(NSData * _Nonnull data, UIImage * _Nonnull image) {
                __strong __typeof(weakSelf) self = weakSelf;
                UIImage *newImage = nil;
                if (data) {
                    if ([self.imageProtocol respondsToSelector:@selector(imageWithData:)]) {
                        newImage = [self.imageProtocol imageWithData:data];
                    }
                    if (!newImage) {
                        newImage = [UIImage imageWithData:data];
                    }
                }else {
                    newImage = image;
                }
                [self setupImageView:image];
            }];
            return;
        }
        
        // 进度条
        [self addSubview:self.loadingView];
        if (!photo.failed) {
            [self.loadingView hideFailure];
        }
        
        if (self.imageView.image) {
            [self adjustFrame];
        }else if (!CGRectEqualToRect(photo.sourceFrame, CGRectZero)) {
            [self adjustFrame];
        }
        
        NSURL *url = nil;
        if (photo.originFinished) {
            url = photo.originUrl;
        }else {
            url = isOrigin ? photo.originUrl : photo.url;
        }
        
        if (url.absoluteString.length > 0) {
            if (!photo.failed && !placeholderImage) {
                if (isOrigin && self.originLoadStyle != GKPhotoBrowserLoadStyleCustom) {
                    [self.loadingView startLoading];
                }else if (!isOrigin && self.loadStyle != GKPhotoBrowserLoadStyleCustom) {
                    [self.loadingView startLoading];
                }
            }
            
            __weak __typeof(self) weakSelf = self;
            GKWebImageProgressBlock progressBlock = ^(NSInteger receivedSize, NSInteger expectedSize) {
                __strong __typeof(weakSelf) self = weakSelf;
                if (expectedSize <= 0) return;
                float progress = (float)receivedSize / expectedSize;
                if (progress <= 0) progress = 0;
                
                // 图片加载中，回调进度
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (isOrigin && self.originLoadStyle == GKLoadingStyleCustom) {
                        !self.loadProgressBlock ? : self.loadProgressBlock(self, progress, YES);
                    }else if (!isOrigin && self.loadStyle == GKLoadingStyleCustom) {
                        !self.loadProgressBlock ? : self.loadProgressBlock(self, progress, NO);
                    }else if (self.loadStyle == GKLoadingStyleDeterminate || self.originLoadStyle == GKLoadingStyleDeterminate) {
                        self.loadingView.progress = progress;
                    }
                });
            };
            
            GKWebImageCompletionBlock completionBlock = ^(UIImage *image, NSURL *url, BOOL finished, NSError *error) {
                __strong __typeof(weakSelf) self = weakSelf;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        photo.failed = YES;
                        [self.loadingView stopLoading];
                        
                        if ([photo.url.absoluteString isEqualToString:url.absoluteString]) {
                            if (self.failStyle == GKPhotoBrowserFailStyleCustom) {
                                !self.loadFailed ? : self.loadFailed(self);
                            }else {
                                [self addSubview:self.loadingView];
                                [self.loadingView showFailure];
                            }
                        }
                    }else {
                        photo.finished = YES;
                        if (isOrigin) {
                            photo.originFinished = YES;
                        }
                        
                        // 图片加载完成，回调进度
                        if (isOrigin && self.originLoadStyle == GKLoadingStyleCustom) {
                            !self.loadProgressBlock ? : self.loadProgressBlock(self, 1.0f, YES);
                        }else if (!isOrigin && self.loadStyle == GKLoadingStyleCustom) {
                            !self.loadProgressBlock ? : self.loadProgressBlock(self, 1.0f, NO);
                        }
                        
                        self.scrollView.scrollEnabled = YES;
                        [self.loadingView stopLoading];
                    }
                    if (!isOrigin) {
                        [self adjustFrame];
                    }
                    if (self.imageView.image && CGSizeEqualToSize(self.imageView.frame.size, CGSizeZero)) {
                        [self adjustFrame];
                    }
                });
            };
            
            [_imageProtocol setImageForImageView:self.imageView url:url placeholderImage:placeholderImage progress:progressBlock completion:completionBlock];
        }else {
            if (self.imageView.image) {
                photo.finished = YES;
                self.scrollView.scrollEnabled = YES;
                [self.loadingView stopLoading];
            }
            [self adjustFrame];
        }
    }else {
        self.imageView.image = nil;
        [self adjustFrame];
    }
}

- (void)resetFrame {
    CGFloat width  = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    BOOL isLandscape = width > height;
    
    if (self.isAdaptiveSafeArea) {
        if (isLandscape) {
            width  -= (kSafeTopSpace + kSafeBottomSpace);
        }else {
            height -= (kSafeTopSpace + kSafeBottomSpace);
        }
    }
    self.scrollView.bounds = CGRectMake(0, 0, width, height);
    self.scrollView.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    self.loadingView.frame = self.bounds;
    self.videoLoadingView.frame = self.bounds;
    
    if (self.photo) {
        [self adjustFrame];
    }
}

- (void)setupImageView:(UIImage *)image {
    self.photo.finished = YES;
    self.imageView.image = image;
    self.scrollView.scrollEnabled = YES;
    [self.loadingView stopLoading];
    [self.loadingView hideFailure];
    [self.loadingView removeFromSuperview];
    [self adjustFrame];
}

#pragma mark - 调整frame
- (void)adjustFrame {
    CGRect frame = self.scrollView.frame;
    if (frame.size.width == 0 || frame.size.height == 0) return;
    
    if (self.imageView.image) {
        CGSize imageSize = self.imageView.image.size;
        // 视频处理，保证视频可以完全显示
        if (self.photo.isVideo && !CGSizeEqualToSize(self.photo.videoSize, CGSizeZero)) {
            imageSize = self.photo.videoSize;
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
        
        if (imageSize.width == 0) imageSize.width = self.scrollView.frame.size.width;
        if (imageSize.height == 0) imageSize.height = self.scrollView.frame.size.height;
        
        CGRect imageF = (CGRect){{0, 0}, imageSize};
        
        // 图片的宽度 = 屏幕的宽度
        CGFloat ratio = frame.size.width / imageF.size.width;
        imageF.size.width  = frame.size.width;
        imageF.size.height = ratio * imageF.size.height;
        
        // 默认情况下，显示出的图片的宽度 = 屏幕的宽度
        // 如果kIsFullWidthForLandScape = NO，需要把图片全部显示在屏幕上
        // 此时由于图片的宽度已经等于屏幕的宽度，所以只需判断图片显示的高度>屏幕高度时，将图片的高度缩小到屏幕的高度即可
        
        if (!self.isFullWidthForLandScape || self.photo.isVideo) {
            // 图片的高度 > 屏幕的高度
            if (imageF.size.height > frame.size.height) {
                CGFloat scale = imageF.size.width / imageF.size.height;
                imageF.size.height = frame.size.height;
                imageF.size.width  = imageF.size.height * scale;
            }
        }
        
        // 设置图片的frame
        self.imageView.bounds = imageF;
        self.scrollView.contentSize = self.imageView.frame.size;
        
        if (imageF.size.height <= self.scrollView.bounds.size.height) {
            self.imageView.center = CGPointMake(self.scrollView.bounds.size.width * 0.5, self.scrollView.bounds.size.height * 0.5);
        }else {
            self.imageView.center = CGPointMake(self.scrollView.bounds.size.width * 0.5, imageF.size.height * 0.5);
        }
        
        // 根据图片大小找到最大缩放等级，保证最大缩放时候，不会有黑边
        // 找到最大的缩放比例
        CGFloat scaleH = frame.size.height / imageF.size.height;
        CGFloat scaleW = frame.size.width / imageF.size.width;
        self.realZoomScale = MAX(MAX(scaleH, scaleW), self.maxZoomScale);
        
        if (self.doubleZoomScale == self.maxZoomScale) {
            self.doubleZoomScale = self.realZoomScale;
        }else if (self.doubleZoomScale > self.realZoomScale) {
            self.doubleZoomScale = self.realZoomScale;
        }
        // 初始化
        self.scrollView.minimumZoomScale = 1.0;
        self.scrollView.maximumZoomScale = self.realZoomScale;
    }else if (!CGRectEqualToRect(self.photo.sourceFrame, CGRectZero)) {
        if (self.photo.sourceFrame.size.width == 0 || self.photo.sourceFrame.size.height == 0) return;
        CGFloat width = frame.size.width;
        CGFloat height = width * self.photo.sourceFrame.size.height / self.photo.sourceFrame.size.width;
        self.imageView.bounds = CGRectMake(0, 0, width, height);
        self.imageView.center = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5);
        self.scrollView.contentSize = self.imageView.frame.size;
    }else {
        self.imageView.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.imageView.center = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5);
        self.scrollView.contentSize = self.imageView.frame.size;
    }
    
    // frame调整完毕，重新设置缩放
    if (self.photo.isZooming) {
        [self.scrollView setZoomScale:1.0f animated:NO];
        [self setScrollMaxZoomScale:self.photo.zoomScale];
        [self zoomToRect:self.photo.zoomRect animated:NO];
        self.scrollView.contentOffset = self.photo.zoomOffset;
        [self setScrollMaxZoomScale:self.realZoomScale];
    }else {
        self.scrollView.contentOffset = self.photo.offset;
    }
    
    self.loadingView.frame = self.bounds;
    self.videoLoadingView.frame = self.bounds;
    if (self.showPlayImage) {
        [self.playBtn sizeToFit];
        self.playBtn.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    }
    [self updateFrame];
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
        self.photo.zoomOffset = scrollView.contentOffset;
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
    !self.zoomEnded ? : self.zoomEnded(self, scrollView.zoomScale);
    [self setScrollMaxZoomScale:self.realZoomScale];
}

- (void)cancelCurrentImageLoad {
    [_imageProtocol cancelImageRequestWithImageView:self.imageView];
}

- (void)dealloc {
    [self cancelCurrentImageLoad];
}

#pragma mark - 懒加载
- (GKScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView                      = [GKScrollView new];
        _scrollView.frame                = CGRectMake(0, 0, GKScreenW, GKScreenH);
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
    }
    return _imageView;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] init];
        [_playBtn setImage:self.videoPlayImage ?: GKPhotoBrowserImage(@"gk_video_play") forState:UIControlStateNormal];
        _playBtn.userInteractionEnabled = NO;
        _playBtn.hidden = YES;
        [_playBtn sizeToFit];
        _playBtn.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    }
    return _playBtn;
}

- (GKLoadingView *)loadingView {
    if (!_loadingView) {
        _loadingView = [GKLoadingView loadingViewWithFrame:self.bounds style:(GKLoadingStyle)self.loadStyle];
        _loadingView.failStyle   = self.failStyle;
        _loadingView.lineWidth   = 3;
        _loadingView.radius      = 12;
        _loadingView.bgColor     = [UIColor blackColor];
        _loadingView.strokeColor = [UIColor whiteColor];
        _loadingView.failText    = self.failureText;
        _loadingView.failImage   = self.failureImage;
    }
    return _loadingView;
}

- (GKLoadingView *)videoLoadingView {
    if (!_videoLoadingView) {
        _videoLoadingView = [GKLoadingView loadingViewWithFrame:self.bounds style:(GKLoadingStyle)self.loadStyle];
        _videoLoadingView.failStyle = self.failStyle;
        _videoLoadingView.lineWidth = 3;
        _videoLoadingView.radius = 12;
        _videoLoadingView.bgColor = UIColor.blackColor;
        _videoLoadingView.strokeColor = UIColor.whiteColor;
        _videoLoadingView.failText = self.failureText;
        _videoLoadingView.failImage = self.failureImage;
    }
    return _videoLoadingView;
}

@end
