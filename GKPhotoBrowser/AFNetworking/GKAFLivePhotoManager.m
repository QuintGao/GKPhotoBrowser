//
//  GKAFLivePhotoManager.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2024/6/20.
//

#import "GKAFLivePhotoManager.h"
#import <AFNetworking/AFNetworking.h>
#import <GKLivePhotoManager/GKLivePhotoManager.h>
#import <CommonCrypto/CommonDigest.h>
#import "GKPhotoView.h"
#import "GKPhotoBrowser.h"

static float progressRatio = 4 / 5.0;

@interface GKAFLivePhotoManager()<PHLivePhotoViewDelegate>

@property (nonatomic, copy) NSString *fileDirectory;

@property (nonatomic, strong) NSMutableArray *filePathList;

@property (nonatomic, copy) void(^progressBlock)(float progress);
@property (nonatomic, copy) void(^completionBlock)(BOOL success);

@end

@implementation GKAFLivePhotoManager

@synthesize browser;
@synthesize livePhotoView = _livePhotoView;
@synthesize photo;
@synthesize liveStatusChanged;
@synthesize isPlaying = _isPlaying;

- (void)dealloc {
    if (self.browser.configure.isClearMemoryForLivePhoto) {
        [self gk_clear];
    }
    [GKLivePhotoManager deallocManager];
}

- (void)loadLivePhotoWithPhoto:(GKPhoto *)photo targetSize:(CGSize)targetSize progressBlock:(void (^)(float))progressBlock completion:(void (^ _Nullable)(BOOL))completion {
    self.photo = photo;
    self.progressBlock = progressBlock;
    self.completionBlock = completion;
    
    __weak __typeof(self) weakSelf = self;
    if (photo.imageAsset && photo.imageAsset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
        [self loadLivePhotoWithAsset:photo.imageAsset targetSize:targetSize];
    }else if (photo.videoUrl) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // 如果传入的是本地地址，判断是否存在
        if ([fileManager fileExistsAtPath:photo.videoUrl.path]) {
            [self loadLivePhotoWithVideoPath:photo.videoUrl.path imagePath:photo.url.path targetSize:targetSize];
            return;
        }
        
        // 本地视频地址
        NSString *videoPath = [self filePathWithOriginURL:photo.videoUrl ext:@"mov"];
        // 本地图片地址
        NSString *imagePath = nil;
        if (photo.url) {
            imagePath = [self filePathWithOriginURL:photo.url ext:@"jpg"];
        }
        
        // 判断是否下载过，下载过直接加载
        if ([fileManager fileExistsAtPath:videoPath]) {
            [self loadLivePhotoWithVideoPath:videoPath imagePath:imagePath targetSize:targetSize];
            return;
        }
        
        [fileManager removeItemAtPath:videoPath error:nil];
        [fileManager removeItemAtPath:imagePath error:nil];
        
        NSURL *videoFileURL = [NSURL fileURLWithPath:videoPath];
        NSURL *imageFileURL = [NSURL fileURLWithPath:imagePath];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        if (photo.url) {
            __block BOOL isVideoFinished = NO;
            __block BOOL isImageFinished = NO;
            
            __block float videoProgress = 0;
            __block float imageProgress = 0;
            
            [[manager downloadTaskWithRequest:[NSURLRequest requestWithURL:photo.videoUrl] progress:^(NSProgress * _Nonnull downloadProgress) {
                __strong __typeof(weakSelf) self = weakSelf;
                videoProgress = (float)downloadProgress.completedUnitCount / (float)downloadProgress.totalUnitCount;
                float progress = (videoProgress + imageProgress) / 2;
                !self.progressBlock ?: self.progressBlock(progress * progressRatio);
            } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                return videoFileURL;
            } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                __strong __typeof(weakSelf) self = weakSelf;
                if (error) {
                    !self.completionBlock ?: self.completionBlock(NO);
                    return;
                }
                
                isVideoFinished = YES;
                if (filePath) {
                    [self.filePathList addObject:filePath.path];
                }
                if (isVideoFinished && isImageFinished) {
                    [self loadLivePhotoWithVideoPath:videoPath imagePath:imagePath targetSize:targetSize];
                }
            }] resume];
            
            [[manager downloadTaskWithRequest:[NSURLRequest requestWithURL:photo.url] progress:^(NSProgress * _Nonnull downloadProgress) {
                __strong __typeof(weakSelf) self = weakSelf;
                imageProgress = (float)downloadProgress.completedUnitCount / (float)downloadProgress.totalUnitCount;
                float progress = (videoProgress + imageProgress) / 2;
                !self.progressBlock ?: self.progressBlock(progress * progressRatio);
            } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                return imageFileURL;
            } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                __strong __typeof(weakSelf) self = weakSelf;
                if (error) {
                    !self.completionBlock ?: self.completionBlock(NO);
                    return;
                }
                
                isImageFinished = YES;
                if (filePath) {
                    [self.filePathList addObject:filePath.path];
                }
                if (isVideoFinished && isImageFinished) {
                    [self loadLivePhotoWithVideoPath:videoPath imagePath:imagePath targetSize:targetSize];
                }
            }] resume];
        }else {
            [[manager downloadTaskWithRequest:[NSURLRequest requestWithURL:photo.videoUrl] progress:^(NSProgress * _Nonnull downloadProgress) {
                __strong __typeof(weakSelf) self = weakSelf;
                float videoProgress = (float)downloadProgress.completedUnitCount / (float)downloadProgress.totalUnitCount;
                !self.progressBlock ?: self.progressBlock(videoProgress * progressRatio);
            } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                return videoFileURL;
            } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                __strong __typeof(weakSelf) self = weakSelf;
                if (error) {
                    !self.completionBlock ?: self.completionBlock(NO);
                    return;
                }
                
                if (filePath) {
                    [self.filePathList addObject:filePath.path];
                }
                [self loadLivePhotoWithVideoPath:videoPath imagePath:imagePath targetSize:targetSize];
            }] resume];
        }
    }
}

- (void)gk_play {
    if (self.isPlaying) return;
    [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
}

- (void)gk_stop {
    if (!self.isPlaying) return;
    [self.livePhotoView stopPlayback];
}

- (void)gk_clear {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    [self.filePathList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([fileManager fileExistsAtPath:obj]) {
            [fileManager removeItemAtPath:obj error:nil];
        }
    }];
    
    // 本地视频地址
    NSString *videoPath = [self filePathWithOriginURL:self.photo.videoUrl ext:@"mov"];
    // 本地图片地址
    NSString *imagePath = nil;
    if (photo.url) {
        imagePath = [self filePathWithOriginURL:self.photo.url ext:@"jpg"];
    }
    if ([fileManager fileExistsAtPath:videoPath]) {
        [fileManager removeItemAtPath:videoPath error:nil];
    }
    if ([fileManager fileExistsAtPath:imagePath]) {
        [fileManager removeItemAtPath:imagePath error:nil];
    }
}

- (void)gk_updateFrame:(CGRect)frame {
    self.livePhotoView.frame = frame;
}

- (void)gk_setMute:(BOOL)mute {
    self.livePhotoView.muted = mute;
}

- (void)loadLivePhotoWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize {
    if (CGSizeEqualToSize(targetSize, CGSizeZero)) {
        targetSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    }
    
    __weak __typeof(self) weakSelf = self;
    [[GKLivePhotoManager manager] createLivePhotoWithAsset:photo.imageAsset targetSize:targetSize progressBlock:^(float progress) {
        __strong __typeof(weakSelf) self = weakSelf;
        !self.progressBlock ?: self.progressBlock(progress/5.0 + progressRatio);
    } completion:^(PHLivePhoto * _Nullable livePhoto, NSError * _Nullable error) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (livePhoto) {
            self.livePhotoView.livePhoto = livePhoto;
            !self.progressBlock ?: self.progressBlock(1);
            !self.completionBlock ?: self.completionBlock(YES);
        }else {
            !self.completionBlock ?: self.completionBlock(NO);
        }
    }];
}

- (void)loadLivePhotoWithVideoPath:(NSString *)videoPath imagePath:(NSString *)imagePath targetSize:(CGSize)targetSize {
    __weak __typeof(self) weakSelf = self;
    if (CGSizeEqualToSize(targetSize, CGSizeZero)) {
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
        
        AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        if (track) {
            targetSize = track.naturalSize;
        }
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
        !self.completionBlock ?: self.completionBlock(NO);
        return;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        imagePath = nil;
    }
    
    [[GKLivePhotoManager manager] handleDataWithVideoPath:videoPath imagePath:imagePath progressBlock:^(float progress) {
        __strong __typeof(weakSelf) self = weakSelf;
        !self.progressBlock ?: self.progressBlock(progress/5.0 + progressRatio);
    } completion:^(NSString * _Nullable outVideoPath, NSString * _Nullable outImagePath, NSError * _Nullable error) {
        __strong __typeof(weakSelf) self = weakSelf;
        [self createLivePhotoWithVideoPath:outVideoPath imagePath:outImagePath targetSize:targetSize];
    }];
}

- (void)createLivePhotoWithVideoPath:(NSString *)videoPath imagePath:(NSString * _Nonnull)imagePath targetSize:(CGSize)targetSize {
    if (![self isBundlePathWithUrl:videoPath]) {
        [self.filePathList addObject:videoPath];
    }
    if (![self isBundlePathWithUrl:imagePath]) {
        [self.filePathList addObject:imagePath];
    }
    __weak __typeof(self) weakSelf = self;
    [[GKLivePhotoManager manager] createLivePhotoWithVideoPath:videoPath imagePath:imagePath targetSize:targetSize completion:^(PHLivePhoto * _Nullable livePhoto, NSError * _Nullable error) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (livePhoto) {
            self.livePhotoView.livePhoto = livePhoto;
            !self.progressBlock ?: self.progressBlock(1);
            !self.completionBlock ?: self.completionBlock(YES);
        }else {
            !self.completionBlock ?: self.completionBlock(NO);
        }
    }];
}

- (NSString *)filePathWithOriginURL:(NSURL *)url ext:(NSString *)ext {
    NSString *name = GKDiskCacheFileNameForKey(url.absoluteString);
    name = [NSString stringWithFormat:@"%@.%@", name, ext];
    return [self.fileDirectory stringByAppendingPathComponent:name];
}

- (BOOL)isBundlePathWithUrl:(NSString *)url {
    if ([url hasPrefix:[NSBundle.mainBundle bundlePath]]) {
        return YES;
    }
    return NO;
}

#pragma mark - PHLivePhotoViewDelegate
- (BOOL)livePhotoView:(PHLivePhotoView *)livePhotoView canBeginPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    return self.browser.configure.isLivePhotoLongPressPlay;
}

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView willBeginPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    [self autoresizeToView:livePhotoView];
    self.isPlaying = YES;
    !self.liveStatusChanged ?: self.liveStatusChanged(self, GKLivePlayStatusBegin);
}

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    self.isPlaying = NO;
    !self.liveStatusChanged ?: self.liveStatusChanged(self, GKLivePlayStatusEnded);
}

- (void)autoresizeToView:(UIView *)view {
    for (UIView *subView in view.subviews) {
        subView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self autoresizeToView:subView];
    }
}

#pragma mark - Lazy
- (PHLivePhotoView *)livePhotoView {
    if (!_livePhotoView) {
        _livePhotoView = [[PHLivePhotoView alloc] init];
        _livePhotoView.delegate = self;
        _livePhotoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if (self.browser.configure.isLivePhotoMutedPlay) {
            _livePhotoView.muted = YES;
        }
    }
    return _livePhotoView;
}

- (NSString *)fileDirectory {
    if (!_fileDirectory) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        _fileDirectory = [path stringByAppendingPathComponent:@"livePhoto"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:_fileDirectory]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_fileDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _fileDirectory;
}

- (NSMutableArray *)filePathList {
    if (!_filePathList) {
        _filePathList = [NSMutableArray array];
    }
    return _filePathList;
}

#pragma mark - md5
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
static inline NSString * _Nonnull GKDiskCacheFileNameForKey(NSString * _Nullable key) {
    const char *str = key.UTF8String;
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15]];
    return filename;
}
#pragma clang diagnostic pop

@end
