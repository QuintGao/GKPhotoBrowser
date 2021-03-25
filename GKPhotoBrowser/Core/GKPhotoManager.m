//
//  GKPhotoManager.m
//  GKPhotoBrowserDemo
//
//  Created by gaokun on 2020/6/16.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import "GKPhotoManager.h"

@implementation GKPhoto

@end

@implementation GKPhotoManager

+ (PHImageRequestID)loadImageDataWithImageAsset:(PHAsset *)imageAsset completion:(void (^)(NSData * _Nullable))completion {
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageDataForAsset:imageAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL complete = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (complete && imageData) {
            completion(imageData);
        } else {
            completion(nil);
        }
    }];
    return requestID;
}

+ (PHImageRequestID)loadImageWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage * _Nullable))completion {
    CGSize imageSize;
    CGFloat scale = 2.0;
    if (UIScreen.mainScreen.bounds.size.width > 700) {
        scale = 1.5;
    }
    CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
    CGFloat pixelWidth = photoWidth * scale;
    // 超宽图片
    if (aspectRatio > 1.8) {
        pixelWidth = pixelWidth * aspectRatio;
    }
    // 超高图片
    if (aspectRatio < 0.2) {
        pixelWidth = pixelWidth * 0.5;
    }
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    imageSize = CGSizeMake(pixelWidth, pixelHeight);
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL cancelled = [[info objectForKey:PHImageCancelledKey] boolValue];
        if (!cancelled && result) {
            !completion ? : completion(result);
        }
        // Download image from iCloud / 从iCloud下载图片
        if ([info objectForKey:PHImageResultIsInCloudKey] && !result) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.networkAccessAllowed = YES;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                UIImage *resultImage = [UIImage imageWithData:imageData];
                !completion ? : completion(resultImage);
            }];
        }
    }];
    return requestID;
}

@end
