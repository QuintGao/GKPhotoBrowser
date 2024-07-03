//
//  GKPhotoView+LivePhoto.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2024/6/21.
//

#import "GKPhotoView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKLivePhotoMarkView: UIView
@end

@interface GKPhotoView (LivePhoto)

- (void)showLiveLoading;
- (void)hideLiveLoading;
- (void)showLiveFailure:(NSError *)error;

// 左右滑动
- (void)liveDidScrollAppear;
- (void)liveWillScrollDisappear;
- (void)liveDidScrollDisappear;

// 隐藏滑动
- (void)liveDidDismissAppear;
- (void)liveWillDismissDisappear;
- (void)liveDidDismissDisappear;

- (void)liveUpdateFrame;

@end

NS_ASSUME_NONNULL_END
