//
//  GKPhotoSwipeRightTransition.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2024/9/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GKPhotoBrowser;

@interface GKPhotoSwipeRightTransition : UIPercentDrivenInteractiveTransition<UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) GKPhotoBrowser *browser;

@end

NS_ASSUME_NONNULL_END
