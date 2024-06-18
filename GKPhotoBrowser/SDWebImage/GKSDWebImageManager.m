//
//  GKWebImageManager.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/14.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKSDWebImageManager.h"

#if __has_include(<SDWebImage/SDWebImage.h>)
#import <SDWebImage/SDWebImage.h>
#else
#import "SDWebImage.h"
#endif

@implementation GKSDWebImageManager

@synthesize browser;

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

- (void)clearMemoryForURL:(NSURL *)url {
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
    [[SDImageCache sharedImageCache].memoryCache removeObjectForKey:key];
}

- (void)clearMemory {
    [[SDImageCache sharedImageCache] clearMemory];
}

@end
