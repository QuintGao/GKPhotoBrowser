//
//  GKWebImageManager.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/14.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKSDWebImageManager.h"

#if __has_include(<SDWebImage/SDImageCache.h>)
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIView+WebCache.h>
#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/SDAnimatedImageView.h>
#import <SDWebImage/UIImage+GIF.h>
#else
#import "UIImageView+WebCache.h"
#import "UIView+WebCache.h"
#import "SDWebImageDownloader.h"
#import "SDImageCache.h"
#import "SDAnimatedImageView.h"
#endif

@implementation GKSDWebImageManager

- (Class)imageViewClass {
    return SDAnimatedImageView.class;
}

- (void)setImageForImageView:(UIImageView *)imageView url:(NSURL *)url placeholderImage:(UIImage *)placeholderImage progress:(GKWebImageProgressBlock)progress completion:(GKWebImageCompletionBlock)completion {
    [imageView sd_setImageWithURL:url placeholderImage:placeholderImage options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        !progress ? : progress(receivedSize, expectedSize);
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        !completion ? : completion(image, imageURL, !error, error);
    }];
}

- (UIImage *)imageWithData:(NSData *)data {
    return [UIImage sd_imageWithGIFData:data];
}

- (void)cancelImageRequestWithImageView:(UIImageView *)imageView {
    [imageView sd_cancelCurrentImageLoad];
}

- (UIImage *)imageFromMemoryForURL:(NSURL *)url {
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
    return [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
}

- (void)clearMemory {
    [[SDImageCache sharedImageCache] clearMemory];
}

@end
