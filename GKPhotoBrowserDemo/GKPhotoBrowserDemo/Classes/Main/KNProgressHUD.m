//
//  KNProgressHUD.m
//  KNPhotoBrowser
//
//  Created by LuKane on 16/8/17.
//  Copyright © 2016年 LuKane. All rights reserved.
//

#import "KNProgressHUD.h"

@interface KNProgressHUD()

@property (nonatomic, strong) CAShapeLayer *sectorLayer;
@property (nonatomic, strong) CAShapeLayer *loadingLayer;
@property (nonatomic, strong) CAShapeLayer *sharpLayer;

@end

@implementation KNProgressHUD

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    [self setupSectorLayer];
    [self setupLoadingLayer];
    [self setupSharpLayer:rect];
}

// layer of sector
- (void)setupSectorLayer{
    self.sectorLayer= [CAShapeLayer layer];
    [self.sectorLayer setFillColor:UIColor.clearColor.CGColor];
    [self.sectorLayer setLineWidth:1.f];
    [self.sectorLayer setStrokeColor:[UIColor whiteColor].CGColor];
    [self.sectorLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:[self bounds]] CGPath]];
    [self.sectorLayer setHidden:YES];
    [self.layer addSublayer:self.sectorLayer];
}

// loading
- (void)setupLoadingLayer{
    self.loadingLayer = [CAShapeLayer layer];
    [self.loadingLayer setFrame:[self bounds]];
    [self.loadingLayer setAnchorPoint:CGPointMake(0.5f, 0.5f)];
    [self.loadingLayer setFillColor:UIColor.clearColor.CGColor];
    [self.loadingLayer setLineWidth:1.f];
    [self.loadingLayer setStrokeColor:[[UIColor whiteColor] CGColor]];
    
    CGPoint center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    CGFloat loadRadius = self.bounds.size.width * 0.5;
    CGFloat endAngle = (2 * (float)M_PI) - ((float)M_PI / 8);
    
    self.loadingLayer.path = [UIBezierPath bezierPathWithArcCenter:center
                                                            radius:loadRadius
                                                        startAngle:0
                                                          endAngle:endAngle
                                                         clockwise:YES].CGPath;
    
    CABasicAnimation   *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [rotationAnimation setToValue:[NSNumber numberWithFloat:M_PI * 2.0]];
    [rotationAnimation setDuration:1.f];
    [rotationAnimation setCumulative:YES];
    [rotationAnimation setRepeatCount:HUGE_VALF];
    [self.loadingLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    [self.layer addSublayer:self.loadingLayer];
}

// sector
- (void)setupSharpLayer:(CGRect)rect{
    CGFloat minSide = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect));
    CGFloat radius  = minSide/2 - 3;
    
    self.sharpLayer = [CAShapeLayer layer];
    [self.sharpLayer setFrame:[self bounds]];
    [self.sharpLayer setAnchorPoint:CGPointMake(0.5f, 0.5f)];
    [self.sharpLayer setFillColor:[[UIColor clearColor] CGColor]];
    [self.sharpLayer setStrokeColor:[[UIColor whiteColor] CGColor]];
    [self.sharpLayer setLineWidth:radius];
    
    [self.sharpLayer setStrokeStart:0];
    [self.sharpLayer setStrokeEnd:0];
    
    CGRect pathRect = CGRectMake(CGRectGetWidth(self.bounds)/2 - radius/2, CGRectGetHeight(self.bounds)/2 - radius/2, radius, radius);
    [self.sharpLayer setPath:[[UIBezierPath bezierPathWithRoundedRect:pathRect cornerRadius:radius] CGPath]];
    [self.layer addSublayer:self.sharpLayer];
}

// progress
- (void)setProgress:(CGFloat)progress{
    progress = MAX(0.0f, progress);
    progress = MIN(1.0f, progress);
    
    if (progress > 0) {
        [self.loadingLayer removeAllAnimations];
        self.sectorLayer.hidden = false;
        [self.loadingLayer removeFromSuperlayer];
    }
    
    if (progress != _progress) {
        self.sharpLayer.strokeEnd = progress;
        _progress = progress;
    }
    
    if (progress >= 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setHidden:true];
        });
    }
}

@end
