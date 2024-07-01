//
//  GKPhotoView+Video.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2024/6/21.
//

#import "GKPhotoView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKPhotoView (Video)

- (void)videoPlay;
- (void)videoPause;

- (void)showVideoLoading;
- (void)hideVideoLoading;
- (void)showVideoFailure:(NSError *)error;
- (void)showVideoPlayBtn;

// 左右滑动
- (void)videoDidScrollAppear;
- (void)videoWillScrollDisappear;
- (void)videoDidScrollDisappear;

// 隐藏滑动
- (void)videoDidDismissAppear;
- (void)videoWillDismissDisappear;
- (void)videoDidDismissDisappear;

- (void)videoUpdateFrame;

@end

NS_ASSUME_NONNULL_END
