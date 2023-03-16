//
//  ZFFloatView.m
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

#import "ZFFloatView.h"

@implementation ZFFloatView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initilize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initilize];
    }
    return self;
}

- (void)initilize {
    self.safeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doMoveAction:)];
    [self addGestureRecognizer:panGestureRecognizer];
}

- (void)setParentView:(UIView *)parentView {
    _parentView = parentView;
    [parentView addSubview:self];
}

#pragma mark - Action

- (void)doMoveAction:(UIPanGestureRecognizer *)recognizer {
    /// The position where the gesture is moving in the self.view.
    CGPoint translation = [recognizer translationInView:self.parentView];
    CGPoint newCenter = CGPointMake(recognizer.view.center.x + translation.x,
                                    recognizer.view.center.y + translation.y);
    
    // Limited screen range:
    // Top margin limit.
    newCenter.y = MAX(recognizer.view.frame.size.height/2 + self.safeInsets.top, newCenter.y);
    
    // Bottom margin limit.
    newCenter.y = MIN(self.parentView.frame.size.height - self.safeInsets.bottom - recognizer.view.frame.size.height/2, newCenter.y);
    
    // Left margin limit.
    newCenter.x = MAX(recognizer.view.frame.size.width/2, newCenter.x);
    
    // Right margin limit.
    newCenter.x = MIN(self.parentView.frame.size.width - recognizer.view.frame.size.width/2,newCenter.x);
    
    // Set the center point.
    recognizer.view.center = newCenter;
    
    // Set the gesture coordinates to 0, otherwise it will add up.
    [recognizer setTranslation:CGPointZero inView:self.parentView];
}


@end
