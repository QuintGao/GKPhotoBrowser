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
@synthesize coverImage = _coverImage;
@synthesize assetURL = _assetURL;
@synthesize isPlaying = _isPlaying;
@synthesize currentTime = _currentTime;
@synthesize totalTime = _totalTime;
@synthesize status = _status;
@synthesize playerStatusChange = _playerStatusChange;
@synthesize playerPlayTimeChange = _playerPlayTimeChange;
@synthesize playerGetVideoSize = _playerGetVideoSize;

- (void)initPlayer {
    if (self.player) [self gk_stop];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.assetURL];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.videoPlayView.layer;
    playerLayer.player = self.player;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self addPlayerObserver];
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
    __weak __typeof(self) weakSelf = self;
    [self gk_seekToTime:0 completionHandler:^(BOOL finished) {
        __strong __typeof(weakSelf) self = weakSelf;
        [self gk_play];
        self.status = GKVideoPlayerStatusPlaying;
    }];
}

- (void)gk_pause {
    if (!self.isPlaying) return;
    [self.player pause];
    [self.player.currentItem cancelPendingSeeks];
    _isPlaying = NO;
    self.status = GKVideoPlayerStatusPaused;
}

- (void)gk_stop {
    if (self.player) {
        [self gk_pause];
        [self removePlayerObserver];
        self.player = nil;
        [self.videoPlayView removeFromSuperview];
        self.videoPlayView = nil;
        self.currentTime = 0;
        self.seekTime = 0;
        self.completionHandler = nil;
        _totalTime = 0;
        _isPlaying = NO;
    }
}

- (void)gk_seekToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL))completionHandler {
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

- (void)gk_updateFrame:(CGRect)frame {
    self.videoPlayView.frame = frame;
}

#pragma mark - Notification
- (void)appDidEnterBackground {
    if (!self.player) return;
    self.isPlay = self.isPlaying;
    [self gk_pause];
}

- (void)appDidEnterPlayground {
    if (!self.player) return;
    if (self.isPlay) {
        [self gk_play];
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
    // 视频尺寸
    [self.player.currentItem addObserver:self forKeyPath:@"presentationSize" options:NSKeyValueObservingOptionNew context:nil];
    
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
    [self.player.currentItem removeObserver:self forKeyPath:@"presentationSize"];
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
                            if (!self || !self.player) return;
                            // 获取当前播放时间
                            self.currentTime = CMTimeGetSeconds(time);
                        }];
                    }
                    if (self.seekTime) {
                        [self gk_seekToTime:self.seekTime completionHandler:self.completionHandler];
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
                if (self.isPlaying) [self.player play];
            }else {
                self.status = GKVideoPlayerStatusBuffering;
            }
        }else if ([keyPath isEqualToString:@"presentationSize"]) {
            CGSize size = self.player.currentItem.presentationSize;
            !self.playerGetVideoSize ?: self.playerGetVideoSize(self, size);
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
