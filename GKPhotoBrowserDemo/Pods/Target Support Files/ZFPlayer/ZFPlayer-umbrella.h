#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ZFAVPlayerManager.h"
#import "UIScrollView+ZFPlayer.h"
#import "ZFFloatView.h"
#import "ZFKVOController.h"
#import "ZFLandscapeRotationManager.h"
#import "ZFLandscapeRotationManager_iOS15.h"
#import "ZFLandscapeRotationManager_iOS16.h"
#import "ZFLandscapeViewController.h"
#import "ZFLandscapeViewController_iOS15.h"
#import "ZFLandscapeWindow.h"
#import "ZFOrientationObserver.h"
#import "ZFPersentInteractiveTransition.h"
#import "ZFPlayer.h"
#import "ZFPlayerConst.h"
#import "ZFPlayerController.h"
#import "ZFPlayerGestureControl.h"
#import "ZFPlayerLogManager.h"
#import "ZFPlayerMediaControl.h"
#import "ZFPlayerMediaPlayback.h"
#import "ZFPlayerNotification.h"
#import "ZFPlayerView.h"
#import "ZFPortraitViewController.h"
#import "ZFPresentTransition.h"
#import "ZFReachabilityManager.h"

FOUNDATION_EXPORT double ZFPlayerVersionNumber;
FOUNDATION_EXPORT const unsigned char ZFPlayerVersionString[];

