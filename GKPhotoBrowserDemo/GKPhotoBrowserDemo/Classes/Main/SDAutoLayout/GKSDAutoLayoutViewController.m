//
//  GKSDAutoLayoutViewController.m
//  GKPhotoBrowserDemo
//
//  Created by gaokun on 2018/8/13.
//  Copyright © 2018年 QuintGao. All rights reserved.
//

#import "GKSDAutoLayoutViewController.h"
#import "GKTimeLineViewCell.h"
#import <GKPhotoBrowser/GKPhotoBrowser.h>
#import "GKTopView.h"
#import "GKBottomView.h"
#import <SDAutoLayout/SDAutoLayout.h>

@interface GKSDAutoLayoutViewController ()<UITableViewDataSource, UITableViewDelegate, GKPhotoBrowserDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *dataFrames;

/** 这里用weak是防止GKPhotoBrowser被强引用，导致不能释放 */
@property (nonatomic, weak) GKPhotoBrowser *browser;

// coverView
@property (nonatomic, strong) GKTopView       *topView;

@property (nonatomic, strong) GKBottomView    *bottomView;

@end

@implementation GKSDAutoLayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self setupData];
}

- (void)setupUI {
    self.gk_navigationItem.title = @"微博";
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.top        = self.gk_navigationBar.bottom;
    self.tableView.height     = self.view.height - self.gk_navigationBar.height;
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[GKTimeLineViewCell class] forCellReuseIdentifier:kTimeLineViewCellID];
    [self.view addSubview:self.tableView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
    self.tableView.top = self.gk_navigationBar.bottom;
    self.tableView.height = self.view.height - self.gk_navigationBar.height;
}

- (void)setupData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"txt"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    self.dataSource = [NSArray yy_modelArrayWithClass:[GKTimeLineModel class] json:data];
    
    self.dataFrames = [self dataFramesWithModels:self.dataSource];
    
    [self.tableView reloadData];
}

- (NSArray *)dataFramesWithModels:(NSArray *)models {
    NSMutableArray *dataFrames = [NSMutableArray new];
    
    for (GKTimeLineModel *model in models) {
        GKTimeLineFrame *f = [GKTimeLineFrame new];
        f.model = model;
        
        [dataFrames addObject:f];
    }
    return dataFrames;
}

- (void)dealloc {
    NSLog(@"%@ dealloc", NSStringFromClass([self class]));
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
        NSMutableArray *photos = [NSMutableArray new];
        [cell.timeLineFrame.model.images enumerateObjectsUsingBlock:^(GKTimeLineImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            GKPhoto *photo = [GKPhoto new];
            photo.url = [NSURL URLWithString:obj.url];
            photo.sourceImageView = cell.photosView.subviews[idx];
            
            [photos addObject:photo];
        }];
        
        GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photos currentIndex:index];
        browser.showStyle = GKPhotoBrowserShowStyleZoom;        // 缩放显示
        browser.hideStyle = GKPhotoBrowserHideStyleZoomScale;   // 缩放隐藏
        browser.loadStyle = GKPhotoBrowserLoadStyleDeterminate; // 加载方式
        
        browser.delegate = weakSelf;
        if (kIsiPad) {
            browser.isFollowSystemRotation = YES;
        }
    
        
        weakSelf.topView = [[GKTopView alloc] init];
        
        weakSelf.bottomView = [[GKBottomView alloc] init];
        weakSelf.bottomView.text = cell.timeLineFrame.model.content;
        
        [browser setupCoverViews:@[weakSelf.topView, weakSelf.bottomView] layoutBlock:^(GKPhotoBrowser * _Nonnull photoBrowser, CGRect superFrame) {
            
            CGFloat topH = (KIsiPhoneX && !photoBrowser.isLandscape) ? 84 : 60;
            
            CGFloat w = (KIsiPhoneX && photoBrowser.isLandscape) ? (superFrame.size.width - 58.0f) : superFrame.size.width;
            
            CGFloat x = (KIsiPhoneX && photoBrowser.isLandscape) ? 30 : 0;
            
//            self.topView.frame = CGRectMake(x, 0, w, topH);
            weakSelf.topView.sd_layout.leftSpaceToView(photoBrowser.contentView, x).topEqualToView(photoBrowser.contentView).widthIs(w).heightIs(topH);
            
            CGFloat btmH = (KIsiPhoneX && !photoBrowser.isLandscape) ? 94 : 60;
//            self.bottomView.frame = CGRectMake(x, superFrame.size.height - btmH, w, btmH);
            weakSelf.bottomView.sd_layout.leftSpaceToView(photoBrowser.contentView, x).topSpaceToView(photoBrowser.contentView, superFrame.size.height - btmH).widthIs(w).heightIs(btmH);
        }];
        
        [browser showFromVC:weakSelf];
        
        [weakSelf.topView setupCurrent:(index + 1) total:browser.photos.count];
        
        weakSelf.browser = browser;
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKTimeLineFrame *f = self.dataFrames[indexPath.row];
    return f.cellHeight;
}

#pragma mark - GKPhotoBrowserDelegate
- (void)photoBrowser:(GKPhotoBrowser *)browser didChangedIndex:(NSInteger)index {
    [self.topView setupCurrent:(index + 1) total:browser.photos.count];
}

- (void)photoBrowser:(GKPhotoBrowser *)browser longPressWithIndex:(NSInteger)index {
    
}

- (void)photoBrowser:(GKPhotoBrowser *)browser willLayoutSubViews:(NSInteger)index {
    
}

- (void)photoBrowser:(GKPhotoBrowser *)browser panBeginWithIndex:(NSInteger)index {
    self.topView.hidden = YES;
    self.bottomView.hidden = YES;
}

- (void)photoBrowser:(GKPhotoBrowser *)browser panEndedWithIndex:(NSInteger)index willDisappear:(BOOL)disappear {
    if (disappear) {
        self.topView = nil;
        self.bottomView = nil;
    }else {
        self.topView.hidden = NO;
        self.bottomView.hidden = NO;
    }
}

- (void)photoBrowser:(GKPhotoBrowser *)browser onDeciceChangedWithIndex:(NSInteger)index isLandscape:(BOOL)isLandscape {
    [GKCover hideCover];
}

@end
