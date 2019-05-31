//
//  GKWebImageProtocol.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/14.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKPhotoBrowserConfigure.h"

typedef void (^gkWebImageProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);

typedef void (^gkWebImageCompletionBlock)(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL);

@protocol GKWebImageProtocol<NSObject>

// 加载图片
- (id _Nonnull )loadImageWithURL:(nullable NSURL *)url
                        progress:(nullable gkWebImageProgressBlock)progress
                       completed:(nullable gkWebImageCompletionBlock)completion;

- (void)cancelImageRequestWithImageView:(nullable UIImageView *)imageView;

- (UIImage *_Nullable)imageFromMemoryForURL:(nullable NSURL *)url;

@end
