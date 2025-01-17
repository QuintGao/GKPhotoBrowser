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

#import "GKAFLivePhotoManager.h"
#import "GKAVPlayerManager.h"
#import "GKPhotoBrowser.h"
#import "GKPhotoBrowserConfigure.h"
#import "GKPhotoBrowserDelegate.h"
#import "GKPhotoBrowserHandler.h"
#import "GKPhotoGestureHandler.h"
#import "GKPhotoRotationHandler.h"
#import "UIDevice+GKPhotoBrowser.h"
#import "UIImage+GKPhotoBrowser.h"
#import "UIScrollView+GKPhotoBrowser.h"
#import "GKLoadingView.h"
#import "GKPhoto.h"
#import "GKPhotoView+Image.h"
#import "GKPhotoView+LivePhoto.h"
#import "GKPhotoView+Video.h"
#import "GKPhotoView.h"
#import "GKCoverViewProtocol.h"
#import "GKLivePhotoProtocol.h"
#import "GKProgressViewProtocol.h"
#import "GKVideoPlayerProtocol.h"
#import "GKWebImageProtocol.h"
#import "GKDefaultCoverView.h"
#import "GKProgressView.h"
#import "GKSDWebImageManager.h"
#import "GKSJPlayerManager.h"
#import "GKYYWebImageManager.h"

FOUNDATION_EXPORT double GKPhotoBrowserVersionNumber;
FOUNDATION_EXPORT const unsigned char GKPhotoBrowserVersionString[];

