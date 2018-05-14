//
//  GKWeChatTimeLineViewController.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/8.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKTimeLineViewController.h"
#import "GKTimeLineViewCell.h"
#import "GKPhotoBrowser.h"

@interface GKTimeLineViewController ()<UITableViewDataSource, UITableViewDelegate, GKPhotoBrowserDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *dataFrames;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, weak) UIView *fromView;

@property (nonatomic, weak) UIView *actionSheet;

@property (nonatomic, assign) NSInteger count;

@end

@implementation GKTimeLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self setupData];
}

- (void)setupUI {
    self.gk_navigationItem.title = @"朋友圈";
    
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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"timeline" ofType:@"txt"];
    
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

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataFrames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKTimeLineViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTimeLineViewCellID forIndexPath:indexPath];
    
    cell.timeLineFrame = self.dataFrames[indexPath.row];
    
    cell.photosImgClickBlock = ^(GKTimeLineViewCell *cell, NSInteger index) {
        NSMutableArray *photos = [NSMutableArray new];
        [cell.timeLineFrame.model.images enumerateObjectsUsingBlock:^(GKTimeLineImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            GKPhoto *photo = [GKPhoto new];
            photo.url = [NSURL URLWithString:obj.url];
            photo.sourceImageView = cell.photosView.subviews[idx];
            
            [photos addObject:photo];
        }];
        
        self.pageControl = [[UIPageControl alloc] init];
        self.pageControl.numberOfPages = photos.count;
        self.pageControl.currentPage = index;
        self.pageControl.hidesForSinglePage = YES;
        
        GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photos currentIndex:index];
        browser.showStyle           = GKPhotoBrowserShowStyleZoom;
        browser.hideStyle           = GKPhotoBrowserHideStyleZoomScale;
        browser.loadStyle           = GKPhotoBrowserLoadStyleIndeterminateMask;
//        browser.isStatusBarShow     = YES;
//        browser.isResumePhotoZoom   = YES;
        [browser setupCoverViews:@[self.pageControl] layoutBlock:^(GKPhotoBrowser *photoBrowser, CGRect superFrame) {
            
            self.pageControl.center = CGPointMake(superFrame.size.width * 0.5, superFrame.size.height - 30);
            
            self.count ++;
            
            NSLog(@"%zd", self.count);
            
        }];
        browser.delegate = self;
        
        [browser showFromVC:self];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKTimeLineFrame *f = self.dataFrames[indexPath.row];
    return f.cellHeight;
}

#pragma mark - GKPhotoBrowserDelegate
- (void)photoBrowser:(GKPhotoBrowser *)browser didChangedIndex:(NSInteger)index {
    self.pageControl.currentPage = index;
}

- (void)photoBrowser:(GKPhotoBrowser *)browser longPressWithIndex:(NSInteger)index {
    
    if (self.fromView) return;
    
    UIView *contentView = browser.contentView;
    
    UIView *fromView = [UIView new];
    fromView.backgroundColor = [UIColor clearColor];
    fromView.frame = CGRectMake(0, 0, contentView.bounds.size.width, contentView.bounds.size.height);
    [contentView addSubview:fromView];
    self.fromView = fromView;
    
    UIView *actionSheet = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentView.bounds.size.width, 100)];
    self.actionSheet = actionSheet;

    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, actionSheet.width, 50)];
    [saveBtn setTitle:@"保存图片" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    saveBtn.backgroundColor = [UIColor whiteColor];
    [actionSheet addSubview:saveBtn];

    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 50, actionSheet.width, 50)];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.backgroundColor = [UIColor whiteColor];
    [actionSheet addSubview:cancelBtn];

    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, actionSheet.width, 0.5)];
    lineView.center = CGPointMake(actionSheet.width * 0.5, actionSheet.height * 0.5);
    lineView.backgroundColor = [UIColor grayColor];
    [actionSheet addSubview:lineView];

    [GKCover coverFrom:fromView
           contentView:actionSheet
                 style:GKCoverStyleTranslucent
             showStyle:GKCoverShowStyleBottom
             animStyle:GKCoverAnimStyleBottom
              notClick:NO
             showBlock:nil
             hideBlock:^{
                 [self.fromView removeFromSuperview];
                 self.fromView = nil;
             }];
}

- (void)photoBrowser:(GKPhotoBrowser *)browser willLayoutSubViews:(NSInteger)index {
    
    UIView *contentView = browser.contentView;
    
    self.fromView.frame = CGRectMake(0, 0, contentView.bounds.size.width, contentView.bounds.size.height);
    
    self.actionSheet.width = self.fromView.width;
    [self.actionSheet.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.width = self.fromView.width;
    }];
    
    [GKCover layoutSubViews];
}

- (void)saveBtnClick:(id)sender {
    
}

- (void)cancelBtnClick:(id)sender {
    [GKCover hideView];
}

@end
