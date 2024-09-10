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
#import <TZImagePickerController/TZImagePickerController.h>
#import <MobileCoreServices/MobileCoreServices.h>


@interface GKTestViewController ()<GKPhotosViewDelegate, TZImagePickerControllerDelegate, UIDocumentPickerDelegate, GKPhotoBrowserDelegate>

@property (nonatomic, strong) GKPhotosView *photosView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, weak) GKPhotoBrowser *browser;

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
}

- (void)updatePhotosView {
    CGFloat height = [GKPhotosView sizeWithCount:self.dataSource.count width:self.view.bounds.size.width - 20 andMargin:10].height;
    CGFloat y = CGRectGetMaxY(self.gk_navigationBar.frame) + 20;
    self.photosView.frame = CGRectMake(10, y, self.view.bounds.size.width - 20, height);
    self.photosView.images = self.dataSource;
}

- (void)albumClick {
    TZImagePickerController *picker = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    picker.allowPickingGif = YES;
    picker.allowPickingImage = YES;
    picker.allowPickingVideo = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)fileClick {
    
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - TZImagePickerControllerDelegate
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(PHAsset *)asset {
    GKTimeLineImage *m = [[GKTimeLineImage alloc] init];
    m.coverImage = animatedImage;
    m.image_asset = asset;
    [self.dataSource addObject:m];
    
    [self updatePhotosView];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset {
    GKTimeLineImage *m = [[GKTimeLineImage alloc] init];
    m.coverImage = coverImage;
    m.video_asset = asset;
    [self.dataSource addObject:m];
    
    [self updatePhotosView];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    
    UIImage *image = photos.firstObject;
    PHAsset *asset = assets.firstObject;
    
    GKTimeLineImage *m = [[GKTimeLineImage alloc] init];
    m.coverImage = image;
    m.image_asset = asset;
    [self.dataSource addObject:m];
    
    [self updatePhotosView];
}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(nonnull NSArray<NSURL *> *)urls {
    for (NSURL *url in urls) {
        
        GKTimeLineImage *m = [[GKTimeLineImage alloc] init];
        m.islocal = YES;
//        m.imageURL = url;
        m.url = url.path;
        [self.dataSource addObject:m];
        
        [self updatePhotosView];
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
            photo.url = [NSURL URLWithString:obj.url];
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
    
    [browser setupCoverViews:@[UIView.new] layoutBlock:^(GKPhotoBrowser *browser, CGRect frame) {
        NSLog(@"%f", browser.view.safeAreaInsets.top);
        NSLog(@"%@", NSStringFromCGRect(UIApplication.sharedApplication.statusBarFrame));
        NSLog(@"%@", NSStringFromCGRect([(UIWindowScene *)UIApplication.sharedApplication.connectedScenes.anyObject statusBarManager].statusBarFrame));
    }];
    
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
