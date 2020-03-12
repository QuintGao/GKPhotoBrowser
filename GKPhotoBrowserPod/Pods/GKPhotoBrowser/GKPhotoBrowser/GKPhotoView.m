//
//  GKPhotoView.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/23.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKPhotoView.h"
#import <SDWebImage/UIImage+MultiFormat.h>

@interface GKPhotoView()

@property (nonatomic, strong, readwrite) GKScrollView   *scrollView;

@property (nonatomic, strong, readwrite) UIImageView    *imageView;

@property (nonatomic, strong, readwrite) GKLoadingView  *loadingView;

@property (nonatomic, strong, readwrite) GKPhoto        *photo;

@property (nonatomic, strong) id<GKWebImageProtocol>    imageProtocol;

@property (nonatomic, strong) id operation;

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
        _imageView               = [UIImageView new];
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
        [photo stopAnimation];
        [self.imageView removeFromSuperview];
        self.imageView = nil;
        [self.scrollView addSubview:self.imageView];
        
        // 每次设置数据时，恢复缩放
        [self.scrollView setZoomScale:1.0 animated:NO];
        
        // 已经加载成功，无需再加载
        if (photo.image) {
            [self.loadingView stopLoading];
            [self.loadingView hideFailure];
            
            photo.finished = YES; // 加载完成
            
            if (photo.isGif) {
                [self setupPhotoWithData:self.photo.gifData image:self.photo.image];
            }else {
                self.imageView.image = photo.image;
            }
            
            [self adjustFrame];
            
            return;
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
        
        // 正在加载
        if (self.operation) return;
        
        NSURL *url = isOrigin ? photo.originUrl : photo.url;
        
        // 获取原图的缓存图片，如果有缓存就显示原图
        UIImage *originCacheImage = [_imageProtocol imageFromMemoryForURL:photo.originUrl];
        NSData *originImageData = [[SDImageCache sharedImageCache] diskImageDataForKey:photo.originUrl.absoluteString];
        
        if (originCacheImage && originImageData) {
            photo.originFinished = YES;
            self.scrollView.scrollEnabled = YES;
            [self.loadingView stopLoading];
            !self.loadProgressBlock ? : self.loadProgressBlock(self, 1.0, YES);
            [self setupPhotoWithData:originImageData image:originCacheImage];
            [self adjustFrame];
            
            return;
        }
        
        // 获取图片缓存
        UIImage *cacheImage = [_imageProtocol imageFromMemoryForURL:url];
        NSData *cacheData = [[SDImageCache sharedImageCache] diskImageDataForKey:photo.url.absoluteString];
        
        if (cacheImage && cacheData) {
            photo.finished = YES;
            self.scrollView.scrollEnabled = YES;
            [self.loadingView stopLoading];
            !self.loadProgressBlock ? : self.loadProgressBlock(self, 1.0, NO);
            [self setupPhotoWithData:cacheData image:cacheImage];
            [self adjustFrame];
            
            return;
        }
        
        if (!photo.failed && !cacheImage) {
            if (isOrigin && self.originLoadStyle != GKPhotoBrowserLoadStyleCustom) {
                [self.loadingView startLoading];
            }else if (!isOrigin && self.loadStyle != GKPhotoBrowserLoadStyleCustom) {
                [self.loadingView startLoading];
            }
        }
        
        // 开始加载图片
        __weak typeof(self) weakSelf = self;
        gkWebImageProgressBlock progressBlock = ^(NSInteger receivedSize, NSInteger expectedSize) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
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

        gkWebImageCompletionBlock completionBlock = ^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.operation = nil;
                if (error) {
                    photo.failed = YES;
                    [strongSelf.loadingView stopLoading];
                    
                    if ([photo.url.absoluteString isEqualToString:imageURL.absoluteString]) {
                        if (self.failStyle == GKPhotoBrowserFailStyleCustom) {
                            !strongSelf.loadFailed ? : strongSelf.loadFailed(self);
                        }else {
                            [strongSelf addSubview:strongSelf.loadingView];
                            [strongSelf.loadingView showFailure];
                        }
                    }
                }else {
                    photo.finished = YES;
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
                    
                    if (cacheType == SDImageCacheTypeMemory) {
                        NSData *imageData = [[SDImageCache sharedImageCache] diskImageDataForKey:photo.url.absoluteString];
                        [strongSelf setupPhotoWithData:imageData image:image];
                    }else {
                        [strongSelf setupPhotoWithData:data image:image];
                    }
                }
                [strongSelf adjustFrame];
            });
        };
        
        self.operation = [_imageProtocol loadImageWithURL:url progress:progressBlock completed:completionBlock];
    }else {
        self.imageView.image = nil;
        
        [self adjustFrame];
    }
}

- (void)setupPhotoWithData:(NSData *)data image:(UIImage *)image {
    if (!data && !image) {
        self.photo.failed = YES;
        [self.loadingView showFailure];
        return;
    }
    
    UIImage *currentImage = image.images.count == 1 ? image.images.firstObject : image;
    if (currentImage.images.count > 1) {
        self.photo.image = currentImage;
        self.photo.isGif = NO;
        
        self.imageView.image = currentImage;
        
        return;
    }
    
    if (!currentImage) {
        currentImage = [UIImage imageWithData:data];
    }
    
    if (!data) {
        self.photo.image = currentImage;
        self.photo.isGif = NO;
    }
    
    // gif图片
    if ([NSData sd_imageFormatForImageData:data] == SDImageFormatGIF) {
        self.photo.gifData  = data;
        self.photo.isGif    = YES;
        self.photo.image    = currentImage;
        if (self.isLowGifMemory) {
            self.photo.gifImage  = currentImage;
            self.photo.imageView = self.imageView;
            
            [self.photo startAnimation];
        }else {
            self.photo.gifImage = [UIImage sdOverdue_animatedGIFWithData:data];
        }
        
        self.imageView.image = self.photo.gifImage;
    }else {
        self.photo.isGif = NO;
        self.photo.image = currentImage;
        
        self.imageView.image = self.photo.image;
    }
}

- (void)resetFrame {
    self.scrollView.frame  = self.bounds;
    self.loadingView.frame = self.bounds;
    
    if (self.photo) {
        [self adjustFrame];
    }
}

- (void)startGifAnimation {
    if (self.photo.gifData) {
        [self setupPhotoWithData:self.photo.gifData image:self.photo.image];
    }
}

- (void)stopGifAnimation {
    if (self.photo) {
        if (self.isLowGifMemory) {
            [self.photo stopAnimation];
        }else {
            self.imageView.image = self.photo.image;
        }
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
        CGFloat maxScale = MAX(MAX(scaleH, scaleW), self.maxZoomScale);
        // 初始化
        self.scrollView.minimumZoomScale = 1.0;
        self.scrollView.maximumZoomScale = maxScale;
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
}

- (void)cancelCurrentImageLoad {
    [self.imageView sd_cancelCurrentImageLoad];
}

- (void)dealloc {
    [self cancelCurrentImageLoad];
}

@end
