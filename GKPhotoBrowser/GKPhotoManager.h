//
//  GKPhotoManager.h
//  GKPhotoBrowserDemo
//
//  Created by gaokun on 2020/6/16.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKPhotoManager : NSObject

+ (void)loadImageDataWithImageAsset:(PHAsset *)imageAsset completion:(nonnull void(^)(NSData *_Nullable data))completion;

@end

NS_ASSUME_NONNULL_END
