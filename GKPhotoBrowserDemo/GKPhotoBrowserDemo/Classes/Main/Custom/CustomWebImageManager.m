//
//  CustomWebImageManager.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2025/1/8.
//  Copyright © 2025 QuintGao. All rights reserved.
//

#import "CustomWebImageManager.h"
#import <SDWebImage/SDWebImage.h>


@implementation CustomWebImageManager

@synthesize browser;
@synthesize photo;

- (NSString *)cacheKey {
    return self.photo.extraInfo;
}

- (Class)imageViewClass {
    return SDAnimatedImageView.class;
}

- (void)setImageForImageView:(UIImageView *)imageView url:(NSURL *)url placeholderImage:(UIImage *)placeholderImage progress:(GKWebImageProgressBlock)progress completion:(GKWebImageCompletionBlock)completion {
    NSLog(@"%@", [self cacheKey]);
    
    SDWebImageContext *context = @{
        SDWebImageContextCacheKeyFilter: [SDWebImageCacheKeyFilter cacheKeyFilterWithBlock:^NSString * _Nullable(NSURL * _Nonnull url) {
            return [self cacheKey];
        }]
    };
    
    [imageView sd_setImageWithURL:url placeholderImage:placeholderImage options:SDWebImageRetryFailed context:context progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
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
    return [SDImageCache.sharedImageCache imageFromMemoryCacheForKey:[self cacheKey]];
}

- (void)clearMemoryForURL:(NSURL *)url {
    [SDImageCache.sharedImageCache.memoryCache removeObjectForKey:[self cacheKey]];
}

- (void)clearMemory {
    [[SDImageCache sharedImageCache] clearMemory];
}

@end
