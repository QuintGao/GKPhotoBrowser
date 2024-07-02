//
//  GKChatViewController.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2023/5/25.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKChatViewController.h"
#import "GKChatViewCell.h"
#import <Masonry/Masonry.h>
#import <GKPhotoBrowser/GKPhotoBrowser.h>
#import <GKPhotoBrowser/GKZFPlayerManager.h>
#import "GKVideoProgressView.h"
#import <TZImagePickerController/TZImagePickerController.h>

@interface GKChatViewController ()<UITableViewDataSource, UITableViewDelegate, GKPhotoBrowserDelegate, TZImagePickerControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, weak) GKPhotoBrowser *browser;

@end

@implementation GKChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navTitle = @"聊天";
    [self setupUI];
    [self setupData];
}

- (void)setupUI {
    self.gk_navRightBarButtonItem = [UIBarButtonItem gk_itemWithTitle:@"相册" target:self action:@selector(selectPhoto)];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(GK_STATUSBAR_NAVBAR_HEIGHT, 0, 0, 0));
    }];
}

- (void)setupData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"chat" ofType:@"txt"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    NSArray *chatList = [NSArray yy_modelArrayWithClass:GKTimeLineModel.class json:data];
    [self.dataSource addObjectsFromArray:chatList];
    
    [self.tableView reloadData];
}

- (void)selectPhoto {
    TZImagePickerController *pickerVC = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    [self presentViewController:pickerVC animated:YES completion:nil];
}

#pragma mark - TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    UIImage *photo = photos.firstObject;
    PHAsset *asset = assets.firstObject;
    
    GKTimeLineImage *icon = [[GKTimeLineImage alloc] init];
    icon.url = @"https://gips0.baidu.com/it/u=2761017119,608134785&fm=3012&app=3012&autime=1679294217&size=b200,200";
    icon.width = 300;
    icon.height = 300;
    
    GKTimeLineImage *image = [[GKTimeLineImage alloc] init];
    image.width = photo.size.width;
    image.height = photo.size.height;
    image.coverImage = photo;
    image.image_asset = asset;
    
    GKTimeLineModel *model = [[GKTimeLineModel alloc] init];
    model.name = @"QuintGao";
    model.icon = icon;
    model.images = @[image];
    [self.dataSource insertObject:model atIndex:0];
    
    [self.tableView reloadData];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset {
    GKTimeLineImage *icon = [[GKTimeLineImage alloc] init];
    icon.url = @"https://gips0.baidu.com/it/u=2761017119,608134785&fm=3012&app=3012&autime=1679294217&size=b200,200";
    icon.width = 300;
    icon.height = 300;
    
    GKTimeLineImage *image = [[GKTimeLineImage alloc] init];
    image.width = coverImage.size.width;
    image.height = coverImage.size.height;
    image.coverImage = coverImage;
    image.video_asset = asset;
    
    GKTimeLineModel *model = [[GKTimeLineModel alloc] init];
    model.name = @"QuintGao";
    model.icon = icon;
    model.images = @[image];
    [self.dataSource insertObject:model atIndex:0];
    
    [self.tableView reloadData];
}

#pragma mark - <UITableViewDataSource, UITableViewDelegate>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKChatViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GKChatViewCell" forIndexPath:indexPath];
    cell.model = self.dataSource[indexPath.row];
    cell.index = indexPath.row;
    
    __weak __typeof(self) weakSelf = self;
    cell.imgClickBlock = ^(NSInteger index) {
        __strong __typeof(weakSelf) self = weakSelf;
        [self showBrowserWithIndex:index];
    };
    
    return cell;
}

- (void)showBrowserWithIndex:(NSInteger)index {
    NSMutableArray *photos = [NSMutableArray new];
    [self.dataSource enumerateObjectsUsingBlock:^(GKTimeLineModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        GKChatViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
        GKTimeLineImage *img = model.images.firstObject;
        
        GKPhoto *photo = [GKPhoto new];
        photo.sourceImageView = cell.imgView;
        if (img.isVideo) {
            if (img.video_asset) {
                photo.videoAsset = img.video_asset;
            }else {
                photo.videoUrl = [NSURL URLWithString:img.video_url];
            }
            photo.autoPlay = NO;
        }else {
            if (img.image_asset) {
                photo.imageAsset = img.image_asset;
            }else {
                photo.url = [NSURL URLWithString:img.url];
            }
        }
//        photo.image = img.coverImage;
        
        // 首次点击的是视频，自动播放
        if (img.isVideo && index == idx) {
            photo.isVideoClicked = YES;
        }
        
        [photos addObject:photo];
    }];
    
    GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photos currentIndex:index];
    browser.showStyle = GKPhotoBrowserShowStyleZoom;
    browser.hideStyle = GKPhotoBrowserHideStyleZoomScale;
    browser.hidesPageControl = YES;
    browser.hidesSavedBtn = YES;
    browser.hidesCountLabel = YES;
    browser.delegate = self;
    browser.isSingleTapDisabled = YES;
    browser.isVideoPausedWhenDragged = NO;
    [browser setupVideoProgressProtocol:[GKVideoProgressView new]];
    [browser setupVideoPlayerProtocol:[GKZFPlayerManager new]];
    browser.isVideoReplay = NO;
    [browser showFromVC:self];
    self.browser = browser;
}

#pragma mark - GKPhotoBrowserDelegate
- (void)photoBrowser:(GKPhotoBrowser *)browser singleTapWithIndex:(NSInteger)index {
    GKPhoto *photo = browser.curPhoto;
    if (photo.isVideo) {
        browser.progressView.hidden = !browser.progressView.isHidden;
    }else {
        [browser dismiss];
    }
}

#pragma mark - lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        [_tableView registerClass:GKChatViewCell.class forCellReuseIdentifier:@"GKChatViewCell"];
        _tableView.rowHeight = 160;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

@end
