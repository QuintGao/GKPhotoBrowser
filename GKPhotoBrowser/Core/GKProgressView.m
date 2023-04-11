//
//  GKProgressView.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2023/3/1.
//

#import "GKProgressView.h"
#import <GKSliderView/GKSliderView.h>

@interface GKProgressView()<GKSliderViewDelegate>

@property (nonatomic, strong) UILabel *currentLabel;

@property (nonatomic, strong) GKSliderView *sliderView;

@property (nonatomic, strong) UILabel *totalLabel;

@property (nonatomic, assign) NSTimeInterval totalTime;

@property (nonatomic, assign) BOOL isSeeking;

@end

@implementation GKProgressView

- (instancetype)init {
    if (self = [super init]) {
        [self initUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.currentLabel sizeToFit];
    [self.totalLabel sizeToFit];
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = 0;
    CGFloat h = self.bounds.size.height;
    CGFloat totalW = self.bounds.size.width;
    CGFloat margin = 5;
    
    w = self.currentLabel.frame.size.width;
    self.currentLabel.frame = CGRectMake(x, y, w, h);
    
    w = self.totalLabel.frame.size.width;
    x = totalW - w;
    self.totalLabel.frame = CGRectMake(x, y, w, h);
    
    x = CGRectGetWidth(self.currentLabel.frame) + margin;
    w = totalW - x - margin - CGRectGetWidth(self.totalLabel.frame);
    self.sliderView.frame = CGRectMake(x, y, w, h);
}

#pragma mark - Public
- (void)updateCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    if (self.isSeeking) return;
    self.totalTime = totalTime;
    CGFloat progress = 0;
    if (totalTime == 0) {
        progress = 0;
    }else {
        progress = currentTime / totalTime;
    }
    if (progress <= 0) progress = 0;
    if (progress >= 1) progress = 1;
    self.sliderView.value = progress;
    self.currentLabel.text = [self convertTimeSecond:currentTime];
    self.totalLabel.text = [self convertTimeSecond:totalTime];
}

#pragma mark - GKSliderViewDelegate
- (void)sliderView:(GKSliderView *)sliderView touchBegan:(float)value {
    [self showLargeSlider];
    self.isSeeking = YES;
}

- (void)sliderView:(GKSliderView *)sliderView touchEnded:(float)value {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showSmallSlider) object:nil];
    [self performSelector:@selector(showSmallSlider) withObject:nil afterDelay:3.0f];
    
    if (!self.player) return;
    __weak __typeof(self) weakSelf = self;
    [self.player gk_seekToTime:self.totalTime * value completionHandler:^(BOOL finished) {
        __strong __typeof(weakSelf) self = weakSelf;
        self.isSeeking = NO;
    }];
}

#pragma mark - Private
- (void)initUI {
    [self addSubview:self.currentLabel];
    [self addSubview:self.sliderView];
    [self addSubview:self.totalLabel];
    [self showSmallSlider];
}

- (void)showSmallSlider {
    CGRect frame = self.sliderView.sliderBtn.frame;
    frame.size = CGSizeMake(6, 6);
    self.sliderView.sliderBtn.frame = frame;
    self.sliderView.sliderBtn.layer.cornerRadius = 3;
    self.currentLabel.hidden = YES;
    self.totalLabel.hidden = YES;
}

- (void)showLargeSlider {
    CGRect frame = self.sliderView.sliderBtn.frame;
    frame.size = CGSizeMake(20, 20);
    self.sliderView.sliderBtn.frame = frame;
    self.sliderView.sliderBtn.layer.cornerRadius = 10;
    self.currentLabel.hidden = NO;
    self.totalLabel.hidden = NO;
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

#pragma mark - Lazy
- (UILabel *)currentLabel {
    if (!_currentLabel) {
        _currentLabel = [[UILabel alloc] init];
        _currentLabel.font = [UIFont systemFontOfSize:14];
        _currentLabel.textColor = UIColor.whiteColor;
        _currentLabel.text = @"00:00";
    }
    return _currentLabel;
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

- (UILabel *)totalLabel {
    if (!_totalLabel) {
        _totalLabel = [[UILabel alloc] init];
        _totalLabel.font = [UIFont systemFontOfSize:14];
        _totalLabel.textColor = UIColor.whiteColor;
        _totalLabel.text = @"00:00";
    }
    return _totalLabel;
}

@end
