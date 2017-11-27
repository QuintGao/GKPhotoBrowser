//
//  UIScrollView+GKCategory.h
//  GKNavigationBarViewControllerDemo
//
//  Created by QuintGao on 2017/7/11.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (GKCategory)

/** 是否解除对手势冲突的处理，默认是NO */
@property (nonatomic, assign) BOOL gk_gestureHandleDisabled;

@end
