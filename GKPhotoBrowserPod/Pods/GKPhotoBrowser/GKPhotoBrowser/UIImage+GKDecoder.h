//
//  UIImage+GKDecoder.h
//  GKPhotoBrowserDemo
//
//  Created by gaokun on 2018/8/6.
//  Copyright © 2018年 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (GKDecoder)

// 存储图片
@property (nonatomic, setter=gk_setImageBuffer:,getter=gk_imageBuffer) NSMutableDictionary *buffer;

// 是否需要不停刷新buffer
@property (nonatomic, setter=gk_setNeedUpdateBuffer:,getter=gk_needUpdateBuffer) NSNumber *needUpdateBuffer;

// 当前展示到哪一张图片了
@property (nonatomic, setter=gk_setHandleIndex:,getter=gk_handleIndex) NSNumber *handleIndex;

// 最大的缓存图片数
@property (nonatomic, setter=gk_setMaxBufferCount:,getter=gk_maxBufferCount) NSNumber *maxBufferCount;

// 当前这帧图像是否展示
@property (nonatomic, setter=gk_setBufferMiss:,getter=gk_bufferMiss) NSNumber *bufferMiss;

// 增加的buffer数目
@property (nonatomic, setter=gk_setIncrBufferCount:,getter=gk_incrBufferCount) NSNumber *incrBufferCount;

// 该gif 一共多少帧
@property (nonatomic, setter=gk_setTotalFrameCount:,getter=gk_totalFrameCount) NSNumber *totalFrameCount;

+ (UIImage *)sdOverdue_animatedGIFWithData:(NSData *)data;

- (void)gk_animatedGIFData:(NSData *)data;

- (NSTimeInterval)animatedImageDurationAtIndex:(int)index;

- (UIImage *)animatedImageFrameAtIndex:(int)index;

- (void)imageViewShowFinished;

@end
