//
//  GKVideoProgressView.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2023/5/26.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKVideoProgressView.h"
#import <GKSliderView/GKSliderView.h>
#import <Masonry/Masonry.h>
#import "GKPhotoView+Video.h"

@interface GKVideoProgressView()<GKSliderViewDelegate>

@property (nonatomic, strong) UIButton *playBtn;

@property (nonatomic, strong) UILabel *currentTimeLabel;

@property (nonatomic, strong) GKSliderView *sliderView;

@property (nonatomic, strong) UILabel *totalTimeLabel;

@property (nonatomic, assign) NSTimeInterval totalTime;
@property (nonatomic, assign) BOOL isSeeking;

@end

@implementation GKVideoProgressView

@synthesize browser = _browser;
@synthesize progressView = _progressView;

- (UIView *)progressView {
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.playBtn];
    [self addSubview:self.currentTimeLabel];
    [self addSubview:self.sliderView];
    [self addSubview:self.totalTimeLabel];
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.bottom.equalTo(self).offset(-30);
    }];

    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playBtn.mas_right).offset(10);
        make.centerY.equalTo(self.playBtn);
    }];

    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(100);
        make.right.equalTo(self).offset(-70);
        make.centerY.equalTo(self.playBtn);
        make.height.mas_equalTo(20);
    }];

    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.centerY.equalTo(self.playBtn);
    }];

    CGRect frame = self.sliderView.sliderBtn.frame;
    frame.size = CGSizeMake(20, 20);
    self.sliderView.sliderBtn.frame = frame;
    self.sliderView.sliderBtn.layer.cornerRadius = 10;
}

- (void)playPause {
    GKPhotoView *photoView = self.browser.curPhotoView;
    if (photoView.player.isPlaying) {
        [photoView videoPause];
    }else {
        [photoView videoPlay];
    }
}

- (NSString *)convertTimeSecond:(NSInteger)timeSecond {
    NSString *theLastTime = nil;
    long second = timeSecond;
    if (timeSecond < 60) {
        theLastTime = [NSString stringWithFormat:@"00:%02zd", second];
    } else if(timeSecond >= 60 && timeSecond < 3600){
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd", second/60, second%60];
    } else if(timeSecond >= 3600){
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", second/3600, second%3600/60, second%60];
    }
    return theLastTime;
}

#pragma mark - GKProgressViewProtocol
- (void)updatePlayStatus:(GKVideoPlayerStatus)status {
    if (status == GKVideoPlayerStatusEnded) {
        self.sliderView.value = 0;
        self.currentTimeLabel.text = @"00:00";
        self.playBtn.selected = NO;
    }else if (status == GKVideoPlayerStatusFailed || status == GKVideoPlayerStatusPaused) {
        self.playBtn.selected = NO;
    }else {
        self.playBtn.selected = YES;
    }
}

- (void)updateCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    self.totalTime = totalTime;
    if (self.sliderView.isDragging) return;
    if (self.isSeeking) return;
    CGFloat progress = 0;
    if (totalTime == 0) {
        progress = 0;
    }else {
        progress = currentTime / totalTime;
    }
    if (progress <= 0) progress = 0;
    if (progress >= 1) progress = 1;
    self.sliderView.value = progress;
    self.currentTimeLabel.text = [self convertTimeSecond:currentTime];
    self.totalTimeLabel.text = [self convertTimeSecond:totalTime];
}

- (void)updateLayoutWithFrame:(CGRect)frame {
    self.frame = CGRectMake(0, frame.size.height - 80 - kSafeBottomSpace, frame.size.width, 80);
}

#pragma mark - GKSliderViewDelegate
- (void)sliderView:(GKSliderView *)sliderView valueChanged:(float)value {
    NSTimeInterval currentTime = self.totalTime * value;
    self.currentTimeLabel.text = [self convertTimeSecond:currentTime];
}

- (void)sliderView:(GKSliderView *)sliderView touchEnded:(float)value {
    self.isSeeking = YES;
    __weak __typeof(self) weakSelf = self;
    [self.browser.player gk_seekToTime:self.totalTime * value completionHandler:^(BOOL finished) {
        __strong __typeof(weakSelf) self = weakSelf;
        self.isSeeking = NO;
    }];
}

#pragma mark - Lazy
- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] init];
        [_playBtn setImage:[UIImage imageNamed:@"ic_play"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"ic_pause"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(playPause) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.font = [UIFont systemFontOfSize:14];
        _currentTimeLabel.textColor = UIColor.whiteColor;
        _currentTimeLabel.text = @"00:00";
    }
    return _currentTimeLabel;
}

- (GKSliderView *)sliderView {
    if (!_sliderView) {
        _sliderView = [[GKSliderView alloc] init];
        _sliderView.sliderHeight = 2;
        _sliderView.sliderBtn.backgroundColor = UIColor.whiteColor;
        _sliderView.sliderBtn.layer.masksToBounds = YES;
        _sliderView.delegate = self;
        _sliderView.isSliderAllowTapped = NO;
        _sliderView.maximumTrackTintColor = UIColor.grayColor;
        _sliderView.minimumTrackTintColor = UIColor.whiteColor;
    }
    return _sliderView;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.font = [UIFont systemFontOfSize:14];
        _totalTimeLabel.textColor = UIColor.whiteColor;
        _totalTimeLabel.text = @"00:00";
    }
    return _totalTimeLabel;
}

@end
