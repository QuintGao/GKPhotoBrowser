//
//  GKPhotoLoadingView.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/23.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#define kDegreeToRadian(x) (M_PI / 180.0 * (x))

#import "GKPhotoLoadingView.h"

@interface GKPhotoLoadingView()
{
    UILabel *_failureLabel;
    GKPhotoProgressView *_progressView;
}

@end

@implementation GKPhotoLoadingView

- (void)showLoading {
    [_failureLabel removeFromSuperview];
    
    if (_progressView == nil) {
        _progressView = [GKPhotoProgressView new];
        _progressView.bounds = CGRectMake(0, 0, 60, 60);
        _progressView.center = self.center;
    }
    _progressView.progress = kMinProgress;
    [self addSubview:_progressView];
}

- (void)showFailure {
    [_progressView removeFromSuperview];
    
    if (_failureLabel == nil) {
        _failureLabel                  = [UILabel new];
        _failureLabel.bounds           = CGRectMake(0, 0, self.bounds.size.width, 44);
        _failureLabel.textAlignment    = NSTextAlignmentCenter;
        _failureLabel.center           = self.center;
        _failureLabel.text             = @"加载失败！";
        _failureLabel.font             = [UIFont boldSystemFontOfSize:20.0];
        _failureLabel.textColor        = [UIColor whiteColor];
        _failureLabel.backgroundColor  = [UIColor clearColor];
        _failureLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    [self addSubview:_failureLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _progressView.center = self.center;
    _failureLabel.center = self.center;
}

#pragma mark - Customlize Method
- (void)setProgress:(float)progress {
    _progress = progress;
    _progressView.progress = progress;
    if (progress >= 1.0) {
        [_progressView removeFromSuperview];
    }
}

@end

@implementation GKPhotoProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGPoint centerPoint = CGPointMake(rect.size.height * 0.5, rect.size.width * 0.5);
    CGFloat radius = MIN(rect.size.height, rect.size.width) * 0.5;
    
    CGFloat pathWidth = radius * 0.3f;
    
    CGFloat radians = kDegreeToRadian((_progress * 359.9) - 90);
    CGFloat xOffset = radius * (1 + 0.85 * cosf(radians));
    CGFloat yOffset = radius * (1 + 0.85 * sinf(radians));
    CGPoint endPoint = CGPointMake(xOffset, yOffset);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.trackTintColor setFill];
    CGMutablePathRef trackPath = CGPathCreateMutable();
    CGPathMoveToPoint(trackPath, NULL, centerPoint.x, centerPoint.y);
    CGPathAddArc(trackPath, NULL, centerPoint.x, centerPoint.y, radius, kDegreeToRadian(270), kDegreeToRadian(-90), NO);
    CGPathCloseSubpath(trackPath);
    CGContextAddPath(context, trackPath);
    CGContextFillPath(context);
    CGPathRelease(trackPath);
    
    [self.progressTintColor setFill];
    CGMutablePathRef progressPath = CGPathCreateMutable();
    CGPathMoveToPoint(progressPath, NULL, centerPoint.x, centerPoint.y);
    CGPathAddArc(progressPath, NULL, centerPoint.x, centerPoint.y, radius, kDegreeToRadian(270), radians, NO);
    CGPathCloseSubpath(progressPath);
    CGContextAddPath(context, progressPath);
    CGContextFillPath(context);
    CGPathRelease(progressPath);
    
    CGContextAddEllipseInRect(context, CGRectMake(centerPoint.x - pathWidth * 0.5, 0, pathWidth, pathWidth));
    CGContextFillPath(context);
    
    CGContextAddEllipseInRect(context, CGRectMake(endPoint.x - pathWidth * 0.5, endPoint.y - pathWidth * 0.5, pathWidth, pathWidth));
    CGContextFillPath(context);
    
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGFloat innerRadius = radius * 0.7;
    CGPoint newCenterPoint = CGPointMake(centerPoint.x - innerRadius, centerPoint.y - innerRadius);
    CGContextAddEllipseInRect(context, CGRectMake(newCenterPoint.x, newCenterPoint.y, innerRadius * 2, innerRadius * 2));
    CGContextFillPath(context);
}

#pragma mark - Property Methods
- (UIColor *)trackTintColor {
    if (!_trackTintColor) {
        _trackTintColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
    }
    return _trackTintColor;
}

- (UIColor *)progressTintColor {
    if (!_progressTintColor) {
        _progressTintColor = [UIColor whiteColor];
    }
    return _progressTintColor;
}

- (void)setProgress:(float)progress {
    _progress = progress;
    
    [self setNeedsDisplay];
}

@end
