//
//  GKTestViewController.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2018/5/14.
//  Copyright © 2018年 QuintGao. All rights reserved.
//

#import "GKTestViewController.h"
#import "GKTest02ViewCell.h"
#import "GKBottomView.h"
#import <GKPhotoBrowser/GKPhotoBrowser.h>
#import "GKVideoProgressView.h"
#import <Masonry/Masonry.h>
#import <PhotosUI/PhotosUI.h>
#import <SDWebImage/SDWebImage.h>
#import <AFNetworking/AFNetworking.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <GKLivePhotoManager/GKLivePhotoManager.h>
#import "KNProgressHUD.h"

@interface GKTestViewController ()<UITableViewDataSource, UITableViewDelegate, GKPhotoBrowserDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, weak) GKPhotoBrowser *browser;

@property (nonatomic, weak) GKVideoProgressView *progressView;

@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) NSTimeInterval totalTime;

@property (nonatomic, assign) BOOL movieFinished;
@property (nonatomic, assign) BOOL imageFinished;

@property (nonatomic, strong) PHLivePhotoView *photoView;

@property (nonatomic, strong) GKLoadingView *loadingView;

@property (nonatomic, strong) KNProgressHUD *hud;

@property (nonatomic, assign) float progress;

@end

@implementation GKTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationItem.title = @"test02";
    self.view.backgroundColor = [UIColor whiteColor];
    
//    GKVideoProgressView *progressView = [[GKVideoProgressView alloc] init];
//    progressView.backgroundColor = UIColor.redColor;
//    [self.view addSubview:progressView];
//
////    [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
////        make.left.right.equalTo(self.view);
////        make.top.equalTo(self.gk_navigationBar.mas_bottom).offset(50);
////        make.height.mas_equalTo(80);
////    }];
//    progressView.frame = CGRectMake(0, 200, self.view.bounds.size.width, 80);
//    self.progressView = progressView;
    
//    self.totalTime = 10;
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeCount) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
//    GKBottomView *btmView = [GKBottomView new];
//    btmView.frame = CGRectMake(0, 100, self.view.frame.size.width, 100);
//    [self.view addSubview:btmView];
//    [self setupView];
//
//    [self setupData];
    
//    self.photoView = [[PHLivePhotoView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 300)/2, 100, 300, 300)];
//    [self.view addSubview:self.photoView];
//    
//    [self requestMovie];
    
    self.view.backgroundColor = UIColor.blackColor;
    
    self.loadingView = [GKLoadingView loadingViewWithFrame:self.view.bounds style:GKLoadingStyleDeterminateSector];
    self.loadingView.radius = 40;
    self.loadingView.lineWidth = 1;
    self.loadingView.bgColor = UIColor.whiteColor;
    self.loadingView.strokeColor = UIColor.whiteColor;
    [self.view addSubview:self.loadingView];
    
    [self.loadingView startLoading];
    
//    self.hud = [[KNProgressHUD alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
//    [self.view addSubview:self.hud];
//    
//    self.progress = 0;
    
    [self addProgress];
}

- (void)addProgress {
    if (self.progress >= 1.0) {
        return;
    }
    self.progress += 0.01;
    self.loadingView.progress = self.progress;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addProgress];
    });
}

- (void)requestMovie {
    NSURL *movieURL = [NSURL URLWithString:@"https://video.weibo.com/media/play?livephoto=https%3A%2F%2Fus.sinaimg.cn%2F002TS7JWjx08fNcQ4Aar0f0f0100e0dt0k01.mov"];
    NSURL *imageURL = [NSURL URLWithString:@"https://wx2.sinaimg.cn/orj360/c4d5a512ly1hqvjl5qkfij22by2quqv7.jpg"];
    
    NSString *url = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"test"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:url]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:url withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *moviePath = [url stringByAppendingPathComponent:@"test.mov"];
    NSString *imagePath = [url stringByAppendingPathComponent:@"test.jpg"];
    [[NSFileManager defaultManager] removeItemAtPath:moviePath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
    
    NSURL *movieFileURL = [NSURL fileURLWithPath:moviePath];
    NSURL *imageFileURL = [NSURL fileURLWithPath:imagePath];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    __block BOOL movieFinished = NO;
    __block BOOL imageFinished = NO;
    
    [[manager downloadTaskWithRequest:[NSURLRequest requestWithURL:movieURL] progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return movieFileURL;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        movieFinished = YES;
        if (movieFinished && imageFinished) {
            [self loadLivePhotoWith:moviePath imagePath:imagePath];
        }
    }] resume];
    
    [[manager downloadTaskWithRequest:[NSURLRequest requestWithURL:imageURL] progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return imageFileURL;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        imageFinished = YES;
        if (movieFinished && imageFinished) {
            [self loadLivePhotoWith:moviePath imagePath:imagePath];
        }
    }] resume];
}

- (void)loadLivePhotoWith:(NSString *)moviePath imagePath:(NSString *)imagePath {
//    [[GKLivePhotoManager manager] handleDataWithVideoPath:moviePath imagePath:imagePath completion:^(NSString * _Nullable outVideoPath, NSString * _Nullable outImagePath, NSError * _Nullable error) {
//        [[GKLivePhotoManager manager] createLivePhotoWithVideoPath:outVideoPath imagePath:outImagePath targetSize:CGSizeMake(300, 300) completion:^(PHLivePhoto * _Nullable livePhoto, NSError * _Nullable error) {
//            if (livePhoto) {
//                self.photoView.livePhoto = livePhoto;
//                [self.photoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
//            }
//        }];
//    }];
}

- (void)getImageWithPath:(NSURL *)filePath completion:(void(^)(NSString *imagePath))completion {
    AVURLAsset *asset = [AVURLAsset assetWithURL:filePath];
    
    AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = track.naturalSize;
    CGImageRef image = [generator copyCGImageAtTime:CMTimeMakeWithSeconds(0, asset.duration.timescale) actualTime:nil error:nil];
    if (image != nil) {
        NSData *data = UIImagePNGRepresentation([UIImage imageWithCGImage:image]);
        NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL *url = urls[0];
        NSString *imageURL = [url.path stringByAppendingPathComponent:@"temp.jpg"];
        [data writeToFile:imageURL atomically:YES];
        !completion ?: completion(imageURL);
        CGImageRelease(image);
    }
}

- (void)dealImageWithOriginPath:(NSString *)originPath
                 filePath:(NSString *)finalPath
                     assetIdentifier:(NSString *)assetIdentifier {
    CGImageDestinationRef dest = CGImageDestinationCreateWithURL((CFURLRef)[NSURL fileURLWithPath:finalPath], kUTTypeJPEG, 1, nil);
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData((CFDataRef)[NSData dataWithContentsOfFile:originPath], nil);
    NSMutableDictionary *metaData = [(__bridge_transfer  NSDictionary*)CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, nil) mutableCopy];
    
    NSMutableDictionary *makerNote = [NSMutableDictionary dictionary];
    [makerNote setValue:assetIdentifier forKey:@"17"];
    [metaData setValue:makerNote forKey:(__bridge_transfer  NSString*)kCGImagePropertyMakerAppleDictionary];
    CGImageDestinationAddImageFromSource(dest, imageSourceRef, 0, (CFDictionaryRef)metaData);
    CGImageDestinationFinalize(dest);
    CFRelease(dest);
}

- (void)movieTransformWithSourcePath:(NSString *)sourcePath outputPath:(NSString *)outputPath identifier:(NSString *)identifier success:(void(^)(NSString *videoPath))success failure:(void(^)(NSString *error))failure {
    NSURL *sourceURL = [NSURL fileURLWithPath:sourcePath];
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:sourceURL options:nil];
    NSArray *comptiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    if ([comptiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
        AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
        item.key = @"com.apple.quicktime.content.identifier";
        item.keySpace = AVMetadataKeySpaceQuickTimeMetadata;
        item.value = identifier;
        item.dataType = @"com.apple.metadata.datatype.UTF-8";
        NSArray *metadata = [NSArray arrayWithObject:item];
        session.metadata = metadata;
        session.outputURL = [NSURL fileURLWithPath:outputPath];
        session.outputFileType = AVFileTypeQuickTimeMovie;
        session.shouldOptimizeForNetworkUse = YES;
        
        // 如果有文件则直接返回
        if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
            !success ?: success(outputPath);
            return;
        }
        
        __block AVAssetExportSession *weakSession = session;
        [session exportAsynchronouslyWithCompletionHandler:^{
            switch (weakSession.status) {
                case AVAssetExportSessionStatusUnknown: {
                    NSLog(@"未知状态");
                }
                    break;
                case AVAssetExportSessionStatusWaiting: {
                    NSLog(@"等待中");
                }
                    break;
                case AVAssetExportSessionStatusExporting: {
                    NSLog(@"导出中");
                }
                    break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"导出完成");
                    !success ?: success(outputPath);
                }
                    break;
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"导出失败");
                    !failure ?: failure(weakSession.error.localizedDescription);
                }
                    break;
                case AVAssetExportSessionStatusCancelled:{
                    NSLog(@"导出取消");
                    !failure ?: failure(weakSession.error.localizedDescription);
                }
                    break;
                default:
                    break;
            }
        }];
    }
}

- (void)requestLivePhotoWithMovieURL:(NSURL *)movieURL imageURL:(NSURL *)imageURL {
//    NSString *moviePath = [[NSBundle mainBundle] pathForResource:@"IMG_E8375" ofType:@"mov"];
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"IMG_E8375" ofType:@"heic"];
//    
//    movieURL = [NSURL fileURLWithPath:moviePath];
//    imageURL = [NSURL fileURLWithPath:imagePath];
    
//    [self addAssetID:NSUUID.UUID.UUIDString imageURL:imageURL destinationURL:imageURL];
    
    NSLog(@"requestLivePhoto");
    
    [PHLivePhoto requestLivePhotoWithResourceFileURLs:@[movieURL, imageURL] placeholderImage:nil targetSize:CGSizeMake(300, 300) contentMode:PHImageContentModeAspectFill resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nonnull info) {
        NSLog(@"%@--%@", livePhoto, info);
        if (livePhoto) {
            [self.photoView setLivePhoto:livePhoto];
        }
    }];
}

- (void)addAssetID:(NSString *)assetIdentifier imageURL:(NSURL *)imageURL destinationURL:(NSURL *)destinationURL {
    NSString *kFigAppleMakerNote_AssetIdentifier = @"17";
    
    NSData *data = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = [[UIImage alloc] initWithData:data];
    
    CGImageRef imageRef = image.CGImage;
    
    NSDictionary *imageMetadata = @{(NSString *)kCGImagePropertyMakerAppleDictionary : @{kFigAppleMakerNote_AssetIdentifier : assetIdentifier}};
    
    CFStringRef type = CGImageGetUTType(imageRef);
//    CGImageDestinationRef dest = CGImageDestinationCreateWithData((CFMutableDataRef)data, type, 1, nil);
    
//    CFURLRef ref;
    CFURLRef urlRef = (__bridge CFURLRef)destinationURL;
    
    CGImageDestinationRef dest = CGImageDestinationCreateWithURL(urlRef, type, 1, nil);
    
    CGImageDestinationAddImage(dest, imageRef, (CFDictionaryRef)imageMetadata);
    CGImageDestinationFinalize(dest);
    
    
    
    
    
//    CGImageDestinationRef dest = CGImageDestinationCreateWithURL((CFURLRef)[NSURL fileURLWithPath:finalPath], kUTTypeJPEG, 1, nil);
//    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData((CFDataRef)[NSData dataWithContentsOfFile:originPath], nil);
//    NSMutableDictionary *metaData = [(__bridge_transfer  NSDictionary*)CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, nil) mutableCopy];
//    
//    NSMutableDictionary *makerNote = [NSMutableDictionary dictionary];
//    [makerNote setValue:assetIdentifier forKey:@"17"];
//    [metaData setValue:makerNote forKey:(__bridge_transfer  NSString*)kCGImagePropertyMakerAppleDictionary];
//    CGImageDestinationAddImageFromSource(dest, imageSourceRef, 0, (CFDictionaryRef)metaData);
//    CGImageDestinationFinalize(dest);
//    CFRelease(dest);
}

- (AVAsset *)cutVideoWithPath:(NSString *)videoPath {
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
    return asset;
}

- (void)timeCount {
    self.currentTime ++;
    if (self.currentTime > self.totalTime) {
        self.currentTime = 0;
    }
    [self.progressView updateCurrentTime:self.currentTime totalTime:self.totalTime];
}

- (void)setupView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.top        = self.gk_navigationBar.bottom;
    self.tableView.height     = self.view.height - self.gk_navigationBar.height;
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    self.tableView.rowHeight  = 200;
    [self.tableView registerClass:[GKTest02ViewCell class] forCellReuseIdentifier:@"test02"];
    [self.view addSubview:self.tableView];
}

- (void)setupData {
    
    self.dataSource = @[@[@"http://p1.music.126.net/9k3CAPfB9WdcMCFk4CYnKQ==/109951167793871917.jpg?imageView&quality=89",
         @"http://p1.music.126.net/GK7JvutM88U4ZkohN71TKQ==/109951167794081491.jpg?imageView&quality=89",
//         @"http://p1.music.126.net/QywPBMy3VK-P-wk_eYjrZw==/109951167793910298.jpg?imageView&quality=89",
//         @"http://p1.music.126.net/c4vOjlBA5bQsmpuASPi5QQ==/109951167794545716.jpg?imageView&quality=89",
//         @"http://p1.music.126.net/4ryVvqlvXp0Kh_fcxCWMsA==/109951166903789195.jpg?param=140y140",
         @"http://p1.music.126.net/gZWQbChzhCbGFXtpin2MXw==/109951167592864239.jpg?param=140y140"]
                        ];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKTest02ViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"test02" forIndexPath:indexPath];
    
    cell.photos = self.dataSource[indexPath.row];
    
    cell.imgClickBlock = ^(UIView *containerView, NSArray *photos, NSInteger index) {
        NSMutableArray *photoArrs = [NSMutableArray new];
        
        [photos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GKPhoto *photo        = [GKPhoto new];
            if ([obj hasPrefix:@"http"]) {
                photo.url         = [NSURL URLWithString:obj];
            }else {
                photo.image       = [UIImage imageNamed:obj];
            }
            photo.sourceImageView = containerView.subviews[idx];
            [photoArrs addObject:photo];
        }];
        
        GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photoArrs currentIndex:index];
        //        browser.photos       = photoArrs;
        //        browser.currentIndex = index;
        browser.showStyle    = GKPhotoBrowserShowStyleZoom;
        browser.hideStyle    = GKPhotoBrowserHideStyleZoomScale;
//        browser.isFollowSystemRotation = YES;
        browser.addNavigationController = YES;
        
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[UIImage imageNamed:@"cm2_list_detail_icn_cmt"] forState:UIControlStateNormal];
        [btn sizeToFit];
        
        [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
        
        [browser setupCoverViews:@[btn] layoutBlock:^(GKPhotoBrowser * _Nonnull photoBrowser, CGRect superFrame) {
            CGRect frame = btn.frame;
            frame.origin.x = superFrame.size.width - frame.size.width - 30;
            frame.origin.y = superFrame.size.height - frame.size.height - 30;
            btn.frame = frame;
        }];
        
        browser.delegate = self;
        [browser showFromVC:self];
        self.browser = browser;
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [photoArrs enumerateObjectsUsingBlock:^(GKPhoto *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                if (idx == 2) {
//                    obj.videoUrl = [NSURL URLWithString:@"http://vd3.bdstatic.com/mda-ph53eii3pywz9ax9/cae_h264/1691439126672883676/mda-ph53eii3pywz9ax9.mp4"];
//                }
//            }];
//            [self.browser resetPhotoBrowserWithPhotos:photoArrs];
//        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            GKPhoto *photo = photoArrs[2];
            photo.videoUrl = [NSURL URLWithString:@"http://vd3.bdstatic.com/mda-ph53eii3pywz9ax9/cae_h264/1691439126672883676/mda-ph53eii3pywz9ax9.mp4"];
            [self.browser resetPhotoBrowserWithPhoto:photo index:2];
        });
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *images = self.dataSource[indexPath.row];
    
    return [GKTest02ViewCell cellHeightWithWidth:self.view.bounds.size.width count:images.count];
}

- (void)pangesture:(UIPanGestureRecognizer *)pan {
    
}

- (void)btnClick {
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = UIColor.grayColor;
    [self.browser.navigationController setNavigationBarHidden:NO];
    [self.browser.navigationController pushViewController:vc animated:YES];
}

#pragma mark - GKPhotoBrowserDelegate
- (void)photoBrowser:(GKPhotoBrowser *)browser didDisappearAtIndex:(NSInteger)index {
    
}

- (void)photoBrowser:(GKPhotoBrowser *)browser willLayoutSubViews:(NSInteger)index {
    CGFloat width = browser.contentView.bounds.size.width;
    CGFloat height = browser.contentView.bounds.size.height;
    
    browser.pageControl.center = CGPointMake(width * 0.5, height - kSafeBottomSpace - 10);
}

#pragma mark - 懒加载
- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [UIView new];
        _coverView.backgroundColor = [UIColor redColor];
        [_coverView addGestureRecognizer:self.panGesture];
    }
    return _coverView;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pangesture:)];
    }
    return _panGesture;
}

@end
