//
//  GKAFLivePhotoManager+Extension.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2024/9/23.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import "GKAFLivePhotoManager+Extension.h"
#import <GKNavigationBar/GKNavigationBar.h>

@interface GKAFLivePhotoManager()<PHLivePhotoViewDelegate>

@property (nonatomic, strong) PHLivePhotoView *wxLivePhotoView;

@property (nonatomic, strong) UIView *wxMarkView;

@end

@implementation GKAFLivePhotoManager (Extension)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        gk_navigationBar_swizzled_instanceMethod(@"wx", GKAFLivePhotoManager.class, @"gk_updateFrame:", self);
        
    });
}

- (void)wx_gk_updateFrame:(CGRect)frame {
    self.livePhotoView.frame = frame;
    
    if (self.addMark) {
        CGRect markFrame = self.wxMarkView.frame;
        markFrame.size.height = 20;
        markFrame.origin.x = 15;
        markFrame.origin.y = frame.size.height - markFrame.size.height - 15;
        self.wxMarkView.frame = markFrame;
    }
}

static char kWxAddMark;
- (BOOL)addMark {
    return [objc_getAssociatedObject(self, &kWxAddMark) boolValue];
}

- (void)setAddMark:(BOOL)addMark {
    objc_setAssociatedObject(self, &kWxAddMark, @(addMark), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PHLivePhotoView *)livePhotoView {
    return self.wxLivePhotoView;
}

static char kWxLivePhotoViewKey;
- (PHLivePhotoView *)wxLivePhotoView {
    PHLivePhotoView *livePhotoView = objc_getAssociatedObject(self, &kWxLivePhotoViewKey);
    if (!livePhotoView) {
        livePhotoView = [[PHLivePhotoView alloc] init];
        livePhotoView.delegate = (id<PHLivePhotoViewDelegate>)self;
        livePhotoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if (self.browser.configure.isLivePhotoMutedPlay) {
            livePhotoView.muted = YES;
        }
        if (self.addMark) {
            [livePhotoView addSubview:self.wxMarkView];
        }
        objc_setAssociatedObject(self, &kWxLivePhotoViewKey, livePhotoView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return livePhotoView;
}

static char kWxMarkView;
- (UIView *)wxMarkView {
    UIView *markView = objc_getAssociatedObject(self, &kWxMarkView);
    if (!markView) {
        markView = [[UIView alloc] init];
        
        UIImage *image = nil;
        if (@available(iOS 13.0, *)) {
            image = [[UIImage systemImageNamed:@"livephoto"] imageWithTintColor:UIColor.whiteColor renderingMode:UIImageRenderingModeAlwaysOriginal];
        }else {
            image = [UIImage gk_changeImage:[UIImage gkbrowser_imageNamed:@"gk_photo_live"] color:UIColor.whiteColor];
        }
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [markView addSubview:imageView];
        imageView.frame = CGRectMake(0, 0, 20, 20);
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:13];
        label.text = @"实况";
        label.textColor = UIColor.whiteColor;
        [markView addSubview:label];
        [label sizeToFit];
        label.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, label.frame.size.width, 20);
        
        markView.frame = CGRectMake(0, 0, 20 + 5 + label.frame.size.width, 20);
        objc_setAssociatedObject(self, &kWxMarkView, markView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return markView;
}

- (void)setIsPlaying:(BOOL)isPlaying {
    self.wxMarkView.hidden = isPlaying;
}

@end
