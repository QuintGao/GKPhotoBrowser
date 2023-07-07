//
//  GKDemoViewController.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2023/3/7.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDemoViewController.h"
#import <GKPhotoBrowser/GKPhotoBrowser.h>
#import "GKPhotosView.h"
#import <Masonry/Masonry.h>
#import <GKPhotoBrowser/GKSDWebImageManager.h>
#import <GKPhotoBrowser/GKYYWebImageManager.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <GKMessageTool/GKMessageTool.h>

@interface GKDemoViewController ()<GKPhotosViewDelegate, GKPhotoBrowserDelegate>

// 必须弱引用
@property (nonatomic, weak) GKPhotoBrowser *browser;

// 显示方式
@property (nonatomic, assign) GKPhotoBrowserShowStyle showStyle;
@property (nonatomic, strong) UILabel *showLabel;
@property (nonatomic, strong) UISegmentedControl *showControl;

// 隐藏方式
@property (nonatomic, assign) GKPhotoBrowserHideStyle hideStyle;
@property (nonatomic, strong) UILabel *hideLabel;
@property (nonatomic, strong) UISegmentedControl *hideControl;

// 加载方式
@property (nonatomic, assign) GKPhotoBrowserLoadStyle loadStyle;
@property (nonatomic, strong) UILabel *loadLabel;
@property (nonatomic, strong) UISegmentedControl *loadControl;

// 失败显示方式
@property (nonatomic, assign) GKPhotoBrowserFailStyle failStyle;
@property (nonatomic, strong) UILabel *failLabel;
@property (nonatomic, strong) UISegmentedControl *failControl;

// 图片加载方式
@property (nonatomic, assign) NSInteger imgLoadStyle;
@property (nonatomic, strong) UILabel *imgLoadLabel;
@property (nonatomic, strong) UISegmentedControl *imgLoadControl;

@property (nonatomic, strong) GKPhotosView *photosView;
@property (nonatomic, strong) NSArray *photos;

@property (nonatomic, strong) UIImageView *customFailView;

@end

@implementation GKDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self loadData];
}

- (void)initUI {
    self.view.backgroundColor = UIColor.whiteColor;
    self.gk_navTitle = @"GKPhotoBrowser";
    
    [self.view addSubview:self.showLabel];
    [self.view addSubview:self.showControl];
    [self.view addSubview:self.hideLabel];
    [self.view addSubview:self.hideControl];
    [self.view addSubview:self.loadLabel];
    [self.view addSubview:self.loadControl];
    [self.view addSubview:self.failLabel];
    [self.view addSubview:self.failControl];
    [self.view addSubview:self.imgLoadLabel];
    [self.view addSubview:self.imgLoadControl];
    
    [self.showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.gk_navigationBar.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
    }];
    
    [self.showControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.showLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.view);
    }];
    
    [self.hideLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.showControl.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
    }];
    
    [self.hideControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hideLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.view);
    }];
    
    [self.loadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hideControl.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
    }];
    
    [self.loadControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loadLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.view);
    }];
    
    [self.failLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loadControl.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
    }];
    
    [self.failControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.failLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.view);
    }];
    
    [self.imgLoadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.failControl.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
    }];
    
    [self.imgLoadControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgLoadLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.view);
    }];
    
    self.photosView =  [GKPhotosView photosViewWithWidth:self.view.bounds.size.width - 20 andMargin:10];
    self.photosView.delegate = self;
    [self.view addSubview:self.photosView];
}

- (void)loadData {
    NSArray *images = @[
                        @"https://img2.baidu.com/it/u=3316344338,3288169191&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500",
                        @"https://img0.baidu.com/it/u=3886978592,3432337795&fm=253&fmt=auto&app=138&f=JPEG?w=1194&h=500",
                        @"https://img1.baidu.com/it/u=2226546102,192117690&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=889",
                        @"https://img.zdwx.net/group1/M00/05/71/wKgCFF7Gg4GAVIB8ABNYPLSU3f0067.jpg",
                        @"https://hbimg.huaban.com/553632d876c342a9ffb007999b67432b69bebcf8684b4",
                        @"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fitem%2F201703%2F23%2F20170323121431_QzNxW.thumb.400_0.gif&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1680760815&t=a95782bbf075125d6ccfbb401a831364"];
    self.photos = images;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat height = [GKPhotosView sizeWithCount:images.count width:self.view.bounds.size.width - 20 andMargin:10].height;
        CGFloat y = CGRectGetMaxY(self.imgLoadControl.frame) + 20;
        self.photosView.frame = CGRectMake(10, y, self.view.bounds.size.width - 20, height);
        
        self.photosView.photos = images;
    });
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.photosView updateWidth:self.view.bounds.size.width - 20];
    CGFloat height = [GKPhotosView sizeWithCount:self.photos.count width:self.view.bounds.size.width - 20 andMargin:10].height;
    CGFloat y = CGRectGetMaxY(self.imgLoadControl.frame) + 20;
    self.photosView.frame = CGRectMake(10, y, self.view.bounds.size.width - 20, height);
}

#pragma mark - Action
- (void)controlAction:(UISegmentedControl *)control {
    if (control == self.showControl) {
        self.showStyle = (GKPhotoBrowserShowStyle)control.selectedSegmentIndex;
    }else if (control == self.hideControl) {
        self.hideStyle = (GKPhotoBrowserHideStyle)control.selectedSegmentIndex;
    }else if (control == self.loadControl){
        self.loadStyle = (GKPhotoBrowserLoadStyle)control.selectedSegmentIndex;
    }else if (control == self.failControl) {
        self.failStyle = (GKPhotoBrowserFailStyle)control.selectedSegmentIndex;
    }else if (control == self.imgLoadControl) {
        self.imgLoadStyle = control.selectedSegmentIndex;
    }
}

#pragma mark - GKPhotosViewDelegate
- (void)photoTapped:(UIImageView *)imgView {
    NSMutableArray *photos = [NSMutableArray array];
    
    [self.photos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GKPhoto *photo = [[GKPhoto alloc] init];
        photo.url = [NSURL URLWithString:obj];
        photo.sourceImageView = self.photosView.subviews[idx];
        [photos addObject:photo];
    }];
    
    NSInteger index = imgView.tag;
    
    GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photos currentIndex:index];
    browser.showStyle = self.showStyle;
    browser.hideStyle = self.hideStyle;
    browser.loadStyle = self.loadStyle;
    browser.failStyle = self.failStyle;
    if (self.imgLoadStyle == 0) {
        [browser setupWebImageProtocol:[[GKSDWebImageManager alloc] init]];
    }else {
        [browser setupWebImageProtocol:[[GKYYWebImageManager alloc] init]];
    }
    browser.isPopGestureEnabled = YES; // push显示，在第一页时手势返回
    
    [browser showFromVC:self];
    browser.delegate = self;
    self.browser = browser;
}

#pragma mark - GKPhotoBrowserDelegate
- (void)photoBrowser:(GKPhotoBrowser *)browser didChangedIndex:(NSInteger)index {
    
}

- (void)photoBrowser:(GKPhotoBrowser *)browser didSelectAtIndex:(NSInteger)index {
    
}

- (void)photoBrowser:(GKPhotoBrowser *)browser loadImageAtIndex:(NSInteger)index progress:(float)progress isOriginImage:(BOOL)isOriginImage {
    if (progress == 1.0f) {
        [GKMessageTool hideMessage];
    }else {
        [GKMessageTool showMessage:nil];
    }
}

- (void)photoBrowser:(GKPhotoBrowser *)browser loadFailedAtIndex:(NSInteger)index {    
    if (self.customFailView) return;
    self.customFailView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
    [self.customFailView sizeToFit];
    
    UIView *photoView = browser.curPhotoView;
    self.customFailView.center = CGPointMake(photoView.bounds.size.width * 0.5, photoView.bounds.size.height * 0.5);
    [photoView addSubview:self.customFailView];
}

- (void)photoBrowser:(GKPhotoBrowser *)browser panBeginWithIndex:(NSInteger)index {
    
}

- (void)photoBrowser:(GKPhotoBrowser *)browser panEndedWithIndex:(NSInteger)index willDisappear:(BOOL)disappear {
    
}

- (void)photoBrowser:(GKPhotoBrowser *)browser didDisappearAtIndex:(NSInteger)index {
    NSLog(@"browser dismiss");
    [self.customFailView removeFromSuperview];
    self.customFailView = nil;
}

#pragma mark - Lazy
- (UILabel *)showLabel {
    if (!_showLabel) {
        _showLabel = [[UILabel alloc] init];
        _showLabel.font = [UIFont systemFontOfSize:15];
        _showLabel.textColor = UIColor.blackColor;
        _showLabel.text = @"显示方式";
    }
    return _showLabel;
}

- (UISegmentedControl *)showControl {
    if (!_showControl) {
        _showControl = [[UISegmentedControl alloc] initWithItems:@[@"无动画", @"zoom动画", @"push动画"]];
        [_showControl addTarget:self action:@selector(controlAction:) forControlEvents:UIControlEventValueChanged];
        _showControl.selectedSegmentIndex = 0;
    }
    return _showControl;
}

- (UILabel *)hideLabel {
    if (!_hideLabel) {
        _hideLabel = [[UILabel alloc] init];
        _hideLabel.font = [UIFont systemFontOfSize:15];
        _hideLabel.textColor = UIColor.blackColor;
        _hideLabel.text = @"隐藏方式";
    }
    return _hideLabel;
}

- (UISegmentedControl *)hideControl {
    if (!_hideControl) {
        _hideControl = [[UISegmentedControl alloc] initWithItems:@[@"zoom", @"zoomScale", @"zoomSlide"]];
        [_hideControl addTarget:self action:@selector(controlAction:) forControlEvents:UIControlEventValueChanged];
        _hideControl.selectedSegmentIndex = 0;
    }
    return _hideControl;
}

- (UILabel *)loadLabel {
    if (!_loadLabel) {
        _loadLabel = [[UILabel alloc] init];
        _loadLabel.font = [UIFont systemFontOfSize:15];
        _loadLabel.textColor = UIColor.blackColor;
        _loadLabel.text = @"加载方式";
    }
    return _loadLabel;
}

- (UISegmentedControl *)loadControl {
    if (!_loadControl) {
        _loadControl = [[UISegmentedControl alloc] initWithItems:@[@"不明确", @"不明确+阴影", @"明确进度条", @"自定义"]];
        [_loadControl addTarget:self action:@selector(controlAction:) forControlEvents:UIControlEventValueChanged];
        _loadControl.selectedSegmentIndex = 0;
    }
    return _loadControl;
}

- (UILabel *)failLabel {
    if (!_failLabel) {
        _failLabel = [[UILabel alloc] init];
        _failLabel.font = [UIFont systemFontOfSize:15];
        _failLabel.textColor = UIColor.blackColor;
        _failLabel.text = @"失败显示方式";
    }
    return _failLabel;
}

- (UISegmentedControl *)failControl {
    if (!_failControl) {
        _failControl = [[UISegmentedControl alloc] initWithItems:@[@"文字", @"图片", @"文字+图片", @"自定义"]];
        [_failControl addTarget:self action:@selector(controlAction:) forControlEvents:UIControlEventValueChanged];
        _failControl.selectedSegmentIndex = 0;
    }
    return _failControl;
}

- (UILabel *)imgLoadLabel {
    if (!_imgLoadLabel) {
        _imgLoadLabel = [[UILabel alloc] init];
        _imgLoadLabel.font = [UIFont systemFontOfSize:15];
        _imgLoadLabel.textColor = UIColor.blackColor;
        _imgLoadLabel.text = @"图片加载方式";
    }
    return _imgLoadLabel;
}

- (UISegmentedControl *)imgLoadControl {
    if (!_imgLoadControl) {
        _imgLoadControl = [[UISegmentedControl alloc] initWithItems:@[@"SDWebImage", @"YYWebImage"]];
        [_imgLoadControl addTarget:self action:@selector(controlAction:) forControlEvents:UIControlEventValueChanged];
        _imgLoadControl.selectedSegmentIndex = 0;
    }
    return _imgLoadControl;
}

@end
