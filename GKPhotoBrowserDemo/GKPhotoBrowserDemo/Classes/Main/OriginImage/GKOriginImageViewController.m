//
//  GKOriginImageViewController.m
//  GKPhotoBrowserDemo
//
//  Created by gaokun on 2019/4/25.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKOriginImageViewController.h"
#import "GKPhotoBrowser.h"

@interface GKOriginImageViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, GKPhotoBrowserDelegate>

@property (nonatomic, strong) UICollectionView  *collectionView;

@property (nonatomic, strong) NSMutableArray    *thumbImgs;
@property (nonatomic, strong) NSMutableArray    *originImgs;

@property (nonatomic, weak) GKPhotoBrowser      *browser;

@property (nonatomic, weak) UIButton            *originBtn;

@end

@implementation GKOriginImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.gk_navTitle = @"加载原图";
    
    self.collectionView.frame = CGRectMake(0, GK_STATUSBAR_NAVBAR_HEIGHT, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT - GK_STATUSBAR_NAVBAR_HEIGHT);
    [self.view addSubview:self.collectionView];
    
    NSMutableArray *thumbnailImageUrls = [NSMutableArray array];
    [thumbnailImageUrls addObject:@"http://ww3.sinaimg.cn/thumbnail/006ka0Iygw1f6bqm7zukpj30g60kzdi2.jpg"];
    [thumbnailImageUrls addObject:@"http://ww1.sinaimg.cn/thumbnail/61b69811gw1f6bqb1bfd2j20b4095dfy.jpg"];
    [thumbnailImageUrls addObject:@"http://ww1.sinaimg.cn/thumbnail/54477ddfgw1f6bqkbanqoj20ku0rsn4d.jpg"];
    [thumbnailImageUrls addObject:@"http://ww4.sinaimg.cn/thumbnail/006ka0Iygw1f6b8gpwr2tj30bc0bqmyz.jpg"];
    [thumbnailImageUrls addObject:@"http://ww2.sinaimg.cn/thumbnail/9c2b5f31jw1f6bqtinmpyj20dw0ae76e.jpg"];
    [thumbnailImageUrls addObject:@"http://ww1.sinaimg.cn/thumbnail/536e7093jw1f6bqdj3lpjj20va134ana.jpg"];
    [thumbnailImageUrls addObject:@"http://ww1.sinaimg.cn/thumbnail/75b1a75fjw1f6bqn35ij6j20ck0g8jtf.jpg"];
    [thumbnailImageUrls addObject:@"https://img.aiyinsitanfm.com/data/img/album/content/2018/10/16/728170c229bc4465a0c3084e2abaa86e.jpg?imageView2/q/10"];
    self.thumbImgs = thumbnailImageUrls;
    
    NSMutableArray *originalImageUrls = [NSMutableArray array];
    [originalImageUrls addObject:@"http://ww3.sinaimg.cn/large/006ka0Iygw1f6bqm7zukpj30g60kzdi2.jpg"];
    [originalImageUrls addObject:@"http://ww1.sinaimg.cn/large/61b69811gw1f6bqb1bfd2j20b4095dfy.jpg"];
    [originalImageUrls addObject:@"http://ww1.sinaimg.cn/large/54477ddfgw1f6bqkbanqoj20ku0rsn4d.jpg"];
    [originalImageUrls addObject:@"http://ww4.sinaimg.cn/large/006ka0Iygw1f6b8gpwr2tj30bc0bqmyz.jpg"];
    [originalImageUrls addObject:@"http://ww2.sinaimg.cn/large/9c2b5f31jw1f6bqtinmpyj20dw0ae76e.jpg"];
    [originalImageUrls addObject:@"http://ww1.sinaimg.cn/large/536e7093jw1f6bqdj3lpjj20va134ana.jpg"];
    [originalImageUrls addObject:@"http://ww1.sinaimg.cn/large/75b1a75fjw1f6bqn35ij6j20ck0g8jtf.jpg"];
    [originalImageUrls addObject:@"https://img.aiyinsitanfm.com/data/img/album/content/2018/10/16/728170c229bc4465a0c3084e2abaa86e.jpg"];
    self.originImgs = originalImageUrls;
    
    [self.collectionView reloadData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.collectionView.frame = CGRectMake(0, self.gk_navigationBar.bottom, KScreenW, KScreenH - self.gk_navigationBar.height);
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegate>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.thumbImgs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    UIImageView *imgView = [UIImageView new];
    imgView.frame = cell.bounds;
    imgView.tag = [cell hash] + indexPath.item;
    [imgView sd_setImageWithURL:[NSURL URLWithString:self.thumbImgs[indexPath.item]]];
    [cell addSubview:imgView];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *photos = [NSMutableArray new];
    [self.thumbImgs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GKPhoto *photo = [GKPhoto new];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        UIImageView *imgView = [cell viewWithTag:([cell hash] + indexPath.item)];
        
        photo.sourceImageView = imgView;
        photo.url = [NSURL URLWithString:obj];
        photo.originUrl = [NSURL URLWithString:self.originImgs[idx]];
        [photos addObject:photo];
    }];
    
    GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photos currentIndex:indexPath.item];
    browser.showStyle = GKPhotoBrowserShowStyleZoom;
    browser.hideStyle = GKPhotoBrowserHideStyleZoomScale;
//    browser.loadStyle = GKPhotoBrowserLoadStyleIndeterminate;
    browser.loadStyle = GKPhotoBrowserLoadStyleCustom;
    browser.originLoadStyle = GKPhotoBrowserLoadStyleCustom;
    browser.delegate = self;
    if (kIsiPad) {
        browser.isFollowSystemRotation = YES;
    }
    self.browser = browser;
    
    UIButton *originBtn = [UIButton new];
    originBtn.backgroundColor = [UIColor blackColor];
    [originBtn setTitle:@"查看原图" forState:UIControlStateNormal];
    [originBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    originBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    originBtn.layer.masksToBounds = YES;
    originBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    originBtn.layer.borderWidth = 1.0f;
    [originBtn addTarget:self action:@selector(originBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.originBtn = originBtn;
    
    [browser setupCoverViews:@[originBtn] layoutBlock:^(GKPhotoBrowser * _Nonnull photoBrowser, CGRect superFrame) {
        originBtn.frame = CGRectMake((superFrame.size.width - 160) / 2, superFrame.size.height - 80, 160, 40);
    }];
    
    [browser showFromVC:self];
}

- (void)originBtnClick:(id)sender {
    [self.browser loadCurrentPhotoImage];
}

#pragma mark - GKPhotoBrowserDelegate
- (void)photoBrowser:(GKPhotoBrowser *)browser willLayoutSubViews:(NSInteger)index {
    
}

- (void)photoBrowser:(GKPhotoBrowser *)browser loadImageAtIndex:(NSInteger)index progress:(float)progress isOriginImage:(BOOL)isOriginImage {
    
    if (!isOriginImage && progress == 1.0f && !browser.curPhotoView.photo.originFinished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [browser loadCurrentPhotoImage];
        });
    }
    
    if (isOriginImage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *text = [NSString stringWithFormat:@"%.f%%", progress * 100];
            [self.originBtn setTitle:text forState:UIControlStateNormal];
            
            if (progress == 1.0) {
                self.originBtn.hidden = YES;
            }
        });
    }
}

- (void)photoBrowser:(GKPhotoBrowser *)browser didSelectAtIndex:(NSInteger)index {
    GKPhoto *photo = browser.curPhotoView.photo;
    
    if (photo.originFinished) {
        self.originBtn.hidden = YES;
    }else {
        [self.originBtn setTitle:@"查看原图" forState:UIControlStateNormal];
        self.originBtn.hidden = NO;
    }
}

#pragma mark - 懒加载
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat itemWH = (KScreenW - 40) / 3 - 0.01;
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(itemWH, itemWH);
        layout.minimumLineSpacing = 10.0f;
        layout.minimumInteritemSpacing = 10.0f;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 0, 10);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}

@end
