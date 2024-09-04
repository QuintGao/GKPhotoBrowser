//
//  GKZFPlayerManager.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2023/3/16.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKZFPlayerManager.h"
#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFAVPlayerManager.h>
#import "GKPhotoBrowser.h"

@interface GKZFPlayerManager()

@property (nonatomic, strong) ZFPlayerController *player;

@end

@implementation GKZFPlayerManager

@synthesize browser;
@synthesize videoPlayView = _videoPlayView;
@synthesize coverImage = _coverImage;
@synthesize assetURL = _assetURL;
@synthesize isPlaying = _isPlaying;
@synthesize currentTime = _currentTime;
@synthesize totalTime = _totalTime;
@synthesize status = _status;
@synthesize playerStatusChange = _playerStatusChange;
@synthesize playerPlayTimeChange = _playerPlayTimeChange;
@synthesize playerGetVideoSize = _playerGetVideoSize;
@synthesize error = _error;

- (void)initPlayer {
    ZFAVPlayerManager *manager = [[ZFAVPlayerManager alloc] init];
    manager.shouldAutoPlay = NO;
    
    ZFPlayerController *player = [[ZFPlayerController alloc] initWithPlayerManager:manager containerView:self.videoPlayView];
    player.disableGestureTypes = ZFPlayerDisableGestureTypesAll;
    player.allowOrentitaionRotation = NO;
    player.customAudioSession = YES;
    self.player = player;
    
    // 设置封面图片
    manager.view.coverImageView.image = self.coverImage;
    
    __weak __typeof(self) weakSelf = self;
    // 准备播放
    player.playerPrepareToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        UIViewAutoresizing autoresizing = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        asset.view.autoresizingMask = autoresizing;
        asset.view.coverImageView.autoresizingMask = autoresizing;
        asset.view.playerView.autoresizingMask = autoresizing;
        if (self.browser.configure.isVideoMutedPlay) {
            [self gk_setMute:YES];
        }
    };
    
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
    
    // 视频尺寸
    player.presentationSizeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, CGSize size) {
        __strong __typeof(weakSelf) self = weakSelf;
        !self.playerGetVideoSize ?: self.playerGetVideoSize(self, size);
    };
    
    // 播放进度回调
    player.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        __strong __typeof(weakSelf) self = weakSelf;
        self->_totalTime = duration;
        self.currentTime = currentTime;
    };
    
    // 播放失败
    player.playerPlayFailed = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, id  _Nonnull error) {
        __strong __typeof(weakSelf) self = weakSelf;
        self->_error = error;
    };
    
    // 设置播放地址
    self.player.assetURL = self.assetURL;
}

- (void)dealloc {
    [self gk_stop];
}

#pragma mark - GKVideoPlayerProtocol
- (void)gk_prepareToPlay {
    if (!_assetURL) return;
    self.status = GKVideoPlayerStatusPrepared;
    [self initPlayer];
}

- (void)gk_play {
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    [manager play];
    _isPlaying = YES;
}

- (void)gk_replay {
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    [manager replay];
}

- (void)gk_pause {
    if (!self.isPlaying) return;
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    [manager pause];
    _isPlaying = NO;
    self.status = GKVideoPlayerStatusPaused;
}

- (void)gk_stop {
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

- (void)gk_seekToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL))completionHandler {
    [self.player seekToTime:time completionHandler:completionHandler];
}

- (void)gk_updateFrame:(CGRect)frame {
    self.videoPlayView.frame = frame;
}

- (void)gk_setMute:(BOOL)mute {
    self.player.currentPlayerManager.muted = mute;
}

#pragma mark - Getter
- (UIView *)videoPlayView {
    if (!_videoPlayView) {
        _videoPlayView = [[UIView alloc] init];
        _videoPlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
