//
//  GKTest02ViewController.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/27.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKTest02ViewController.h"
#import "GKTest02ViewCell.h"

#import <GKPhotoBrowser/GKPhotoBrowser.h>
#import <GKPhotoBrowser/GKYYWebImageManager.h>
#import <SDWebImage/SDWebImage.h>
#import <YYWebImage/YYWebImage.h>
#import <GKMessageTool/GKMessageTool.h>

@interface GKTest02ViewController ()<UITableViewDataSource, UITableViewDelegate, GKPhotoBrowserDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

//@property (nonatomic, strong) UIView *containerView;

@end

@implementation GKTest02ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationItem.title = @"test02";
    
    [self setupView];

    [self setupData];
}

- (void)dealloc {
    NSLog(@"002dealloc");
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

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
    self.tableView.top = self.gk_navigationBar.bottom;
    self.tableView.height = self.view.height - self.gk_navigationBar.height;
}

- (void)setupData {
    
    self.dataSource = @[
        @[@"001", @"002", @"003", @"test.gif"],
        @[@"http://ww2.sinaimg.cn/large/85d77acdgw1f4hzsolyscg20cy07xkjp.jpg",
          @"http://ww2.sinaimg.cn/large/85ccde71gw1f9ksx38wjrg20dw05ah0v.jpg",
          @"http://ww1.sinaimg.cn/large/85cccab3gw1etdecj1njlg20dw06lnpd.jpg",
          @"http://ww2.sinaimg.cn/large/85cccab3gw1etdeckhl80g20dw0991f4.jpg",
          @"http://ww1.sinaimg.cn/large/85cccab3gw1etekil9309g20dw06ex1r.jpg",
          @"http://ww2.sinaimg.cn/large/85cccab3gw1etdz3c7w9ag20dw07th5f.jpg"]
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
    
    __weak __typeof(self) weakSelf = self;
    cell.imgClickBlock = ^(UIView *containerView, NSArray *photos, NSInteger index) {
        NSMutableArray *photoArrs = [NSMutableArray new];
        
        [photos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GKPhoto *photo        = [GKPhoto new];
            if ([obj hasPrefix:@"http"]) {
                photo.url         = [NSURL URLWithString:obj];
            }else {
//                photo.image       = [UIImage imageNamed:obj];
                
                // 如果使用SDWebImage，请使用SDAnimatedImage加载本地图片
                // photo.image = [SDAnimatedImage imageNamed:obj];
                
                // 如果使用YYWebImage，请使用YYImage加载本地图片
                NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:obj ofType:nil]];
//                photo.image = [YYImage imageNamed:obj];
                photo.image = [YYImage imageWithData:data];
                
                if (!photo.image) {
                    photo.image = [UIImage imageNamed:obj];
                }
            }
            photo.sourceImageView = containerView.subviews[idx];
            [photoArrs addObject:photo];
        }];
        
        GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photoArrs currentIndex:index];
        browser.showStyle       = GKPhotoBrowserShowStyleZoom;
        browser.hideStyle       = GKPhotoBrowserHideStyleZoomScale;
        
        // 指定imageProtocol
        [browser setupWebImageProtocol:[GKYYWebImageManager new]];
        
        if (indexPath.row == 2) {
            if (index == 0) {
                browser.failStyle = GKPhotoBrowserFailStyleOnlyText;
            }else if (index == 1) {
                browser.failStyle = GKPhotoBrowserFailStyleOnlyImage;
            }else if (index == 2) {
                browser.failStyle = GKPhotoBrowserFailStyleImageAndText;
            }else if (index == 3) {
                browser.failStyle = GKPhotoBrowserFailStyleCustom;
            }
        }
        browser.loadStyle = GKPhotoBrowserLoadStyleDeterminate;
//        browser.failStyle       = GKPhotoBrowserFailStyleOnlyImage;
        browser.failureText     = @"图片加载失败了，555";
        browser.failureImage    = [UIImage imageNamed:@"error"];
        browser.delegate        = weakSelf;
        if (kIsiPad) {
            browser.isFollowSystemRotation = YES;
        }
        
        [browser showFromVC:weakSelf];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *images = self.dataSource[indexPath.row];
    
    return [GKTest02ViewCell cellHeightWithWidth:self.view.bounds.size.width count:images.count];
}

#pragma mark - GKPhotoBrowserDelegate
- (void)photoBrowser:(GKPhotoBrowser *)browser loadFailedAtIndex:(NSInteger)index {
    [GKMessageTool showText:@"加载失败"];
}

@end
