//
//  GKDemoPhotoViewController.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2024/5/24.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import "GKDemoPhotoViewController.h"
#import <TZImagePickerController/TZImagePickerController.h>
#import "GKPhotosView.h"
#import "GKTimeLineModel.h"
#import <GKMessageTool/GKMessageTool.h>

@interface GKDemoPhotoViewController ()<GKPhotosViewDelegate, GKPhotoBrowserDelegate>

@property (nonatomic, strong) TZAlbumModel *model;

@property (nonatomic, strong) NSArray *models;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) GKPhotosView *photosView;
@property (nonatomic, strong) NSArray *photos;

@property (nonatomic, strong) UIImageView *customFailView;

@end

@implementation GKDemoPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.gk_navTitle = @"相册图片";
    
    TZImagePickerConfig *config = [TZImagePickerConfig sharedInstance];
    config.allowPickingVideo = YES;
    config.allowPickingImage = YES;
    
    [[TZImageManager manager] getCameraRollAlbumWithFetchAssets:NO completion:^(TZAlbumModel *model) {
        self.model = model;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[TZImageManager manager] getAssetsFromFetchResult:self->_model.result completion:^(NSArray<TZAssetModel *> *models) {
                self->_models = [NSMutableArray arrayWithArray:models];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self initSubviews];
                });
            }];
        });
    }];
}

- (void)initSubviews {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.scrollView.frame = CGRectMake(0, CGRectGetMaxY(self.gk_navigationBar.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.gk_navigationBar.frame));
    [self.view addSubview:self.scrollView];
    
    self.photosView =  [GKPhotosView photosViewWithWidth:self.view.bounds.size.width - 20 andMargin:10];
    self.photosView.delegate = self;
    [self.scrollView addSubview:self.photosView];
    
    NSMutableArray *images = [NSMutableArray array];
    [self.models enumerateObjectsUsingBlock:^(TZAssetModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GKTimeLineImage *image = [GKTimeLineImage new];
        
        [[TZImageManager manager] getPhotoWithAsset:obj.asset photoWidth:self.view.width/2 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            image.coverImage = photo;
        }];
        
        if (obj.type == TZAssetModelMediaTypeVideo) {
            image.video_asset = obj.asset;
        }else {
            image.image_asset = obj.asset;
            image.isLivePhoto = obj.asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive;
        }
        [images addObject:image];
    }];
    
    self.photos = images;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat height = [GKPhotosView sizeWithCount:images.count width:self.view.bounds.size.width - 20 andMargin:10].height;
        CGFloat y = 20;
        self.photosView.frame = CGRectMake(10, y, self.view.bounds.size.width - 20, height);
        self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, y + height + 20);
        
        self.photosView.images = images;
    });
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.photosView updateWidth:self.view.bounds.size.width - 20];
    CGFloat height = [GKPhotosView sizeWithCount:self.photos.count width:self.view.bounds.size.width - 20 andMargin:10].height;
    CGFloat y = 20;
    self.photosView.frame = CGRectMake(10, y, self.view.bounds.size.width - 20, height);
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, y + height + 20);
}

#pragma mark - GKPhotosViewDelegate
- (void)photoTapped:(UIImageView *)imgView {
    
    NSMutableArray *photos = [NSMutableArray array];
    
    [self.photos enumerateObjectsUsingBlock:^(GKTimeLineImage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GKPhoto *photo = [[GKPhoto alloc] init];
        if (obj.isVideo) {
            photo.videoAsset = obj.video_asset;
        }else {
            photo.imageAsset = obj.image_asset;
        }
        photo.sourceImageView = self.photosView.subviews[idx];
        [photos addObject:photo];
    }];
    
    NSInteger index = imgView.tag;
    
    Class cls = NSClassFromString(@"GKIJKPlayerManager");
    if (self.videoPlayStyle == 2 && !cls) {
        [GKMessageTool showText:@"请先 pod 'GKPhotoBrowser/IJKPlayer'"];
        return;
    }
    
    GKPhotoBrowserConfigure *configure = GKPhotoBrowserConfigure.defaultConfig;
    configure.showStyle = self.showStyle;
    configure.hideStyle = self.hideStyle;
    configure.loadStyle = self.loadStyle;
    configure.failStyle = self.failStyle;
    
    if (self.imageLoadStyle == 0) {
        [configure setupWebImageProtocol:[[GKSDWebImageManager alloc] init]];
    }else if (self.imageLoadStyle == 1) {
        [configure setupWebImageProtocol:[[GKYYWebImageManager alloc] init]];
    }else {
        [configure setupWebImageProtocol:[[GKKFWebImageManager alloc] init]];
    }
    
    configure.videoLoadStyle = self.videoLoadStyle;
    configure.videoFailStyle = self.videoFailStyle;
    
    if (self.videoPlayStyle == 0) {
        [configure setupVideoPlayerProtocol:[[GKAVPlayerManager alloc] init]];
    }else if (self.videoPlayStyle == 1) {
        [configure setupVideoPlayerProtocol:[[GKZFPlayerManager alloc] init]];
    }else {
        [configure setupVideoPlayerProtocol:[[cls alloc] init]];
    }
    
    configure.isShowLivePhotoMark = YES;
    if (self.livePhotoStyle == 0) {
        [configure setupLivePhotoProtocol:GKAFLivePhotoManager.new];
    }else {
        [configure setupLivePhotoProtocol:GKAlamofireLivePhotoManager.new];
    }
    configure.isPopGestureEnabled = YES; // push显示，在第一页时手势返回
    
    GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photos currentIndex:index];
    browser.configure = configure;
    browser.delegate = self;
    [browser showFromVC:self];
}

#pragma mark - GKPhotoBrowserDelegate
- (void)photoBrowser:(GKPhotoBrowser *)browser didChangedIndex:(NSInteger)index {
    
}

- (void)photoBrowser:(GKPhotoBrowser *)browser didSelectAtIndex:(NSInteger)index {
    
}

- (void)photoBrowser:(GKPhotoBrowser *)browser loadImageAtIndex:(NSInteger)index progress:(float)progress isOriginImage:(BOOL)isOriginImage {
    if (progress == 1.0f) {
        [GKMessageTool hideMessage];
    }else {
        [GKMessageTool showMessage:nil];
    }
}

- (void)photoBrowser:(GKPhotoBrowser *)browser loadFailedAtIndex:(NSInteger)index {
    if (self.customFailView) return;
    self.customFailView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
    [self.customFailView sizeToFit];
    
    UIView *photoView = browser.curPhotoView;
    self.customFailView.center = CGPointMake(photoView.bounds.size.width * 0.5, photoView.bounds.size.height * 0.5);
    [photoView addSubview:self.customFailView];
}

- (void)photoBrowser:(GKPhotoBrowser *)browser panBeginWithIndex:(NSInteger)index {
    
}

- (void)photoBrowser:(GKPhotoBrowser *)browser panEndedWithIndex:(NSInteger)index willDisappear:(BOOL)disappear {
    
}

- (void)photoBrowser:(GKPhotoBrowser *)browser didDisappearAtIndex:(NSInteger)index {
    NSLog(@"browser dismiss");
    [self.customFailView removeFromSuperview];
    self.customFailView = nil;
}

@end
