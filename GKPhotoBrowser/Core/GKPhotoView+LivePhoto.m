//
//  GKPhotoView+LivePhoto.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2024/6/21.
//

#import "GKPhotoView+LivePhoto.h"

@implementation GKPhotoView (LivePhoto)

- (void)showLiveLoading {
    if (!self.photo.isLivePhoto) return;
    if (!self.livePhoto) return;
    self.loadingView.hidden = YES;
    self.liveLoadingView.frame = self.bounds;
    [self addSubview:self.liveLoadingView];
    [self.liveLoadingView startLoading];
}

- (void)hideLiveLoading {
    if (!self.photo.isLivePhoto) return;
    if (!self.livePhoto) return;
    [self.liveLoadingView stopLoading];
}

- (void)showLiveFailure:(NSError *)error {
    if (!self.photo.isLivePhoto) return;
    if (!self.livePhoto) return;
}

- (void)liveDidScrollAppear {
    if (!self.photo.isLivePhoto) return;
    if (!self.livePhoto) return;
    if (!self.livePhoto.photo || self.livePhoto.photo != self.photo) {
        [self showLoading];
        __weak __typeof(self) weakSelf = self;
        [self.livePhoto loadLivePhotoWithPhoto:self.photo targetSize:self.imageView.frame.size progressBlock:^(float progress) {
            __strong __typeof(weakSelf) self = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.liveLoadingView.progress = progress;
            });
        } completion:^(BOOL success) {
            __strong __typeof(weakSelf) self = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideLoading];
                if (success) {
                    self.imageView.userInteractionEnabled = YES;
                    [self.imageView addSubview:self.livePhoto.livePhotoView];
                    [self adjustFrame];
                    [self.livePhoto gk_play];
                }
            });
        }];
    }else {
        [self.livePhoto gk_play];
    }
}

- (void)liveWillScrollDisappear {
    if (!self.photo.isLivePhoto) return;
    if (!self.livePhoto) return;
}

- (void)liveDidScrollDisappear {
    if (!self.photo.isLivePhoto) return;
    if (!self.livePhoto) return;
//    [self.livePhoto gk_stop];
}

- (void)liveDidDismissAppear {
    if (!self.photo.isLivePhoto) return;
    if (!self.livePhoto) return;
}

- (void)liveWillDismissDisappear {
    if (!self.photo.isLivePhoto) return;
    if (!self.livePhoto) return;
    [self.livePhoto gk_stop];
}

- (void)liveDidDismissDisappear {
    if (!self.photo.isLivePhoto) return;
    if (!self.livePhoto) return;
    [self.livePhoto gk_stop];
    [self.livePhoto gk_clear];
}

- (void)liveUpdateFrame {
    if (!self.photo.isLivePhoto) return;
    if (!self.livePhoto) return;
    [self.livePhoto gk_updateFrame:self.imageView.bounds];
}

@end
