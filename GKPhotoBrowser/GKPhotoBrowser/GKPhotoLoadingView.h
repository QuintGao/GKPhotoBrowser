//
//  GKPhotoLoadingView.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/23.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#define kMinProgress 0.0001

#import <UIKit/UIKit.h>

@interface GKPhotoLoadingView : UIView

@property (nonatomic, assign) float progress;

- (void)showLoading;
- (void)showFailure;

@end

@interface GKPhotoProgressView: UIView

@property (nonatomic, assign) float progress;

@property (nonatomic, strong) UIColor *trackTintColor;
@property (nonatomic, strong) UIColor *progressTintColor;

@end
