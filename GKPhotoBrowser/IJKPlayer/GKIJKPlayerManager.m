//
//  GKIJKPlayerManager.m
//  AFNetworking
//
//  Created by QuintGao on 2024/6/4.
//

#import "GKIJKPlayerManager.h"
#import "GKPhotoBrowser.h"
#if __has_include(<IJKMediaFramework/IJKMediaFramework.h>)
#import <IJKMediaFramework/IJKMediaFramework.h>
#endif

@interface GKIJKPlayerManager()

@property (nonatomic, strong) IJKFFMoviePlayerController *player;
@property (nonatomic, strong) IJKFFOptions *options;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isReadyToPlay;

@property (nonatomic, assign) NSTimeInterval seekTime;
@property (nonatomic, assign) CGFloat lastVolume;

@end

@implementation GKIJKPlayerManager

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
    // IJKFFMoviePlayerController 初始化后，必须手动进行释放，否则会依然存在内存中对资源进行播放。
    if (self.player) {
        [self removePlayerNotifications];
        [self.player shutdown];
        [self.player.view removeFromSuperview];
        self.player = nil;
    }
    
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.assetURL withOptions:self.options];
    self.player.shouldAutoplay = NO;
    [self.player prepareToPlay];
    self.videoPlayView = self.player.view;
    if (self.browser.configure.isVideoMutedPlay) {
        [self gk_setMute:YES];
    }
    [self addPlayerNotifications];
}

- (void)dealloc {
    [self gk_stop];
}

#pragma mark - Notification
- (void)addPlayerNotifications {
    /// 加载状态变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStateDidChange:) name:IJKMPMoviePlayerLoadStateDidChangeNotification object:nil];
    /// 播放完成或者用户退出
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackFinish:) name:IJKMPMoviePlayerPlaybackDidFinishNotification object:nil];
    /// 准备开始播放了
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaIsPreparedToPlayDidChange:) name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];
    /// 播放状态改变了
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackStateDidChange:) name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    /// 视频尺寸变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeAvailableChange:) name:IJKMPMovieNaturalSizeAvailableNotification object:nil];
}

- (void)removePlayerNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IJKMPMovieNaturalSizeAvailableNotification object:nil];
}

// 加载状态改变
- (void)loadStateDidChange:(NSNotification *)notify {
    IJKMPMovieLoadState state = self.player.loadState;
    if (state & IJKMPMovieLoadStateStalled) {
        self.status = GKVideoPlayerStatusBuffering;
    }
}

// 播放完成
- (void)moviePlayBackFinish:(NSNotification *)notify {
    int reason = [notify.userInfo[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    switch (reason) {
        case IJKMPMovieFinishReasonPlaybackEnded: {
            self.status = GKVideoPlayerStatusEnded;
        }
            break;
        case IJKMPMovieFinishReasonUserExited:
            break;
        case IJKMPMovieFinishReasonPlaybackError: {
            self.status = GKVideoPlayerStatusFailed;
            self->_error = [NSError errorWithDomain:@"" code:reason userInfo:@{@"msg": @"播放失败"}];
        }
            break;
            
        default:
            break;
    }
}

// 准备开始播放
- (void)mediaIsPreparedToPlayDidChange:(NSNotification *)notify {
    // 视频开始播放的时候开启定时器
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerUpdate) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    if (self.isPlaying) {
        [self gk_play];
        if (self.seekTime > 0) {
            [self gk_seekToTime:self.seekTime completionHandler:nil];
            self.seekTime = 0;
            [self gk_play];
        }
    }
}

- (void)moviePlayBackStateDidChange:(NSNotification *)notify {
    switch (self.player.playbackState) {
        case IJKMPMoviePlaybackStatePlaying:
            self.status = GKVideoPlayerStatusPlaying;
            break;
        case IJKMPMoviePlaybackStatePaused:
            self.status = GKVideoPlayerStatusPaused;
            break;
        case IJKMPMoviePlaybackStateStopped:
            if (self.status == GKVideoPlayerStatusEnded) return;
            self.status = GKVideoPlayerStatusEnded;
            break;
        default:
            break;
    }
}

- (void)sizeAvailableChange:(NSNotification *)notify {
    !self.playerGetVideoSize ?: self.playerGetVideoSize(self, self.player.naturalSize);
}

- (void)timerUpdate {
    if (self.player.currentPlaybackTime > 0 && !self.isReadyToPlay) {
        self.isReadyToPlay = YES;
    }
    self->_currentTime = self.player.currentPlaybackTime > 0 ? self.player.currentPlaybackTime : 0;
    self->_totalTime = self.player.duration;
    !self.playerPlayTimeChange ?: self.playerPlayTimeChange(self, self.currentTime, self.totalTime);
}

#pragma mark - GKVideoPlayerProtocol
- (void)gk_prepareToPlay {
    if (!_assetURL) return;
    self.status = GKVideoPlayerStatusPrepared;
    [self initPlayer];
}

- (void)gk_play {
    [self.player play];
    if (self.timer) [self.timer setFireDate:[NSDate date]];
    _isPlaying = YES;
}

- (void)gk_replay {
    __weak __typeof(self) weakSelf = self;
    [self gk_seekToTime:0 completionHandler:^(BOOL finished) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (finished) {
            [self gk_play];
            self.currentTime = 0;
        }
    }];
}

- (void)gk_pause {
    if (self.timer) [self.timer setFireDate:[NSDate distantFuture]];
    [self.player pause];
    _isPlaying = NO;
}

- (void)gk_stop {
    [self removePlayerNotifications];
    [self.player shutdown];
    [self.player.view removeFromSuperview];
    self.player = nil;
    [self.timer invalidate];
    self.timer = nil;
    _isPlaying = NO;
    self.currentTime = 0;
    [self.videoPlayView removeFromSuperview];
    self.videoPlayView = nil;
    _totalTime = 0;
    _isPlaying = NO;
}

- (void)gk_seekToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL))completionHandler {
    if (self.player.duration > 0) {
        self.player.currentPlaybackTime = time;
        !completionHandler ?: completionHandler(YES);
    }else {
        self.seekTime = time;
    }
}

- (void)gk_updateFrame:(CGRect)frame {
    self.videoPlayView.frame = frame;
    self.player.view.frame = self.videoPlayView.bounds;
}

- (void)gk_setMute:(BOOL)mute {
    if (mute) {
        self.lastVolume = self.player.playbackVolume;
        self.player.playbackVolume = 0;
    } else {
        /// Fix first called the lastVolume is 0.
        if (self.lastVolume == 0) self.lastVolume = self.player.playbackVolume;
        self.player.playbackVolume = self.lastVolume;
    }
}

#pragma mark - Getter
- (IJKFFOptions *)options {
    if (!_options) {
        _options = [IJKFFOptions optionsByDefault];
        /// 精准seek
        [_options setPlayerOptionIntValue:1 forKey:@"enable-accurate-seek"];
        /// 解决http播放不了
        [_options setOptionIntValue:1 forKey:@"dns_cache_clear" ofCategory:kIJKFFOptionCategoryFormat];
    }
    return _options;
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
