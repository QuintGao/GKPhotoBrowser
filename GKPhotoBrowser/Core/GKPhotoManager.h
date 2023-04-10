//
//  GKPhotoManager.h
//  GKPhotoBrowserDemo
//
//  Created by gaokun on 2020/6/16.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "GKPhotoBrowserConfigure.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKPhoto : NSObject

/** 图片地址 */
@property (nonatomic, strong) NSURL              *url;

/** 原图地址 */
@property (nonatomic, strong) NSURL              *originUrl;

/** 来源imageView */
@property (nonatomic, strong) UIImageView        *sourceImageView;

/** 来源frame */
@property (nonatomic, assign) CGRect             sourceFrame;

/** 图片(静态) */
@property (nonatomic, strong, nullable) UIImage  *image;

/** 相册图片资源 */
@property (nonatomic, strong, nullable) PHAsset  *imageAsset;

/** 占位图 */
@property (nonatomic, strong, nullable) UIImage  *placeholderImage;

#pragma mark - 以下属性播放视频时使用
@property (nonatomic, strong) NSURL              *videoUrl;
@property (nonatomic, strong, nullable) PHAsset  *videoAsset;
@property (nonatomic, assign) CGSize             videoSize;
@property (nonatomic, assign, readonly) BOOL     isVideo;
 

/************************内部使用，无需关心 ********************/
/** 图片是否加载完成 */
@property (nonatomic, assign) BOOL               finished;
@property (nonatomic, assign) BOOL               originFinished;
/** 图片是否加载失败 */
@property (nonatomic, assign) BOOL               failed;

/** 记录photoView是否缩放 */
@property (nonatomic, assign) BOOL               isZooming;

/** 记录photoView缩放时的rect */
@property (nonatomic, assign) CGRect             zoomRect;

@property (nonatomic, assign) CGFloat            zoomScale;

@property (nonatomic, assign) CGPoint            zoomOffset;

/** 记录每个GKPhotoView的滑动位置 */
@property (nonatomic, assign) CGPoint            offset;

/** 视频是否准备过 */
@property (nonatomic, assign) BOOL               isVideoPrepared;

- (void)getImage:(nullable void(^)(NSData *_Nullable data, UIImage *_Nullable image))completion;

- (void)getVideo:(nullable void(^)(NSURL *_Nullable url))completion;

@end

@interface GKPhotoManager : NSObject

/// 加载相册图片资源
/// @param imageAsset PHAsset对象
/// @param completion 完成回调
+ (PHImageRequestID)loadImageDataWithImageAsset:(PHAsset *)imageAsset completion:(nonnull void(^)(NSData *_Nullable data))completion;

/// 根据宽度加载相册资源图片
/// @param asset PHAsset对象
/// @param photoWidth 宽度
/// @param completion 完成回调
+ (PHImageRequestID)loadImageWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(nonnull void(^)(UIImage *_Nullable image))completion;

/// 加载相册视频资源
/// @param asset PHAsset对象
/// @param completion 完成回调
+ (PHImageRequestID)loadVideoWithAsset:(PHAsset *)asset completion:(nonnull void(^)(NSURL *url))completion;

@end

NS_ASSUME_NONNULL_END
