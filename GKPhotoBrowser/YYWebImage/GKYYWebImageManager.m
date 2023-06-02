//
//  GKYYWebImageManager.m
//  GKPhotoBrowserDemo
//
//  Created by gaokun on 2020/4/27.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import "GKYYWebImageManager.h"

#if __has_include(<YYWebImage/YYWebImage>)
#import <YYWebImage/YYWebImage.h>
#else
#import "YYWebImage.h"
#endif

@implementation GKYYWebImageManager

@synthesize browser;

- (Class)imageViewClass {
    return [NSClassFromString(@"YYAnimatedImageView") class];
}

- (void)setImageForImageView:(UIImageView *)imageView url:(NSURL *)url placeholderImage:(UIImage *)placeholderImage progress:(GKWebImageProgressBlock)progressBlock completion:(GKWebImageCompletionBlock)completionBlock {
    [imageView yy_setImageWithURL:url placeholder:placeholderImage options:kNilOptions progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        !progressBlock ? : progressBlock(receivedSize, expectedSize);
    } transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        BOOL success = (stage == YYWebImageStageFinished) && !error;
        !completionBlock ? : completionBlock(image, url, success, error);
    }];
}

- (UIImage *)imageWithData:(NSData *)data {
    return [UIImage yy_imageWithSmallGIFData:data scale:UIScreen.mainScreen.scale];
}

- (void)cancelImageRequestWithImageView:(UIImageView *)imageView {
    [imageView yy_cancelCurrentImageRequest];
}

- (UIImage *)imageFromMemoryForURL:(NSURL *)url {
    NSString *key = [[YYWebImageManager sharedManager] cacheKeyForURL:url];
    return [[YYImageCache sharedCache] getImageForKey:key];
}

- (void)clearMemoryForURL:(NSURL *)url {
    NSString *key = [[YYWebImageManager sharedManager] cacheKeyForURL:url];
    [[YYImageCache sharedCache].memoryCache removeObjectForKey:key];
}

- (void)clearMemory {
    [[YYImageCache sharedCache].memoryCache removeAllObjects];
}

@end
