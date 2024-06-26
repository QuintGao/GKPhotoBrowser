//
//  GKDemoLocalViewController.h
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2024/6/18.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import "GKBaseViewController.h"
#import <GKPhotoBrowser/GKPhotoBrowser.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDemoLocalViewController : GKBaseViewController

@property (nonatomic, assign) GKPhotoBrowserShowStyle showStyle;

@property (nonatomic, assign) GKPhotoBrowserHideStyle hideStyle;

@property (nonatomic, assign) GKPhotoBrowserLoadStyle loadStyle;

@property (nonatomic, assign) GKPhotoBrowserFailStyle failStyle;

@property (nonatomic, assign) NSInteger imageLoadStyle;

@property (nonatomic, assign) GKPhotoBrowserLoadStyle videoLoadStyle;

@property (nonatomic, assign) GKPhotoBrowserFailStyle videoFailStyle;

@property (nonatomic, assign) NSInteger videoPlayStyle;

@property (nonatomic, assign) NSInteger livePhotoStyle;

@end

NS_ASSUME_NONNULL_END
