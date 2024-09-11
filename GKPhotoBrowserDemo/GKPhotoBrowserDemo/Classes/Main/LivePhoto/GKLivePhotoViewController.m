//
//  GKLivePhotoViewController.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2024/6/28.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import "GKLivePhotoViewController.h"
#import "GKTimeLineViewCell.h"
#import <GKPhotoBrowser/GKPhotoBrowser.h>
#import <GKPhotoBrowser/GKYYWebImageManager.h>
#import <SDWebImage/SDWebImage.h>
#import <YYWebImage/YYWebImage.h>
#import "GKPublishViewController.h"
#import <GKMessageTool/GKMessageTool.h>
#import "GKZFPlayerManager.h"
#import "GKWBPlayerManager.h"

@interface GKLivePhotoViewController ()<UITableViewDataSource, UITableViewDelegate, GKPhotoBrowserDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *dataFrames;

@property (nonatomic, weak) UIView *fromView;

@property (nonatomic, weak) UIView *actionSheet;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) BOOL isLandscape;

/** 这里用weak是防止GKPhotoBrowser被强引用，导致不能释放 */
@property (nonatomic, weak) GKPhotoBrowser *browser;

@property (nonatomic, assign) NSInteger     currentIndex;

@property (nonatomic, assign) CGFloat viewWidth;

@end

@implementation GKLivePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self setupData];
}

- (void)setupUI {
    self.gk_navigationItem.title = @"LivePhoto";
    
    self.viewWidth = self.view.bounds.size.width;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.top        = self.gk_navigationBar.bottom;
    self.tableView.height     = self.view.height - self.gk_navigationBar.height;
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[GKTimeLineViewCell class] forCellReuseIdentifier:kTimeLineViewCellID];
    [self.view addSubview:self.tableView];
}

- (void)setupData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"livephoto" ofType:@"txt"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    self.dataSource = [NSArray yy_modelArrayWithClass:[GKTimeLineModel class] json:data];
    
    self.dataFrames = [self dataFramesWithModels:self.dataSource];
    
    [self.tableView reloadData];
}

- (NSArray *)dataFramesWithModels:(NSArray *)models {
    NSMutableArray *dataFrames = [NSMutableArray new];
    
    for (GKTimeLineModel *model in models) {
        GKTimeLineFrame *f = [GKTimeLineFrame new];
        f.width = self.view.frame.size.width;
        f.model = model;
        
        [dataFrames addObject:f];
    }
    return dataFrames;
}

- (void)dealloc {
    NSLog(@"%@ dealloc", NSStringFromClass([self class]));
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.dataFrames enumerateObjectsUsingBlock:^(GKTimeLineFrame *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.width = self.view.frame.size.width;
        [obj updateFrameWithWidth:obj.width];
    }];
    self.tableView.frame   = self.view.bounds;
    self.tableView.top     = self.gk_navigationBar.bottom;
    self.tableView.height  = self.view.height - self.gk_navigationBar.height;
    
    if (self.view.bounds.size.width != self.viewWidth) {
        self.viewWidth = self.view.bounds.size.width;
        [self.tableView.visibleCells enumerateObjectsUsingBlock:^(__kindof GKTimeLineViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj updateFrame];
        }];
    }
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataFrames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKTimeLineViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTimeLineViewCellID forIndexPath:indexPath];
    
    cell.timeLineFrame = self.dataFrames[indexPath.row];
    
    __weak __typeof(self) weakSelf = self;
    cell.photosImgClickBlock = ^(GKTimeLineViewCell *cell, NSInteger index) {
        __strong __typeof(weakSelf) self = weakSelf;
        NSMutableArray *photos = [NSMutableArray new];
        [cell.timeLineFrame.model.images enumerateObjectsUsingBlock:^(GKTimeLineImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            GKPhoto *photo = [[GKPhoto alloc] init];
            photo.url = [NSURL URLWithString:obj.url];
            
            photo.sourceImageView = cell.photosView.subviews[idx];
            
            if (obj.isLivePhoto) {
                photo.isLivePhoto = YES;
                photo.videoUrl = [NSURL URLWithString:obj.video_url];
            }else if (obj.isVideo) {
                photo.videoUrl = [NSURL URLWithString:obj.video_url];
            }
            
            [photos addObject:photo];
        }];
        
        GKPhotoBrowserConfigure *configure = [GKPhotoBrowserConfigure defaultConfig];
        configure.showStyle = GKPhotoBrowserShowStyleZoom;        // 缩放显示
        configure.hideStyle = GKPhotoBrowserHideStyleZoomScale;   // 缩放隐藏
        configure.loadStyle = GKPhotoBrowserLoadStyleIndeterminateMask; // 不明确的加载方式带阴影
        configure.maxZoomScale = 20.0f;
        configure.doubleZoomScale = 2.0f;
//        configure.isAdaptiveSafeArea = YES;
        configure.hidesCountLabel = YES;
        configure.hidesSavedBtn = YES;
        configure.isFullWidthForLandScape = NO;
        configure.isSingleTapDisabled = YES;
        configure.isShowPlayImage = NO;
        configure.isVideoReplay = YES;
        configure.videoPlayImage = [UIImage imageNamed:@"ic_play3"];
        configure.isShowLivePhotoMark = YES;
        configure.isClearMemoryForLivePhoto = NO;
        [configure setupVideoPlayerProtocol:GKWBPlayerManager.new];
        [configure setupVideoProgressProtocol:nil];
        configure.isNeedNavigationController = YES;
        GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photos currentIndex:index];
        browser.configure = configure;
        browser.delegate = self;
        [browser showFromVC:self];
        
        self.browser = browser;
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKTimeLineFrame *f = self.dataFrames[indexPath.row];
    return f.cellHeight;
}

#pragma mark - GKPhotoBrowserDelegate
- (void)photoBrowser:(GKPhotoBrowser *)browser didChangedIndex:(NSInteger)index {
    
}

- (void)photoBrowser:(GKPhotoBrowser *)browser singleTapWithIndex:(NSInteger)index {
    if (browser.curPhoto.isVideo) {
        if (browser.configure.player.isPlaying) {
            [browser.configure.player gk_pause];
        }else {
            [browser.configure.player gk_play];
        }
    }else {
        [browser dismiss];
    }
}

- (void)photoBrowser:(GKPhotoBrowser *)browser longPressWithIndex:(NSInteger)index {
    
}

- (void)photoBrowser:(GKPhotoBrowser *)browser willLayoutSubViews:(NSInteger)index {
    UIView *contentView = browser.contentView;

    [self.fromView removeFromSuperview];

    if (browser.contentView.size.width > browser.contentView.size.height) { // 横屏
        [contentView addSubview:self.fromView];
        self.fromView.frame = CGRectMake(0, 0, contentView.bounds.size.width, contentView.bounds.size.height);
    }else {
        [browser.view addSubview:self.fromView];
        self.fromView.frame = CGRectMake(0, 0, contentView.bounds.size.width, contentView.bounds.size.height);
    }

    self.actionSheet.width = contentView.frame.size.width;
    [self.actionSheet.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.width = contentView.frame.size.width;
    }];

    [GKCover layoutSubViews];
}

- (void)photoBrowser:(GKPhotoBrowser *)browser onDeciceChangedWithIndex:(NSInteger)index isLandscape:(BOOL)isLandscape {
    [GKCover hideCoverWithoutAnimation];
}

- (void)photoBrowser:(GKPhotoBrowser *)browser didDisappearAtIndex:(NSInteger)index {
    NSLog(@"浏览器完全消失%@", browser);
}

- (void)delBtnClick:(id)sender {
    [GKCover hideCover];

//    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.browser.photos];
//
//    [arr removeObjectAtIndex:self.browser.currentIndex];
//
//    [self.browser resetPhotoBrowserWithPhotos:arr];
//
//    self.pageControl.numberOfPages = arr.count;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.browser removePhotoAtIndex:self.currentIndex];
//        [self.browser selectedPhotoWithIndex:2 animated:NO];
    });
}

- (void)saveBtnClick:(id)sender {
    [GKCover hideCover];
    
    GKPhotoView *photoView = self.browser.curPhotoView;
    
    NSData *imageData = [photoView.imageView.image sd_imageData];
    
    
//    if ([photo.image isKindOfClass:[SDAnimatedImage class]]) {
//        imageData = [(SDAnimatedImage *)photo.image animatedImageData];
//    }else if ([photo.image isKindOfClass:[YYImage class]]) {
//        imageData = [(YYImage *)photo.image animatedImageData];
//    }else {
//        imageData = [photo.image sd_imageData];
//    }
    
    if (!imageData) return;
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        if (@available(iOS 9, *)) {
            PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
            [request addResourceWithType:PHAssetResourceTypePhoto data:imageData options:nil];
            request.creationDate = [NSDate date];
        }
    } completionHandler:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                NSLog(@"保存照片成功");
                [GKMessageTool showSuccess:@"图片保存成功"];
            } else if (error) {
                [GKMessageTool showError:@"图片保存失败"];
                NSLog(@"保存照片出错:%@",error.localizedDescription);
            }
        });
    }];
}

- (void)tabkePhoto {
    GKPublishViewController *publishVC = [GKPublishViewController new];
    [self.navigationController pushViewController:publishVC animated:YES];
}

- (void)cancelBtnClick:(id)sender {
    [GKCover hideCover];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
