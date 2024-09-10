//
//  GKPhotoGestureHandler.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2023/3/2.
//

#import "GKPhotoBrowserHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKPanGestureRecognizer : UIPanGestureRecognizer
@end

@class GKPhotoBrowser;

@protocol GKPhotoGestureDelegate <NSObject>

// 浏览器将要消失
- (void)browserWillDisappear;

// 浏览器取消消失
- (void)browserCancelDisappear;

// 浏览器已经消失
- (void)browserDidDisappear;

@end

@interface GKPhotoGestureHandler : GKPhotoBrowserHandler

@property (nonatomic, weak) id<GKPhotoGestureDelegate> delegate;

@property (nonatomic, strong) UITapGestureRecognizer *singleTapGesture;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) GKPanGestureRecognizer *panGesture;

@property (nonatomic, assign) BOOL isClickDismiss;
@property (nonatomic, assign) BOOL isPanBegan;

- (void)addGestureRecognizer;
- (void)addPanGesture:(BOOL)isFirst;
- (void)removePanGesture;

@end

NS_ASSUME_NONNULL_END
