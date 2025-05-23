//
//  GKWebImageProtocol.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/14.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^GKWebImageProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);

typedef void (^GKWebImageCompletionBlock)(UIImage * _Nullable image, NSURL * _Nullable url, BOOL finished, NSError * _Nullable error);

@class GKPhotoBrowser, GKPhoto;

@protocol GKWebImageProtocol<NSObject>

@property (nonatomic, weak, nullable) GKPhotoBrowser *browser;

/// 设置imageView类
- (Class _Nonnull)imageViewClass;

/// 为imageView设置图片
/// @param imageView imageView
/// @param url 图片url
/// @param placeholderImage 缺省图片
/// @param progressBlock 加载进度
/// @param completionBlock 完成进度
- (void)setImageForImageView:(nullable UIImageView *)imageView
                         url:(nullable NSURL *)url
            placeholderImage:(nullable UIImage *)placeholderImage
                    progress:(nullable GKWebImageProgressBlock)progressBlock
                  completion:(nullable GKWebImageCompletionBlock)completionBlock;

/// 取消imageView的图片请求
/// @param imageView imageView
- (void)cancelImageRequestWithImageView:(nullable UIImageView *)imageView;

/// 根据url从内存中获取图片
/// @param url url
- (UIImage *_Nullable)imageFromMemoryForURL:(nullable NSURL *)url;

@optional

/// 当前对应的数据模型
@property (nonatomic, weak, nullable) GKPhoto *photo;

/// 可选实现，主要用于加载相册图片资源PHAsset
/// 根据data获取image对象
/// @param data 图片数据
- (UIImage *_Nullable)imageWithData:(nullable NSData *)data;

/// 根据url清除内存，当photoView放入重用池时会调用此方法，可解决多个大图切换时内存暴涨问题
/// @param url 图片url
- (void)clearMemoryForURL:(nullable NSURL *)url;

/// 清理内存
- (void)clearMemory;

@end
