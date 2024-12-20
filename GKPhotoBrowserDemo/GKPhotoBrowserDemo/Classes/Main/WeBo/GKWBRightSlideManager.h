//
//  GKWBRightSlideManager.h
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2024/9/11.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GKPhotoBrowser;
@class GKWBPlayerManager;

@interface GKWBRightSlideManager : NSObject

@property (nonatomic, weak) GKPhotoBrowser *browser;

@property (nonatomic, weak) GKWBPlayerManager *manager;

@end

NS_ASSUME_NONNULL_END
