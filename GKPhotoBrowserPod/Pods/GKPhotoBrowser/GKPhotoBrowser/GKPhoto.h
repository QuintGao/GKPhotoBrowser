//
//  GKPhoto.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/20.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKWebImageProtocol.h"
#import "GKPhotoBrowserConfigure.h"

@interface GKPhoto : NSObject

/** 图片地址 */
@property (nonatomic, strong) NSURL         *url;

/** 原图地址 */
@property (nonatomic, strong) NSURL         *originUrl;

/** 来源imageView */
@property (nonatomic, strong) UIImageView   *sourceImageView;

/** 来源frame */
@property (nonatomic, assign) CGRect        sourceFrame;

/** 图片(静态) */
@property (nonatomic, strong) UIImage       *image;

/** gif图片 */
@property (nonatomic, strong) UIImage       *gifImage;
@property (nonatomic, strong) NSData        *gifData;
@property (nonatomic, assign) BOOL          isGif;

// imageView对象
@property (nonatomic, strong) UIImageView   *imageView;

/** 占位图 */
@property (nonatomic, strong) UIImage       *placeholderImage;

/** 图片是否加载完成 */
@property (nonatomic, assign) BOOL          finished;
@property (nonatomic, assign) BOOL          originFinished;
/** 图片是否加载失败 */
@property (nonatomic, assign) BOOL          failed;

/** 记录photoView是否缩放 */
@property (nonatomic, assign) BOOL          isZooming;

/** 记录photoView缩放时的rect */
@property (nonatomic, assign) CGRect        zoomRect;

/** 记录每个GKPhotoView的滑动位置 */
@property (nonatomic, assign) CGPoint       offset;

/**
 开始gif动画
 */
- (void)startAnimation;

/**
 停止gif动画
 */
- (void)stopAnimation;

@end

@interface GKPhotoDecoder : NSOperation

@property (nonatomic, assign) NSUInteger            nextIndex;
@property (nonatomic, strong) UIImage               *curImage;
@property (nonatomic, weak) dispatch_semaphore_t    lock;

@end
