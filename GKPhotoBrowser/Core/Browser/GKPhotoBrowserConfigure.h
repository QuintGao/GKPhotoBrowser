//
//  GKPhotoBrowserConfigure.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2020/10/19.
//  Copyright © 2020年 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+GKPhotoBrowser.h"
#import "UIDevice+GKPhotoBrowser.h"
#import "UIImage+GKPhotoBrowser.h"
#import "GKWebImageProtocol.h"
#import "GKVideoPlayerProtocol.h"
#import "GKLivePhotoProtocol.h"
#import "GKProgressViewProtocol.h"

#if __has_include(<GKPhotoBrowser/GKSDWebImageManager.h>)
#import <GKPhotoBrowser/GKSDWebImageManager.h>
#endif

#if __has_include(<GKPhotoBrowser/GKYYWebImageManager.h>)
#import <GKPhotoBrowser/GKYYWebImageManager.h>
#endif

#if __has_include(<GKPhotoBrowser/GKAVPlayerManager.h>)
#import <GKPhotoBrowser/GKAVPlayerManager.h>
#endif

#if __has_include(<GKPhotoBrowser/GKZFPlayerManager.h>)
#import <GKPhotoBrowser/GKZFPlayerManager.h>
#endif

#if __has_include(<GKPhotoBrowser/GKIJKPlayerManager.h>)
#import <GKPhotoBrowser/GKIJKPlayerManager.h>
#endif

#if __has_include(<GKPhotoBrowser/GKProgressView.h>)
#import <GKPhotoBrowser/GKProgressView.h>
#endif

#if __has_include(<GKPhotoBrowser/GKAFLivePhotoManager.h>)
#import <GKPhotoBrowser/GKAFLivePhotoManager.h>
#endif

// 判断iPhone X
#define KIsiPhoneX          [UIDevice gk_isNotchedScreen]
// 底部安全区域高度
#define kSafeTopSpace       [UIDevice gk_safeAreaTop]
#define kSafeBottomSpace    [UIDevice gk_safeAreaBottom]

// 加载本地图片
#define GKPhotoBrowserImage(name)  [UIImage gkbrowser_imageNamed:name]

// 图片浏览器的显示方式
typedef NS_ENUM(NSUInteger, GKPhotoBrowserShowStyle) {
    GKPhotoBrowserShowStyleNone,       // 直接显示，默认方式
    GKPhotoBrowserShowStyleZoom,       // 缩放显示，动画效果
    GKPhotoBrowserShowStylePush        // push方式展示
};

// 图片浏览器的隐藏方式
typedef NS_ENUM(NSUInteger, GKPhotoBrowserHideStyle) {
    GKPhotoBrowserHideStyleNone,           // 无动画
    GKPhotoBrowserHideStyleZoom,           // 点击缩放消失
    GKPhotoBrowserHideStyleZoomScale,      // 点击缩放消失、滑动缩小后消失
    GKPhotoBrowserHideStyleZoomSlide       // 点击缩放消失、滑动平移后消失
};

// 图片浏览器的加载方式
typedef NS_ENUM(NSUInteger, GKPhotoBrowserLoadStyle) {
    GKPhotoBrowserLoadStyleIndeterminate,        // 不明确的加载方式
    GKPhotoBrowserLoadStyleIndeterminateMask,    // 不明确的加载方式带阴影
    GKPhotoBrowserLoadStyleDeterminate,          // 明确的加载方式带进度条
    GKPhotoBrowserLoadStyleDeterminateSector,    // 明确的加载方式扇形进度
    GKPhotoBrowserLoadStyleCustom                // 自定义加载方式
};

// 图片加载失败的显示方式
typedef NS_ENUM(NSUInteger, GKPhotoBrowserFailStyle) {
    GKPhotoBrowserFailStyleOnlyText,           // 显示文字
    GKPhotoBrowserFailStyleOnlyImage,          // 显示图片
    GKPhotoBrowserFailStyleImageAndText,       // 显示图片+文字
    GKPhotoBrowserFailStyleCustom              // 自定义（如：显示HUD）
};

@interface GKPhotoBrowserConfigure : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)defaultConfig NS_SWIFT_NAME(default());

/// 显示方式，默认GKPhotoBrowserShowStyleZoom
@property (nonatomic, assign) GKPhotoBrowserShowStyle showStyle;

/// 隐藏方式，默认GKPhotoBrowserHideStyleZoom
@property (nonatomic, assign) GKPhotoBrowserHideStyle hideStyle;

/// 图片加载方式，默认GKPhotoBrowserLoadStyleIndeterminate
@property (nonatomic, assign) GKPhotoBrowserLoadStyle loadStyle;

/// 原图加载方式，默认GKPhotoBrowserLoadStyleIndeterminate
@property (nonatomic, assign) GKPhotoBrowserLoadStyle originLoadStyle;

/// 图片加载失败显示方式，默认GKPhotoBrowserFailStyleOnlyText
@property (nonatomic, assign) GKPhotoBrowserFailStyle failStyle;

/// 是否跟随系统旋转，默认是NO，如果设置为YES，isScreenRotateDisabled属性将失效
@property (nonatomic, assign) BOOL isFollowSystemRotation;

/// 是否禁止屏幕旋转监测
@property (nonatomic, assign) BOOL isScreenRotateDisabled;

/// 是否禁用默认单击事件
@property (nonatomic, assign) BOOL isSingleTapDisabled;

/// 是否禁用双击事件，默认NO
@property (nonatomic, assign) BOOL isDoubleTapDisabled;

/// 是否禁用双击放大缩小
@property (nonatomic, assign) BOOL isDoubleTapZoomDisabled;

/// 滑动消失时是否隐藏原来的视图：默认YES
@property (nonatomic, assign) BOOL isHideSourceView;

/// 滑动切换图片时，是否恢复上（下）一张图片的缩放程度，默认是NO
/// 如果滑动超过一张，则恢复原状
@property (nonatomic, assign) BOOL isResumePhotoZoom;

/// 横屏时是否充满屏幕宽度，默认YES，为NO时图片自动填充屏幕
@property (nonatomic, assign) BOOL isFullWidthForLandScape;

/// 是否适配安全区域，默认NO，为YES时图片会自动适配iPhone X的安全区域
@property (nonatomic, assign) BOOL isAdaptiveSafeArea;

/// 图片最大放大倍数，默认2.0
@property (nonatomic, assign) CGFloat maxZoomScale;

/// 双击放大倍数，默认maxZoomScale，不能超过maxZoomScale
@property (nonatomic, assign) CGFloat doubleZoomScale;

/// 图片间距，默认10
@property (nonatomic, assign) CGFloat photoViewPadding;

/// 动画时间，默认0.3
@property (nonatomic, assign) NSTimeInterval animDuration;

/// 浏览器背景（默认黑色）
@property (nonatomic, strong) UIColor *bgColor;

/// 是否隐藏countLabel，默认NO
@property (nonatomic, assign) BOOL hidesCountLabel;

/// 是否隐藏pageControl，默认NO
@property (nonatomic, assign) BOOL hidesPageControl;

/// 是否隐藏saveBtn，默认YES
@property (nonatomic, assign) BOOL hidesSavedBtn;

#pragma mark - GKPhotoBrowserShowStylePush
/// 是否添加导航控制器，默认NO，添加后会默认隐藏导航栏
/// showStyle = GKPhotoBrowserShowStylePush时无效
@property (nonatomic, assign) BOOL isNeedNavigationController;

/// 是否启用滑动返回手势处理（当showStyle为GKPhotoBrowserShowStylePush时有效）
@property (nonatomic, assign) BOOL isPopGestureEnabled;

#pragma mark - 图片相关
/// 图片加载类
@property (nonatomic, strong, readonly) id<GKWebImageProtocol> imager;
/// 加载失败时显示的文字或图片
@property (nonatomic, copy) NSString    *failureText;
@property (nonatomic, strong) UIImage   *failureImage;

/// 浏览器消失时是否清除缓存，默认NO
/// 如果设置为YES，则结束显示时会调用GKWebImageProtocol协议的clearMemory方法
@property (nonatomic, assign) BOOL isClearMemoryWhenDisappear;

/// 视图重用时是否清除对应url的缓存，默认NO
/// 如果设置为YES，则视图放入重用池时会调用GKWebImageProtocol协议的clearMemoryForURL:方法
@property (nonatomic, assign) BOOL isClearMemoryWhenViewReuse;

#pragma mark - 视频相关
/// 视频播放处理
@property (nonatomic, strong, readonly) id<GKVideoPlayerProtocol> player;
/// 视频加载方式，默认GKPhotoBrowserLoadStyleIndeterminate
@property (nonatomic, assign) GKPhotoBrowserLoadStyle videoLoadStyle;
/// 视频播放失败显示方式，默认GKPhotoBrowserFailStyleOnlyText
@property (nonatomic, assign) GKPhotoBrowserFailStyle videoFailStyle;
/// 视频暂停或停止时是否显示播放图标，默认YES
@property (nonatomic, assign) BOOL isShowPlayImage;
/// 视频暂停或停止时显示的播放图
@property (nonatomic, strong) UIImage *videoPlayImage;
/// 视频是否静音播放，默认NO
@property (nonatomic, assign) BOOL isVideoMutedPlay;
/// 视频播放结束后是否自动重播，默认YES
@property (nonatomic, assign) BOOL isVideoReplay;
/// 拖拽消失时是否暂停播放，默认YES
@property (nonatomic, assign) BOOL isVideoPausedWhenDragged;
/// 左右滑动开始时是否暂停播放视频，默认NO
@property (nonatomic, assign) BOOL isVideoPausedWhenScrollBegan;

/// 视频播放失败显示的文字或图片
@property (nonatomic, copy) NSString *videoFailureText;
@property (nonatomic, strong) UIImage *videoFailureImage;

#pragma mark - 视频进度相关
/// 进度处理
@property (nonatomic, strong, readonly) id<GKProgressViewProtocol> progress;
/// 是否隐藏视频进度视图，默认NO，内容为视频时有效
@property (nonatomic, assign) BOOL isHideProgressView;

#pragma mark - livePhoto相关
/// livePhoto处理
@property (nonatomic, strong, readonly) id<GKLivePhotoProtocol> livePhoto;
/// livePhoto加载方式，默认GKPhotoBrowserLoadStyleDeterminateSector
@property (nonatomic, assign) GKPhotoBrowserLoadStyle liveLoadStyle;
/// 拖拽消失时是否暂停播放livePhoto，默认YES
@property (nonatomic, assign) BOOL isLivePhotoPausedWhenDragged;
/// 左右滑动开始时是否暂停播放livePhoto，默认NO
@property (nonatomic, assign) BOOL isLivePhotoPausedWhenScrollBegan;
/// livePhoto是否静音播放，默认NO
@property (nonatomic, assign) BOOL isLivePhotoMutedPlay;
/// 是否显示livePhoto标识，默认NO
@property (nonatomic, assign) BOOL isShowLivePhotoMark;
/// livePhoto是否支持长按播放，默认YES
@property (nonatomic, assign) BOOL isLivePhotoLongPressPlay;
/// 是否清理livePhoto缓存，默认YES
@property (nonatomic, assign) BOOL isClearMemoryForLivePhoto;
/// 相册livePhoto目标尺寸，默认屏幕尺寸的2倍
@property (nonatomic, assign) CGSize liveTargetSize;

/// 自定义图片请求类
/// @param protocol 需实现GKWebImageProtocol协议
- (void)setupWebImageProtocol:(id<GKWebImageProtocol>)protocol;

/// 自定义视频播放处理类，需要视频播放时必须添加
/// @param protocol 需实现GKVideoPlayerProtocol协议
- (void)setupVideoPlayerProtocol:(id<GKVideoPlayerProtocol>)protocol;

/// 自定义视频播放进度条
/// @param protocol 需实现GKProgressViewProtocol协议
- (void)setupVideoProgressProtocol:(id<GKProgressViewProtocol>)protocol;

/// 自定义livePhoto加载处理类
/// @param protocol 需实现GKLivePhotoProtocol协议
- (void)setupLivePhotoProtocol:(id<GKLivePhotoProtocol>)protocol;

/// 隐藏
- (void)didDisappear;

@end
