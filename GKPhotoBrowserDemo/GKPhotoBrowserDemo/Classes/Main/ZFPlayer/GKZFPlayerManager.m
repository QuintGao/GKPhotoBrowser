//
//  GKZFPlayerManager.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2023/3/16.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKZFPlayerManager.h"
#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFAVPlayerManager.h>

@interface GKZFPlayerManager()

@property (nonatomic, strong) ZFPlayerController *player;

@end

@implementation GKZFPlayerManager

@synthesize videoPlayView = _videoPlayView;
@synthesize coverImage = _coverImage;
@synthesize assetURL = _assetURL;
@synthesize isPlaying = _isPlaying;
@synthesize currentTime = _currentTime;
@synthesize totalTime = _totalTime;
@synthesize status = _status;
@synthesize playerStatusChange = _playerStatusChange;
@synthesize playerPlayTimeChange = _playerPlayTimeChange;

- (void)initPlayer {
    ZFAVPlayerManager *manager = [[ZFAVPlayerManager alloc] init];
    manager.shouldAutoPlay = NO;
    
    ZFPlayerController *player = [[ZFPlayerController alloc] initWithPlayerManager:manager containerView:self.videoPlayView];
    player.disableGestureTypes = ZFPlayerDisableGestureTypesAll;
    player.allowOrentitaionRotation = NO;
    self.player = player;
    
    // 设置封面图片
    manager.view.coverImageView.image = self.coverImage;
    
    // 设置播放地址
    self.player.assetURL = self.assetURL;
    
    __weak __typeof(self) weakSelf = self;
    // 加载状态改变回调
    player.playerLoadStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerLoadState loadState) {
        __strong __typeof(weakSelf) self = weakSelf;
        if ((loadState == ZFPlayerLoadStatePrepare || loadState == ZFPlayerLoadStateStalled) && self.player.currentPlayerManager.isPlaying) {
            self.status = GKVideoPlayerStatusBuffering;
        }else if (loadState == ZFPlayerLoadStatePlayable) {
            self.status = GKVideoPlayerStatusPlaying;
        }
    };
    
    // 播放状态改变
    player.playerPlayStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerPlaybackState playState) {
        __strong __typeof(weakSelf) self = weakSelf;
        switch (playState) {
            case ZFPlayerPlayStateUnknown:
                break;
            case ZFPlayerPlayStatePlaying: {
                id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
                if (manager.loadState == ZFPlayerLoadStatePlayable) {
                    self.status = GKVideoPlayerStatusPlaying;
                }
            }
                break;
            case ZFPlayerPlayStatePaused:
                self.status = GKVideoPlayerStatusPaused;
                break;
            case ZFPlayerPlayStatePlayFailed:
                self.status = GKVideoPlayerStatusFailed;
                break;
            case ZFPlayerPlayStatePlayStopped:
                self.status = GKVideoPlayerStatusEnded;
                break;
                
            default:
                break;
        }
    };
    
    // 播放进度回调
    player.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        __strong __typeof(weakSelf) self = weakSelf;
        self->_totalTime = duration;
        self.currentTime = currentTime;
    };
}

- (void)dealloc {
    [self stop];
}

#pragma mark - GKVideoPlayerProtocol
- (void)prepareToPlay {
    if (!_assetURL) return;
    [self initPlayer];
    self.status = GKVideoPlayerStatusPrepared;
}

- (void)play {
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    [manager play];
    _isPlaying = YES;
}

- (void)replay {
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    [manager replay];
}

- (void)pause {
    if (!self.isPlaying) return;
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    [manager pause];
    _isPlaying = NO;
    self.status = GKVideoPlayerStatusPaused;
}

- (void)stop {
    if (self.player) {
        [self.player stop];
        self.player = nil;
        [self.videoPlayView removeFromSuperview];
        self.videoPlayView = nil;
        self.currentTime = 0;
        _totalTime = 0;
        _isPlaying = NO;
    }
}

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL))completionHandler {
    [self.player seekToTime:time completionHandler:completionHandler];
}

- (void)updateFrame:(CGRect)frame {
    self.videoPlayView.frame = frame;
}

#pragma mark - Getter
- (UIView *)videoPlayView {
    if (!_videoPlayView) {
        _videoPlayView = [[UIView alloc] init];
    }
    return _videoPlayView;
}

#pragma mark - Setter
- (void)setStatus:(GKVideoPlayerStatus)status {
    _status = status;
    !self.playerStatusChange ?: self.playerStatusChange(self, status);
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    _currentTime = currentTime;
    !self.playerPlayTimeChange ?: self.playerPlayTimeChange(self, self.currentTime, self.totalTime);
}

@end
