//
//  LocalImageLoadManager.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2024/8/29.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import "LocalImageLoadManager.h"

@implementation LocalImageLoadManager

@synthesize browser;

- (Class)imageViewClass {
    return UIImageView.class;
}

- (void)setImageForImageView:(UIImageView *)imageView url:(NSURL *)url placeholderImage:(UIImage *)placeholderImage progress:(GKWebImageProgressBlock)progressBlock completion:(GKWebImageCompletionBlock)completionBlock {
    !progressBlock ?: progressBlock(1, 1);
    !completionBlock ?: completionBlock(placeholderImage, url, YES, nil);
}

- (void)cancelImageRequestWithImageView:(nullable UIImageView *)imageView { 
    
}

- (UIImage * _Nullable)imageFromMemoryForURL:(nullable NSURL *)url { 
    return nil;
}

@end
