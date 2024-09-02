//
//  GKPhotoView+Image.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2024/6/21.
//

#import "GKPhotoView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKPhotoView (Image)

/// 加载图片
/// - Parameters:
///   - photo: 数据模型
///   - isOrigin: 是否是原图
- (void)loadImageWithPhoto:(GKPhoto *)photo isOrigin:(BOOL)isOrigin;

// 加载原图（必须传originUrl）
- (void)loadOriginImage;

// 取消图片加载
- (void)cancelImageLoad;

// 调整frame
- (void)adjustImageFrame;

@end

NS_ASSUME_NONNULL_END
