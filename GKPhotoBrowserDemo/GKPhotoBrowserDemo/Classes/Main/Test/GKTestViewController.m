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
#import <Masonry/Masonry.h>
#import <PhotosUI/PhotosUI.h>
#import <SDWebImage/SDWebImage.h>
#import <AFNetworking/AFNetworking.h>
#import "GKPhotosView.h"
#import "GKTimeLineModel.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <GKLivePhotoManager/GKLivePhotoManager.h>
#import <ZLPhotoBrowser-Swift.h>

@interface GKTestViewController ()<GKPhotosViewDelegate, UIDocumentPickerDelegate, GKPhotoBrowserDelegate>

@property (nonatomic, strong) GKPhotosView *photosView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, weak) GKPhotoBrowser *browser;

@property (nonatomic, strong) PHLivePhotoView *livePhotoView;

@end

@implementation GKTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationItem.title = @"测试";
    self.view.backgroundColor = [UIColor whiteColor];
    self.dataSource = [NSMutableArray array];
    
    [self setupView];
    [self setupData];
}

- (void)dealloc {
    [GKLivePhotoManager deallocManager];
}

- (void)setupView {
    self.photosView =  [GKPhotosView photosViewWithWidth:self.view.bounds.size.width - 20 andMargin:10];
    self.photosView.delegate = self;
    [self.view addSubview:self.photosView];
    
    UIButton *albumBtn = [[UIButton alloc] init];
    albumBtn.backgroundColor = UIColor.blackColor;
    albumBtn.layer.cornerRadius = 5;
    albumBtn.layer.masksToBounds = YES;
    [albumBtn setTitle:@"添加相册资源" forState:UIControlStateNormal];
    [albumBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [albumBtn addTarget:self action:@selector(albumClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:albumBtn];
    
    [albumBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.photosView.mas_bottom).offset(30);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(180);
    }];
    
    UIButton *fileBtn = [[UIButton alloc] init];
    fileBtn.backgroundColor = UIColor.blackColor;
    fileBtn.layer.cornerRadius = 5;
    fileBtn.layer.masksToBounds = YES;
    [fileBtn setTitle:@"添加文件资源" forState:UIControlStateNormal];
    [fileBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [fileBtn addTarget:self action:@selector(fileClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fileBtn];
    
    [fileBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(albumBtn.mas_bottom).offset(30);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(180);
    }];
    
    self.livePhotoView = [[PHLivePhotoView alloc] init];
    [self.view addSubview:self.livePhotoView];
    
    [self.livePhotoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fileBtn.mas_bottom).offset(30);
        make.centerX.equalTo(self.view);
        make.width.height.mas_equalTo(300);
    }];
}

- (void)setupData {
    
//    self.dataSource = @[@[@"http://p1.music.126.net/9k3CAPfB9WdcMCFk4CYnKQ==/109951167793871917.jpg?imageView&quality=89",
//         @"http://p1.music.126.net/GK7JvutM88U4ZkohN71TKQ==/109951167794081491.jpg?imageView&quality=89",
////         @"http://p1.music.126.net/QywPBMy3VK-P-wk_eYjrZw==/109951167793910298.jpg?imageView&quality=89",
////         @"http://p1.music.126.net/c4vOjlBA5bQsmpuASPi5QQ==/109951167794545716.jpg?imageView&quality=89",
////         @"http://p1.music.126.net/4ryVvqlvXp0Kh_fcxCWMsA==/109951166903789195.jpg?param=140y140",
//         @"http://p1.music.126.net/gZWQbChzhCbGFXtpin2MXw==/109951167592864239.jpg?param=140y140"]
//                        ];
//    self.dataSource = @[@[@"002"]];
//    self.dataSource = @[@[@"002", @"test.gif"]];
    
    // 1、网络图片
    GKTimeLineImage *m1 = [[GKTimeLineImage alloc] init];
    m1.url = @"http://p1.music.126.net/9k3CAPfB9WdcMCFk4CYnKQ==/109951167793871917.jpg?imageView&quality=89";
    [self.dataSource addObject:m1];
    
    // 2、项目Assets下的图片
    GKTimeLineImage *m2 = [[GKTimeLineImage alloc] init];
    m2.url = @"002";
    [self.dataSource addObject:m2];
    
    // 3、项目工程下的图片
    GKTimeLineImage *m3 = [[GKTimeLineImage alloc] init];
    m3.url = @"test.gif";
    [self.dataSource addObject:m3];
    
    [self updatePhotosView];
    
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"IMG_E8375" ofType:@"mov"];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"IMG_E8375" ofType:@"heic"];
    
    [[GKLivePhotoManager manager] createLivePhotoWithVideoPath:videoPath imagePath:imagePath targetSize:CGSizeMake(300, 300) completion:^(PHLivePhoto * _Nullable livePhoto, NSError * _Nullable error) {
        if (livePhoto) {
            self.livePhotoView.livePhoto = livePhoto;
            [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
        }else {
            NSLog(@"create live photo error:%@", error);
        }
    }];
}

- (void)updatePhotosView {
    CGFloat height = [GKPhotosView sizeWithCount:self.dataSource.count width:self.view.bounds.size.width - 20 andMargin:10].height;
    CGFloat y = CGRectGetMaxY(self.gk_navigationBar.frame) + 20;
    self.photosView.frame = CGRectMake(10, y, self.view.bounds.size.width - 20, height);
    self.photosView.images = self.dataSource;
}

- (void)albumClick {
    ZLPhotoConfiguration *config = [ZLPhotoConfiguration default];
    config.allowSelectImage = YES;
    config.allowSelectGif = YES;
    config.allowSelectVideo = YES;
    config.allowSelectLivePhoto = YES;
    config.maxSelectCount = 1;
    
    ZLPhotoPreviewSheet *picker = [[ZLPhotoPreviewSheet alloc] init];
    __weak __typeof(self) weakSelf = self;
    [picker setSelectImageBlock:^(NSArray<ZLResultModel *> *models, BOOL success) {
        __strong __typeof(weakSelf) self = weakSelf;
        GKTimeLineImage *m = [[GKTimeLineImage alloc] init];
        m.coverImage = models.firstObject.image;
        PHAsset *asset = models.firstObject.asset;
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            m.video_asset = asset;
        }else if (asset.mediaType == PHAssetMediaTypeImage) {
            m.image_asset = asset;
            m.isLivePhoto = asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive;
        }
        [self.dataSource addObject:m];
        
        [self updatePhotosView];
    }];
    [picker showPhotoLibraryWithSender:self];
}

- (void)fileClick {
    
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(nonnull NSArray<NSURL *> *)urls {
    for (NSURL *url in urls) {
        if ([self isVideoFileWithUrl:url]) {
            GKTimeLineImage *m = [[GKTimeLineImage alloc] init];
            m.islocal = YES;
            m.video_url = url.path;
            [self.dataSource addObject:m];
            
            [self updatePhotosView];
        }else if ([self isImageFileWithUrl:url]) {
            GKTimeLineImage *m = [[GKTimeLineImage alloc] init];
            m.islocal = YES;
            m.url = url.path;
            [self.dataSource addObject:m];
            
            [self updatePhotosView];
        }else {
            NSLog(@"未知类型文件");
        }
    }
}

#pragma mark - GKPhotosViewDelegate
- (void)photoTapped:(UIImageView *)imgView {
    NSMutableArray *photos = [NSMutableArray new];
    
    [self.dataSource enumerateObjectsUsingBlock:^(GKTimeLineImage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GKPhoto *photo = [[GKPhoto alloc] init];
        if (obj.image_asset) {
            photo.imageAsset = obj.image_asset;
        }
        if (obj.video_asset) {
            photo.videoAsset = obj.video_asset;
        }
        if (obj.url) {
            if (obj.islocal) {
                photo.url = [NSURL fileURLWithPath:obj.url];
            }else {
                photo.url = [NSURL URLWithString:obj.url];
            }
        }
        if (obj.video_url) {
            if (obj.islocal) {
                photo.videoUrl = [NSURL fileURLWithPath:obj.video_url];
            }else {
                photo.videoUrl = [NSURL URLWithString:obj.video_url];
            }
        }
        
        photo.sourceImageView = self.photosView.subviews[idx];
        [photos addObject:photo];
    }];
    
    NSInteger index = imgView.tag;
    
    GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photos currentIndex:index];
    browser.configure.showStyle    = GKPhotoBrowserShowStyleZoom;
    browser.configure.hideStyle    = GKPhotoBrowserHideStyleZoomScale;
    browser.configure.isNeedNavigationController = YES;
    
//        [browser.configure setupWebImageProtocol:[LocalImageLoadManager new]];
    [browser.configure setupWebImageProtocol:nil];
//    
//    [browser setupCoverViews:@[UIView.new] layoutBlock:^(GKPhotoBrowser *browser, CGRect frame) {
//        NSLog(@"%f", browser.view.safeAreaInsets.top);
//        NSLog(@"%@", NSStringFromCGRect(UIApplication.sharedApplication.statusBarFrame));
//        NSLog(@"%@", NSStringFromCGRect([(UIWindowScene *)UIApplication.sharedApplication.connectedScenes.anyObject statusBarManager].statusBarFrame));
//    }];
    
    browser.delegate = self;
    [browser showFromVC:self];
    self.browser = browser;
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

#pragma mark - private
- (BOOL)isVideoFileWithUrl:(NSURL *)url {
    // 常见的视频文件扩展名
    NSArray *videoExtensions = @[@"mp4", @"mov", @"avi", @"mkv", @"flv", @"wmv", @"webm", @"m4v"];
    
    // 获取文件扩展名并转为小写
    NSString *fileExtension = url.pathExtension.lowercaseString;
    
    // 判断扩展名是否为视频文件类型
    return [videoExtensions containsObject:fileExtension];
}

- (BOOL)isImageFileWithUrl:(NSURL *)url {
    NSArray *imageExtensions = @[@"jpg", @"jpeg", @"png", @"gif", @"tiff", @"heic"];
    
    NSString *fileExtension = url.pathExtension.lowercaseString;
    
    return [imageExtensions containsObject:fileExtension];
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
