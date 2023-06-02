//
//  GKLargeImageManager.h
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2023/6/1.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GKPhotoBrowser/GKPhotoBrowser.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKLargeImageManager : NSObject<GKWebImageProtocol>

// 1：UIImageView 2：CATiledLayer
- (instancetype)initWithType:(NSInteger)type;

@end

NS_ASSUME_NONNULL_END
