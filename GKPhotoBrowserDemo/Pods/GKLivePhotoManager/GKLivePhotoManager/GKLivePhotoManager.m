//
//  GKLivePhotoManager.m
//  GKLivePhotoManager
//
//  Created by QuintGao on 2024/6/27.
//

#import "GKLivePhotoManager.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define kLivePhotoPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"GKLivePhoto"]
#define kOutVideoPath [kLivePhotoPath stringByAppendingPathComponent:@"livephoto.mov"]
#define kOutImageHeicPath [kLivePhotoPath stringByAppendingPathComponent:@"livephoto.heic"]
#define kOutImageJpegPath [kLivePhotoPath stringByAppendingPathComponent:@"livephoto.jpeg"]

@implementation GKLivePhotoManager

static GKLivePhotoManager *_manager = nil;
+ (instancetype)manager {
    if (_manager == nil) {
        _manager = [[GKLivePhotoManager alloc] init];
    }
    return _manager;
}

- (instancetype)init {
    if (self = [super init]) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:kLivePhotoPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:kLivePhotoPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

+ (void)deallocManager {
    [[NSFileManager defaultManager] removeItemAtPath:kOutVideoPath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:kOutImageHeicPath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:kOutImageJpegPath error:nil];
    _manager = nil;
}

- (void)handleDataWithVideoPath:(NSString *)videoPath progressBlock:(void (^ _Nullable)(float))progressBlock completion:(void (^ _Nullable)(NSString * _Nullable, NSString * _Nullable, NSError * _Nullable))completion {
    [self handleDataWithVideoPath:videoPath imagePath:nil progressBlock:progressBlock completion:completion];
}

- (void)handleDataWithVideoPath:(NSString *)videoPath imagePath:(NSString *)imagePath progressBlock:(void (^ _Nullable)(float))progressBlock completion:(void (^ _Nullable)(NSString * _Nullable, NSString * _Nullable, NSError * _Nullable))completion {
    if (![self isLocalPath:videoPath]) {
        !completion ?: completion(nil, nil, [self errorWithMsg:@"video is not local path"]);
        return;
    }
    if (imagePath.length > 0 && ![self isLocalPath:imagePath]) {
        !completion ?: completion(nil, nil, [self errorWithMsg:@"image is not local path"]);
        return;
    }
    
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
    if (!asset) {
        !completion ?: completion(nil, nil, [self errorWithMsg:@"video asset not available"]);
        return;
    }
    
    NSString *videoIdentifier = [self getVideoIdentifierWithAsset:asset];
    NSString *imageIdentifier = [self getImageIdentifierWithPath:imagePath];
    if (videoIdentifier.length && imageIdentifier.length && [videoIdentifier isEqualToString:imageIdentifier]) {
        // 不做处理，直接返回
        !progressBlock ?: progressBlock(1);
        !completion ?: completion(videoPath, imagePath, nil);
        return;
    }
    
    if (videoIdentifier.length) {
        [self exportImageWithAsset:asset imagePath:imagePath identifier:videoIdentifier completion:^(NSString *imagePath, NSError *error) {
            if (error) {
                !completion ?: completion(nil, nil, error);
                return;
            }
            if (imagePath) {
                !completion ?: completion(videoPath, imagePath, nil);
            }
        }];
        return;
    }
    
    // 关联视频和图片的标识
    NSString *identifier = [NSUUID UUID].UUIDString;
    __block NSString *outVideoPath = nil;
    __block NSString *outImagePath = nil;
    
    [self exportVideoWithAsset:asset identifier:identifier progressBlock:^(float progress) {
        !progressBlock ?: progressBlock(progress);
    } completion:^(NSString *videoPath, NSError *error) {
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
            return;
        }
        outImagePath = imagePath;
        if (outVideoPath && outImagePath) {
            !completion ?: completion(outVideoPath, outImagePath, nil);
        }
    }];
}

- (void)createLivePhotoWithVideoPath:(NSString *)videoPath imagePath:(NSString *)imagePath targetSize:(CGSize)targetSize completion:(void (^ _Nullable)(PHLivePhoto * _Nullable, NSError * _Nullable))completion {
    if (![self isLocalPath:videoPath]) {
        !completion ?: completion(nil, [self errorWithMsg:@"video is not local path"]);
        return;
    }
    
    if (![self isLocalPath:imagePath]) {
        !completion ?: completion(nil, [self errorWithMsg:@"image is not local path"]);
        return;
    }
    
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
    if (!asset) {
        !completion ?: completion(nil, [self errorWithMsg:@"video asset not available"]);
        return;
    }
    
    
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    NSURL *imageURL = [NSURL fileURLWithPath:imagePath];
    
    __weak __typeof(self) weakSelf = self;
    [PHLivePhoto requestLivePhotoWithResourceFileURLs:@[videoURL, imageURL] placeholderImage:nil targetSize:targetSize contentMode:PHImageContentModeAspectFill resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nonnull info) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (livePhoto) {
            !completion ?: completion(livePhoto, nil);
        }else {
            !completion ?: completion(nil, [self errorWithMsg:@"create livephoto failed"]);
        }
    }];
}

- (void)createLivePhotoWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize progressBlock:(void (^ _Nullable)(float))progressBlock completion:(void (^ _Nullable)(PHLivePhoto * _Nullable, NSError * _Nullable))completion {
    if (!asset) {
        !completion ?: completion(nil, [self errorWithMsg:@"asset is not exist"]);
        return;
    }
    
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        [self createLivePhotoWithVideoAsset:asset targetSize:targetSize progressBlock:progressBlock completion:completion];
    }else if (asset.mediaType == PHAssetMediaTypeImage && (asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive)) {
        [self createLivePhotoWithLivePhotoAsset:asset targetSize:targetSize progressBlock:progressBlock completion:completion];
    }else {
        !completion ?: completion(nil, [self errorWithMsg:@"asset is not available"]);
    }
}

- (void)createLivePhotoWithLivePhotoAsset:(PHAsset *)asset targetSize:(CGSize)targetSize progressBlock:(void (^ _Nullable)(float))progressBlock completion:(void (^ _Nullable)(PHLivePhoto * _Nullable, NSError * _Nullable))completion {
    PHLivePhotoRequestOptions *options = [[PHLivePhotoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) {
                !progressBlock ?: progressBlock(progress);
            }
        });
    };
    
    __weak __typeof(self) weakSelf = self;
    [[PHImageManager defaultManager] requestLivePhotoForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        __strong __typeof(weakSelf) self = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (livePhoto) {
                !completion ?: completion(livePhoto, nil);
            }else {
                !completion ?: completion(nil, [self errorWithMsg:@"create livephoto failed"]);
            }
        });
    }];
}

- (void)createLivePhotoWithVideoAsset:(PHAsset *)asset targetSize:(CGSize)targetSize progressBlock:(void(^_Nullable)(float))progressBlock completion:(void (^ _Nullable)(PHLivePhoto * _Nullable, NSError * _Nullable))completion {
    
    PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    
    __weak __typeof(self) weakSelf = self;
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable avAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (avAsset && [avAsset isKindOfClass:AVURLAsset.class]) {
            NSURL *videoUrl = [(AVURLAsset *)avAsset URL];
            __weak __typeof(self) weakSelf = self;
            [self handleDataWithVideoPath:videoUrl.path progressBlock:progressBlock completion:^(NSString * _Nullable outVideoPath, NSString * _Nullable outImagePath, NSError * _Nullable error) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self createLivePhotoWithVideoPath:outVideoPath imagePath:outImagePath targetSize:targetSize completion:completion];
            }];
        }else {
            !completion ?: completion(nil, [self errorWithMsg:@"video asset is not available"]);
        }
    }];
}

- (void)saveLivePhotoWithVideoPath:(NSString *)videoPath imagePath:(NSString *)imagePath completion:(void (^)(BOOL, NSError * _Nullable))completion {
    if (![self isLocalPath:videoPath]) {
        !completion ?: completion(NO, [self errorWithMsg:@"video is not local path"]);
        return;
    }
    
    if (![self isLocalPath:imagePath]) {
        !completion ?: completion(NO, [self errorWithMsg:@"image is not local path"]);
        return;
    }
    
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
- (void)exportVideoWithAsset:(AVAsset *)asset identifier:(NSString *)identifier progressBlock:(void(^)(float))progressBlock completion:(void(^)(NSString *videoPath, NSError *error))completion {
    if (![asset isKindOfClass:AVURLAsset.class]) {
        completion ?: completion(nil, [self errorWithMsg:@"video asset is not available"]);
        return;
    }
    
    Float64 length = CMTimeGetSeconds(asset.duration);
    
    Float64 cutLength = 0;
    
    if (@available(iOS 16.0, *)) {
        // iOS16之后最长设置为6s
        if (length > 6) {
            cutLength = 6;
        }
    }else {
        // iOS16之前最长设置为3s
        if (length > 3) {
            cutLength = 3;
        }
    }
    
    if (cutLength > 0) {
        __weak __typeof(self) weakSelf = self;
        [self cutVideoWithAsset:asset length:cutLength completion:^(NSString *tempPath, NSError *error) {
            __strong __typeof(weakSelf) self = weakSelf;
            if (error) {
                !completion ?: completion(nil, error);
                return;
            }
            AVURLAsset *urlAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:tempPath]];
            [self exportVideoWithUrlAsset:urlAsset identifier:identifier progressBlock:progressBlock completion:^(NSString *videoPath, NSError *error) {
                // 移除临时文件
                [self removeFileAtPath:tempPath];
                !completion ?: completion(videoPath, error);
            }];
        }];
    }else {
        AVURLAsset *urlAsset = (AVURLAsset *)asset;
        [self exportVideoWithUrlAsset:urlAsset identifier:identifier progressBlock:progressBlock completion:completion];
    }
}

- (void)cutVideoWithAsset:(AVAsset *)asset length:(Float64)length completion:(void(^)(NSString *videoPath, NSError *error))completion {
    // 裁剪视频
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *assetTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    compositionTrack.preferredTransform = assetTrack.preferredTransform;
    
    NSError *error = nil;
    CMTime duration = CMTimeMakeWithSeconds(length, asset.duration.timescale);
    [compositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration) ofTrack:assetTrack atTime:kCMTimeZero error:&error];
    if (error) {
        !completion ?: completion(nil, error);
        return;
    }
    
    NSString *tempPath = [kLivePhotoPath stringByAppendingPathComponent:@"temp.mp4"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
    }
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    
    exportSession.outputURL = [NSURL fileURLWithPath:tempPath];
    exportSession.outputFileType = AVFileTypeMPEG4;
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
                !completion ?: completion(tempPath, nil);
                break;
            case AVAssetExportSessionStatusFailed:
                !completion ?: completion(nil, session.error);
                break;
            case AVAssetExportSessionStatusExporting:
                
                break;
            default:
                break;
        }
    }];
}

- (void)exportVideoWithUrlAsset:(AVURLAsset *)urlAsset identifier:(NSString *)identifier progressBlock:(void(^)(float))progressBlock completion:(void(^)(NSString *videoPath, NSError *error))completion {
    AVURLAsset *metadataAsset = [AVURLAsset assetWithURL:[self metadataURL]];
    
    NSError *error = nil;
    AVAssetReader *videoReader = [AVAssetReader assetReaderWithAsset:urlAsset error:&error];
    if (error) {
        !completion ?: completion(nil, error);
        return;
    }
    
    AVAssetReader *metadataReader = [AVAssetReader assetReaderWithAsset:metadataAsset error:&error];
    if (error) {
        !completion ?: completion(nil, error);
        return;
    }
    
    NSString *outVideoPath = kOutVideoPath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:outVideoPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:outVideoPath error:nil];
    }
    
    // 创建文件写入类
    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:[NSURL fileURLWithPath:outVideoPath] fileType:AVFileTypeQuickTimeMovie error:&error];
    if (error) {
        !completion ?: completion(nil, error);
        return;
    }
    
    __weak __typeof(self) weakSelf = self;
    [self loadTracksWithAsset:urlAsset type:AVMediaTypeVideo completion:^(NSArray *tracks, NSError *error) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (error) {
            !completion ?: completion(nil, error);
            return;
        }
        NSMutableArray *videoIOs = [NSMutableArray array];
        NSMutableArray *metadataIOs = [NSMutableArray array];
        
        for (AVAssetTrack *track in tracks) {
            AVAssetReaderTrackOutput *output = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track outputSettings:@{(id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
            [videoReader addOutput:output];
            
            AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:@{AVVideoCodecKey: AVVideoCodecTypeH264, AVVideoWidthKey: @(track.naturalSize.width), AVVideoHeightKey: @(track.naturalSize.height)}];
            input.transform = track.preferredTransform;
            input.expectsMediaDataInRealTime = YES;
            [writer addInput:input];
            
            [videoIOs addObject:@{@"input": input, @"output": output}];
        }
        
        [self loadTracksWithAsset:metadataAsset type:AVMediaTypeMetadata completion:^(NSArray *tracks, NSError *error) {
            if (error) {
                !completion ?: completion(nil, error);
                return;
            }
            
            for (AVAssetTrack *track in tracks) {
                AVAssetReaderTrackOutput *output = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track outputSettings:nil];
                [metadataReader addOutput:output];
                
                AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeMetadata outputSettings:nil];
                [writer addInput:input];
                
                [metadataIOs addObject:@{@"input": input, @"output": output}];
            }
            
            writer.metadata = @[[self metadataItemWithAssetID:identifier]];
            [writer startWriting];
            [videoReader startReading];
            [metadataReader startReading];
            [writer startSessionAtSourceTime:kCMTimeZero];
            
            dispatch_group_t group = dispatch_group_create();
            
            
            NSInteger maxCount = videoIOs.count + metadataIOs.count;
            __block NSInteger curCount = 0;
            
            for (NSDictionary *dict in videoIOs) {
                dispatch_group_enter(group);
                AVAssetReaderTrackOutput *output = dict[@"output"];
                AVAssetWriterInput *input = dict[@"input"];
                [input requestMediaDataWhenReadyOnQueue:dispatch_queue_create("assetWriterQueue.video", nil) usingBlock:^{
                    while (input.isReadyForMoreMediaData) {
                        CMSampleBufferRef bufferRef = output.copyNextSampleBuffer;
                        if (bufferRef != NULL) {
                            [input appendSampleBuffer:bufferRef];
                            CFRelease(bufferRef);
                        }else {
                            [input markAsFinished];
                            curCount += 1;
                            !progressBlock ?: progressBlock((float)curCount/maxCount);
                            dispatch_group_leave(group);
                            break;
                        }
                    }
                }];
            }
            for (NSDictionary *dict in metadataIOs) {
                dispatch_group_enter(group);
                AVAssetReaderTrackOutput *output = dict[@"output"];
                AVAssetWriterInput *input = dict[@"input"];
                [input requestMediaDataWhenReadyOnQueue:dispatch_queue_create("assetWriterQueue.metadata", nil) usingBlock:^{
                    while (input.isReadyForMoreMediaData) {
                        CMSampleBufferRef bufferRef = output.copyNextSampleBuffer;
                        if (bufferRef != NULL) {
                            [input appendSampleBuffer:bufferRef];
                            CFRelease(bufferRef);
                        }else {
                            [input markAsFinished];
                            curCount += 1;
                            !progressBlock ?: progressBlock((float)curCount/maxCount);
                            dispatch_group_leave(group);
                            break;
                        }
                    }
                }];
            }
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                if (videoReader.status == AVAssetReaderStatusCompleted &&
                    metadataReader.status == AVAssetReaderStatusCompleted &&
                    writer.status == AVAssetWriterStatusWriting) {
                    [writer finishWritingWithCompletionHandler:^{
                        if (writer.error) {
                            !completion ?: completion(nil, writer.error);
                        }else {
                            !completion ?: completion(outVideoPath, nil);
                        }
                    }];
                }else {
                    if (videoReader.error) {
                        !completion ?: completion(nil, videoReader.error);
                    }else if (metadataReader.error) {
                        !completion ?: completion(nil, metadataReader.error);
                    }else if (writer.error) {
                        !completion ?: completion(nil, writer.error);
                    }else {
                        !completion ?: completion(nil, [self errorWithMsg:@"video writer unknown error"]);
                    }
                }
            });
        }];
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
    NSString *outImagePath = nil;
    NSURL *imageURL = [NSURL fileURLWithPath:imagePath];
    
    CFStringRef type;
    if (@available(iOS 14.0, *)) {
        CFArrayRef supportedTypes = CGImageDestinationCopyTypeIdentifiers();
        if (CFArrayContainsValue(supportedTypes, CFRangeMake(0, CFArrayGetCount(supportedTypes)), (__bridge const void *)(UTTypeHEIC.identifier))) {
            type = (__bridge CFStringRef)UTTypeHEIC.identifier;
            outImagePath = kOutImageHeicPath;
        }else {
            type = (__bridge CFStringRef)UTTypeJPEG.identifier;
        }
    }else {
        type = kUTTypeJPEG;
    }
    
    if (!outImagePath) {
        outImagePath = kOutImageJpegPath;
    }
    [self removeFileAtPath:outImagePath];
    
    NSURL *outImageURL = [NSURL fileURLWithPath:outImagePath];
    
    CGImageDestinationRef dest = CGImageDestinationCreateWithURL((CFURLRef)outImageURL, type, 1, NULL);
    if (!dest) {
        !completion ?: completion(nil, [self errorWithMsg:@"handle image failed"]);
        return;
    }
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)imageURL, NULL);
    NSMutableDictionary *metaData = [(__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL) mutableCopy];
    NSMutableDictionary *makerNote = nil;
    NSString *makerAppleKey = (__bridge_transfer NSString *)kCGImagePropertyMakerAppleDictionary;
    if ([metaData.allKeys containsObject:makerAppleKey]) {
        id makerApple = metaData[makerAppleKey];
        if ([makerApple isKindOfClass:NSDictionary.class]) {
            makerNote = [NSMutableDictionary dictionaryWithDictionary:makerApple];
        }
    }
    if (!makerNote) {
        makerNote = [NSMutableDictionary dictionary];
    }
    
    [makerNote setValue:identifier forKey:@"17"];
    [metaData setObject:makerNote forKey:makerAppleKey];
    CGImageDestinationAddImageFromSource(dest, imageSource, 0, (CFDictionaryRef)metaData);
    CGImageDestinationFinalize(dest);
    !completion ?: completion(outImagePath, nil);
    CFRelease(imageSource);
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
    NSString *tempPath = [kLivePhotoPath stringByAppendingPathComponent:@"temp.jpg"];
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

- (void)loadTracksWithAsset:(AVAsset *)asset type:(AVMediaType)type completion:(void(^)(NSArray *tracks, NSError *error))completion {
    if (@available(iOS 15.0, *)) {
        [asset loadTracksWithMediaType:type completionHandler:^(NSArray<AVAssetTrack *> *tracks, NSError *error) {
            !completion ?: completion(tracks, error);
        }];
    }else {
        NSArray *tracks = [asset tracksWithMediaType:type];
        !completion ?: completion(tracks, nil);
    }
}

- (NSString *)getVideoIdentifierWithAsset:(AVAsset *)asset {
    if (!asset) return nil;
    NSArray *items = [asset metadata];
    if (!items || items.count <= 0) return nil;
    __block NSString *identifier = nil;
    [items enumerateObjectsUsingBlock:^(AVMetadataItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([item.key isEqual:@"com.apple.quicktime.content.identifier"]) {
            if ([item.value isKindOfClass:NSString.class]) {
                identifier = (NSString *)item.value;
            }
        }
    }];
    return identifier;
}

- (NSString *)getImageIdentifierWithPath:(NSString *)imagePath {
    if (!imagePath) return nil;
    NSURL *imageURL = [NSURL fileURLWithPath:imagePath];
    if (!imageURL) return nil;
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)imageURL, NULL);
    if (!imageSource) return nil;
    CFDictionaryRef metadata = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
    if (!metadata) {
        CFRelease(imageSource);
        return nil;
    }
    NSDictionary *metadataDict = (__bridge NSDictionary *)metadata;
    
    NSString *identifier = nil;
    NSString *makerAppleKey = (__bridge_transfer NSString *)kCGImagePropertyMakerAppleDictionary;
    if ([metadataDict.allKeys containsObject:makerAppleKey]) {
        id makerApple = metadataDict[makerAppleKey];
        if ([makerApple isKindOfClass:NSDictionary.class]) {
            NSDictionary *dict = (NSDictionary *)makerApple;
            if ([dict.allKeys containsObject:@"17"]) {
                identifier = dict[@"17"];
            }
        }
    }
    
    CFRelease(metadata);
    CFRelease(imageSource);
    
    return identifier;
}

- (BOOL)isLocalPath:(NSString *)path {
    if (!path) return NO;
    if ([path hasPrefix:@"/"]) {
        return [[NSFileManager defaultManager] fileExistsAtPath:path];
    }
    return NO;
}

- (NSError *)errorWithMsg:(NSString *)msg {
    return [NSError errorWithDomain:@"com.quintgao.livephoto" code:-1 userInfo:@{NSLocalizedDescriptionKey: msg}];
}

- (void)removeFileAtPath:(NSString *)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

- (NSURL *)metadataURL {
    static NSBundle *resourceBundle = nil;
    if (!resourceBundle) {
        NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"GKLivePhotoManager")];
        NSURL *bundleURL = [bundle URLForResource:@"GKLivePhotoManager" withExtension:@"bundle"];
        if (bundleURL == nil) {
            NSURL *associatedBundleURL = [[NSBundle mainBundle] URLForResource:@"Frameworks" withExtension:nil];
            NSURL *url = [[associatedBundleURL URLByAppendingPathComponent:@"GKLivePhotoManager"] URLByAppendingPathExtension:@"framework"];
            if (url) {
                NSBundle *associatedBundle = [NSBundle bundleWithURL:url];
                bundleURL = [associatedBundle URLForResource:@"GKLivePhotoManager" withExtension:@"bundle"];
            }
        }
        resourceBundle = [NSBundle bundleWithURL:bundleURL] ?: bundle;
    }
    return [resourceBundle URLForResource:@"metadata" withExtension:@"mov"];
}

- (AVMetadataItem *)metadataItemWithAssetID:(NSString *)assetIdentifier {
    AVMutableMetadataItem *item = [[AVMutableMetadataItem alloc] init];
    item.key = @"com.apple.quicktime.content.identifier";
    item.keySpace = @"mdta";
    item.value = assetIdentifier;
    item.dataType = @"com.apple.metadata.datatype.UTF-8";
    return item;
}

@end
