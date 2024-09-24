//
//  GKPhotoBrowserConfigure.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2020/10/19.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import "GKPhotoBrowserConfigure.h"

@interface GKPhotoBrowserConfigure()

@property (nonatomic, strong) id<GKWebImageProtocol> imager;

@property (nonatomic, strong) id<GKVideoPlayerProtocol> player;

@property (nonatomic, strong) id<GKProgressViewProtocol> progress;

@property (nonatomic, strong) id<GKLivePhotoProtocol> livePhoto;

@property (nonatomic, weak) UIView *progressView;

@end

@implementation GKPhotoBrowserConfigure

+ (instancetype)defaultConfig {
    return [[GKPhotoBrowserConfigure alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)dealloc {
    [self destory];
}

- (void)initialize {
    self.isHideSourceView        = YES;
    self.isFullWidthForLandScape = YES;
    self.maxZoomScale            = 2.0;
    self.doubleZoomScale         = self.maxZoomScale;
    self.animDuration            = 0.3;
    self.photoViewPadding        = 10;
    self.hidesSavedBtn           = YES;
    self.isVideoReplay           = YES;
    self.isVideoPausedWhenDragged = YES;
    self.isLivePhotoPausedWhenDragged = YES;
    self.isClearMemoryForLivePhoto = YES;
    self.isLivePhotoLongPressPlay = YES;
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.liveTargetSize = CGSizeMake(2 * size.width, 2 * size.height);
    
    self.showStyle = GKPhotoBrowserShowStyleZoom;
    self.hideStyle = GKPhotoBrowserHideStyleZoom;
    self.loadStyle = GKPhotoBrowserLoadStyleIndeterminate;
    self.originLoadStyle = GKPhotoBrowserLoadStyleIndeterminate;
    self.failStyle = GKPhotoBrowserFailStyleOnlyText;
    
    self.isShowPlayImage           = YES;
    self.videoLoadStyle = GKPhotoBrowserLoadStyleIndeterminate;
    self.videoFailStyle = GKPhotoBrowserFailStyleOnlyText;
    
    self.liveLoadStyle = GKPhotoBrowserLoadStyleDeterminateSector;
    
    [self loadManagerIfExist];
}

- (void)loadManagerIfExist {
    // 图片处理
    Class imageManagerClass = NSClassFromString(@"GKSDWebImageManager");
    if (!imageManagerClass) {
        imageManagerClass = NSClassFromString(@"GKYYWebImageManager");
    }
    if (!imageManagerClass) {
        imageManagerClass = NSClassFromString(@"GKPhotoBrowser.GKKFWebImageManager");
    }
    if (imageManagerClass) {
        [self setupWebImageProtocol:[imageManagerClass new]];
    }
    
    // 视频处理
    Class videoManagerClass = NSClassFromString(@"GKAVPlayerManager");
    if (!videoManagerClass) {
        videoManagerClass = NSClassFromString(@"GKZFPlayerManager");
    }
    if (!videoManagerClass) {
        videoManagerClass = NSClassFromString(@"GKIJKPlayerManager");
    }
    if (videoManagerClass) {
        [self setupVideoPlayerProtocol:[videoManagerClass new]];
    }
    
    // 视频进度处理
    Class progressClass = NSClassFromString(@"GKProgressView");
    if (progressClass) {
        [self setupVideoProgressProtocol:[progressClass new]];
    }
    
    // livePhoto处理
    Class livePhotoClass = NSClassFromString(@"GKAFLivePhotoManager");
    if (!livePhotoClass) {
        livePhotoClass = NSClassFromString(@"GKPhotoBrowser.GKAlamofireLivePhotoManager");
    }
    if (livePhotoClass) {
        [self setupLivePhotoProtocol:[livePhotoClass new]];
    }
}

- (void)setDoubleZoomScale:(CGFloat)doubleZoomScale {
    if (doubleZoomScale > self.maxZoomScale) {
        _doubleZoomScale = self.maxZoomScale;
    }else {
        _doubleZoomScale = doubleZoomScale;
    }
}

- (void)setupWebImageProtocol:(id<GKWebImageProtocol>)protocol {
    self.imager = protocol;
}

- (void)setupVideoPlayerProtocol:(id<GKVideoPlayerProtocol>)protocol {
    self.player = protocol;
}

- (void)setupVideoProgressProtocol:(id<GKProgressViewProtocol>)protocol {
    self.progress = protocol;
    self.progressView = protocol.progressView;
}

- (void)setupLivePhotoProtocol:(id<GKLivePhotoProtocol>)protocol {
    self.livePhoto = protocol;
}

- (void)didDisappear {
    if (self.isClearMemoryWhenDisappear && [self.imager respondsToSelector:@selector(clearMemory)]) {
        [self.imager clearMemory];
    }
    [self destory];
}

- (void)destory {
    self.imager = nil;
    [self.player gk_stop];
    self.player = nil;
    self.progress = nil;
    [self.livePhoto gk_stop];
    self.livePhoto = nil;
}

@end
