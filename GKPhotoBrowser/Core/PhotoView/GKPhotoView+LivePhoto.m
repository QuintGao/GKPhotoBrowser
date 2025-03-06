//
//  GKPhotoView+LivePhoto.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2024/6/21.
//

#import "GKPhotoView+LivePhoto.h"
#import "GKPhotoBrowser.h"

@interface GKLivePhotoMarkView()

@property (nonatomic, strong) UIImageView *liveImgView;

@property (nonatomic, strong) UILabel *liveLabel;

@end

@implementation GKLivePhotoMarkView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.liveImgView];
    [self addSubview:self.liveLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.liveImgView.frame;
    frame.origin.x = 5;
    frame.origin.y = (self.frame.size.height - frame.size.height) / 2;
    self.liveImgView.frame = frame;
    
    frame = self.liveLabel.frame;
    frame.origin.x = CGRectGetMaxX(self.liveImgView.frame) + 5;
    frame.origin.y = (self.frame.size.height - frame.size.height) / 2;
    self.liveLabel.frame = frame;
}

#pragma mark - lazy
- (UIImageView *)liveImgView {
    if (!_liveImgView) {
        _liveImgView = [[UIImageView alloc] init];
        _liveImgView.image = GKPhotoBrowserImage(@"gk_photo_live");
        _liveImgView.tintColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_liveImgView sizeToFit];
    }
    return _liveImgView;
}

- (UILabel *)liveLabel {
    if (!_liveLabel) {
        _liveLabel = [[UILabel alloc] init];
        _liveLabel.font = [UIFont systemFontOfSize:14];
        _liveLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _liveLabel.text = @"LIVE";
        [_liveLabel sizeToFit];
    }
    return _liveLabel;
}

@end

@implementation GKPhotoView (LivePhoto)

- (void)showLiveLoading {
    if (!self.livePhoto) return;
    self.loadingView.hidden = YES;
    self.liveLoadingView.frame = self.bounds;
    [self addSubview:self.liveLoadingView];
    [self.liveLoadingView startLoading];
    if (self.configure.isShowLivePhotoMark) {
        [self addSubview:self.liveMarkView];
    }else {
        [self.liveMarkView removeFromSuperview];
    }
}

- (void)hideLiveLoading {
    if (!self.livePhoto) return;
    [self.liveLoadingView stopLoading];
}

- (void)showLiveFailure:(NSError *)error {
    if (!self.livePhoto) return;
}

- (void)liveDidScrollAppear {
    if (!self.livePhoto) return;
    if (!self.livePhoto.photo || self.livePhoto.photo != self.photo) {
        [self showLoading];
        __weak __typeof(self) weakSelf = self;
        if ([self.livePhoto respondsToSelector:@selector(setPhoto:)]) {
            self.livePhoto.photo = self.photo;
        }
        [self.livePhoto loadLivePhotoWithPhoto:self.photo targetSize:self.configure.liveTargetSize progressBlock:^(float progress) {
            __strong __typeof(weakSelf) self = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.liveLoadingView.progress = progress;
                if (progress >= 1.0) {
                    [self hideLoading];
                }
            });
        } completion:^(BOOL success) {
            __strong __typeof(weakSelf) self = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideLoading];
                if (success) {
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
    if (!self.livePhoto) return;
    if (!self.configure.isLivePhotoPausedWhenScrollBegan) return;
    [self.livePhoto gk_stop];
}

- (void)liveDidScrollDisappear {
    if (!self.livePhoto) return;
    [self.livePhoto gk_stop];
}

- (void)liveDidDismissAppear {
    if (!self.livePhoto) return;
    if (!self.configure.isShowLivePhotoMark) return;
    self.liveMarkView.hidden = NO;
}

- (void)liveWillDismissDisappear {
    if (!self.livePhoto) return;
    if (self.configure.isLivePhotoPausedWhenDragged) {
        [self.livePhoto gk_stop];
    }
    if (!self.configure.isShowLivePhotoMark) return;
    self.liveMarkView.hidden = YES;
}

- (void)liveDidDismissDisappear {
    if (!self.livePhoto) return;
    [self.livePhoto gk_stop];
    if (self.configure.isClearMemoryForLivePhoto && [self.livePhoto respondsToSelector:@selector(gk_clear)]) {
        [self.livePhoto gk_clear];
    }
}

- (void)liveUpdateFrame {
    if (!self.livePhoto) return;
    if (self.livePhoto.photo != self.photo) return;
    if (self.livePhoto.livePhotoView.superview != self.imageView) {
        [self.imageView addSubview:self.livePhoto.livePhotoView];
        self.imageView.userInteractionEnabled = YES;
    }
    [self.imageView bringSubviewToFront:self.livePhoto.livePhotoView];
    [self.livePhoto gk_updateFrame:self.imageView.bounds];
    if (self.liveMarkView.superview) {
        CGFloat x = 10;
        CGFloat y = CGRectGetMinY(self.imageView.frame) + 10;
        CGFloat w = 64;
        CGFloat h = 20;
        self.liveMarkView.frame = CGRectMake(x, y, w, h);
        
        if (self.imageView.frame.size.height > (self.frame.size.height - kSafeTopSpace - kSafeBottomSpace)) {
            CGPoint center = self.liveMarkView.center;
            center.y = (KIsiPhoneX && !self.livePhoto.browser.isLandscape) ? (kSafeTopSpace + 10) : 30;
            self.liveMarkView.center = center;
        }
    }
}

@end
