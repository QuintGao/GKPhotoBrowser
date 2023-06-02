//
//  GKProgressViewProtocol.h
//  Pods
//
//  Created by QuintGao on 2023/6/2.
//

#import <UIKit/UIKit.h>
#import "GKVideoPlayerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class GKPhotoBrowser;

@protocol GKProgressViewProtocol <NSObject>

@property (nonatomic, weak) GKPhotoBrowser *browser;

@property (nonatomic, strong) UIView *progressView;

// 更新状态
- (void)updatePlayStatus:(GKVideoPlayerStatus)status;

// 更新时间与进度
- (void)updateCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

// 更新布局
- (void)updateLayoutWithFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
