//
//  GKTopView.h
//  GKPhotoBrowserDemo
//
//  Created by gaokun on 2018/8/14.
//  Copyright © 2018年 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GKTopView : UIView
// type 0: SDAutoLayout  1: Masonry
- (instancetype)initWithType:(NSInteger)type;

- (void)setupCurrent:(NSInteger)current total:(NSInteger)total;

@end
