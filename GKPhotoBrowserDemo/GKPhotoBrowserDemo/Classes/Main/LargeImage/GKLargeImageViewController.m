//
//  GKLargeImageViewController.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2023/6/1.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKLargeImageViewController.h"
#import <Masonry/Masonry.h>
#import "GKLargeImageManager.h"

@interface GKLargeImageViewController ()

@property (nonatomic, strong) NSArray *images;

@end

@implementation GKLargeImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navTitle = @"超大图";
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIButton *imgButton = [[UIButton alloc] init];
    [imgButton setTitle:@"UIImageView显示" forState:UIControlStateNormal];
    [imgButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    imgButton.backgroundColor = UIColor.blackColor;
    imgButton.tag = 1;
    [self.view addSubview:imgButton];
    
    UIButton *tilButton = [[UIButton alloc] init];
    [tilButton setTitle:@"CATiledLayer显示" forState:UIControlStateNormal];
    [tilButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    tilButton.backgroundColor = UIColor.blackColor;
    tilButton.tag = 2;
    [self.view addSubview:tilButton];
    
    [imgButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.gk_navigationBar.mas_bottom).offset(100);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(160);
        make.height.mas_equalTo(100);
    }];
    
    [tilButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgButton.mas_bottom).offset(100);
        make.centerX.width.height.equalTo(imgButton);
    }];
    [imgButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [tilButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.images = @[
        @"https://user-images.githubusercontent.com/1712759/242524251-8a63edc7-97cc-4c85-a853-62ce5b10e2bc.jpg",
        @"https://images.pexels.com/photos/16862428/pexels-photo-16862428.jpeg?auto=compress&cs=tinysrgb&w=40000",
        @"https://images.pexels.com/photos/17028693/pexels-photo-17028693.jpeg?auto=compress&cs=tinysrgb&w=40000&lazy=load",
        @"https://images.pexels.com/photos/16991262/pexels-photo-16991262.jpeg?auto=compress&cs=tinysrgb&w=40000&lazy=load",
        @"https://images.pexels.com/photos/15753228/pexels-photo-15753228.jpeg?auto=compress&cs=tinysrgb&w=40000&lazy=load",
        @"https://images.pexels.com/photos/16960423/pexels-photo-16960423.jpeg?auto=compress&cs=tinysrgb&w=40000&lazy=load"];
}

- (void)btnClick:(UIButton *)btn {
    NSInteger type = btn.tag;
    
    NSMutableArray *photos = [NSMutableArray array];
    [self.images enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GKPhoto *photo = [[GKPhoto alloc] init];
        photo.url = [NSURL URLWithString:obj];
        [photos addObject:photo];
    }];
    
    GKLargeImageManager *manager = [[GKLargeImageManager alloc] initWithType:type];
    
    GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photos currentIndex:0];
    
    // 设置自定义图片加载类
    [browser setupWebImageProtocol:manager];
    
    // 结束显示时自动清理内存
    browser.isClearMemoryWhenDisappear = YES;
    
    // 重用时清理内存
    browser.isClearMemoryWhenViewReuse = YES;
    
    [browser showFromVC:self];
}

@end
