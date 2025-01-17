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

#import "SJVideoPlayer.h"
#import "SJVideoPlayerConfigurations.h"
#import "SJControlLayerIdentifiers.h"
#import "SJItemTags.h"
#import "SJVideoPlayerLocalizedStringKeys.h"
#import "SJDraggingObservation.h"
#import "SJDraggingProgressPopupView.h"
#import "SJFullscreenModeStatusBar.h"
#import "SJLoadingView.h"
#import "SJScrollingTextMarqueeView.h"
#import "SJSpeedupPlaybackPopupView.h"
#import "SJVideoPlayerURLAsset+SJControlAdd.h"
#import "SJControlLayerDefines.h"
#import "SJDraggingObservationDefines.h"
#import "SJDraggingProgressPopupViewDefines.h"
#import "SJFullscreenModeStatusBarDefines.h"
#import "SJLoadingViewDefines.h"
#import "SJScrollingTextMarqueeViewDefines.h"
#import "SJSpeedupPlaybackPopupViewDefines.h"
#import "SJVideoPlayerClipsDefines.h"
#import "UIView+SJAnimationAdded.h"
#import "SJEdgeControlButtonItem.h"
#import "SJEdgeControlButtonItemAdapter.h"
#import "SJEdgeControlButtonItemAdapterLayout.h"
#import "SJEdgeControlButtonItemInternal.h"
#import "SJEdgeControlButtonItemView.h"
#import "SJEdgeControlLayerAdapters.h"
#import "SJButtonProgressSlider.h"
#import "SJCommonProgressSlider.h"
#import "SJProgressSlider.h"
#import "SJVideoPlayerControlMaskView.h"
#import "SJControlLayerSwitcher.h"
#import "SJClipsGIFRecordsControlLayer.h"
#import "SJClipsResultsControlLayer.h"
#import "SJClipsVideoRecordsControlLayer.h"
#import "SJClipsResultShareItem.h"
#import "SJClipsSaveResultToAlbumHandler.h"
#import "SJVideoPlayerClipsConfig.h"
#import "SJVideoPlayerClipsGeneratedResult.h"
#import "SJVideoPlayerClipsParameters.h"
#import "SJClipsBackButton.h"
#import "SJClipsButtonContainerView.h"
#import "SJClipsCommonViewLayer.h"
#import "SJClipsGIFCountDownView.h"
#import "SJClipsResultShareItemsContainerView.h"
#import "SJClipsVideoCountDownView.h"
#import "SJClipsControlLayer.h"
#import "SJEdgeControlLayer.h"
#import "SJLoadFailedControlLayer.h"
#import "SJMoreSettingControlLayer.h"
#import "SJNotReachableControlLayer.h"
#import "SJSmallViewControlLayer.h"
#import "SJVideoDefinitionSwitchingControlLayer.h"
#import "SJVideoPlayerURLAsset+SJExtendedDefinition.h"
#import "SJVideoPlayerResourceLoader.h"

FOUNDATION_EXPORT double SJVideoPlayerVersionNumber;
FOUNDATION_EXPORT const unsigned char SJVideoPlayerVersionString[];

