//
//  GKPhotoRotationHandler.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2023/3/2.
//

#import "GKPhotoBrowserHandler.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GKPhotoRotationDelegate <NSObject>

/// 即将旋转
- (void)willRotation:(BOOL)isLandscape;

/// 已经旋转
- (void)didRotation:(BOOL)isLandscape;

@end

@class GKPhotoBrowser;

@interface GKPhotoRotationHandler : GKPhotoBrowserHandler

@property (nonatomic, weak) id<GKPhotoRotationDelegate> delegate;

@property (nonatomic, assign) BOOL isRotation;
@property (nonatomic, assign) BOOL isLandscape;

@property (nonatomic, assign) UIDeviceOrientation originalOrientation;
@property (nonatomic, assign) UIDeviceOrientation currentOrientation;

- (void)addDeviceOrientationObserver;
- (void)delDeviceOrientationObserver;
- (void)deviceOrientationDidChange;

- (void)handleSystemRotation;

@end

NS_ASSUME_NONNULL_END
