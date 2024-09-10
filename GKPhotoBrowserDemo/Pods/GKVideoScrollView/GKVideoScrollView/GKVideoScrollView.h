//
//  GKVideoScrollView.h
//  GKVideoScrollView
//
//  Created by QuintGao on 2023/2/21.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKVideoViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@class GKVideoScrollView;

@protocol GKVideoScrollViewDataSource <NSObject>

// 内容总数
- (NSInteger)numberOfRowsInScrollView:(GKVideoScrollView *)scrollView;

// 设置cell
- (GKVideoViewCell *)scrollView:(GKVideoScrollView *)scrollView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol GKVideoScrollViewDelegate <NSObject, UIScrollViewDelegate>

@optional

// cell即将显示时调用，可用于请求播放信息
// 注意：1、此时的cell并不一定等于最终显示的cell，慎用 2、在快速滑动时，此方法可能不会回调所有的index
- (void)scrollView:(GKVideoScrollView *)scrollView willDisplayCell:(GKVideoViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

// cell结束显示时调用，可用于结束播放
- (void)scrollView:(GKVideoScrollView *)scrollView didEndDisplayingCell:(GKVideoViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

// 结束滑动时显示的cell，可在这里开始播放
- (void)scrollView:(GKVideoScrollView *)scrollView didEndScrollingCell:(GKVideoViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

// 移除cell回调，须在此回调中删除对应index的数据
- (void)scrollView:(GKVideoScrollView *)scrollView didRemoveCell:(GKVideoViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface GKVideoScrollView : UIScrollView

// 数据源
@property (nonatomic, weak, nullable) id<GKVideoScrollViewDataSource> dataSource;

// 代理
@property (nonatomic, weak, nullable) id<GKVideoScrollViewDelegate> delegate;

// 默认索引
@property (nonatomic, assign) NSInteger defaultIndex;

// 当前索引
@property (nonatomic, assign, readonly) NSInteger currentIndex;

// 当前显示的cell
@property (nonatomic, weak, readonly) GKVideoViewCell *currentCell;

// 可视cells
@property (nonatomic, readonly) NSArray <__kindof UIView *> *visibleCells;

// 获取行数
- (NSInteger)numberOfRows;

// 获取cell对应的indexPath
- (nullable NSIndexPath *)indexPathForCell:(GKVideoViewCell *)cell;

// 获取indexPath对应的cell
- (nullable __kindof GKVideoViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;

// 注册cell
- (void)registerNib:(nullable UINib *)nib forCellReuseIdentifier:(nonnull NSString *)identifier;
- (void)registerClass:(nullable Class)cellClass forCellReuseIdentifier:(nonnull NSString *)identifier;

// 获取可复用的cell
- (__kindof GKVideoViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(nonnull NSIndexPath *)indexPath;

// 刷新数据
- (void)reloadData;

// 根据指定index刷新数据，刷新后将显示对应index的页面
- (void)reloadDataWithIndex:(NSInteger)index;

// 切换到指定索引页面，无动画
- (void)scrollToPageWithIndex:(NSInteger)index;

// 切换到上个页面，有动画
- (void)scrollToLastPage;

// 切换到下个页面，有动画
- (void)scrollToNextPage;

// 移除当前页面，切换到下一个页面，如果当前是最后一个，则切换到上一个页面
- (void)removeCurrentPageAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
