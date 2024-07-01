//
//  GKLivePhotoManager.m
//  GKLivePhotoManager
//
//  Created by QuintGao on 2024/6/27.
//

#import "GKLivePhotoManager.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define kDocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
#define kOutVideoPath [kDocumentPath stringByAppendingPathComponent:@"livephoto.mov"]
#define kOutImagePath [kDocumentPath stringByAppendingPathComponent:@"livephoto.jpg"]

@implementation GKLivePhotoManager

static GKLivePhotoManager *_manager = nil;
+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[GKLivePhotoManager alloc] init];
    });
    return _manager;
}

+ (void)deallocManager {
    [[NSFileManager defaultManager] removeItemAtPath:kOutVideoPath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:kOutImagePath error:nil];
    _manager = nil;
}

- (void)handleDataWithVideoPath:(NSString *)videoPath completion:(void (^)(NSString * _Nullable, NSString * _Nullable, NSError * _Nullable))completion {
    [self handleDataWithVideoPath:videoPath imagePath:nil completion:completion];
}

- (void)handleDataWithVideoPath:(NSString *)videoPath imagePath:(NSString *)imagePath completion:(void (^)(NSString * _Nullable, NSString * _Nullable, NSError * _Nullable))completion {
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
    if (!asset) {
        !completion ?: completion(nil, nil, [self errorWithMsg:@"video asset not available"]);
        return;
    }
    // 关联视频和图片的标识
    NSString *identifier = [NSUUID UUID].UUIDString;
    __block NSString *outVideoPath = nil;
    __block NSString *outImagePath = nil;
    
    [self exportVideoWithAsset:asset identifier:identifier completion:^(NSString *videoPath, NSError *error) {
        if (error) {
            !completion ?: completion(nil, nil, error);
            return;
        }
        outVideoPath = videoPath;
        if (outVideoPath && outImagePath) {
            !completion ?: completion(outVideoPath, outImagePath, nil);
        }
    }];
    
    [self exportImageWithAsset:asset imagePath:imagePath identifier:identifier completion:^(NSString *imagePath, NSError *error) {
        if (error) {
            !completion ?: completion(nil, nil, error);
        }
        outImagePath = imagePath;
        if (outVideoPath && outImagePath) {
            !completion ?: completion(outVideoPath, outImagePath, nil);
        }
    }];
}

- (void)createLivePhotoWithVideoPath:(NSString *)videoPath imagePath:(NSString *)imagePath targetSize:(CGSize)targetSize completion:(nonnull void (^)(PHLivePhoto * _Nullable, NSError * _Nullable))completion {
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
    if (!asset) {
        !completion ?: completion(nil, [self errorWithMsg:@"video asset not available"]);
        return;
    }
    
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    NSURL *imageURL = [NSURL fileURLWithPath:imagePath];
    
    [PHLivePhoto requestLivePhotoWithResourceFileURLs:@[videoURL, imageURL] placeholderImage:nil targetSize:targetSize contentMode:PHImageContentModeAspectFill resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nonnull info) {
        if (livePhoto) {
            !completion ?: completion(livePhoto, nil);
        }else {
            !completion ?: completion(nil, [self errorWithMsg:@"create livephoto failed"]);
        }
    }];
}

- (void)createLivePhotoWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize completion:(nonnull void (^)(PHLivePhoto * _Nullable, NSError * _Nullable))completion {
    if (asset.mediaSubtypes != PHAssetMediaSubtypePhotoLive) {
        !completion ?: completion(nil, [self errorWithMsg:@"asset is not livephoto"]);
        return;
    }
    PHLivePhotoRequestOptions *options = [[PHLivePhotoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    
    [[PHImageManager defaultManager] requestLivePhotoForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (livePhoto) {
                !completion ?: completion(livePhoto, nil);
            }else {
                !completion ?: completion(nil, [self errorWithMsg:@"create livephoto failed"]);
            }
        });
    }];
}

- (void)saveLivePhotoWithVideoPath:(NSString *)videoPath imagePath:(NSString *)imagePath completion:(void (^)(BOOL, NSError * _Nullable))completion {
    __weak __typeof(self) weakSelf = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (status == PHAuthorizationStatusAuthorized) {
            NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
            NSURL *imageURL = [NSURL fileURLWithPath:imagePath];
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                [request addResourceWithType:PHAssetResourceTypePairedVideo fileURL:videoURL options:options];
                [request addResourceWithType:PHAssetResourceTypePhoto fileURL:imageURL options:options];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    !completion ?: completion(success, error);
                });
            }];
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                !completion ?: completion(NO, [self errorWithMsg:@"not authorized"]);
            });
        }
    }];
}

#pragma mark - private
- (void)exportVideoWithAsset:(AVAsset *)asset identifier:(NSString *)identifier completion:(void(^)(NSString *videoPath, NSError *error))completion {
    NSString *outVideoPath = kOutVideoPath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:outVideoPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:outVideoPath error:nil];
    }
    
    AVAssetExportSession *exportSession  = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    item.key = @"com.apple.quicktime.content.identifier";
    item.keySpace = AVMetadataKeySpaceQuickTimeMetadata;
    item.value = identifier;
    item.dataType = @"com.apple.metadata.datatype.UTF-8";
    
    exportSession.metadata = @[item];
    exportSession.outputURL = [NSURL fileURLWithPath:outVideoPath];
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.shouldOptimizeForNetworkUse = YES;
    
    __block AVAssetExportSession *session = exportSession;
    __weak __typeof(self) weakSelf = self;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        __strong __typeof(weakSelf) self = weakSelf;
        switch (session.status) {
            case AVAssetExportSessionStatusUnknown:
                !completion ?: completion(nil, [self errorWithMsg:@"unknown error"]);
                break;
            case AVAssetExportSessionStatusCompleted:
                !completion ?: completion(outVideoPath, nil);
                break;
            case AVAssetExportSessionStatusFailed:
                !completion ?: completion(nil, session.error);
                break;
            default:
                break;
        }
    }];
}

- (void)exportImageWithAsset:(AVAsset *)asset imagePath:(NSString *)imagePath identifier:(NSString *)identifier completion:(void(^)(NSString *imagePath, NSError *error))completion {
    if (imagePath.length > 0) {
        [self handleImageWithPath:imagePath identifier:identifier completion:completion];
    }else {
        __weak __typeof(self) weakSelf = self;
        [self getTempImageWithAsset:asset completion:^(NSString *tempPath, NSError *error) {
            __strong __typeof(weakSelf) self = weakSelf;
            if (error) {
                !completion ?: completion(nil, error);
                return;
            }
            [self handleImageWithPath:tempPath identifier:identifier completion:^(NSString *imagePath, NSError *error) {
                // 删除临时文件
                if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
                }
                !completion ?: completion(imagePath, error);
            }];
        }];
    }
}

- (void)handleImageWithPath:(NSString *)imagePath identifier:(NSString *)identifier completion:(void(^)(NSString *imagePath, NSError *error))completion {
    NSString *outImagePath = kOutImagePath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:outImagePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:outImagePath error:nil];
    }
    
    NSURL *imageURL = [NSURL fileURLWithPath:imagePath];
    NSURL *outImageURL = [NSURL fileURLWithPath:outImagePath];
    
    CFStringRef type;
    if (@available(iOS 14.0, *)) {
        type = (__bridge CFStringRef)UTTypeJPEG.identifier;
    }else {
        type = kUTTypeJPEG;
    }
    
    CGImageDestinationRef dest = CGImageDestinationCreateWithURL((CFURLRef)outImageURL, type, 1, nil);
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)imageURL, nil);
    NSMutableDictionary *metaData = [(__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) mutableCopy];
    NSMutableDictionary *makerNote = [NSMutableDictionary dictionary];
    [makerNote setValue:identifier forKey:@"17"];
    [metaData setObject:makerNote forKey:(__bridge_transfer NSString *)kCGImagePropertyMakerAppleDictionary];
    CGImageDestinationAddImageFromSource(dest, imageSource, 0, (CFDictionaryRef)metaData);
    CGImageDestinationFinalize(dest);
    !completion ?: completion(outImagePath, nil);
    CFRelease(dest);
}

- (void)getTempImageWithAsset:(AVAsset *)asset completion:(void(^)(NSString *tempPath, NSError *error))completion {
    __weak __typeof(self) weakSelf = self;
    [self loadTracksWithAsset:asset completion:^(NSArray *tracks, NSError *error) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (error) {
            !completion ?: completion(nil, error);
            return;
        }
        AVAssetTrack *assetTrack = tracks.firstObject;
        if (!assetTrack) {
            !completion ?: completion(nil, [self errorWithMsg:@"get asset track failed"]);
            return;
        }
        AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        generator.appliesPreferredTrackTransform = YES;
        generator.maximumSize = assetTrack.naturalSize;
        
        CMTime time = CMTimeMakeWithSeconds(0, asset.duration.timescale);
        if (@available(iOS 16.0, *)) {
            [generator generateCGImageAsynchronouslyForTime:time completionHandler:^(CGImageRef  _Nullable image, CMTime actualTime, NSError * _Nullable error) {
                if (error) {
                    !completion ?: completion(nil, error);
                }else {
                    [self saveTempImage:image completion:completion];
                }
            }];
        }else {
            NSError *error = nil;
            CGImageRef image = [generator copyCGImageAtTime:time actualTime:nil error:&error];
            if (error) {
                !completion ?: completion(nil, error);
            }else {
                [self saveTempImage:image completion:completion];
            }
        }
    }];
}

- (void)saveTempImage:(CGImageRef)imageRef completion:(void(^)(NSString *tempPath, NSError *error))completion {
    NSData *data = UIImagePNGRepresentation([UIImage imageWithCGImage:imageRef]);
    NSString *tempPath = [kDocumentPath stringByAppendingPathComponent:@"temp.jpg"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
    }
    BOOL success = [data writeToFile:tempPath atomically:YES];
    if (success) {
        !completion ?: completion(tempPath, nil);
    }else {
        !completion ?: completion(nil, [self errorWithMsg:@"get image failed"]);
    }
}

- (void)loadTracksWithAsset:(AVAsset *)asset completion:(void(^)(NSArray *tracks, NSError *error))completion {
    if (@available(iOS 15.0, *)) {
        [asset loadTracksWithMediaType:AVMediaTypeVideo completionHandler:^(NSArray<AVAssetTrack *> *tracks, NSError *error) {
            !completion ?: completion(tracks, error);
        }];
    }else {
        NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        !completion ?: completion(tracks, nil);
    }
}

- (NSError *)errorWithMsg:(NSString *)msg {
    return [NSError errorWithDomain:@"com.quintgao.livephoto" code:-1 userInfo:@{NSLocalizedDescriptionKey: msg}];
}

@end
