//
//  GKTestViewController.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2018/5/14.
//  Copyright © 2018年 QuintGao. All rights reserved.
//

#import "GKTestViewController.h"
#import "GKTest02ViewCell.h"

#import "GKPhotoBrowser.h"

@interface GKTestViewController ()<UITableViewDataSource, UITableViewDelegate, GKPhotoBrowserDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@end

@implementation GKTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationItem.title = @"test02";
    
    [self setupView];
    
    [self setupData];
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
    
    self.dataSource = @[@[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536686&di=aa91a60dfb4f9f762f58bb4513f9ef64&imgtype=0&src=http%3A%2F%2Fd.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F50da81cb39dbb6fd493c67e70024ab18962b378f.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536685&di=3b472d84a7801f2fd48afaa4f041fadb&imgtype=0&src=http%3A%2F%2Fb.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F0824ab18972bd40704fe413d72899e510fb30930.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536685&di=18fcb83dcc07f87aefbf58e8538ed4d8&imgtype=0&src=http%3A%2F%2Fg.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2Fd1160924ab18972b22abd40aefcd7b899f510a59.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536685&di=b40f1593ca5f51f64c8f8670598e79a2&imgtype=0&src=http%3A%2F%2Fg.hiphotos.baidu.com%2Fimage%2Fcrop%253D0%252C0%252C1024%252C654%2Fsign%3Dafc45f018b025aafc77d248bc6dd8754%2F838ba61ea8d3fd1f3fe3bbfb394e251f94ca5f0c.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536685&di=a47731fce0273aae3ddeb03d89fc273b&imgtype=0&src=http%3A%2F%2Ff.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2Fb7003af33a87e950f0e956ad19385343faf2b471.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536685&di=121d9ff529f2d9807970f965aeca6c0f&imgtype=0&src=http%3A%2F%2Ff.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F241f95cad1c8a7861cb6a3ce6e09c93d71cf5056.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536685&di=a82dd1f57162599367340d0b5a9ece74&imgtype=0&src=http%3A%2F%2Fa.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2Fae51f3deb48f8c546c9162ee33292df5e1fe7fb5.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536684&di=22258dd90dec8f57bdeea79f8c17b04f&imgtype=0&src=http%3A%2F%2Fc.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F0d338744ebf81a4c1393d808de2a6059242da649.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536684&di=16dfed673e74c9e5f1c53e02700ab174&imgtype=0&src=http%3A%2F%2Fe.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2Fd058ccbf6c81800a6d5592cfb83533fa838b47ba.jpg"]
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
        [browser setupCoverViews:@[self.coverView] layoutBlock:^(GKPhotoBrowser * _Nonnull photoBrowser, CGRect superFrame) {
            self.coverView.frame = CGRectMake(0, 200, superFrame.size.width, 100);
        }];
        
        [browser showFromVC:self];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *images = self.dataSource[indexPath.row];
    
    return [GKTest02ViewCell cellHeightWithCount:images.count];
}

- (void)pangesture:(UIPanGestureRecognizer *)pan {
    
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
