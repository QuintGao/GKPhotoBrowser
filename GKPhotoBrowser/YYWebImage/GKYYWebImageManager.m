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

- (Class)imageViewClass {
    return YYAnimatedImageView.class;
}

- (void)setImageForImageView:(UIImageView *)imageView url:(NSURL *)url placeholderImage:(UIImage *)placeholderImage progress:(GKWebImageProgressBlock)progressBlock completion:(GKWebImageCompletionBlock)completionBlock {
    [imageView yy_setImageWithURL:url placeholder:placeholderImage options:kNilOptions progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        !progressBlock ? : progressBlock(receivedSize, expectedSize);
    } transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        BOOL success = (stage == YYWebImageStageFinished) && !error;
        !completionBlock ? : completionBlock(image, url, success, error);
    }];
}

- (void)cancelImageRequestWithImageView:(UIImageView *)imageView {
    [imageView yy_cancelCurrentImageRequest];
}

- (UIImage *)imageFromMemoryForURL:(NSURL *)url {
    YYWebImageManager *manager = [YYWebImageManager sharedManager];
    NSString *key = [manager cacheKeyForURL:url];
    return [manager.cache getImageForKey:key withType:YYImageCacheTypeAll];
}

@end
