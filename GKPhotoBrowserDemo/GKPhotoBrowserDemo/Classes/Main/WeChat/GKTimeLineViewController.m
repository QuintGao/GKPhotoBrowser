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

@property (nonatomic, assign) BOOL isLandspace;

/** 这里用weak是防止GKPhotoBrowser被强引用，导致不能释放 */
@property (nonatomic, weak) GKPhotoBrowser *browser;

@property (nonatomic, assign) NSInteger     currentIndex;

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
        
        weakSelf.pageControl = [[UIPageControl alloc] init];
        weakSelf.pageControl.numberOfPages = photos.count;
        weakSelf.pageControl.currentPage = index;
        weakSelf.pageControl.hidesForSinglePage = YES;
        
        GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photos currentIndex:index];
        browser.showStyle = GKPhotoBrowserShowStyleZoom;        // 缩放显示
        browser.hideStyle = GKPhotoBrowserHideStyleZoomScale;   // 缩放隐藏
        browser.loadStyle = GKPhotoBrowserLoadStyleIndeterminateMask; // 不明确的加载方式带阴影
//        browser.isStatusBarShow     = YES;
//        browser.isResumePhotoZoom   = YES;
        browser.isAdaptiveSafeArea = YES;
        [browser setupCoverViews:@[weakSelf.pageControl] layoutBlock:^(GKPhotoBrowser *photoBrowser, CGRect superFrame) {
            
            CGFloat pointY = 0;
            if (photoBrowser.isLandspace) {
                pointY = superFrame.size.height - 20;
            }else {
                pointY = superFrame.size.height - 10;
            }
            
            weakSelf.pageControl.center = CGPointMake(superFrame.size.width * 0.5, pointY);
            
            weakSelf.count ++;
        }];
        
        browser.delegate = weakSelf;
        
        [browser showFromVC:weakSelf];
        
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
    self.pageControl.currentPage = index;
}

- (void)photoBrowser:(GKPhotoBrowser *)browser longPressWithIndex:(NSInteger)index {
    
    if (self.fromView) return;
    if (browser.currentOrientation == UIDeviceOrientationPortraitUpsideDown) return;
    
    self.currentIndex = index;
    
    UIView *contentView = browser.contentView;
    
    UIView *fromView = [UIView new];
    fromView.backgroundColor = [UIColor clearColor];
    self.fromView = fromView;
    
    self.isLandspace = browser.isLandspace;
    
    CGFloat actionSheetH = 0;
    
    if (self.isLandspace) {
        actionSheetH = 150;
        fromView.frame = contentView.bounds;
        [contentView addSubview:fromView];
    }else {
        actionSheetH = 150 + kSafeBottomSpace;
        fromView.frame = browser.view.bounds;
        [browser.view addSubview:fromView];
    }
    
    UIView *actionSheet = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentView.bounds.size.width, actionSheetH)];
    actionSheet.backgroundColor = [UIColor whiteColor];
    self.actionSheet = actionSheet;
    
    UIButton *delBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, actionSheet.width, 50)];
    [delBtn setTitle:@"删除" forState:UIControlStateNormal];
    [delBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [delBtn addTarget:self action:@selector(delBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    delBtn.backgroundColor = [UIColor whiteColor];
    [actionSheet addSubview:delBtn];

    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 50, actionSheet.width, 50)];
    [saveBtn setTitle:@"保存图片" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    saveBtn.backgroundColor = [UIColor whiteColor];
    [actionSheet addSubview:saveBtn];

    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, actionSheet.width, 50)];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.backgroundColor = [UIColor whiteColor];
    [actionSheet addSubview:cancelBtn];

    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, actionSheet.width, 0.5)];
    lineView.backgroundColor = [UIColor grayColor];
    [actionSheet addSubview:lineView];
    
    UIView *line2View = [[UIView alloc] initWithFrame:CGRectMake(0, 100, actionSheet.width, 0.5)];
    line2View.backgroundColor = [UIColor grayColor];
    [actionSheet addSubview:line2View];

    [GKCover coverFrom:fromView
           contentView:actionSheet
                 style:GKCoverStyleTranslucent
             showStyle:GKCoverShowStyleBottom
         showAnimStyle:GKCoverShowAnimStyleBottom
         hideAnimStyle:GKCoverHideAnimStyleBottom
              notClick:NO
             showBlock:nil
             hideBlock:^{
                 
                 [self.fromView removeFromSuperview];
                 self.fromView = nil;
             }];
}

- (void)photoBrowser:(GKPhotoBrowser *)browser willLayoutSubViews:(NSInteger)index {
    
    
//    UIView *contentView = browser.contentView;
//
//    [self.fromView removeFromSuperview];
//
//    if (browser.contentView.size.width > browser.contentView.size.height) { // 横屏
//        [contentView addSubview:self.fromView];
//        self.fromView.frame = CGRectMake(0, 0, contentView.bounds.size.width, contentView.bounds.size.height);
//    }else {
//        [browser.view addSubview:self.fromView];
//        self.fromView.frame = CGRectMake(0, 0, contentView.bounds.size.width, contentView.bounds.size.height);
//    }
//
//    self.actionSheet.width = contentView.frame.size.width;
//    [self.actionSheet.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        obj.width = contentView.frame.size.width;
//    }];
//
//    [GKCover layoutSubViews];
}

- (void)photoBrowser:(GKPhotoBrowser *)browser onDeciceChangedWithIndex:(NSInteger)index isLandspace:(BOOL)isLandspace {
    [GKCover hideCover];
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
    
    [self.browser removePhotoAtIndex:self.currentIndex];
    
    self.pageControl.numberOfPages = self.browser.photos.count;
}

- (void)saveBtnClick:(id)sender {
    [GKCover hideCover];
    
    GKPhoto *photo = self.browser.photos[self.browser.currentIndex];
    
    UIImageWriteToSavedPhotosAlbum(photo.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)cancelBtnClick:(id)sender {
    [GKCover hideCover];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}

@end
