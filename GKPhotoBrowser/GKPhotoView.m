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

@property (nonatomic, strong, readwrite) GKLoadingView  *loadingView;

@property (nonatomic, strong, readwrite) GKPhoto        *photo;

@property (nonatomic, strong) id<GKWebImageProtocol>    imageProtocol;

@property (nonatomic, assign) CGFloat realZoomScale;

@end

@implementation GKPhotoView

- (instancetype)initWithFrame:(CGRect)frame imageProtocol:(nonnull id<GKWebImageProtocol>)imageProtocol {
    if (self = [super initWithFrame:frame]) {
        _imageProtocol = imageProtocol;
        
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.imageView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.imageView];
    }
    return self;
}

- (GKScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView                      = [GKScrollView new];
        _scrollView.frame                = CGRectMake(0, 0, GKScreenW, GKScreenH);
        _scrollView.backgroundColor      = [UIColor clearColor];
        _scrollView.delegate             = self;
        _scrollView.clipsToBounds        = YES;
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
        _imageView               = [_imageProtocol.imageViewClass new];
        _imageView.frame         = CGRectMake(0, 0, GKScreenW, GKScreenH);
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
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

- (void)setupPhoto:(GKPhoto *)photo {
    _photo = photo;
    
    // 加载图片
    [self loadImageWithPhoto:photo isOrigin:NO];
}

- (void)loadOriginImage {
    // 恢复数据
    self.photo.image    = nil;
    self.photo.finished = NO;
    self.photo.failed   = NO;
    
    [self loadImageWithPhoto:self.photo isOrigin:YES];
}

#pragma mark - 加载图片
- (void)loadImageWithPhoto:(GKPhoto *)photo isOrigin:(BOOL)isOrigin {
    // 取消以前的加载
    [_imageProtocol cancelImageRequestWithImageView:self.imageView];
    
    if (photo) {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
        [self.scrollView addSubview:self.imageView];
        
        // 每次设置数据时，恢复缩放
        [self.scrollView setZoomScale:1.0 animated:NO];
        
        if (photo.image) {
            self.imageView.image = photo.image;
            [self.loadingView stopLoading];
            [self.loadingView hideFailure];
            [self.loadingView removeFromSuperview];
            
            [self adjustFrame];
            
            return;
        }
        
        // 获取原图的缓存
        if ([_imageProtocol imageFromMemoryForURL:photo.originUrl]) {
            photo.originFinished = YES;
        }

        if ([_imageProtocol imageFromMemoryForURL:photo.url]) {
            photo.finished = YES;
        }
        
        // 优先加载缓存图片
        UIImage *placeholderImage = [_imageProtocol imageFromMemoryForURL:photo.url];
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
        // 进度条
        [self addSubview:self.loadingView];
        [self.loadingView hideFailure];
        
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
        
        if (!photo.failed && !placeholderImage) {
            if (isOrigin && self.originLoadStyle != GKPhotoBrowserLoadStyleCustom) {
                [self.loadingView startLoading];
            }else if (!isOrigin && self.loadStyle != GKPhotoBrowserLoadStyleCustom) {
                [self.loadingView startLoading];
            }
        }
        
        __weak __typeof(self) weakSelf = self;
        GKWebImageProgressBlock progressBlock = ^(NSInteger receivedSize, NSInteger expectedSize) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (expectedSize == 0) return;
            float progress = (float)receivedSize / expectedSize;
            if (progress <= 0) progress = 0;
            
            // 图片加载中，回调进度
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isOrigin && strongSelf.originLoadStyle == GKLoadingStyleCustom) {
                    !self.loadProgressBlock ? : self.loadProgressBlock(self, progress, YES);
                }else if (!isOrigin && strongSelf.loadStyle == GKLoadingStyleCustom) {
                    !self.loadProgressBlock ? : self.loadProgressBlock(self, progress, NO);
                }else if (strongSelf.loadStyle == GKLoadingStyleDeterminate || strongSelf.originLoadStyle == GKLoadingStyleDeterminate) {
                    strongSelf.loadingView.progress = progress;
                }
            });
        };
        
        GKWebImageCompletionBlock completionBlock = ^(UIImage *image, NSURL *url, BOOL finished, NSError *error) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    photo.failed = YES;
                    [strongSelf.loadingView stopLoading];
                    
                    if ([photo.url.absoluteString isEqualToString:url.absoluteString]) {
                        if (self.failStyle == GKPhotoBrowserFailStyleCustom) {
                            !strongSelf.loadFailed ? : strongSelf.loadFailed(self);
                        }else {
                            [strongSelf addSubview:strongSelf.loadingView];
                            [strongSelf.loadingView showFailure];
                        }
                    }
                }else {
                    photo.finished = YES;
                    photo.image = image;
                    if (isOrigin) {
                        photo.originFinished = YES;
                    }
                    
                    // 图片加载完成，回调进度
                    if (isOrigin && strongSelf.originLoadStyle == GKLoadingStyleCustom) {
                        !self.loadProgressBlock ? : self.loadProgressBlock(self, 1.0f, YES);
                    }else if (!isOrigin && strongSelf.loadStyle == GKLoadingStyleCustom) {
                        !self.loadProgressBlock ? : self.loadProgressBlock(self, 1.0f, NO);
                    }
                    
                    strongSelf.scrollView.scrollEnabled = YES;
                    [strongSelf.loadingView stopLoading];
                }
                [strongSelf adjustFrame];
            });
        };
        
        [_imageProtocol setImageForImageView:self.imageView url:url placeholderImage:placeholderImage progress:progressBlock completion:completionBlock];
    }else {
        self.imageView.image = nil;
        
        [self adjustFrame];
    }
}

- (void)resetFrame {
    self.scrollView.frame  = self.bounds;
    self.loadingView.frame = self.bounds;
    
    if (self.photo) {
        [self adjustFrame];
    }
}

#pragma mark - 调整frame
- (void)adjustFrame {
    CGRect frame = self.scrollView.frame;
    if (frame.size.width == 0 || frame.size.height == 0) return;
    
    if (self.imageView.image) {
        CGSize imageSize = self.imageView.image.size;
        CGRect imageF = (CGRect){{0, 0}, imageSize};
        
        // 图片的宽度 = 屏幕的宽度
        CGFloat ratio = frame.size.width / imageF.size.width;
        imageF.size.width  = frame.size.width;
        imageF.size.height = ratio * imageF.size.height;
        
        // 默认情况下，显示出的图片的宽度 = 屏幕的宽度
        // 如果kIsFullWidthForLandSpace = NO，需要把图片全部显示在屏幕上
        // 此时由于图片的宽度已经等于屏幕的宽度，所以只需判断图片显示的高度>屏幕高度时，将图片的高度缩小到屏幕的高度即可
        
        if (!self.isFullWidthForLandSpace) {
            // 图片的高度 > 屏幕的高度
            if (imageF.size.height > frame.size.height) {
                CGFloat scale = imageF.size.width / imageF.size.height;
                imageF.size.height = frame.size.height;
                imageF.size.width  = imageF.size.height * scale;
            }
        }
        
        // 设置图片的frame
        self.imageView.frame = imageF;
        
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
        self.scrollView.maximumZoomScale = self.doubleZoomScale;
    }else if (!CGRectEqualToRect(self.photo.sourceFrame, CGRectZero)) {
        if (self.photo.sourceFrame.size.width == 0 || self.photo.sourceFrame.size.height == 0) return;
        CGFloat width = frame.size.width;
        CGFloat height = width * self.photo.sourceFrame.size.height / self.photo.sourceFrame.size.width;
        _imageView.bounds = CGRectMake(0, 0, width, height);
        _imageView.center = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5);
        self.scrollView.contentSize = self.imageView.frame.size;
        
        self.loadingView.bounds = self.scrollView.frame;
        self.loadingView.center = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5);
    }else {
        frame.origin        = CGPointZero;
        CGFloat width       = frame.size.width;
        CGFloat height      = width;
        _imageView.bounds   = CGRectMake(0, 0, width, height);
        _imageView.center   = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5);
        // 重置内容大小
        self.scrollView.contentSize = self.imageView.frame.size;
        
        self.loadingView.bounds = self.scrollView.frame;
        self.loadingView.center = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5);
    }
    self.scrollView.contentOffset = CGPointZero;
    
    // frame调整完毕，重新设置缩放
    if (self.photo.isZooming) {
        [self zoomToRect:self.photo.zoomRect animated:NO];
    }
    
    // 重置offset
    self.scrollView.contentOffset = self.photo.offset;
}

- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}

- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated {
    [self.scrollView zoomToRect:rect animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.photo.offset = scrollView.contentOffset;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.imageView.center = [self centerOfScrollViewContent:scrollView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    !self.zoomEnded ? : self.zoomEnded(self, scrollView.zoomScale);
    
    if (scale == 1) {
        self.scrollView.maximumZoomScale = self.doubleZoomScale;
    }else {
        self.scrollView.maximumZoomScale = self.realZoomScale;
    }
}

- (void)cancelCurrentImageLoad {
    [_imageProtocol cancelImageRequestWithImageView:self.imageView];
}

- (void)dealloc {
    [self cancelCurrentImageLoad];
}

@end
