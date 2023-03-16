//
//  ZFLandscapeRotationManager.h
//  ZFPlayer
//
// Copyright (c) 2020年 任子丰 ( http://github.com/renzifeng )
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

#import <Foundation/Foundation.h>
#import "ZFOrientationObserver.h"
#import "ZFLandscapeWindow.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFLandscapeRotationManager : NSObject

/// The block invoked When player will rotate.
@property (nonatomic, copy, nullable) void(^orientationWillChange)(UIInterfaceOrientation orientation);

/// The block invoked when player rotated.
@property (nonatomic, copy, nullable) void(^orientationDidChanged)(UIInterfaceOrientation orientation);

@property (nonatomic, weak) UIView *contentView;

@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, strong, nullable) ZFLandscapeWindow *window;

/// Whether allow the video orientation rotate.
/// default is YES.
@property (nonatomic, assign) BOOL allowOrientationRotation;

/// Lock screen orientation
@property (nonatomic, getter=isLockedScreen) BOOL lockedScreen;

@property (nonatomic, assign) BOOL disableAnimations;

/// The support Interface Orientation,default is ZFInterfaceOrientationMaskAllButUpsideDown
@property (nonatomic, assign) ZFInterfaceOrientationMask supportInterfaceOrientation;

/// The current orientation of the player.
/// Default is UIInterfaceOrientationPortrait.
@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;

@property (nonatomic, strong, readonly, nullable) ZFLandscapeViewController *landscapeViewController;

/// current device orientation observer is activie.
@property (nonatomic, assign) BOOL activeDeviceObserver;

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation completion:(void(^ __nullable)(void))completion;

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated;

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated completion:(void(^ __nullable)(void))completion;

- (UIInterfaceOrientation)getCurrentOrientation;

- (void)handleDeviceOrientationChange;

/// update the rotateView and containerView.
- (void)updateRotateView:(ZFPlayerView *)rotateView
           containerView:(UIView *)containerView;

- (BOOL)isSuppprtInterfaceOrientation:(UIInterfaceOrientation)orientation;

+ (ZFInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window;

@end

NS_ASSUME_NONNULL_END
