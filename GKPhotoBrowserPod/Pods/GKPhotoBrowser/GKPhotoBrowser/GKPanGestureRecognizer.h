//
//  GKPanGestureRecognizer.h
//  GKPhotoBrowserDemo
//
//  Created by gaokun on 2019/8/15.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GKPanGestureRecognizerDirection) {
    GKPanGestureRecognizerDirectionVertical,
    GKPanGestureRecognizerDirectionHorizontal
};

@interface GKPanGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic, assign) GKPanGestureRecognizerDirection   direction;

@end

NS_ASSUME_NONNULL_END
