//
//  GKDemoWebViewController.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2024/5/24.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import "GKDemoWebViewController.h"
#import "GKPhotosView.h"
#import "GKTimeLineModel.h"
#import <GKMessageTool/GKMessageTool.h>
#import <CommonCrypto/CommonDigest.h>
#import "CustomWebImageManager.h"

@interface GKDemoWebViewController ()<GKPhotosViewDelegate, GKPhotoBrowserDelegate>

@property (nonatomic, strong) GKPhotosView *photosView;
@property (nonatomic, strong) NSArray *photos;

@property (nonatomic, strong) UIImageView *customFailView;

@end

@implementation GKDemoWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.gk_navTitle = @"网络图片";
    
    self.photosView =  [GKPhotosView photosViewWithWidth:self.view.bounds.size.width - 20 andMargin:10];
    self.photosView.delegate = self;
    [self.view addSubview:self.photosView];
    
    [self loadData];
}

- (void)loadData {
    GKTimeLineImage *image1 = [GKTimeLineImage new];
    image1.url = @"https://img2.baidu.com/it/u=3316344338,3288169191&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500";
    
    
    GKTimeLineImage *image2 = [GKTimeLineImage new];
    image2.url = @"https://f7.baidu.com/it/u=271976840,932511730&fm=222&app=106&f=JPEG@f_auto?x-bce-process=image/quality,q_80/resize,m_fill,w_660,h_370";
    image2.video_url = @"https://vd4.bdstatic.com/mda-pcekgt2uzhhuegqt/default/h264/1678890479874385171/mda-pcekgt2uzhhuegqt.mp4?abtest=peav_l52&appver=&auth_key=1680752423-0-0-4bd1b130e6dc6318f95ac68536d24da8&bcevod_channel=searchbox_feed&cd=0&cr=0&did=cfcd208495d565ef66e7dff9f98764da&logid=622881057&model=&osver=&pd=1&pt=4&sl=341&sle=1&split=403358&vid=10495600563257373332&vt=1";
    
    
    GKTimeLineImage *image3 = [GKTimeLineImage new];
    image3.url = @"https://img.zdwx.net/group1/M00/05/71/wKgCFF7Gg4GAVIB8ABNYPLSU3f0067.jpg";
    
    
    GKTimeLineImage *image4 = [GKTimeLineImage new];
    image4.url = @"https://img1.baidu.com/it/u=2226546102,192117690&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=889";
    image4.video_url = @"https://vd4.bdstatic.com/mdadd-pcekgt2uzhhuegqt/default/h264/1678890479874385171/mda-pcekgt2uzhhuegqt.mp4?abtest=peav_l52&appver=&auth_key=1680752423-0-0-4bd1b130e6dc6318f95ac68536d24da8&bcevod_channel=searchbox_feed&cd=0&cr=0&did=cfcd208495d565ef66e7dff9f98764da&logid=622881057&model=&osver=&pd=1&pt=4&sl=341&sle=1&split=403358&vid=10495600563257373332&vt=1";
    
    
    GKTimeLineImage *image5 = [GKTimeLineImage new];
    image5.url = @"https://hbimg.huaban.com/553632d876c342a9ffb007999b67432b69bebcf8684b4";
    
    
    GKTimeLineImage *image6 = [GKTimeLineImage new];
    image6.url = @"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fitem%2F201703%2F23%2F20170323121431_QzNxW.thumb.400_0.gif&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1680760815&t=a95782bbf075125d6ccfbb401a831364";
    
    GKTimeLineImage *image7 = [GKTimeLineImage new];
    image7.url = [[NSBundle mainBundle] pathForResource:@"IMG_E8375" ofType:@"heic"];
    image7.video_url = [[NSBundle mainBundle] pathForResource:@"IMG_E8375" ofType:@"mov"];
    image7.isLivePhoto = YES;
    
    GKTimeLineImage *image8 = [GKTimeLineImage new];
    image8.url = @"https://ak.picdn.net/shutterstock/videos/1061172265/thumb/1.jpg";
    image8.video_url = @"https://ak.picdn.net/shutterstock/videos/1061172265/preview/stock-footage-caribbean-beach-background-sunny-tropical-beach-hot-afternoon-on-an-empty-beach-the-best-beaches.mp4";
    image8.isLivePhoto = YES;
    
    NSArray *images = @[image1, image2, image3, image4, image5, image6, image7, image8];
    
    self.photos = images;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat height = [GKPhotosView sizeWithCount:images.count width:self.view.bounds.size.width - 20 andMargin:10].height;
        CGFloat y = CGRectGetMaxY(self.gk_navigationBar.frame) + 20;
        self.photosView.frame = CGRectMake(10, y, self.view.bounds.size.width - 20, height);
        
        self.photosView.images = images;
    });
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.photosView updateWidth:self.view.bounds.size.width - 20];
    CGFloat height = [GKPhotosView sizeWithCount:self.photos.count width:self.view.bounds.size.width - 20 andMargin:10].height;
    CGFloat y = CGRectGetMaxY(self.gk_navigationBar.frame) + 20;
    self.photosView.frame = CGRectMake(10, y, self.view.bounds.size.width - 20, height);
}

#pragma mark - GKPhotosViewDelegate
- (void)photoTapped:(UIImageView *)imgView {
    
    NSMutableArray *photos = [NSMutableArray array];
    
    [self.photos enumerateObjectsUsingBlock:^(GKTimeLineImage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GKPhoto *photo = [[GKPhoto alloc] init];
        if (obj.isLivePhoto) {
            photo.isLivePhoto = YES;
            if ([obj.url containsString:@"http"]) {
                photo.url = [NSURL URLWithString:obj.url];
            }else {
                photo.url = [NSURL fileURLWithPath:obj.url];
            }
            if ([obj.video_url containsString:@"http"]) {
                photo.videoUrl = [NSURL URLWithString:obj.video_url];
            }else {
                photo.videoUrl = [NSURL fileURLWithPath:obj.video_url];
            }
        }else if (obj.isVideo) {
            photo.url = [NSURL URLWithString:obj.url];
            photo.videoUrl = [NSURL URLWithString:obj.video_url];
        }else {
            photo.url = [NSURL URLWithString:obj.url];
        }
        photo.sourceImageView = self.photosView.subviews[idx];
        photo.extraInfo = GKPhotoDiskCacheFileNameForKey(obj.url);
        [photos addObject:photo];
    }];
    
    NSInteger index = imgView.tag;
    
    Class cls = NSClassFromString(@"GKIJKPlayerManager");
    if (self.videoPlayStyle == 2 && !cls) {
        [GKMessageTool showText:@"请先 pod 'GKPhotoBrowser_Static/IJKPlayer'"];
        return;
    }
    
    GKPhotoBrowserConfigure *configure = GKPhotoBrowserConfigure.defaultConfig;
    configure.showStyle = self.showStyle;
    configure.hideStyle = self.hideStyle;
    configure.loadStyle = self.loadStyle;
    configure.failStyle = self.failStyle;
    
    if (self.imageLoadStyle == 0) {
        [configure setupWebImageProtocol:[[GKSDWebImageManager alloc] init]];
    }else if (self.imageLoadStyle == 1) {
        [configure setupWebImageProtocol:[[GKYYWebImageManager alloc] init]];
    }else if (self.imageLoadStyle == 2) {
        [configure setupWebImageProtocol:[[GKKFWebImageManager alloc] init]];
    }else if (self.imageLoadStyle == 3) {
        [configure setupWebImageProtocol:[[CustomWebImageManager alloc] init]];
    }
    
    configure.videoLoadStyle = self.videoLoadStyle;
    configure.videoFailStyle = self.videoFailStyle;
    
    if (self.videoPlayStyle == 0) {
        [configure setupVideoPlayerProtocol:[[GKAVPlayerManager alloc] init]];
    }else if (self.videoPlayStyle == 1) {
        [configure setupVideoPlayerProtocol:[[GKZFPlayerManager alloc] init]];
    }else {
        [configure setupVideoPlayerProtocol:[[cls alloc] init]];
    }
    
    configure.isShowLivePhotoMark = YES;
    if (self.livePhotoStyle == 0) {
        [configure setupLivePhotoProtocol:GKAFLivePhotoManager.new];
    }else {
        [configure setupLivePhotoProtocol:GKAlamofireLivePhotoManager.new];
    }
    configure.isPopGestureEnabled = YES; // push显示，在第一页时手势返回
    
    GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photos currentIndex:index];
    browser.configure = configure;
    browser.delegate = self;
    [browser showFromVC:self];
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

- (void)photoBrowser:(GKPhotoBrowser *)browser loadFailedAtIndex:(NSInteger)index error:(nonnull NSError *)error {
    if (browser.curPhoto.isVideo) return;
    if (browser.configure.failStyle != GKPhotoBrowserFailStyleCustom) return;
    
    if (self.customFailView) return;
    self.customFailView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
    [self.customFailView sizeToFit];
    
    UIView *photoView = browser.curPhotoView;
    self.customFailView.center = CGPointMake(photoView.bounds.size.width * 0.5, photoView.bounds.size.height * 0.5);
    [photoView addSubview:self.customFailView];
}

- (void)photoBrowser:(GKPhotoBrowser *)browser willLayoutSubViews:(NSInteger)index {
    if (self.customFailView) {
        UIView *photoView = browser.curPhotoView;
        self.customFailView.center = CGPointMake(photoView.bounds.size.width * 0.5, photoView.bounds.size.height * 0.5);
    }
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

- (void)photoBrowser:(GKPhotoBrowser *)browser videoLoadStart:(BOOL)isStart success:(BOOL)success {
    if (isStart) {
        [GKMessageTool showMessage:nil];
    }else {
        if (success) {
            [GKMessageTool hideMessage];
        }else {
            [GKMessageTool showText:@"播放失败"];
        }
    }
}

@end
