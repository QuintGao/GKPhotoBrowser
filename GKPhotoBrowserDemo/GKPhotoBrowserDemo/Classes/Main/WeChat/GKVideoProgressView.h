//
//  GKVideoProgressView.h
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2023/5/26.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GKPhotoBrowser/GKVideoPlayerProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKVideoProgressView : UIView

@property (nonatomic, copy) void(^playPauseBlock)(void);

- (void)updateCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

- (void)updateStatus:(GKVideoPlayerStatus)status;

@end

NS_ASSUME_NONNULL_END
