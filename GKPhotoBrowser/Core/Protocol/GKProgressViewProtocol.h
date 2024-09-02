//
//  GKProgressViewProtocol.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2023/6/2.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKVideoPlayerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class GKPhotoBrowser;

@protocol GKProgressViewProtocol <NSObject>

@property (nonatomic, weak, nullable) GKPhotoBrowser *browser;

@property (nonatomic, strong, nullable) UIView *progressView;

@optional
// 更新状态
- (void)updatePlayStatus:(GKVideoPlayerStatus)status;

// 更新时间与进度
- (void)updateCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

// 更新布局
- (void)updateLayoutWithFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
