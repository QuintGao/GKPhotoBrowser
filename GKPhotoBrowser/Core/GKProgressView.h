//
//  GKProgressView.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2023/3/1.
//

#import <UIKit/UIKit.h>
#import "GKVideoPlayerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKProgressView : UIView

@property (nonatomic, weak) id<GKVideoPlayerProtocol> player;

// 更新时间与进度
- (void)updateCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

@end

NS_ASSUME_NONNULL_END
