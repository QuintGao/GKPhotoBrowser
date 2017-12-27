//
//  UIView+GKExtension.h
//  GKCoverDemo
//
//  Created by 高坤 on 16/8/24.
//  Copyright © 2016年 高坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (GKExtension)

@property CGFloat gk_width;
@property CGFloat gk_height;
@property CGFloat gk_x;
@property CGFloat gk_y;
@property CGFloat gk_right;
@property CGFloat gk_bottom;
@property CGFloat gk_centerX;
@property CGFloat gk_centerY;
@property CGSize  gk_size;

+ (instancetype)gk_viewFromXib;

@end
