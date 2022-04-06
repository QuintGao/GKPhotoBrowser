//
//  GKVideoView.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2022/4/6.
//  Copyright © 2022 QuintGao. All rights reserved.
//

#import "GKVideoView.h"
#import <AVFoundation/AVFoundation.h>

@interface GKVideoView()

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end

@implementation GKVideoView

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.playerLayer.frame = self.bounds;
}

- (void)setPhoto:(GKPhoto *)photo {
    _photo = photo;
    
    if (self.player) {
        [self.player pause];
        self.player = nil;
    }
    
    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
    }
    
    self.player = [AVPlayer playerWithURL:photo.url];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.player prepareForInterfaceBuilder];
}

@end
