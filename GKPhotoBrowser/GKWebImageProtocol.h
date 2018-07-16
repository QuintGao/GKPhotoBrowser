//
//  GKWebImageProtocol.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/14.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

typedef void (^gkWebImageProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);

typedef void (^gkWebImageCompletionBlock)(UIImage *_Nullable image, NSURL * _Nullable url, BOOL success, NSError * _Nullable error);

@protocol GKWebImageProtocol<NSObject>

- (void)setImageWithImageView:(nullable FLAnimatedImageView *)imageView
                          url:(nullable NSURL *)url
                  placeholder:(nullable UIImage *)placeholder
                     progress:(nullable gkWebImageProgressBlock)progress
                   completion:(nullable gkWebImageCompletionBlock)completion;

- (void)cancelImageRequestWithImageView:(nullable FLAnimatedImageView *)imageView;

- (UIImage *_Nullable)imageFromMemoryForURL:(nullable NSURL *)url;

@end
