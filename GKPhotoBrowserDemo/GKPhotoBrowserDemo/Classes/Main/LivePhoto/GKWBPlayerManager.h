//
//  GKWBPlayerManager.h
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2024/9/5.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GKPhotoBrowser/GKPhotoBrowser.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKWBPlayerManager : NSObject<GKVideoPlayerProtocol>

@property (nonatomic, assign) NSInteger currentIndex;

- (void)willDismiss;

@end

NS_ASSUME_NONNULL_END
