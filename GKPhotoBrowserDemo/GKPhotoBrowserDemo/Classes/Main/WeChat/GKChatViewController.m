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
    browser.isSingleTapDisabled = YES;
    browser.isVideoPausedWhenDragged = NO;
    [browser setupVideoProgressProtocol:[GKVideoProgressView new]];
    browser.isVideoReplay = NO;
    [browser showFromVC:self];
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

@end
