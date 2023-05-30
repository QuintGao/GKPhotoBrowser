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
#import "GKVideoProgressView.h"

@interface GKChatViewController ()<UITableViewDataSource, UITableViewDelegate, GKPhotoBrowserDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation GKChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navTitle = @"聊天";
    [self setupUI];
    [self setupData];
}

- (void)setupUI {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(GK_STATUSBAR_NAVBAR_HEIGHT, 0, 0, 0));
    }];
}

- (void)setupData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"chat" ofType:@"txt"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    self.dataSource = [NSArray yy_modelArrayWithClass:[GKTimeLineModel class] json:data];
    
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
        photo.url = [NSURL URLWithString:img.url];
        photo.sourceImageView = cell.imgView;
        if (img.isVideo) {
            photo.videoUrl = [NSURL URLWithString:img.video_url];
            photo.autoPlay = NO;
        }
        
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
    browser.hidesVideoSlider = YES;
    browser.isSingleTapDisabled = YES;
    browser.isVideoPausedWhenDragged = NO;
    [browser showFromVC:self];
}

#pragma mark - GKPhotoBrowserDelegate
- (void)photoBrowser:(GKPhotoBrowser *)browser singleTapWithIndex:(NSInteger)index {
    GKPhoto *photo = browser.curPhoto;
    if (photo.isVideo) {
        GKPhotoView *photoView = browser.curPhotoView;
        if (!photoView) return;
        GKVideoProgressView *progressView = [photoView viewWithTag:1001];
        if (!progressView) return;
        progressView.hidden = !progressView.isHidden;
    }else {
        [browser dismiss];
    }
}

- (void)photoBrowser:(GKPhotoBrowser *)browser reuseAtIndex:(NSInteger)index photoView:(GKPhotoView *)photoView {
    GKPhoto *photo = browser.photos[index];
    if (photo.isVideo) {
        UIView *view = [photoView viewWithTag:1001];
        if (view) return;
        
        GKVideoProgressView *progressView = [[GKVideoProgressView alloc] initWithFrame:CGRectMake(0, photoView.bounds.size.height - 80, photoView.bounds.size.width, 80)];
        progressView.tag = 1001;
        [photoView addSubview:progressView];
        
        __weak __typeof(photoView) weakPhotoView = photoView;
        progressView.playPauseBlock = ^{
            __strong __typeof(weakPhotoView) photoView = weakPhotoView;
            if (photoView.player.isPlaying) {
                [photoView pauseAction];
            }else {
                [photoView playAction];
            }
        };
    }else {
        UIView *view = [photoView viewWithTag:1001];
        if (view) {
            [view removeFromSuperview];
        }
    }
}

- (void)photoBrowser:(GKPhotoBrowser *)browser willLayoutSubViews:(NSInteger)index {
    GKPhotoView *photoView = browser.curPhotoView;
    if (!photoView) return;
    GKVideoProgressView *progressView = [photoView viewWithTag:1001];
    if (!progressView) return;
    progressView.frame = CGRectMake(0, photoView.bounds.size.height - 80, photoView.bounds.size.width, 80);
}

- (void)photoBrowser:(GKPhotoBrowser *)browser videoTimeChangeWithPhotoView:(nonnull GKPhotoView *)photoView currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    if (!photoView) return;
    GKVideoProgressView *progressView = [photoView viewWithTag:1001];
    if (!progressView) return;
    [progressView updateCurrentTime:currentTime totalTime:totalTime];
}

- (void)photoBrowser:(GKPhotoBrowser *)browser videoStateChangeWithPhotoView:(nonnull GKPhotoView *)photoView status:(GKVideoPlayerStatus)status {
    if (!photoView) return;
    GKVideoProgressView *progressView = [photoView viewWithTag:1001];
    if (!progressView) return;
    [progressView updateStatus:status];
}

- (void)photoBrowser:(GKPhotoBrowser *)browser panBeginWithIndex:(NSInteger)index {
    if (!browser.curPhoto.isVideo) return;
    GKVideoProgressView *progressView = [browser.curPhotoView viewWithTag:1001];
    if (!progressView) return;
    progressView.hidden = YES;
}

- (void)photoBrowser:(GKPhotoBrowser *)browser panEndedWithIndex:(NSInteger)index willDisappear:(BOOL)disappear {
    if (!browser.curPhoto.isVideo) return;
    GKVideoProgressView *progressView = [browser.curPhotoView viewWithTag:1001];
    if (!progressView) return;
    if (!disappear) {
        progressView.hidden = NO;
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

@end
