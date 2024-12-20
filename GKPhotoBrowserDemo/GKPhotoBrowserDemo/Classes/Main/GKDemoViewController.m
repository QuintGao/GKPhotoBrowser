//
//  GKDemoViewController.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2023/3/7.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDemoViewController.h"
#import <GKPhotoBrowser/GKPhotoBrowser.h>
#import <Masonry/Masonry.h>
#import "GKDemoWebViewController.h"
#import "GKDemoPhotoViewController.h"
#import "GKDemoLocalViewController.h"

@interface GKDemoViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

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

// 视频加载方式
@property (nonatomic, assign) GKPhotoBrowserLoadStyle videoLoadStyle;
@property (nonatomic, strong) UILabel *videoLoadLabel;
@property (nonatomic, strong) UISegmentedControl *videoLoadControl;

// 视频加载失败
@property (nonatomic, assign) GKPhotoBrowserFailStyle videoFailStyle;
@property (nonatomic, strong) UILabel *videoFailLabel;
@property (nonatomic, strong) UISegmentedControl *videoFailControl;

// 视频播放类
@property (nonatomic, assign) NSInteger videoPlayStyle;
@property (nonatomic, strong) UILabel *videoPlayLabel;
@property (nonatomic, strong) UISegmentedControl *videoPlayControl;

// livePhoto处理类
@property (nonatomic, assign) NSInteger livePhotoStyle;
@property (nonatomic, strong) UILabel *livePhotoLabel;
@property (nonatomic, strong) UISegmentedControl *livePhotoControl;

@property (nonatomic, strong) UIButton *webBtn;

@property (nonatomic, strong) UIButton *photoBtn;

@property (nonatomic, strong) UIButton *localBtn;

@end

@implementation GKDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    self.showControl.selectedSegmentIndex = 1;
    self.hideControl.selectedSegmentIndex = 1;
    self.showStyle = GKPhotoBrowserShowStyleZoom;
    self.hideStyle = GKPhotoBrowserHideStyleZoom;
}

- (void)initUI {
    self.view.backgroundColor = UIColor.whiteColor;
    self.gk_navTitle = @"GKPhotoBrowser";
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.showLabel];
    [self.scrollView addSubview:self.showControl];
    [self.scrollView addSubview:self.hideLabel];
    [self.scrollView addSubview:self.hideControl];
    [self.scrollView addSubview:self.loadLabel];
    [self.scrollView addSubview:self.loadControl];
    [self.scrollView addSubview:self.failLabel];
    [self.scrollView addSubview:self.failControl];
    [self.scrollView addSubview:self.imgLoadLabel];
    [self.scrollView addSubview:self.imgLoadControl];
    [self.scrollView addSubview:self.videoLoadLabel];
    [self.scrollView addSubview:self.videoLoadControl];
    [self.scrollView addSubview:self.videoFailLabel];
    [self.scrollView addSubview:self.videoFailControl];
    [self.scrollView addSubview:self.videoPlayLabel];
    [self.scrollView addSubview:self.videoPlayControl];
    [self.scrollView addSubview:self.livePhotoLabel];
    [self.scrollView addSubview:self.livePhotoControl];
    
    [self.showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@10);
        make.centerX.equalTo(self.scrollView);
    }];
    
    [self.showControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.showLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.showLabel);
    }];
    
    [self.hideLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.showControl.mas_bottom).offset(10);
        make.centerX.equalTo(self.showLabel);
    }];
    
    [self.hideControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hideLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.showLabel);
    }];
    
    [self.loadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hideControl.mas_bottom).offset(10);
        make.centerX.equalTo(self.showLabel);
    }];
    
    [self.loadControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loadLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.showLabel);
    }];
    
    [self.failLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loadControl.mas_bottom).offset(10);
        make.centerX.equalTo(self.showLabel);
    }];
    
    [self.failControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.failLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.showLabel);
    }];
    
    [self.imgLoadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.failControl.mas_bottom).offset(10);
        make.centerX.equalTo(self.showLabel);
    }];
    
    [self.imgLoadControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgLoadLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.showLabel);
    }];
    
    [self.videoLoadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgLoadControl.mas_bottom).offset(10);
        make.centerX.equalTo(self.showLabel);
    }];
    
    [self.videoLoadControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.videoLoadLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.showLabel);
    }];
    
    [self.videoFailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.videoLoadControl.mas_bottom).offset(10);
        make.centerX.equalTo(self.showLabel);
    }];
    
    [self.videoFailControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.videoFailLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.showLabel);
    }];
    
    [self.videoPlayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.videoFailControl.mas_bottom).offset(10);
        make.centerX.equalTo(self.showLabel);
    }];
    
    [self.videoPlayControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.videoPlayLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.showLabel);
    }];
    
    [self.livePhotoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.videoPlayControl.mas_bottom).offset(10);
        make.centerX.equalTo(self.showLabel);
    }];
    
    [self.livePhotoControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.livePhotoLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.showLabel);
    }];
    
    [self.scrollView addSubview:self.webBtn];
    [self.scrollView addSubview:self.photoBtn];
    [self.scrollView addSubview:self.localBtn];
    
    CGFloat margin = (self.view.frame.size.width - 80 * 3) / 4;
    
    [self.webBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(margin);
        make.top.equalTo(self.livePhotoControl.mas_bottom).offset(50);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
    }];
    
    [self.photoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.showLabel);
        make.top.equalTo(self.livePhotoControl.mas_bottom).offset(50);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
    }];
    
    [self.localBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-margin);
        make.top.equalTo(self.livePhotoControl.mas_bottom).offset(50);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.gk_navigationBar.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
        make.bottom.equalTo(self.photoBtn.mas_bottom).offset(30);
    }];
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
    }else if (control == self.videoLoadControl) {
        if (control.selectedSegmentIndex == 2) {
            self.videoLoadStyle = GKPhotoBrowserLoadStyleCustom;
        }else {
            self.videoLoadStyle = (GKPhotoBrowserLoadStyle)control.selectedSegmentIndex;
        }
    }else if (control == self.videoFailControl) {
        self.videoFailStyle = (GKPhotoBrowserFailStyle)control.selectedSegmentIndex;
    }else if (control == self.videoPlayControl) {
        self.videoPlayStyle = control.selectedSegmentIndex;
    }else if (control == self.livePhotoControl) {
        self.livePhotoStyle = control.selectedSegmentIndex;
    }
}

- (void)webBtnClick:(id)sender {
    GKDemoWebViewController *webVC = [[GKDemoWebViewController alloc] init];
    webVC.showStyle = self.showStyle;
    webVC.hideStyle = self.hideStyle;
    webVC.loadStyle = self.loadStyle;
    webVC.failStyle = self.failStyle;
    webVC.imageLoadStyle = self.imgLoadStyle;
    webVC.videoLoadStyle = self.videoLoadStyle;
    webVC.videoFailStyle = self.videoFailStyle;
    webVC.videoPlayStyle = self.videoPlayStyle;
    webVC.livePhotoStyle = self.livePhotoStyle;
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)photoBtnClick:(id)sender {
    GKDemoPhotoViewController *photoVC = [[GKDemoPhotoViewController alloc] init];
    photoVC.showStyle = self.showStyle;
    photoVC.hideStyle = self.hideStyle;
    photoVC.loadStyle = self.loadStyle;
    photoVC.failStyle = self.failStyle;
    photoVC.imageLoadStyle = self.imgLoadStyle;
    photoVC.videoLoadStyle = self.videoLoadStyle;
    photoVC.videoFailStyle = self.videoFailStyle;
    photoVC.videoPlayStyle = self.videoPlayStyle;
    photoVC.livePhotoStyle = self.livePhotoStyle;
    [self.navigationController pushViewController:photoVC animated:YES];
}

- (void)localBtnClick:(id)sender {
    GKDemoLocalViewController *photoVC = [[GKDemoLocalViewController alloc] init];
    photoVC.showStyle = self.showStyle;
    photoVC.hideStyle = self.hideStyle;
    photoVC.loadStyle = self.loadStyle;
    photoVC.failStyle = self.failStyle;
    photoVC.imageLoadStyle = self.imgLoadStyle;
    photoVC.videoLoadStyle = self.videoLoadStyle;
    photoVC.videoFailStyle = self.videoFailStyle;
    photoVC.videoPlayStyle = self.videoPlayStyle;
    photoVC.livePhotoStyle = self.livePhotoStyle;
    [self.navigationController pushViewController:photoVC animated:YES];
}

#pragma mark - Lazy
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}

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
        _showControl = [[UISegmentedControl alloc] initWithItems:@[@"无动画", @"zoom动画", @"push动画", @"pushZoom"]];
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
        _hideControl = [[UISegmentedControl alloc] initWithItems:@[@"无动画", @"zoom", @"zoomScale", @"zoomSlide"]];
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
        _loadControl = [[UISegmentedControl alloc] initWithItems:@[@"不明确", @"不明确阴影", @"圆形进度", @"扇形进度", @"自定义"]];
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
        _imgLoadControl = [[UISegmentedControl alloc] initWithItems:@[@"SDWebImage", @"YYWebImage", @"Kingfisher"]];
        [_imgLoadControl addTarget:self action:@selector(controlAction:) forControlEvents:UIControlEventValueChanged];
        _imgLoadControl.selectedSegmentIndex = 0;
    }
    return _imgLoadControl;
}

- (UILabel *)videoLoadLabel {
    if (!_videoLoadLabel) {
        _videoLoadLabel = [[UILabel alloc] init];
        _videoLoadLabel.font = [UIFont systemFontOfSize:15];
        _videoLoadLabel.textColor = UIColor.blackColor;
        _videoLoadLabel.text = @"视频加载方式";
    }
    return _videoLoadLabel;
}

- (UISegmentedControl *)videoLoadControl {
    if (!_videoLoadControl) {
        _videoLoadControl = [[UISegmentedControl alloc] initWithItems:@[@"不明确", @"不明确+阴影", @"自定义"]];
        [_videoLoadControl addTarget:self action:@selector(controlAction:) forControlEvents:UIControlEventValueChanged];
        _videoLoadControl.selectedSegmentIndex = 0;
    }
    return _videoLoadControl;
}

- (UILabel *)videoFailLabel {
    if (!_videoFailLabel) {
        _videoFailLabel = [[UILabel alloc] init];
        _videoFailLabel.font = [UIFont systemFontOfSize:15];
        _videoFailLabel.textColor = UIColor.blackColor;
        _videoFailLabel.text = @"视频加载失败显示";
    }
    return _videoFailLabel;
}

- (UISegmentedControl *)videoFailControl {
    if (!_videoFailControl) {
        _videoFailControl = [[UISegmentedControl alloc] initWithItems:@[@"文字", @"图片", @"文字+图片", @"自定义"]];
        [_videoFailControl addTarget:self action:@selector(controlAction:) forControlEvents:UIControlEventValueChanged];
        _videoFailControl.selectedSegmentIndex = 0;
    }
    return _videoFailControl;
}

- (UILabel *)videoPlayLabel {
    if (!_videoPlayLabel) {
        _videoPlayLabel = [[UILabel alloc] init];
        _videoPlayLabel.font = [UIFont systemFontOfSize:15];
        _videoPlayLabel.textColor = UIColor.blackColor;
        _videoPlayLabel.text = @"视频播放类";
    }
    return _videoPlayLabel;
}

- (UISegmentedControl *)videoPlayControl {
    if (!_videoPlayControl) {
        _videoPlayControl = [[UISegmentedControl alloc] initWithItems:@[@"AVPlayer", @"ZFPlayer", @"IJKPlayer"]];
        [_videoPlayControl addTarget:self action:@selector(controlAction:) forControlEvents:UIControlEventValueChanged];
        _videoPlayControl.selectedSegmentIndex = 0;
    }
    return _videoPlayControl;
}

- (UILabel *)livePhotoLabel {
    if (!_livePhotoLabel) {
        _livePhotoLabel = [[UILabel alloc] init];
        _livePhotoLabel.font = [UIFont systemFontOfSize:15];
        _livePhotoLabel.textColor = UIColor.blackColor;
        _livePhotoLabel.text = @"livePhoto处理类";
    }
    return _livePhotoLabel;
}

- (UISegmentedControl *)livePhotoControl {
    if (!_livePhotoControl) {
        _livePhotoControl = [[UISegmentedControl alloc] initWithItems:@[@"AFNetworking", @"Alamofire"]];
        [_livePhotoControl addTarget:self action:@selector(controlAction:) forControlEvents:UIControlEventValueChanged];
        _livePhotoControl.selectedSegmentIndex = 0;
    }
    return _livePhotoControl;
}

- (UIButton *)webBtn {
    if (!_webBtn) {
        _webBtn = [[UIButton alloc] init];
        [_webBtn setTitle:@"网络图片" forState:UIControlStateNormal];
        [_webBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _webBtn.backgroundColor = UIColor.blackColor;
        _webBtn.layer.cornerRadius = 5;
        _webBtn.layer.masksToBounds = YES;
        _webBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_webBtn addTarget:self action:@selector(webBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _webBtn;
}

- (UIButton *)photoBtn {
    if (!_photoBtn) {
        _photoBtn = [[UIButton alloc] init];
        [_photoBtn setTitle:@"相册图片" forState:UIControlStateNormal];
        [_photoBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _photoBtn.backgroundColor = UIColor.blackColor;
        _photoBtn.layer.cornerRadius = 5;
        _photoBtn.layer.masksToBounds = YES;
        _photoBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_photoBtn addTarget:self action:@selector(photoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoBtn;
}

- (UIButton *)localBtn {
    if (!_localBtn) {
        _localBtn = [[UIButton alloc] init];
        [_localBtn setTitle:@"本地图片" forState:UIControlStateNormal];
        [_localBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _localBtn.backgroundColor = UIColor.blackColor;
        _localBtn.layer.cornerRadius = 5;
        _localBtn.layer.masksToBounds = YES;
        _localBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_localBtn addTarget:self action:@selector(localBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _localBtn;
}

@end
