//
//  GKPhotoView+Video.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2024/6/21.
//

#import "GKPhotoView+Video.h"
#import "GKPhotoBrowser.h"

@implementation GKPhotoView (Video)

- (void)videoPlay {
    self.photo.isVideoClicked = YES;
    [self didScrollAppear];
}

- (void)videoPause {
    if (!self.player) return;
    self.photo.isVideoClicked = NO;
    self.playBtn.hidden = NO;
    [self.player gk_pause];
}

- (void)showVideoLoading {
    if (!self.photo.isAutoPlay && !self.photo.isVideoClicked) return;
    if (!self.player) return;
    if (self.player.assetURL != self.photo.videoUrl) return;
    self.videoLoadingView.frame = self.bounds;
    [self addSubview:self.videoLoadingView];
    [self loadVideo:YES success:NO];
}

- (void)hideVideoLoading {
    if (!self.photo.isAutoPlay && !self.photo.isVideoClicked) return;
    if (!self.player) return;
    if (self.player.assetURL != self.photo.videoUrl) return;
    [self loadVideo:NO success:YES];
}

- (void)showVideoFailure:(NSError *)error {
    if (!self.photo.isAutoPlay && !self.photo.isVideoClicked) return;
    if (!self.player) return;
    if (self.player.assetURL != self.photo.videoUrl) return;
    [self loadFailedWithError:error];
    [self loadVideo:NO success:NO];
}

- (void)showVideoPlayBtn {
    if (!self.photo.isAutoPlay && !self.photo.isVideoClicked) return;
    if (!self.player) return;
    if (self.player.assetURL != self.photo.videoUrl) return;
    if (!self.configure.isShowPlayImage) return;
    self.playBtn.hidden = NO;
}

- (void)videoDidScrollAppear {
    if (!self.photo.isAutoPlay && !self.photo.isVideoClicked) {
        if (!self.playBtn.superview) {
            [self addSubview:self.playBtn];
            [self.playBtn sizeToFit];
            self.playBtn.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
        }
        self.playBtn.hidden = NO;
        return;
    }
    if (!self.player) return;
    
    // 如果没有设置，则设置播放内容
    if (!self.player.assetURL || self.player.assetURL != self.photo.videoUrl) {
        __weak __typeof(self) weakSelf = self;
        [self.photo getVideo:^(NSURL * _Nullable url, NSError * _Nullable error) {
            __strong __typeof(weakSelf) self = weakSelf;
            if (!self) return;
            if (!self.player) return;
            if (error) {
                [self loadFailedWithError:error];
                [self loadVideo:NO success:NO];
            }else {
                self.player.coverImage = self.imageView.image;
                self.player.assetURL = url;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.player gk_prepareToPlay];
                    [self updateFrame];
                    [self.player gk_play];
                });
            }
        }];
    }else {
        [self.player gk_play];
    }
    
    if (!self.configure.isShowPlayImage) return;
    if (!self.playBtn.superview) {
        [self addSubview:self.playBtn];
    }
    self.playBtn.hidden = YES;
}

- (void)videoWillScrollDisappear {
    if (!self.player) return;
    if (!self.configure.isVideoPausedWhenScrollBegan) return;
    if (!self.photo.isAutoPlay && !self.photo.isVideoClicked) {
        if (self.player.isPlaying) {
            [self.player gk_pause];
        }
        return;
    }
    [self.player gk_pause];
}

- (void)videoDidScrollDisappear {
    if (!self.player) return;
    if (!self.photo.isAutoPlay) {
        if (self.photo.isVideoClicked) {
            self.photo.isVideoClicked = NO;
        }
        [self.player gk_stop];
        self.player.assetURL = nil;
        self.playBtn.hidden = NO;
        return;
    }
    [self.player gk_pause];
    if (!self.configure.isShowPlayImage) return;
    self.playBtn.hidden = NO;
}

- (void)videoDidDismissAppear {
    if (!self.player) return;
    if (self.player.status == GKVideoPlayerStatusEnded) {
        [self.player gk_replay];
    }else {
        [self.player gk_play];
    }
    if (!self.configure.isShowPlayImage) return;
    self.playBtn.hidden = YES;
}

- (void)videoWillDismissDisappear {
    if (!self.player) return;
    if (!self.configure.isVideoPausedWhenDragged) return;
    if (self.player.status == GKVideoPlayerStatusEnded) {
        if (!self.configure.isShowPlayImage) return;
        self.playBtn.hidden = YES;
    }else {
        [self.player gk_pause];
    }
}

- (void)videoDidDismissDisappear {
    if (!self.player) return;
    [self.player gk_stop];
    self.player.assetURL = nil;
}

- (void)videoUpdateFrame {
    if (!self.photo.isAutoPlay && !self.photo.isVideoClicked) return;
    if (!self.player) return;
    if (self.player.assetURL != self.photo.videoUrl) return;
    if (self.player.videoPlayView.superview != self.imageView) {
        [self.imageView addSubview:self.player.videoPlayView];
        self.imageView.userInteractionEnabled = YES;
    }
    [self.imageView bringSubviewToFront:self.player.videoPlayView];
    [self.player gk_updateFrame:self.imageView.bounds];
}

- (void)loadVideo:(BOOL)isStart success:(BOOL)success {
    self.loadingView.hidden = YES;
    if (self.configure.videoLoadStyle == GKPhotoBrowserLoadStyleCustom) {
        if ([self.delegate respondsToSelector:@selector(photoView:loadStart:success:)]) {
            [self.delegate photoView:self loadStart:isStart success:success];
        }
    }else {
        if (isStart) {
            [self.videoLoadingView startLoading];
        }else {
            if (success) {
                [self.videoLoadingView stopLoading];
            }else {
                [self.videoLoadingView showFailure];
            }
        }
    }
}

@end
