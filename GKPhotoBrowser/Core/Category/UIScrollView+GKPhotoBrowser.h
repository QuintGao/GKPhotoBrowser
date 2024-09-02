//
//  UIScrollView+GKPhotoBrowser.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/10.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (GKPhotoBrowser)

/**
 * 是否启用手势处理功能，默认为NO
 * 为了防止与APP中其他UIScrollview滑动的冲突，默认设置为NO，需要时设置为YES即可
 */
@property (nonatomic, assign) BOOL gk_gestureHandleEnabled;

@end
