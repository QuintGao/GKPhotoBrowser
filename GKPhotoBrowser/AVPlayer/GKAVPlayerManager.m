//
//  GKAVPlayerManager.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2023/3/1.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKAVPlayerManager.h"
#import <AVFoundation/AVFoundation.h>
#import "GKPhotoBrowserConfigure.h"

@interface GKAVPlayerView : UIView

@end

@implementation GKAVPlayerView

+ (Class)layerClass {
    return AVPlayerLayer.class;
}

@end

@interface GKAVPlayerManager()

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, assign) BOOL isAddObserver;
@property (nonatomic, strong) id timeObserver;

@property (nonatomic, assign) NSTimeInterval seekTime;
@property (nonatomic, copy) void(^completionHandler)(BOOL);

@property (nonatomic, strong) UIButton *playBtn;

// 进入后台前是否在播放
@property (nonatomic, assign) BOOL isPlay;

@end

@implementation GKAVPlayerManager

@synthesize videoPlayView = _videoPlayView;
@synthesize assetURL = _assetURL;
@synthesize isPlaying = _isPlaying;
@synthesize currentTime = _currentTime;
@synthesize totalTime = _totalTime;
@synthesize status = _status;
@synthesize playerStatusChange = _playerStatusChange;
@synthesize playerPlayTimeChange = _playerPlayTimeChange;

- (void)initPlayer {
    if (self.player) [self stop];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.assetURL];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.videoPlayView.layer;
    playerLayer.player = self.player;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self addPlayerObserver];
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
    [self.player play];
    _isPlaying = YES;
}

- (void)replay {
    __weak __typeof(self) weakSelf = self;
    [self seekToTime:0 completionHandler:^(BOOL finished) {
        __strong __typeof(weakSelf) self = weakSelf;
        [self play];
    }];
}

- (void)pause {
    if (!self.isPlaying) return;
    [self.player pause];
    [self.player.currentItem cancelPendingSeeks];
    _isPlaying = NO;
    self.status = GKVideoPlayerStatusPaused;
}

- (void)stop {
    if (self.player) {
        [self pause];
        self.player = nil;
        [self.videoPlayView removeFromSuperview];
        self.videoPlayView = nil;
        [self removePlayerObserver];
        self.currentTime = 0;
        self.seekTime = 0;
        self.completionHandler = nil;
        _totalTime = 0;
        _isPlaying = NO;
    }
}

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL))completionHandler {
    if (self.totalTime > 0) {
        [self.player.currentItem cancelPendingSeeks];
        int32_t timeScale = self.player.currentItem.asset.duration.timescale;
        CMTime seekTime = CMTimeMakeWithSeconds(time, timeScale);
        [self.player seekToTime:seekTime completionHandler:completionHandler];
    }else {
        self.seekTime = time;
        self.completionHandler = completionHandler;
    }
}

- (void)updateFrame:(CGRect)frame {
    self.videoPlayView.frame = frame;
}

#pragma mark - Notification
- (void)appDidEnterBackground {
    if (!self.player) return;
    self.isPlay = self.isPlaying;
    [self pause];
}

- (void)appDidEnterPlayground {
    if (!self.player) return;
    if (self.isPlay) {
        [self play];
    }
}

- (void)playToEnd {
    self.status = GKVideoPlayerStatusEnded;
    _isPlaying = NO;
}

#pragma mark - Observer
- (void)addPlayerObserver {
    self.isAddObserver = YES;
    // 播放状态
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 缓冲状态
    [self.player.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    // 播放结束
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playToEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    // 进入后台及前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)removePlayerObserver {
    if (!self.isAddObserver) return;
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    self.isAddObserver = NO;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([object isKindOfClass:[AVPlayerItem class]] && object == self.player.currentItem) {
        if ([keyPath isEqualToString:@"status"]) {
            switch (self.player.currentItem.status) {
                case AVPlayerItemStatusReadyToPlay: {
                    self.status = GKVideoPlayerStatusPlaying;
                    _totalTime = CMTimeGetSeconds(self.player.currentItem.duration);
                    if (!self.timeObserver) {
                        __weak __typeof(self) weakSelf = self;
                        self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                            __strong __typeof(weakSelf) self = weakSelf;
                            if (!self) return;
                            if (!self.player) return;
                            // 获取当前播放时间
                            self.currentTime = CMTimeGetSeconds(time);
                        }];
                    }
                    if (self.seekTime) {
                        [self seekToTime:self.seekTime completionHandler:self.completionHandler];
                        self.seekTime = 0;
                    }
                } break;
                case AVPlayerItemStatusFailed: {
                    self.status = GKVideoPlayerStatusFailed;
                } break;
                default:
                    break;
            }
        }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            if (self.status == GKVideoPlayerStatusEnded) return;
            if (self.player.currentItem.playbackLikelyToKeepUp) {
                self.status = GKVideoPlayerStatusPlaying;
            }else {
                self.status = GKVideoPlayerStatusBuffering;
            }
        }
    }
}

#pragma mark - Getter
- (UIView *)videoPlayView {
    if (!_videoPlayView) {
        _videoPlayView = [[GKAVPlayerView alloc] init];
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
