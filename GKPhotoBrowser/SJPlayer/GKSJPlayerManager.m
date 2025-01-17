//
//  GKSJPlayerManager.m
//  GKPhotoBrowser_Static
//
//  Created by QuintGao on 2025/1/17.
//

#import "GKSJPlayerManager.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import "GKPhotoBrowser.h"

static SJControlLayerIdentifier GKSJControlViewIdentifier = 999;
@interface GKSJControlView : UIView<SJControlLayer>
@end

@implementation GKSJControlView

#pragma mark - SJControlLayer
@synthesize restarted;

- (UIView *)controlView {
    return self;
}

- (void)restartControlLayer { }

- (void)exitControlLayer { }

@end

@interface GKSJPlayerManager()

@property (nonatomic, strong) SJVideoPlayer *player;

@end

@implementation GKSJPlayerManager

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
    SJVideoPlayer *player = [SJVideoPlayer player];
    self.player = player;
    
    self.videoPlayView = player.view;
    player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    player.view.backgroundColor = UIColor.clearColor;
    player.presentView.backgroundColor = UIColor.clearColor;
    player.controlLayerAppearManager.disabled = YES;
    player.presentView.placeholderImageViewContentMode = UIViewContentModeScaleAspectFit;
    player.videoGravity = AVLayerVideoGravityResizeAspect;
    player.autoplayWhenSetNewAsset = NO;
    player.rotationManager.disabledAutorotation = YES;
    player.pausedInBackground = YES;
    player.resumePlaybackWhenScrollAppeared = NO;
    player.resumePlaybackWhenAppDidEnterForeground = NO;
    player.automaticallyHidesPlaceholderImageView = YES;
    player.gestureController.supportedGestureTypes = SJPlayerGestureTypeMask_None;

    // 添加自定义控制层并切换
    [player.switcher addControlLayerForIdentifier:GKSJControlViewIdentifier lazyLoading:^id<SJControlLayer> _Nonnull(SJControlLayerIdentifier identifier) {
        return [[GKSJControlView alloc] init];
    }];
    [player.switcher switchControlLayerForIdentifier:GKSJControlViewIdentifier];
    
    // 设置封面图片
    player.presentView.placeholderImageView.image = self.coverImage;
    
    if (self.browser.configure.isVideoMutedPlay) {
        [self gk_setMute:YES];
    }
    
    __weak __typeof(self) weakSelf = self;
    // 加载状态改变回调
    player.playbackObserver.assetStatusDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong __typeof(weakSelf) self = weakSelf;
        switch (player.assetStatus) {
            case SJAssetStatusUnknown:
                
                break;
            case SJAssetStatusPreparing:
                self.status = GKVideoPlayerStatusBuffering;
                break;
            case SJAssetStatusReadyToPlay:
                
                break;
            case SJAssetStatusFailed: {
                self->_error = player.error;
                self.status = GKVideoPlayerStatusFailed;
            }
                break;
                
            default:
                break;
        }
    };
    
    // 播放状态改变
    player.playbackObserver.timeControlStatusDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong __typeof(weakSelf) self = weakSelf;
        switch (player.timeControlStatus) {
            case SJPlaybackTimeControlStatusPaused:
                self.status = GKVideoPlayerStatusPaused;
                break;
            case SJPlaybackTimeControlStatusWaitingToPlay:
                self.status = GKVideoPlayerStatusBuffering;
                break;
            case SJPlaybackTimeControlStatusPlaying:
                self.status = GKVideoPlayerStatusPlaying;
                break;
                
            default:
                break;
        }
    };
    
    player.playbackObserver.playbackDidFinishExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (self.status == GKVideoPlayerStatusEnded) return;
        self.status = GKVideoPlayerStatusEnded;
    };
    
    // 视频尺寸
    player.playbackObserver.presentationSizeDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong __typeof(weakSelf) self = weakSelf;
        !self.playerGetVideoSize ?: self.playerGetVideoSize(self, player.videoPresentationSize);
    };
    
    // 播放进度回调
    player.playbackObserver.currentTimeDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong __typeof(weakSelf) self = weakSelf;
        self->_totalTime = player.duration;
        self.currentTime = player.currentTime;
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
    [self.player play];
    _isPlaying = YES;
}

- (void)gk_replay {
    [self.player replay];
    self.currentTime = 0;
}

- (void)gk_pause {
    if (!self.isPlaying) return;
    [self.player pause];
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
    self.player.muted = mute;
}

#pragma mark - Getter
//- (UIView *)videoPlayView {
//    if (!_videoPlayView) {
//        _videoPlayView = [[UIView alloc] init];
//        _videoPlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    }
//    return _videoPlayView;
//}

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
