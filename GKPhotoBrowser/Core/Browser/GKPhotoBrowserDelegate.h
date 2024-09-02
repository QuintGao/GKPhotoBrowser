//
//  GKPhotoBrowserDelegate.h
//  Pods
//
//  Created by QuintGao on 2024/8/30.
//

#import <UIKit/UIKit.h>

@class GKPhotoBrowser;

@protocol GKPhotoBrowserDelegate<NSObject>

@optional

// 滚动到一半时索引改变
- (void)photoBrowser:(GKPhotoBrowser *)browser didChangedIndex:(NSInteger)index;

// 选择photoView时回调
- (void)photoBrowser:(GKPhotoBrowser *)browser didSelectAtIndex:(NSInteger)index;

// 单击事件
- (void)photoBrowser:(GKPhotoBrowser *)browser singleTapWithIndex:(NSInteger)index;

// 双击事件
- (void)photoBrowser:(GKPhotoBrowser *)browser doubleTapWithIndex:(NSInteger)index;

// 长按事件
- (void)photoBrowser:(GKPhotoBrowser *)browser longPressWithIndex:(NSInteger)index;

// 旋转事件
- (void)photoBrowser:(GKPhotoBrowser *)browser onDeciceChangedWithIndex:(NSInteger)index isLandscape:(BOOL)isLandscape;

// 缩放事件
- (void)photoBrowser:(GKPhotoBrowser *)browser zoomEndedWithIndex:(NSInteger)index zoomScale:(CGFloat)scale;

// photoView复用回调
- (void)photoBrowser:(GKPhotoBrowser *)browser reuseAtIndex:(NSInteger)index photoView:(GKPhotoView *)photoView;

// 保存按钮点击事件
- (void)photoBrowser:(GKPhotoBrowser *)browser onSaveBtnClick:(NSInteger)index image:(UIImage *)image;

// 上下滑动消失
// 开始滑动时
- (void)photoBrowser:(GKPhotoBrowser *)browser panBeginWithIndex:(NSInteger)index;

// 结束滑动时 disappear：是否消失
- (void)photoBrowser:(GKPhotoBrowser *)browser panEndedWithIndex:(NSInteger)index willDisappear:(BOOL)disappear;

// 布局子视图
- (void)photoBrowser:(GKPhotoBrowser *)browser willLayoutSubViews:(NSInteger)index;

// browser完全消失回调
- (void)photoBrowser:(GKPhotoBrowser *)browser didDisappearAtIndex:(NSInteger)index;

// browser自定义加载方式时回调
- (void)photoBrowser:(GKPhotoBrowser *)browser loadImageAtIndex:(NSInteger)index progress:(float)progress isOriginImage:(BOOL)isOriginImage;

// browser加载失败自定义弹窗
- (void)photoBrowser:(GKPhotoBrowser *)browser loadFailedAtIndex:(NSInteger)index error:(NSError *)error;

// 自定义单个图片或视频的加载失败文字，优先级高于failureText
- (NSString *)photoBrowser:(GKPhotoBrowser *)browser failedTextAtIndex:(NSInteger)index;

// 自定义单个图片或视频的加载失败图片，优先级高于failureImage
- (UIImage *)photoBrowser:(GKPhotoBrowser *)browser failedImageAtIndex:(NSInteger)index;

// 视频相关
// 视频播放状态回调
- (void)photoBrowser:(GKPhotoBrowser *)browser videoStateChangeWithPhotoView:(GKPhotoView *)photoView status:(GKVideoPlayerStatus)status;

// 视频播放进度回调
- (void)photoBrowser:(GKPhotoBrowser *)browser videoTimeChangeWithPhotoView:(GKPhotoView *)photoView currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

// 视频加载回调，用于自定义加载方式
// isStart: 是否开始加载  success：加载是否成功
- (void)photoBrowser:(GKPhotoBrowser *)browser videoLoadStart:(BOOL)isStart success:(BOOL)success;

// browser UIScrollViewDelegate
- (void)photoBrowser:(GKPhotoBrowser *)browser scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)photoBrowser:(GKPhotoBrowser *)browser scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)photoBrowser:(GKPhotoBrowser *)browser scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)photoBrowser:(GKPhotoBrowser *)browser scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)photoBrowser:(GKPhotoBrowser *)browser scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;

@end
