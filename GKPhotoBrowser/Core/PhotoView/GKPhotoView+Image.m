//
//  GKPhotoView+Image.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2024/6/21.
//

#import "GKPhotoView+Image.h"
#import "UIDevice+GKPhotoBrowser.h"

@implementation GKPhotoView (Image)

- (void)loadImageWithPhoto:(GKPhoto *)photo isOrigin:(BOOL)isOrigin {
    // 取消以前的加载
    [self cancelImageLoad];
    
    if (photo) {
        [self resetImageView];
        
        if (!photo.isVideo && self.configure.isShowPlayImage) {
            self.playBtn.hidden = YES;
        }else if (photo.isVideo && !photo.isAutoPlay && !photo.isVideoClicked) {
            [self addSubview:self.playBtn];
            self.playBtn.hidden = NO;
        }
        
        // 每次设置数据时，恢复缩放
        [self.scrollView setZoomScale:1.0 animated:NO];
        
        // 优先加载缓存图片
        UIImage *placeholderImage = nil;
        UIImage *image = [self.imager imageFromMemoryForURL:photo.url];
        if (image) {
            photo.finished = YES;
            placeholderImage = image;
        }
        
        UIImage *originImage = [self.imager imageFromMemoryForURL:photo.originUrl];
        if (originImage) {
            photo.originFinished = YES;
            placeholderImage = originImage;
            isOrigin = YES;
        }
        
        // 如果没有就加载sourceImageView的image
        if (!placeholderImage) {
            placeholderImage = photo.sourceImageView.image;
        }
        
        // 如果还没有就加载传入的占位图
        if (!placeholderImage) {
            placeholderImage = photo.placeholderImage;
        }
        
        self.imageView.image = placeholderImage;
        self.imageView.contentMode = photo.sourceImageView.contentMode;
        self.scrollView.scrollEnabled = NO;
        
        if (photo.image) {
            [self setupImageView:photo.image];
        }else if (photo.imageAsset) {
            [self loadAssetImageWithPhoto:photo isOrigin:isOrigin placeholderImage:placeholderImage];
        }else {
            [self loadWebImageWithPhoto:photo isOrigin:isOrigin placeholderImage:placeholderImage];
        }
    }else {
        self.imageView.image = nil;
        [self adjustFrame];
    }
}

- (void)loadOriginImage {
    // 恢复数据
    self.photo.image    = nil;
    self.photo.finished = NO;
    self.photo.failed   = NO;
    
    [self loadImageWithPhoto:self.photo isOrigin:YES];
}

- (void)cancelImageLoad {
    [self.imager cancelImageRequestWithImageView:self.imageView];
}

- (void)loadAssetImageWithPhoto:(GKPhoto *)photo isOrigin:(BOOL)isOrigin placeholderImage:(UIImage *)placeholderImage {
    [self addSubview:self.loadingView];
    if (!photo.failed) {
        [self.loadingView hideFailure];
    }
    [self adjustFrame];
    
    if (!photo.failed && !placeholderImage) {
        if (isOrigin && self.configure.originLoadStyle != GKPhotoBrowserLoadStyleCustom) {
            [self.loadingView startLoading];
        }else if (!isOrigin && self.configure.loadStyle != GKPhotoBrowserLoadStyleCustom) {
            [self.loadingView startLoading];
        }
    }
    
    __weak __typeof(self) weakSelf = self;
    [photo getImage:^(NSData * _Nullable data, UIImage * _Nullable image, NSError * _Nullable error) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (!self) return;
        UIImage *newImage = nil;
        if (data) {
            if ([self.imager respondsToSelector:@selector(imageWithData:)]) {
                newImage = [self.imager imageWithData:data];
            }
            if (!newImage) {
                newImage = [UIImage gkbrowser_imageWithData:data];
            }
        }else {
            newImage = image;
        }
        if (newImage) {
            [self setupImageView:newImage];
        }else {
            [self loadFailedWithError:error];
            if (self.configure.failStyle != GKPhotoBrowserFailStyleCustom) {
                [self addSubview:self.loadingView];
                [self.loadingView showFailure];
            }
        }
    }];
}

- (void)loadWebImageWithPhoto:(GKPhoto *)photo isOrigin:(BOOL)isOrigin placeholderImage:(UIImage *)placeholderImage {
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
            if (isOrigin && self.configure.originLoadStyle != GKPhotoBrowserLoadStyleCustom) {
                [self.loadingView startLoading];
            }else if (!isOrigin && self.configure.loadStyle != GKPhotoBrowserLoadStyleCustom) {
                [self.loadingView startLoading];
            }
        }
        
        if (!self.imager) {
            UIImage *image = [UIImage gkbrowser_imageNamed:url.path];
            if (!image) {
                image = self.imageView.image;
            }
            if (image) {
                self.imageView.image = image;
                self.imageSize = image.size;
                photo.finished = YES;
                if (isOrigin) {
                    photo.originFinished = YES;
                }
                
                // 图片加载完成，回调进度
                [self loadProgress:1.0 isOriginImage:isOrigin];
                
                self.scrollView.scrollEnabled = YES;
                [self.loadingView stopLoading];
                [self adjustFrame];
            }else {
                photo.failed = YES;
                [self.loadingView stopLoading];
                NSError *error = [NSError errorWithDomain:@"com.browser.error" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"图片加载失败"}];
                [self loadFailedWithError:error];
                if (self.configure.failStyle != GKPhotoBrowserFailStyleCustom) {
                    [self addSubview:self.loadingView];
                    [self.loadingView showFailure];
                }
            }
            return;
        }
        
        __weak __typeof(self) weakSelf = self;
        GKWebImageProgressBlock progressBlock = ^(NSInteger receivedSize, NSInteger expectedSize) {
            __strong __typeof(weakSelf) self = weakSelf;
            if (!self) return;
            if (expectedSize <= 0) return;
            float progress = (float)receivedSize / expectedSize;
            if (progress <= 0) progress = 0;
            
            // 图片加载中，进度回调
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadProgress:progress isOriginImage:isOrigin];
            });
        };
        
        GKWebImageCompletionBlock completionBlock = ^(UIImage *image, NSURL *url, BOOL finished, NSError *error) {
            __strong __typeof(weakSelf) self = weakSelf;
            if (!self) return;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    photo.failed = YES;
                    [self.loadingView stopLoading];
                    [self loadFailedWithError:error];
                    if (self.configure.failStyle != GKPhotoBrowserFailStyleCustom) {
                        [self addSubview:self.loadingView];
                        [self.loadingView showFailure];
                    }
                }else {
                    self.imageSize = image.size;
                    photo.finished = YES;
                    if (isOrigin) {
                        photo.originFinished = YES;
                    }
                    
                    // 图片加载完成，回调进度
                    [self loadProgress:1.0 isOriginImage:isOrigin];
                    
                    self.scrollView.scrollEnabled = YES;
                    [self.loadingView stopLoading];
                }
                if (!isOrigin) {
                    [self adjustFrame];
                }
                if (self.imageView.image && CGSizeEqualToSize(self.imageView.frame.size, CGSizeZero)) {
                    [self adjustFrame];
                }
                if (!self.imageView.image && !CGSizeEqualToSize(self.imageSize, CGSizeZero)) {
                    [self adjustFrame];
                }
            });
        };
        [self.imager setImageForImageView:self.imageView url:url placeholderImage:placeholderImage progress:progressBlock completion:completionBlock];
    }else {
        if (self.imageView.image) {
            photo.finished = YES;
            self.scrollView.scrollEnabled = YES;
            [self.loadingView stopLoading];
        }else {
            photo.failed = YES;
            [self.loadingView stopLoading];
            NSError *error = [NSError errorWithDomain:@"com.browser.error" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"图片加载失败"}];
            [self loadFailedWithError:error];
            if (self.configure.failStyle != GKPhotoBrowserFailStyleCustom) {
                [self addSubview:self.loadingView];
                [self.loadingView showFailure];
            }
        }
        [self adjustFrame];
    }
}

- (void)adjustImageFrame {
    CGRect frame = self.scrollView.frame;
    if (frame.size.width == 0 || frame.size.height == 0) return;
    
    if (self.imageView.image || !CGSizeEqualToSize(self.imageSize, CGSizeZero)) {
        CGSize imageSize = self.imageView.image.size;
        if (CGSizeEqualToSize(imageSize, CGSizeZero)) {
            imageSize = self.imageSize;
        }
        // 视频处理，保证视频可以完全显示
        if (self.photo.isVideo && !CGSizeEqualToSize(self.photo.videoSize, CGSizeZero)) {
            imageSize = self.photo.videoSize;
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
        
        if (imageSize.width == 0) imageSize.width = self.scrollView.frame.size.width;
        if (imageSize.height == 0) imageSize.height = self.scrollView.frame.size.height;
        
        CGRect imageFrame = (CGRect){{0, 0}, imageSize};
        
        // 图片的宽度 = 屏幕的宽度
        CGFloat ratio = frame.size.width / imageFrame.size.width;
        imageFrame.size.width = frame.size.width;
        imageFrame.size.height = ratio * imageFrame.size.height;
        
        // 默认情况下，显示出的图片的宽度 = 屏幕的宽度
        // 如果isFullWidthForLandScape = NO,需要把图片全部显示在屏幕上
        // 此时由于图片的宽度已经等于屏幕的宽度，所以只需判断图片显示的高度>屏幕高度时，将图片的高度缩小到屏幕的高度即可
        if (!self.configure.isFullWidthForLandScape || self.photo.isVideo) {
            // 图片的高度 > 屏幕的高度
            if (imageFrame.size.height > frame.size.height) {
                CGFloat scale = imageFrame.size.width / imageFrame.size.height;
                imageFrame.size.height = frame.size.height;
                imageFrame.size.width = imageFrame.size.height * scale;
            }
        }
        
        // 设置图片的frame
        self.imageView.bounds = imageFrame;
        self.scrollView.contentSize = self.imageView.frame.size;
        
        if (imageFrame.size.height <= self.scrollView.bounds.size.height) {
            self.imageView.center = CGPointMake(self.scrollView.bounds.size.width * 0.5, self.scrollView.bounds.size.height * 0.5);
        }else {
            self.imageView.center = CGPointMake(self.scrollView.bounds.size.width * 0.5, imageFrame.size.height * 0.5);
        }
        
        // 根据图片大小找到最大缩放等级，保证最大缩放时候，不会有黑边
        // 找到最大缩放比例
        CGFloat scaleH = frame.size.height / imageFrame.size.height;
        CGFloat scaleW = frame.size.width / imageFrame.size.width;
        self.realZoomScale = MAX(MAX(scaleH, scaleW), self.configure.maxZoomScale);
        if (self.doubleZoomScale == self.configure.maxZoomScale) {
            self.doubleZoomScale = self.realZoomScale;
        }else if (self.doubleZoomScale > self.realZoomScale) {
            self.doubleZoomScale = self.realZoomScale;
        }
        // 初始化
        self.scrollView.minimumZoomScale = 1.0f;
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
        if (self.scrollView.contentSize.height < self.scrollView.frame.size.height) {
            self.scrollView.contentOffset = CGPointZero;
        }else {
            self.scrollView.contentOffset = self.photo.offset;
        }
    }
    
    
    
    self.loadingView.frame = self.bounds;
    self.videoLoadingView.frame = self.bounds;
    self.liveLoadingView.frame = self.bounds;
    if (self.photo.isVideo && self.configure.isShowPlayImage) {
        [self.playBtn sizeToFit];
        self.playBtn.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    }
    if (self.photo.isLivePhoto) {
        self.liveMarkView.frame = CGRectMake(10, UIDevice.gk_safeAreaTop, 64, 20);
    }
    [self updateFrame];
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

- (void)loadProgress:(float)progress isOriginImage:(BOOL)isOriginImage {
    if ([self.delegate respondsToSelector:@selector(photoView:loadProgress:isOriginImage:)]) {
        if (self.configure.loadStyle == GKPhotoBrowserLoadStyleCustom ||
            self.configure.originLoadStyle == GKPhotoBrowserLoadStyleCustom) {
            [self.delegate photoView:self loadProgress:progress isOriginImage:isOriginImage];
        }
    }
    if (self.configure.loadStyle == GKPhotoBrowserLoadStyleDeterminate ||
        self.configure.originLoadStyle == GKPhotoBrowserLoadStyleDeterminate ||
        self.configure.loadStyle == GKPhotoBrowserLoadStyleDeterminateSector ||
        self.configure.originLoadStyle == GKPhotoBrowserLoadStyleDeterminateSector) {
        self.loadingView.progress = progress;
    }
}

@end
