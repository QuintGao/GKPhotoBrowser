//
//  GKPhotoManager.m
//  GKPhotoBrowserDemo
//
//  Created by gaokun on 2020/6/16.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import "GKPhotoManager.h"

@implementation GKPhotoManager

+ (void)loadImageDataWithImageAsset:(PHAsset *)imageAsset completion:(void (^)(NSData * _Nullable))completion {
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeNone;
    options.synchronous = YES;
    [[PHImageManager defaultManager] requestImageDataForAsset:imageAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL complete = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (complete && imageData) {
            completion(imageData);
        } else {
            completion(nil);
        }
    }];
}

@end
