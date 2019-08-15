//
//  GKPanGestureRecognizer.m
//  GKPhotoBrowserDemo
//
//  Created by gaokun on 2019/8/15.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKPanGestureRecognizer.h"

int const static kDirectionPanThreshold = 5;

@interface GKPanGestureRecognizer()

@property (nonatomic, assign) BOOL isDrag;

@property (nonatomic, assign) int   moveX;

@property (nonatomic, assign) int   moveY;

@end

@implementation GKPanGestureRecognizer

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint nowPoint = [[touches anyObject] locationInView:self.view];
    CGPoint prevPoint = [[touches anyObject] previousLocationInView:self.view];
    _moveX += prevPoint.x - nowPoint.x;
    _moveY += prevPoint.y - nowPoint.y;
    if (!self.isDrag) {
        if (abs(_moveX) > kDirectionPanThreshold) {
            if (_direction == GKPanGestureRecognizerDirectionVertical) {
                self.state = UIGestureRecognizerStateFailed;
            }else {
                _isDrag = YES;
            }
        }else if (abs(_moveY) > kDirectionPanThreshold) {
            if (_direction == GKPanGestureRecognizerDirectionHorizontal) {
                self.state = UIGestureRecognizerStateFailed;
            }else {
                _isDrag = YES;
            }
        }
    }
}

- (void)reset {
    [super reset];
    _isDrag = NO;
    _moveX = 0;
    _moveY = 0;
}

@end
