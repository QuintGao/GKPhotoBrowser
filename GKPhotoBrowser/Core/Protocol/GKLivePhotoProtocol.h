//
//  GKLivePhotoProtocol.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2024/6/20.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

@class GKPhoto;
@class GKPhotoBrowser;

typedef NS_ENUM(NSUInteger, GKLivePlayStatus) {
    GKLivePlayStatusBegin,
    GKLivePlayStatusEnded
};

@protocol GKLivePhotoProtocol <NSObject>

@property (nonatomic, weak, nullable) GKPhotoBrowser *browser;

@property (nonatomic, strong, nullable) PHLivePhotoView *livePhotoView;

@property (nonatomic, strong, nullable) GKPhoto *photo;

@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, copy, nullable) void(^liveStatusChanged)(id<GKLivePhotoProtocol> _Nonnull mgr, GKLivePlayStatus status);

// 加载livePhoto
- (void)loadLivePhotoWithPhoto:(GKPhoto *_Nonnull)photo targetSize:(CGSize)targetSize progressBlock:(void(^_Nullable)(float progress))progressBlock completion:(void(^_Nullable)(BOOL success))completion;

// 播放livePhoto
- (void)gk_play;

// 停止livePhoto
- (void)gk_stop;

// 更新布局
- (void)gk_updateFrame:(CGRect)frame;

// 设置静音
- (void)gk_setMute:(BOOL)mute;

@optional
// 清除下载的文件
- (void)gk_clear;

@end
