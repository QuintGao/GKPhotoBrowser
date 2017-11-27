//
//  GKToutiaoViewController.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/9.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKToutiaoViewController.h"
#import "GKToutiaoViewCell.h"
#import "GKPhotoBrowser.h"
#import "GKToutiaoDetailViewController.h"

@interface GKToutiaoViewController ()<UITableViewDataSource, UITableViewDelegate, GKPhotoBrowserDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *moreBtn;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIImageView *btmImageView;
@property (nonatomic, strong) UILabel *btmLabel;

@property (nonatomic, assign) BOOL isCoverShow;

/** 不能强引用 */
@property (nonatomic, weak) GKPhotoBrowser *browser;

@property (nonatomic, weak) GKToutiaoViewCell *selectCell;

@end

@implementation GKToutiaoViewController

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
    [self.tableView registerClass:[GKToutiaoViewCell class] forCellReuseIdentifier:kToutiaoViewCellID];
    [self.view addSubview:self.tableView];
}

- (void)setupData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"toutiao" ofType:@"txt"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    self.dataSource = [NSArray yy_modelArrayWithClass:[GKToutiaoModel class] json:data];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKToutiaoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kToutiaoViewCellID forIndexPath:indexPath];
    
    cell.model = self.dataSource[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKToutiaoModel *model = self.dataSource[indexPath.row];
    
    return model.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray *photos = [NSMutableArray new];
    
    GKToutiaoViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    self.selectCell = cell;
    
    if (cell.model.type == 2) {
        
        GKToutiaoDetailViewController *detailVC = [GKToutiaoDetailViewController new];
        detailVC.model = cell.model;
        [self.navigationController pushViewController:detailVC animated:YES];
        
        return;
    }
    
    [cell.model.images enumerateObjectsUsingBlock:^(GKToutiaoImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GKPhoto *photo = [GKPhoto new];
        photo.url = [NSURL URLWithString:obj.url];
        
        if (idx < cell.photosView.subviews.count) {
            photo.sourceImageView = cell.photosView.subviews[idx];
        }
        
        [photos addObject:photo];
    }];
    
    GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photos currentIndex:0];
    
    browser.showStyle           = GKPhotoBrowserShowStyleNone;
    browser.hideStyle           = cell.model.type == 1 ? GKPhotoBrowserHideStyleZoomSlide : GKPhotoBrowserHideStyleZoomScale;
    browser.isSingleTapDisabled = YES;  // 不响应默认单击事件
    browser.isStatusBarShow     = YES;  // 显示状态栏
    browser.isHideSourceView    = NO;
    browser.delegate            = self;
    
    [browser setupCoverViews:@[self.closeBtn, self.moreBtn, self.bottomView] layoutBlock:^(GKPhotoBrowser *photoBrowser, CGRect superFrame) {
        
        [self resetCoverFrame:superFrame index:photoBrowser.currentIndex];
        
    }];
    
    [browser showFromVC:self];
    
    self.isCoverShow = YES;
    
    self.browser = browser;
}

- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxW:(CGFloat)maxW {
    CGSize size = CGSizeMake(maxW, CGFLOAT_MAX);
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:size options:options attributes:attrs context:nil].size;
}

#pragma makr - GKPhotoBrowserDelegate
- (void)photoBrowser:(GKPhotoBrowser *)browser scrollEndedIndex:(NSInteger)index {
    [self resetCoverFrame:browser.contentView.bounds index:index];
}

- (void)photoBrowser:(GKPhotoBrowser *)browser singleTapWithIndex:(NSInteger)index {
    
    self.isCoverShow = !self.isCoverShow;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.browser.isStatusBarShow = self.isCoverShow;
        self.closeBtn.hidden         = !self.isCoverShow;
        self.moreBtn.hidden          = !self.isCoverShow;
        self.bottomView.hidden       = !self.isCoverShow;
    }];
}

- (void)photoBrowser:(GKPhotoBrowser *)browser longPressWithIndex:(NSInteger)index {
    
}

- (void)photoBrowser:(GKPhotoBrowser *)browser panBeginWithIndex:(NSInteger)index {
    self.closeBtn.hidden   = YES;
    self.moreBtn.hidden    = YES;
    self.bottomView.hidden = YES;
    
    self.selectCell.photosView.alpha = 0;
}

- (void)photoBrowser:(GKPhotoBrowser *)browser panEndedWithIndex:(NSInteger)index willDisappear:(BOOL)disappear {
    
    if (disappear) {
        self.isCoverShow = NO;
        
        self.closeBtn    = nil;
        self.moreBtn     = nil;
        self.bottomView  = nil;
        
        self.selectCell.photosView.alpha = 1.0;
        
    }else {
        self.closeBtn.hidden   = !self.isCoverShow;
        self.moreBtn.hidden    = !self.isCoverShow;
        self.bottomView.hidden = !self.isCoverShow;
    }
}

- (void)resetCoverFrame:(CGRect)frame index:(NSInteger)index{
    self.closeBtn.left = 15;
    self.closeBtn.top  = 30;
    
    self.moreBtn.left  = frame.size.width - 15 - self.moreBtn.width;
    self.moreBtn.top   = 30;
    
    BOOL isLandspace = frame.size.width > frame.size.height;
    
    // 计算高度
    GKToutiaoImage *image = self.selectCell.model.images[index];
    
    CGFloat width    = frame.size.width;
    CGFloat maxWidth = width - 30;
    
    NSString *desc = [NSString stringWithFormat:@"%zd/%zd %@", index + 1, self.selectCell.model.images.count, image.desc];
    
    CGSize size = [self sizeWithText:desc font:self.btmLabel.font maxW:maxWidth];
    self.btmLabel.frame = CGRectMake(15, 15, maxWidth, size.height);
    self.btmLabel.text  = desc;
    
    CGFloat height = CGRectGetMaxY(self.btmLabel.frame) + 10;
    height = isLandspace ? height : height + 40;
    
    self.bottomView.frame = CGRectMake(0, frame.size.height - height, width, height);
    
    self.btmImageView.frame = isLandspace ? CGRectZero : CGRectMake(0, height - 40, width, 40);
}

#pragma mark - Action
- (void)closeBtnClick:(id)sender {
    self.selectCell.photosView.alpha = 1.0;
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    
    [self.browser dismissViewControllerAnimated:YES completion:nil];
}

- (void)moreBtnClick:(id)sender {
    
}

#pragma mark - 懒加载
- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton new];
        [_closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn sizeToFit];
    }
    return _closeBtn;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [UIButton new];
        [_moreBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        [_moreBtn addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_moreBtn sizeToFit];
    }
    return _moreBtn;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [UIView new];
        _bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        
        [_bottomView addSubview:self.btmLabel];
        [_bottomView addSubview:self.btmImageView];
    }
    return _bottomView;
}

- (UIImageView *)btmImageView {
    if (!_btmImageView) {
        _btmImageView = [UIImageView new];
        _btmImageView.image = [UIImage imageNamed:@"bottom"];
        
    }
    return _btmImageView;
}

- (UILabel *)btmLabel {
    if (!_btmLabel) {
        _btmLabel = [UILabel new];
        _btmLabel.numberOfLines = 0;
        _btmLabel.textColor = [UIColor whiteColor];
        _btmLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _btmLabel;
}

@end
