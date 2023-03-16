//
//  ZFPlayerView.m
//  ZFPlayer
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ZFPlayerView.h"
#import "ZFPlayerConst.h"

@implementation ZFPlayerView
@synthesize presentationSize = _presentationSize;
@synthesize coverImageView = _coverImageView;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.coverImageView];
    }
    return self;
}

- (void)setPlayerView:(UIView *)playerView {
    if (_playerView) {
        [_playerView removeFromSuperview];
        self.presentationSize = CGSizeZero;
    }
    _playerView = playerView;
    if (playerView != nil) {
        [self addSubview:playerView];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.bounds.size.width;
    CGFloat min_view_h = self.bounds.size.height;
    
    CGSize playerViewSize = CGSizeZero;
    CGFloat videoWidth = self.presentationSize.width;
    CGFloat videoHeight = self.presentationSize.height;
    if (videoHeight == 0) return;
    CGFloat screenScale = min_view_w/min_view_h;
    CGFloat videoScale = videoWidth/videoHeight;
    if (screenScale > videoScale) {
        CGFloat height = min_view_h;
        CGFloat width = height * videoScale;
        playerViewSize = CGSizeMake(width, height);
    } else {
        CGFloat width = min_view_w;
        CGFloat height = width / videoScale;
        playerViewSize = CGSizeMake(width, height);
    }
    
    if (self.scalingMode == ZFPlayerScalingModeNone || self.scalingMode == ZFPlayerScalingModeAspectFit) {
        min_w = playerViewSize.width;
        min_h = playerViewSize.height;
        min_x = (min_view_w - min_w) / 2.0;
        min_y = (min_view_h - min_h) / 2.0;
        self.playerView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    } else if (self.scalingMode == ZFPlayerScalingModeAspectFill || self.scalingMode == ZFPlayerScalingModeFill) {
        self.playerView.frame = self.bounds;
    }
    self.coverImageView.frame = self.playerView.frame;
}

- (CGSize)presentationSize {
    if (CGSizeEqualToSize(_presentationSize, CGSizeZero)) {
        _presentationSize = self.frame.size;
    }
    return _presentationSize;
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.clipsToBounds = YES;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _coverImageView;
}

- (void)setScalingMode:(ZFPlayerScalingMode)scalingMode {
    _scalingMode = scalingMode;
     if (scalingMode == ZFPlayerScalingModeNone || scalingMode == ZFPlayerScalingModeAspectFit) {
         self.coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    } else if (scalingMode == ZFPlayerScalingModeAspectFill) {
        self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    } else if (scalingMode == ZFPlayerScalingModeFill) {
        self.coverImageView.contentMode = UIViewContentModeScaleToFill;
    }
    [self layoutIfNeeded];
}

- (void)setPresentationSize:(CGSize)presentationSize {
    _presentationSize = presentationSize;
    if (CGSizeEqualToSize(CGSizeZero, presentationSize)) return;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end
