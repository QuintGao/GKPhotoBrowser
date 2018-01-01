//
//  UIView+GKExtension.m
//  GKCoverDemo
//
//  Created by 高坤 on 16/8/24.
//  Copyright © 2016年 高坤. All rights reserved.
//

#import "UIView+GKExtension.h"

@implementation UIView (GKExtension)

- (void)setGk_width:(CGFloat)gk_width
{
    CGRect rect = self.frame;
    rect.size.width = gk_width;
    self.frame = rect;
}

- (CGFloat)gk_width
{
    return self.frame.size.width;
}

- (void)setGk_height:(CGFloat)gk_height
{
    CGRect rect = self.frame;
    rect.size.height = gk_height;
    self.frame = rect;
}

- (CGFloat)gk_height
{
    return self.frame.size.height;
}

- (void)setGk_x:(CGFloat)gk_x
{
    CGRect rect = self.frame;
    rect.origin.x = gk_x;
    self.frame = rect;
}

- (CGFloat)gk_x
{
    return self.frame.origin.x;
}

- (void)setGk_y:(CGFloat)gk_y
{
    CGRect rect = self.frame;
    rect.origin.y = gk_y;
    self.frame = rect;
}

- (CGFloat)gk_y
{
    return self.frame.origin.y;
}

- (void)setGk_right:(CGFloat)gk_right
{
    CGRect rect = self.frame;
    rect.origin.x = gk_right - rect.size.width;
    self.frame = rect;
}

- (CGFloat)gk_right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setGk_bottom:(CGFloat)gk_bottom
{
    CGRect rect = self.frame;
    rect.origin.y = gk_bottom - rect.size.height;
    self.frame = rect;
}

- (CGFloat)gk_bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setGk_centerX:(CGFloat)gk_centerX
{
    CGPoint center = self.center;
    center.x = gk_centerX;
    self.center = center;
}

- (CGFloat)gk_centerX
{
    return self.center.x;
}

- (void)setGk_centerY:(CGFloat)gk_centerY
{
    CGPoint center = self.center;
    center.y = gk_centerY;
    self.center = center;
}

- (CGFloat)gk_centerY
{
    return self.center.y;
}

- (void)setGk_size:(CGSize)gk_size
{
    CGRect rect = self.frame;
    rect.size = gk_size;
    self.frame = rect;
}

- (CGSize)gk_size
{
    return self.frame.size;
}

+ (instancetype)gk_viewFromXib
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}

@end
