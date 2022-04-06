//
//  GKVideoView.h
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2022/4/6.
//  Copyright © 2022 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKPhotoManager.h"

NS_ASSUME_NONNULL_BEGIN

@class GKVideoView;

@protocol GKVideoViewDelegate <NSObject>

- (void)videoViewPlayStart:(GKVideoView *)videoView;

- (void)videoViewPlayEnded:(GKVideoView *)videoView;

- (void)videoViewPlayError:(GKVideoView *)videoView;

@end

@interface GKVideoView : UIView

@property (nonatomic, strong) GKPhoto *photo;

@end

NS_ASSUME_NONNULL_END
