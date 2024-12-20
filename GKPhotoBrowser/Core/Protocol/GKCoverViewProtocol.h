//
//  GKCoverViewProtocol.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2024/12/11.
//

#import <UIKit/UIKit.h>

@class GKPhotoBrowser, GKPhoto;

@protocol GKCoverViewProtocol <NSObject>

@property (nonatomic, weak, nullable) GKPhotoBrowser *browser;

/// 添加子视图
- (void)addCoverToView:(UIView *_Nullable)view;

/// 更新子视图frame
- (void)updateLayoutWithFrame:(CGRect)frame;

@optional

/// 当前对应的数据模型
@property (nonatomic, weak, nullable) GKPhoto *photo;

/// 更新索引
- (void)updateCoverWithCount:(NSInteger)count index:(NSInteger)index;

/// 更新子视图内容
- (void)updateCoverWithPhoto:(GKPhoto *_Nullable)photo;

@end
