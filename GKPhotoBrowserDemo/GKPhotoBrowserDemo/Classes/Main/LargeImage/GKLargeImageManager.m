//
//  GKLargeImageManager.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2023/6/1.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKLargeImageManager.h"
#import "GKLargeImageView.h"
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/UIView+WebCache.h>

@interface GKLargeImageManager()

@property (nonatomic, assign) NSInteger type;

@end

@implementation GKLargeImageManager

@synthesize browser;

- (instancetype)initWithType:(NSInteger)type {
    if (self = [super init]) {
        self.type = type;
    }
    return self;
}

- (Class)imageViewClass {
    if (self.type == 1) {
        return UIImageView.class;
    }else {
        return GKLargeImageView.class;
    }
}

- (void)setImageForImageView:(UIImageView *)imageView url:(NSURL *)url placeholderImage:(UIImage *)placeholderImage progress:(GKWebImageProgressBlock)progressBlock completion:(GKWebImageCompletionBlock)completionBlock {
    if ([imageView isKindOfClass:GKLargeImageView.class]) {
        [imageView sd_setImageWithURL:url placeholderImage:placeholderImage options:SDWebImageLowPriority | SDWebImageAvoidAutoSetImage progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            !progressBlock ?: progressBlock(receivedSize, expectedSize);
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [(GKLargeImageView *)imageView setUrl:url];
            [(GKLargeImageView *)imageView addTiledLayerWithImage:image];
            !completionBlock ?: completionBlock(image, url, !error, error);
        }];
    }else {
        [imageView sd_setImageWithURL:url placeholderImage:placeholderImage options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            !progressBlock ?: progressBlock(receivedSize, expectedSize);
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            !completionBlock ?: completionBlock(image, imageURL, !error, error);
            NSLog(@"%@", self.browser);
        }];
    }
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
