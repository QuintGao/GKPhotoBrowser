//
//  GKTestViewController.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2018/5/14.
//  Copyright © 2018年 QuintGao. All rights reserved.
//

#import "GKTestViewController.h"
#import "GKTest02ViewCell.h"
#import "GKBottomView.h"
#import <GKPhotoBrowser/GKPhotoBrowser.h>
#import "GKVideoProgressView.h"
#import <Masonry/Masonry.h>

@interface GKTestViewController ()<UITableViewDataSource, UITableViewDelegate, GKPhotoBrowserDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, weak) GKPhotoBrowser *browser;

@property (nonatomic, weak) GKVideoProgressView *progressView;

@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) NSTimeInterval totalTime;

@end

@implementation GKTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationItem.title = @"test02";
    self.view.backgroundColor = [UIColor whiteColor];
    
//    GKVideoProgressView *progressView = [[GKVideoProgressView alloc] init];
//    progressView.backgroundColor = UIColor.redColor;
//    [self.view addSubview:progressView];
//
////    [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
////        make.left.right.equalTo(self.view);
////        make.top.equalTo(self.gk_navigationBar.mas_bottom).offset(50);
////        make.height.mas_equalTo(80);
////    }];
//    progressView.frame = CGRectMake(0, 200, self.view.bounds.size.width, 80);
//    self.progressView = progressView;
    
//    self.totalTime = 10;
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeCount) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    GKBottomView *btmView = [GKBottomView new];
    btmView.frame = CGRectMake(0, 100, self.view.frame.size.width, 100);
    [self.view addSubview:btmView];
    [self setupView];

    [self setupData];
}

- (void)timeCount {
    self.currentTime ++;
    if (self.currentTime > self.totalTime) {
        self.currentTime = 0;
    }
    [self.progressView updateCurrentTime:self.currentTime totalTime:self.totalTime];
}

- (void)setupView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.top        = self.gk_navigationBar.bottom;
    self.tableView.height     = self.view.height - self.gk_navigationBar.height;
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    self.tableView.rowHeight  = 200;
    [self.tableView registerClass:[GKTest02ViewCell class] forCellReuseIdentifier:@"test02"];
    [self.view addSubview:self.tableView];
}

- (void)setupData {
    
    self.dataSource = @[@[@"http://p1.music.126.net/9k3CAPfB9WdcMCFk4CYnKQ==/109951167793871917.jpg?imageView&quality=89",
         @"http://p1.music.126.net/GK7JvutM88U4ZkohN71TKQ==/109951167794081491.jpg?imageView&quality=89",
//         @"http://p1.music.126.net/QywPBMy3VK-P-wk_eYjrZw==/109951167793910298.jpg?imageView&quality=89",
//         @"http://p1.music.126.net/c4vOjlBA5bQsmpuASPi5QQ==/109951167794545716.jpg?imageView&quality=89",
//         @"http://p1.music.126.net/4ryVvqlvXp0Kh_fcxCWMsA==/109951166903789195.jpg?param=140y140",
         @"http://p1.music.126.net/gZWQbChzhCbGFXtpin2MXw==/109951167592864239.jpg?param=140y140"]
                        ];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKTest02ViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"test02" forIndexPath:indexPath];
    
    cell.photos = self.dataSource[indexPath.row];
    
    cell.imgClickBlock = ^(UIView *containerView, NSArray *photos, NSInteger index) {
        NSMutableArray *photoArrs = [NSMutableArray new];
        
        [photos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GKPhoto *photo        = [GKPhoto new];
            if ([obj hasPrefix:@"http"]) {
                photo.url         = [NSURL URLWithString:obj];
            }else {
                photo.image       = [UIImage imageNamed:obj];
            }
            photo.sourceImageView = containerView.subviews[idx];
            [photoArrs addObject:photo];
        }];
        
        GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photoArrs currentIndex:index];
        //        browser.photos       = photoArrs;
        //        browser.currentIndex = index;
        browser.showStyle    = GKPhotoBrowserShowStyleZoom;
        browser.hideStyle    = GKPhotoBrowserHideStyleZoomScale;
//        browser.isFollowSystemRotation = YES;
        browser.addNavigationController = YES;
        
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[UIImage imageNamed:@"cm2_list_detail_icn_cmt"] forState:UIControlStateNormal];
        [btn sizeToFit];
        
        [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
        
        [browser setupCoverViews:@[btn] layoutBlock:^(GKPhotoBrowser * _Nonnull photoBrowser, CGRect superFrame) {
            CGRect frame = btn.frame;
            frame.origin.x = superFrame.size.width - frame.size.width - 30;
            frame.origin.y = superFrame.size.height - frame.size.height - 30;
            btn.frame = frame;
        }];
        
        browser.delegate = self;
        [browser showFromVC:self];
        self.browser = browser;
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [photoArrs enumerateObjectsUsingBlock:^(GKPhoto *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                if (idx == 2) {
//                    obj.videoUrl = [NSURL URLWithString:@"http://vd3.bdstatic.com/mda-ph53eii3pywz9ax9/cae_h264/1691439126672883676/mda-ph53eii3pywz9ax9.mp4"];
//                }
//            }];
//            [self.browser resetPhotoBrowserWithPhotos:photoArrs];
//        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            GKPhoto *photo = photoArrs[2];
            photo.videoUrl = [NSURL URLWithString:@"http://vd3.bdstatic.com/mda-ph53eii3pywz9ax9/cae_h264/1691439126672883676/mda-ph53eii3pywz9ax9.mp4"];
            [self.browser resetPhotoBrowserWithPhoto:photo index:2];
        });
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *images = self.dataSource[indexPath.row];
    
    return [GKTest02ViewCell cellHeightWithWidth:self.view.bounds.size.width count:images.count];
}

- (void)pangesture:(UIPanGestureRecognizer *)pan {
    
}

- (void)btnClick {
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = UIColor.grayColor;
    [self.browser.navigationController setNavigationBarHidden:NO];
    [self.browser.navigationController pushViewController:vc animated:YES];
}

#pragma mark - GKPhotoBrowserDelegate
- (void)photoBrowser:(GKPhotoBrowser *)browser didDisappearAtIndex:(NSInteger)index {
    
}

- (void)photoBrowser:(GKPhotoBrowser *)browser willLayoutSubViews:(NSInteger)index {
    CGFloat width = browser.contentView.bounds.size.width;
    CGFloat height = browser.contentView.bounds.size.height;
    
    browser.pageControl.center = CGPointMake(width * 0.5, height - kSafeBottomSpace - 10);
}

#pragma mark - 懒加载
- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [UIView new];
        _coverView.backgroundColor = [UIColor redColor];
        [_coverView addGestureRecognizer:self.panGesture];
    }
    return _coverView;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pangesture:)];
    }
    return _panGesture;
}

@end
