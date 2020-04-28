//
//  GKWebImageProtocol.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/14.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKPhotoBrowserConfigure.h"

typedef void (^GKWebImageProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);

typedef void (^GKWebImageCompletionBlock)(UIImage * _Nullable image, NSURL * _Nullable url, BOOL finished, NSError * _Nullable error);

@protocol GKWebImageProtocol<NSObject>

- (Class _Nonnull)imageViewClass;

- (void)setImageForImageView:(nullable UIImageView *)imageView
                         url:(nullable NSURL *)url
            placeholderImage:(nullable UIImage *)placeholderImage
                    progress:(nullable GKWebImageProgressBlock)progressBlock
                  completion:(nullable GKWebImageCompletionBlock)completionBlock;

- (void)cancelImageRequestWithImageView:(nullable UIImageView *)imageView;

- (UIImage *_Nullable)imageFromMemoryForURL:(nullable NSURL *)url;

@end
