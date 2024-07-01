//
//  GKDemoLocalViewController.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2024/6/18.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import "GKDemoLocalViewController.h"
#import <Masonry/Masonry.h>
#import <TZImagePickerController/TZImagePickerController.h>
#import "GKPhotosView.h"
#import "GKTimeLineModel.h"
#import <GKMessageTool/GKMessageTool.h>

@interface GKDemoLocalViewController ()<TZImagePickerControllerDelegate, GKPhotosViewDelegate, GKPhotoBrowserDelegate>

@property (nonatomic, strong) UIButton *selectBtn;

@property (nonatomic, copy) NSString *directryPath;

@property (nonatomic, strong) NSMutableArray *models;

@property (nonatomic, strong) GKPhotosView *photosView;

@property (nonatomic, strong) UIImageView *customFailView;

@end

@implementation GKDemoLocalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.gk_navTitle = @"本地图片";
    
    [self.view addSubview:self.selectBtn];
    [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.gk_navigationBar.mas_bottom).offset(10);
        make.width.mas_equalTo(160);
        make.height.mas_equalTo(30);
    }];
    
    self.photosView =  [GKPhotosView photosViewWithWidth:self.view.bounds.size.width - 20 andMargin:10];
    self.photosView.delegate = self;
    [self.view addSubview:self.photosView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.photosView updateWidth:self.view.bounds.size.width - 20];
    CGFloat height = [GKPhotosView sizeWithCount:self.models.count width:self.view.bounds.size.width - 20 andMargin:10].height;
    CGFloat y = CGRectGetMaxY(self.selectBtn.frame) + 20;
    self.photosView.frame = CGRectMake(10, y, self.view.bounds.size.width - 20, height);
}

- (void)selectBtnClick:(id)sender {
    TZImagePickerController *pickerVC = [[TZImagePickerController alloc] initWithMaxImagesCount:10 delegate:self];
    pickerVC.allowPickingGif = YES;
    pickerVC.allowPickingMultipleVideo = YES;
    [self presentViewController:pickerVC animated:YES completion:nil];
}

#pragma mark - TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    
    
    // 删除文件
    BOOL isDirectory;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.directryPath isDirectory:&isDirectory]) {
        NSLog(@"%d", isDirectory);
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:self.directryPath error:&error];
        if (error) {
            NSLog(@"删除失败！--%@", error);
        }else {
            NSLog(@"删除成功！");
        }
        self.directryPath = nil;
    }
    [self.models removeAllObjects];
    
    __weak __typeof(self) weakSelf = self;
    [GKMessageTool showMessage:@"数据写入中..."];
    [self saveWithIndex:0 assets:assets photos:photos completion:^{
        [GKMessageTool hideMessage];
        __strong __typeof(weakSelf) self = weakSelf;
        CGFloat height = [GKPhotosView sizeWithCount:self.models.count width:self.view.bounds.size.width - 20 andMargin:10].height;
        CGFloat y = CGRectGetMaxY(self.selectBtn.frame) + 20;
        self.photosView.frame = CGRectMake(10, y, self.view.bounds.size.width - 20, height);
        self.photosView.images = self.models;
    }];
}

- (void)saveWithIndex:(NSInteger)index assets:(NSArray *)assets photos:(NSArray *)photos completion:(void(^)(void))completion {
    [self saveWithAsset:assets[index] image:photos[index] completion:^(BOOL success, GKTimeLineImage *image) {
        if (success) {
            [self.models addObject:image];
        }
        if (index == assets.count - 1) {
            !completion ?: completion();
        }else {
            [self saveWithIndex:index+1 assets:assets photos:photos completion:completion];
        }
    }];
}

- (void)saveWithAsset:(PHAsset *)asset image:(UIImage *)image completion:(void(^)(BOOL success, GKTimeLineImage *image))completion {
    GKTimeLineImage *imageModel = [[GKTimeLineImage alloc] init];
    imageModel.islocal = YES;
    
    PHContentEditingInputRequestOptions *options = [[PHContentEditingInputRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    
    [asset requestContentEditingInputWithOptions:options completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
        if (contentEditingInput.mediaType == PHAssetMediaTypeVideo) {
            NSURL *fileURL = [(AVURLAsset *)contentEditingInput.audiovisualAsset URL];
            
            NSString *videoName = [fileURL.absoluteString componentsSeparatedByString:@"/"].lastObject;
            NSString *imageName = [[videoName componentsSeparatedByString:@"."].firstObject stringByAppendingString:@".png"];
            NSString *imagePath = [self.directryPath stringByAppendingPathComponent:imageName];
            NSURL *imageURL = [NSURL fileURLWithPath:imagePath];
            imageModel.imageURL = imageURL;
            NSData *data = UIImagePNGRepresentation(image);
            BOOL success = [data writeToURL:imageURL atomically:YES];
            if (success) {
                NSLog(@"视频封面图保存成功！");
                // 开始保存视频
                [[TZImageManager manager] requestVideoOutputPathWithAsset:asset presetName:nil success:^(NSString *outputPath) {
                    NSLog(@"视频保存成功");
                    imageModel.videoURL = [NSURL fileURLWithPath:outputPath];
                    !completion ?: completion(YES, imageModel);
                } failure:^(NSString *errorMessage, NSError *error) {
                    !completion ?: completion(NO, nil);
                }];
            }else {
                !completion ?: completion(NO, nil);
            }
        }else {
            NSURL *fileURL = contentEditingInput.fullSizeImageURL;
            
            NSString *imageName = [fileURL.absoluteString componentsSeparatedByString:@"/"].lastObject;
            NSString *imagePath = [self.directryPath stringByAppendingPathComponent:imageName];
            NSURL *imageURL = [NSURL fileURLWithPath:imagePath];
            imageModel.imageURL = imageURL;
            NSData *data = UIImagePNGRepresentation(image);
            BOOL success = [data writeToURL:imageURL atomically:YES];
            if (success) {
                NSLog(@"图片保存成功");
                !completion ?: completion(YES, imageModel);
            }else {
                !completion ?: completion(NO, nil);
            }
        }
    }];
}

#pragma mark - GKPhotosViewDelegate
- (void)photoTapped:(UIImageView *)imgView {
    
    NSMutableArray *photos = [NSMutableArray array];
    
    [self.models enumerateObjectsUsingBlock:^(GKTimeLineImage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GKPhoto *photo = [[GKPhoto alloc] init];
        photo.url = obj.imageURL;
        if (obj.isVideo) {
            photo.videoUrl = obj.videoURL;
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
    
    GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photos currentIndex:index];
    browser.showStyle = self.showStyle;
    browser.hideStyle = self.hideStyle;
    browser.loadStyle = self.loadStyle;
    browser.failStyle = self.failStyle;
    
    if (self.imageLoadStyle == 0) {
        [browser setupWebImageProtocol:[[GKSDWebImageManager alloc] init]];
    }else if (self.imageLoadStyle == 1) {
        [browser setupWebImageProtocol:[[GKYYWebImageManager alloc] init]];
    }else {
        [browser setupWebImageProtocol:[[GKKFWebImageManager alloc] init]];
    }
    if (self.livePhotoStyle == 0) {
        [browser setupLivePhotoProtocol:GKAFLivePhotoManager.new];
    }else {
        [browser setupLivePhotoProtocol:GKAlamofireLivePhotoManager.new];
    }
    
    browser.videoLoadStyle = self.videoLoadStyle;
    browser.videoFailStyle = self.videoFailStyle;
    
    if (self.videoPlayStyle == 0) {
        [browser setupVideoPlayerProtocol:[[GKAVPlayerManager alloc] init]];
    }else if (self.videoPlayStyle == 1) {
        [browser setupVideoPlayerProtocol:[[GKZFPlayerManager alloc] init]];
    }else {
        [browser setupVideoPlayerProtocol:[[cls alloc] init]];
    }
    browser.isPopGestureEnabled = YES; // push显示，在第一页时手势返回
    
    [browser showFromVC:self];
    browser.delegate = self;
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

#pragma mark - Lazy
- (UIButton *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [[UIButton alloc] init];
        [_selectBtn setTitle:@"点击选择图片写入本地" forState:UIControlStateNormal];
        [_selectBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _selectBtn.backgroundColor = UIColor.blackColor;
        _selectBtn.layer.cornerRadius = 5;
        _selectBtn.layer.masksToBounds = YES;
        _selectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectBtn;
}

- (NSString *)directryPath {
    if (!_directryPath) {
        NSString *basePath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,  NSUserDomainMask, YES).firstObject;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *directryPath = [basePath stringByAppendingPathComponent:@"uploadFile"];
        if (![fileManager fileExistsAtPath:directryPath]) {
            [fileManager createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _directryPath = directryPath;
    }
    return _directryPath;
}

- (NSMutableArray *)models {
    if (!_models) {
        _models = [NSMutableArray array];
    }
    return _models;
}

@end
