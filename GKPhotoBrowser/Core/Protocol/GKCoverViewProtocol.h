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
- (void)gk_addCoverToView:(UIView *_Nullable)view;

/// 更新子视图frame
- (void)gk_updateCoverWithFrame:(CGRect)frame;

@optional

/// 更新子视图内容
- (void)gk_updateCoverWithCount:(NSInteger)count index:(NSInteger)index;

/// 更新子视图的显示与隐藏
- (void)gk_updateCoverWithPhoto:(GKPhoto *)photo;

@end
