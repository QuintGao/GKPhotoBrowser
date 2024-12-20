//
//  GKPublishViewController.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2020/6/16.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import "GKPublishViewController.h"
#import "GKPhotosView.h"
#import <GKPhotoBrowser/GKPhotoBrowser.h>
#import <ZLPhotoBrowser-Swift.h>

@interface GKPublishViewController ()<GKPhotosViewDelegate>

@property (nonatomic, strong) UIButton *selectBtn;

@property (nonatomic, strong) GKPhotosView *photoView;

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSMutableArray *photos;

@end

@implementation GKPublishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navTitle = @"发布";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.selectBtn];
    self.selectBtn.frame = CGRectMake((KScreenW - 80)/2, 100, 80, 30);
    
    [self.view addSubview:self.photoView];
    self.photoView.frame = CGRectMake(0, 150, (kScreenW - 60 - 50 - 20), 0);
    
    self.assets = [NSMutableArray new];
    self.photos = [NSMutableArray new];
}

- (void)selectPhoto {
    ZLPhotoConfiguration *config = [ZLPhotoConfiguration default];
    config.maxSelectCount = 9;
    config.allowSelectImage = YES;
    config.allowSelectGif = YES;
    config.allowSelectVideo = YES;
    
    ZLPhotoPreviewSheet *picker = [[ZLPhotoPreviewSheet alloc] init];
    __weak __typeof(self) weakSelf = self;
    [picker setSelectImageBlock:^(NSArray<ZLResultModel *> *models, BOOL success) {
        __strong __typeof(weakSelf) self = weakSelf;
        [models enumerateObjectsUsingBlock:^(ZLResultModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.assets addObject:obj.asset];
            [self.photos addObject:obj.image];
        }];
        
        self.photoView.photoImages = self.photos;
        CGFloat height = [GKPhotosView sizeWithCount:self.photos.count width:(kScreenW - 60 - 50 - 20) andMargin:5].height;
        self.photoView.frame = CGRectMake(0, 150, (kScreenW - 60 - 50 - 20), height);
    }];
    [picker showPhotoLibraryWithSender:self];
}

#pragma mark - GKPhotosViewDelegate
- (void)photoTapped:(UIImageView *)imgView {
    NSMutableArray *photos = [NSMutableArray new];
    [self.assets enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GKPhoto *photo = [GKPhoto new];
        if (obj.mediaType == PHAssetMediaTypeVideo) {
            photo.videoAsset = obj;
        }else {
            photo.imageAsset = obj;
        }
        photo.sourceImageView = self.photoView.subviews[idx];
        [photos addObject:photo];
    }];
    
    GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photos currentIndex:imgView.tag];
    browser.configure.showStyle = GKPhotoBrowserShowStyleZoom;
    browser.configure.hideStyle = GKPhotoBrowserHideStyleZoomScale;
    browser.configure.loadStyle = GKPhotoBrowserLoadStyleIndeterminateMask;
    browser.configure.isFullWidthForLandScape = NO;
    browser.configure.isAdaptiveSafeArea = YES;
    [browser showFromVC:self];
}

#pragma mark - 懒加载
- (UIButton *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [UIButton new];
        [_selectBtn setTitle:@"选择图片" forState:UIControlStateNormal];
        _selectBtn.backgroundColor = [UIColor redColor];
        [_selectBtn addTarget:self action:@selector(selectPhoto) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectBtn;
}

- (GKPhotosView *)photoView {
    if (!_photoView) {
        _photoView = [GKPhotosView photosViewWithWidth:(kScreenW - 60 - 50 - 20) andMargin:5];
        _photoView.delegate = self;
    }
    return _photoView;
}

@end
