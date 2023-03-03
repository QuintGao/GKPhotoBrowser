//
//  GKPublishViewController.m
//  GKPhotoBrowserDemo
//
//  Created by gaokun on 2020/6/16.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import "GKPublishViewController.h"
#import <TZImagePickerController/TZImagePickerController.h>
#import "GKPhotosView.h"
#import "GKPhotoBrowser.h"

@interface GKPublishViewController ()<TZImagePickerControllerDelegate, GKPhotosViewDelegate>

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
    TZImagePickerController *pickerVC = [[TZImagePickerController alloc] initWithMaxImagesCount:90 delegate:self];
    pickerVC.allowTakeVideo = NO;
    pickerVC.allowPickingVideo = NO;
    pickerVC.allowPickingGif = YES;
    pickerVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:pickerVC animated:YES completion:nil];
}

#pragma mark - TZImagePickerControllerDelegate
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    [self.assets addObjectsFromArray:assets];
    [self.photos addObjectsFromArray:photos];
    
    self.photoView.photoImages = self.photos;
    CGFloat height = [GKPhotosView sizeWithCount:photos.count width:(kScreenW - 60 - 50 - 20) andMargin:5].height;
    self.photoView.frame = CGRectMake(0, 150, (kScreenW - 60 - 50 - 20), height);
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(PHAsset *)asset {
    [self.assets addObject:asset];
    [self.photos addObject:animatedImage];
    
    self.photoView.photoImages = self.photos;
    CGFloat height = [GKPhotosView sizeWithCount:1 width:(kScreenH - 60 - 50 - 20) andMargin:5].height;
    self.photoView.frame = CGRectMake(0, 150, (KScreenW - 60 - 50 - 20), height);
}

#pragma mark - GKPhotosViewDelegate
- (void)photoTapped:(UIImageView *)imgView {
    NSMutableArray *photos = [NSMutableArray new];
    [self.assets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GKPhoto *photo = [GKPhoto new];
        photo.imageAsset = self.assets[idx];
        photo.sourceImageView = self.photoView.subviews[idx];
        [photos addObject:photo];
    }];
    
    GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photos currentIndex:imgView.tag];
    browser.showStyle = GKPhotoBrowserShowStyleZoom;
    browser.hideStyle = GKPhotoBrowserHideStyleZoomScale;
    browser.loadStyle = GKPhotoBrowserLoadStyleIndeterminateMask;
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
