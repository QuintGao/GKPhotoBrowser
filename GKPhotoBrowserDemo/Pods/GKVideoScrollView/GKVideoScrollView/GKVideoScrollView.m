//
//  GKVideoScrollView.m
//  GKVideoScrollView
//
//  Created by QuintGao on 2023/2/21.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKVideoScrollView.h"

/// cell更新类型
typedef NS_ENUM(NSUInteger, GKVideoCellUpdateType) {
    GKVideoCellUpdateType_Top,  // 显示topCell，更新上中
    GKVideoCellUpdateType_Ctr,  // 显示ctrCell，更新上中下
    GKVideoCellUpdateType_Btm   // 显示btmCell，更新中下
};

@interface GKVideoScrollView()<UIScrollViewDelegate>

@property (nonatomic, weak) id<GKVideoScrollViewDelegate> userDelegate;

// 创建三个控制视图，用于滑动切换
@property (nonatomic, strong) GKVideoViewCell *topCell; // 顶部视图
@property (nonatomic, strong) GKVideoViewCell *ctrCell; // 中间视图
@property (nonatomic, strong) GKVideoViewCell *btmCell; // 底部视图

// 控制播放的索引，不完全等于当前播放内容的索引
@property (nonatomic, assign) NSInteger index;

// 当前索引
@property (nonatomic, assign) NSInteger currentIndex;

// 当前显示的view
@property (nonatomic, weak) GKVideoViewCell *currentCell;

// 将要改变的索引
@property (nonatomic, assign) NSInteger changeIndex;

// 内容总数
@property (nonatomic, assign) NSInteger totalCount;

// 记录是否刷新过
@property (nonatomic, assign) BOOL isLoaded;

// 处理上拉加载回弹问题
@property (nonatomic, assign) NSInteger lastCount;
@property (nonatomic, assign) BOOL isDelay;

// 当前正在更新的view
@property (nonatomic, weak) GKVideoViewCell *updateCell;

// 处理view即将显示
@property (nonatomic, assign) CGFloat lastOffsetY;
@property (nonatomic, weak) GKVideoViewCell *lastWillDisplayCell;
@property (nonatomic, weak) GKVideoViewCell *lastEndDisplayCell;

// 记录是否在切换页面
@property (nonatomic, assign) BOOL isChanging;

// 记录是否正在切换到下一个
@property (nonatomic, assign) BOOL isChangeToNext;

// 记录是否正在改变位置
@property (nonatomic, assign) BOOL isChangeOffset;

// 移除cell
@property (nonatomic, weak) GKVideoViewCell *willRemoveCell;
@property (nonatomic, assign) NSInteger willRemoveIndex;

// 存放cell标识和对应的nib
@property (nonatomic, strong) NSMutableDictionary<NSString *, UINib *> *cellNibs;

// 存放cell标识和对应的类（包括nib对应的类）
@property (nonatomic, strong) NSMutableDictionary<NSString *, Class> *cellClasses;

// 存放cell标识和对应的可重用view列表
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableSet *> *reusableCells;

@end

@implementation GKVideoScrollView

@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [super setDelegate:self];
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.backgroundColor = UIColor.clearColor;
    self.pagingEnabled = YES;
    self.scrollsToTop = NO;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.cellNibs = [NSMutableDictionary dictionary];
    self.cellClasses = [NSMutableDictionary dictionary];
    self.reusableCells = [NSMutableDictionary dictionary];
    
    [self initValue];
}

- (void)initValue {
    [self saveReusableCell:self.topCell];
    [self saveReusableCell:self.ctrCell];
    [self saveReusableCell:self.btmCell];
    [self saveReusableCell:self.willRemoveCell];
    self.topCell = nil;
    self.ctrCell = nil;
    self.btmCell = nil;
    self.updateCell = nil;
    self.lastWillDisplayCell = nil;
    self.lastEndDisplayCell = nil;
    [self updateContentSize:CGSizeZero];
    [self updateContentOffset:CGPointZero];
    self.defaultIndex = 0;
    self.isLoaded = NO;
    self.currentIndex = 0;
    self.changeIndex = 0;
    self.lastCount = 0;
    self.index = 0;
    self.isChanging = NO;
    self.isChangeOffset = NO;
    self.isChangeToNext = NO;
    self.willRemoveCell = nil;
    self.willRemoveIndex = 0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat scrollW = CGRectGetWidth(self.frame);
    CGFloat scrollH = CGRectGetHeight(self.frame);
    
    self.topCell.frame = CGRectMake(0, 0, scrollW, scrollH);
    self.ctrCell.frame = CGRectMake(0, scrollH, scrollW, scrollH);
    self.btmCell.frame = CGRectMake(0, scrollH * 2, scrollW, scrollH);
    
    if (CGSizeEqualToSize(self.contentSize, CGSizeZero) || self.contentSize.width != scrollW) {
        [self updateContentSize];
        [self updateContentOffset];
    }
}

- (void)setDelegate:(id<GKVideoScrollViewDelegate>)delegate {
    self.userDelegate = delegate;
}

#pragma mark - Public Methods
- (NSArray<__kindof UIView *> *)visibleCells {
    if (!self.currentCell) return nil;
    return @[self.currentCell];
}

- (NSInteger)numberOfRows {
    return self.totalCount;
}

- (NSIndexPath *)indexPathForCell:(GKVideoViewCell *)cell {
    NSInteger index = NSNotFound;
    
    NSInteger diff = NSNotFound;
    if (cell == self.topCell) {
        diff = -1;
    }else if (cell == self.ctrCell) {
        diff = 0;
    }else if (cell == self.btmCell) {
        diff = 1;
    }
    
    if (diff != NSNotFound) {
        if (self.currentCell == self.topCell) {
            index = self.currentIndex + 1 + diff;
        }else if (self.currentCell == self.ctrCell) {
            index = self.currentIndex + diff;
        }else if (self.currentCell == self.btmCell) {
            index = self.currentIndex - 1 + diff;
        }
    }
    
    if (index != NSNotFound) {
        return [NSIndexPath indexPathForRow:index inSection:0];
    }
    return nil;
}

- (__kindof GKVideoViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    if (index < 0 || index > self.totalCount - 1) return nil;
    GKVideoViewCell *cell = nil;
    NSInteger diff = self.currentIndex - index;
    if (self.currentIndex == 0) {
        diff += 1;
    }else if (self.currentIndex == self.totalCount - 1) {
        diff -= 1;
    }
    if (diff == 1) {
        cell = self.topCell;
    }else if (diff == 0) {
        cell = self.ctrCell;
    }else if (diff == -1) {
        cell = self.btmCell;
    }
    return cell;
}

- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier {
    if (identifier.length <= 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"must pass a valid reuse identifier to - %s", __func__]
                                     userInfo:nil];
    }
    [self clearWithIdentifier:identifier];
    [self.cellNibs setValue:nib forKey:identifier];
    [self.reusableCells setValue:[NSMutableSet set] forKey:identifier];
}

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
    if (cellClass == nil) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"unable to dequeue a cell with identifier %@ - must register a nib or a class for the identifier or connect a prototype cell in a storyboard", identifier]
                                     userInfo:nil];
    }
    if (![cellClass isSubclassOfClass:GKVideoViewCell.class]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"must pass a class of kind GKVideoViewCell"
                                     userInfo:nil];
    }
    if (identifier.length <= 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"must pass a valid reuse identifier to - %s", __func__]
                                     userInfo:nil];
    }
    [self clearWithIdentifier:identifier];
    [self.cellClasses setValue:cellClass forKey:identifier];
    [self.reusableCells setValue:[NSMutableSet set] forKey:identifier];
}

- (__kindof GKVideoViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    Class cellClass = [self cellClassWithIdentifier:identifier];
    GKVideoViewCell *cell = nil;
    if (!self.updateCell || self.updateCell.class != cellClass) {
        cell = [self dequeueReusableCellWithIdentifier:identifier];
        if (self.updateCell) {
            [self saveReusableCell:self.updateCell];
            self.updateCell = nil;
        }
    }else {
        cell = self.updateCell;
        self.updateCell = nil;
    }
    return cell;
}

- (void)reloadData {
    // 总数
    self.totalCount = [self getTotalCount];
    if (self.totalCount <= 0) return;
    
    // 索引
    if (self.defaultIndex < 0 || self.defaultIndex >= self.totalCount) {
        if (!self.isLoaded) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"please set defaultIndex correctly"
                                         userInfo:nil];
        }
    }
    NSInteger index = self.defaultIndex;
    self.defaultIndex = 0;
    
    // 加载cell
    if (self.isLoaded) {
        [self createCellsIfNeeded];
        [self updateContentSize];
        [self updateDisplayCell:NO];
    }else {
        self.isLoaded = YES;
        self.index = index;
        self.currentIndex = index;
        self.changeIndex = index;
        [self createCellsIfNeeded];
        [self updateContentSize];
        [self updateContentOffset];
        [self updateDisplayCell:YES];
    }
}

- (void)reloadDataWithIndex:(NSInteger)index {
    // 总数
    self.totalCount = [self getTotalCount];
    if (self.totalCount <= 0) return;
    
    self.index = index;
    self.currentIndex = index;
    self.changeIndex = index;
    
    [self createCellsIfNeeded];
    [self updateContentSize];
    [self updateContentOffset];
    [self updateDisplayCell:YES];
}

- (void)scrollToPageWithIndex:(NSInteger)index {
    if (index < 0 || index > self.totalCount - 1) return;
    if (self.currentIndex == index) return;
    if (self.isChanging) return;
    self.isChanging = YES;
    self.index = index;
    self.changeIndex = index;
    
    // 更新cell
    GKVideoCellUpdateType type = GKVideoCellUpdateType_Top;
    if (self.totalCount >= 3) {
        if (index == 0) {
            type = GKVideoCellUpdateType_Top;
        }else if (index == self.totalCount - 1) {
            type = GKVideoCellUpdateType_Btm;
        }else {
            type = GKVideoCellUpdateType_Ctr;
        }
        [self createCellWithType:type index:index];
    }
    
    // 显示cell
    [self updateDisplayCellWithIndex:index];
    
    self.isChanging = NO;
}

- (void)scrollToLastPage {
    // 当前是第一个，不做处理
    if (self.currentIndex == 0) return;
    if (self.isChangeToNext) return;
    self.changeIndex = self.currentIndex - 1;
    // 即将显示
    GKVideoViewCell *cell = nil;
    CGFloat offsetY = 0;
    if (self.currentCell == self.ctrCell) {
        cell = self.topCell;
        offsetY = 0;
    }else if (self.currentCell == self.btmCell) {
        cell = self.ctrCell;
        offsetY = self.viewHeight;
    }
    if (cell && !self.willRemoveCell) {
        [self willDisplayCell:cell forIndex:self.changeIndex];
        self.lastWillDisplayCell = nil;
    }
    
    self.isChangeToNext = YES;
    // 切换
    [self setContentOffset:CGPointMake(0, offsetY) animated:YES];
}

- (void)scrollToNextPage {
    // 当前是最后一个，不做处理
    if (self.currentIndex == self.totalCount - 1) return;
    if (self.isChangeToNext) return;
    
    self.changeIndex = self.currentIndex + 1;
    // 即将显示
    GKVideoViewCell *cell = nil;
    CGFloat offsetY = 0;
    if (self.currentCell == self.topCell) {
        cell = self.ctrCell;
        offsetY = self.viewHeight;
    }else if (self.currentCell == self.ctrCell) {
        cell = self.btmCell;
        offsetY = self.viewHeight * 2;
    }
    if (cell && !self.willRemoveCell) {
        [self willDisplayCell:cell forIndex:self.changeIndex];
        self.lastWillDisplayCell = nil;
    }
    
    self.isChangeToNext = YES;
    
    // 切换
    [self setContentOffset:CGPointMake(0, offsetY) animated:YES];
}

- (void)removeCurrentPageAnimated:(BOOL)animated {
    // 记录即将移除的cell和index
    self.willRemoveCell = self.currentCell;
    self.willRemoveIndex = self.currentIndex;
    
    // 结束显示
    [self didEndDisplayingCell:self.willRemoveCell forIndex:self.willRemoveIndex];
    
    if (animated) {
        if (self.totalCount == 1) {
            [self removeCurrentPage];
        }else {
            if (self.currentIndex == self.totalCount - 1) {
                [self scrollToLastPage];
            }else {
                [self scrollToNextPage];
            }
        }
    }else {
        [self removeCurrentPage];
    }
}

- (void)removeCurrentPage {
    // 移除
    if ([self.userDelegate respondsToSelector:@selector(scrollView:didRemoveCell:forRowAtIndexPath:)]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
        [self.userDelegate scrollView:self didRemoveCell:self.currentCell forRowAtIndexPath:indexPath];
    }else {
        [NSException exceptionWithName:NSInternalInconsistencyException
                                reason:@"when using the `removeCurrentPageAnimated` method，you must implement the `scrollView:didRemoveCell:forRowAtIndexPath` protocol and remove the data for index"
                              userInfo:nil];
    }
    if (self.topCell == self.willRemoveCell) self.topCell = nil;
    if (self.ctrCell == self.willRemoveCell) self.ctrCell = nil;
    if (self.btmCell == self.willRemoveCell) self.btmCell = nil;
    
    // 刷新
    self.totalCount = [self getTotalCount];
    if (self.totalCount <= 0) return;
    
    if (self.currentIndex == self.totalCount) {
        self.currentIndex = self.totalCount - 1;
    }
    self.changeIndex = self.currentIndex;
    [self reloadData];
    [self updateContentOffset];
}

#pragma mark - Private Methods
- (NSInteger)getTotalCount {
    // 总数
    NSInteger totalCount = [self.dataSource numberOfRowsInScrollView:self];
    
    // 修复刷新时可能出现的bug
    CGFloat offsetY = self.contentOffset.y;
    if (totalCount > self.totalCount && self.lastCount > 0 && (offsetY == 0 || offsetY == self.viewHeight || offsetY == self.viewHeight * 2)) {
        self.lastCount = 0;
    }
    
    // 清空数据处理
    if (self.totalCount <= 0 && self.isLoaded) {
        [self didEndDisplayingCell:self.currentCell forIndex:self.currentIndex];
        [self initValue];
    }
    
    return totalCount;
}

- (void)clearWithIdentifier:(NSString *)identifier {
    if ([self.cellNibs.allKeys containsObject:identifier]) {
        [self.cellNibs removeObjectForKey:identifier];
    }
    if ([self.cellClasses.allKeys containsObject:identifier]) {
        [self.cellClasses removeObjectForKey:identifier];
    }
    if ([self.reusableCells.allKeys containsObject:identifier]) {
        [self.reusableCells removeObjectForKey:identifier];
    }
}

#pragma mark - dequeue reusable cell
- (Class)cellClassWithIdentifier:(NSString *)identifier {
    // 标识未注册
    if (![self.cellNibs.allKeys containsObject:identifier] && ![self.cellClasses.allKeys containsObject:identifier]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"unable to dequeue a cell with identifier %@ - must register a nib or a class for the identifier or connect a prototype cell in a storyboard", identifier]
                                     userInfo:nil];
    }
    // 如果获取过class，直接返回
    if ([self.cellClasses.allKeys containsObject:identifier]) {
        return self.cellClasses[identifier];
    }
    // 通过nib获取cell
    UINib *nib = self.cellNibs[identifier];
    GKVideoViewCell *nibCell = [self cellWithNib:nib identifier:identifier];
    // 放入重用池
    [self saveReusableCell:nibCell];
    // 存储class
    Class class = nibCell.class;
    [self.cellClasses setValue:class forKey:identifier];
    return class;
}

- (GKVideoViewCell *)cellWithNib:(UINib *)nib identifier:(NSString *)identifier {
    NSArray *views = [nib instantiateWithOwner:self options:nil];
    // 只能存在一个view且必须是GKVideoViewCell或其子类
    if (views.count == 1 && [[views.firstObject class] isSubclassOfClass:GKVideoViewCell.class]) {
        GKVideoViewCell *nibCell = (GKVideoViewCell *)views.firstObject;
        if (nibCell.reuseIdentifier.length > 0 && ![nibCell.reuseIdentifier isEqualToString:identifier]) {
            // 重用标识不一致
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:[NSString stringWithFormat:@"cell reuse indentifier in nib (%@) does not match the identifier used to register the nib (%@)", nibCell.reuseIdentifier, identifier]
                                         userInfo:nil];
        }else {
            if (nibCell.reuseIdentifier.length <= 0) {
                [nibCell setValue:identifier forKey:@"reuseIdentifier"];
            }
            return nibCell;
        }
    }else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"invalid nib registered for identifier (%@) - nib must contain exactly one top level object which must be a UIView instance", identifier]
                                     userInfo:nil];
    }
}

- (GKVideoViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    NSMutableSet *cells = self.reusableCells[identifier];
    
    GKVideoViewCell *cell = cells.anyObject;
    if (cell) {
        [UIView performWithoutAnimation:^{
            [cell prepareForReuse];
        }];
        [cells removeObject:cell];
    }else {
        if ([self.cellNibs.allKeys containsObject:identifier]) {
            UINib *nib = self.cellNibs[identifier];
            cell = [self cellWithNib:nib identifier:identifier];
        }else {
            Class class = self.cellClasses[identifier];
            cell = [[class alloc] initWithReuseIdentifier:identifier];
        }
    }
    return cell;
}

- (void)saveReusableCell:(GKVideoViewCell *)cell {
    if (!cell) return;
    NSString *identifier = cell.reuseIdentifier;
    NSMutableSet *cells = self.reusableCells[identifier];
    __block BOOL exist = NO;
    [cells enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj == cell) {
            exist = YES;
            *stop = YES;
        }
    }];
    if (!exist) {
        [cells addObject:cell];
    }
    [cell removeFromSuperview];
    [self.reusableCells setValue:cells forKey:identifier];
}

#pragma mark - create and update cell
- (void)createCellsIfNeeded {
    GKVideoCellUpdateType type = GKVideoCellUpdateType_Top;
    NSInteger index = self.changeIndex;
    if (self.totalCount >= 3) {
        if (index == 0) {
            type = GKVideoCellUpdateType_Top;
        }else if (index == self.totalCount - 1) {
            type = GKVideoCellUpdateType_Btm;
        }else {
            type = GKVideoCellUpdateType_Ctr;
            if (self.currentCell && self.currentCell == self.btmCell) {
                if (self.contentOffset.y > self.viewHeight * 2) return;
                [self updateContentOffset];
                [self updateUpScrollCellWithIndex:index];
            }
        }
    }
    [self createCellWithType:type index:index];
}

- (void)createCellWithType:(GKVideoCellUpdateType)type index:(NSInteger)index {
    if (type == GKVideoCellUpdateType_Top) {
        [self createTopCellWithIndex:0];
        if (self.totalCount > 1) {
            [self createCtrCellWithIndex:1];
        }
        if (self.btmCell && self.changeIndex == self.currentIndex) {
            [self saveReusableCell:self.btmCell];
            self.btmCell = nil;
        }
    }else if (type == GKVideoCellUpdateType_Ctr) {
        if (self.contentOffset.y > self.viewHeight * 2) {
            [self createTopCellWithIndex:index - 2];
            [self createCtrCellWithIndex:index - 1];
            [self createBtmCellWithIndex:index];
        }else {
            [self createTopCellWithIndex:index - 1];
            [self createCtrCellWithIndex:index];
            [self createBtmCellWithIndex:index + 1];
        }
    }else if (type == GKVideoCellUpdateType_Btm) {
        if (self.topCell) {
            [self saveReusableCell:self.topCell];
            self.topCell = nil;
        }
        [self createCtrCellWithIndex:index - 1];
        [self createBtmCellWithIndex:index];
    }
    [self updateLayout];
}

- (void)updateDisplayCell:(BOOL)isFirstLoad {
    GKVideoViewCell *cell = nil;
    if (self.totalCount == 1) {
        cell = self.topCell;
    }else if (self.totalCount == 2) {
        cell = self.currentIndex == 0 ? self.topCell : self.ctrCell;
    }else {
        if (self.currentIndex == 0) {
            cell = self.topCell;
        }else if (self.currentIndex == self.totalCount - 1) {
            cell = self.btmCell;
        }else {
            cell = self.ctrCell;
        }
    }
    
    if (isFirstLoad || self.willRemoveCell) {
        [self saveReusableCell:self.willRemoveCell];
        self.willRemoveCell = nil;
        self.willRemoveIndex = 0;
        
        [self willDisplayCell:cell forIndex:self.currentIndex];
        self.lastWillDisplayCell = nil;
        
        [self didEndScrollingCell:cell];
    }else {
        if (self.isDecelerating) return;
        if (self.contentOffset.y > 0 && self.contentOffset.y != self.viewHeight * 2) return;
        [self didEndScrollingCell:cell];
    }
}

- (void)updateDisplayCellWithIndex:(NSInteger)index {
    CGFloat viewH = self.viewHeight;
    
    GKVideoViewCell *cell = nil;
    CGFloat offsetY = 0;
    if (self.totalCount == 1) {
        cell = self.topCell;
        offsetY = 0;
    }else if (self.totalCount == 2) {
        cell = index == 0 ? self.topCell : self.ctrCell;
        offsetY = index == 0 ? 0 : viewH;
    }else {
        if (index == 0) {
            cell = self.topCell;
            offsetY = 0;
        }else if (index == self.totalCount - 1) {
            cell = self.btmCell;
            offsetY = viewH * 2;
        }else {
            cell = self.ctrCell;
            offsetY = viewH;
        }
    }
    //即将显示cell
    [self willDisplayCell:cell forIndex:index];
    self.lastWillDisplayCell = nil;
    
    // 切换位置
    [self updateContentOffset:CGPointMake(0, offsetY)];
    
    // 滑动结束显示
    [self didEndScrollingCell:cell];
}

- (void)updateContentSize {
    if (self.totalCount == 0) return;
    CGFloat height = self.viewHeight * (self.totalCount >= 3 ? 3 : self.totalCount);
    [self updateContentSize:CGSizeMake(self.viewWidth, height)];
}

- (void)updateContentOffset {
    CGFloat viewH = self.viewHeight;
    CGFloat offsetY = 0;
    if (self.totalCount == 0) {
        offsetY = 0;
    }else if (self.totalCount == 1 || self.totalCount == 2) {
        offsetY = self.currentIndex == 0 ? 0 : viewH;
    }else {
        if (self.currentIndex == 0) {
            offsetY = 0;
        }else if (self.currentIndex == self.totalCount - 1) {
            offsetY = viewH * 2;
        }else {
            offsetY = viewH;
        }
    }
    [self updateContentOffset:CGPointMake(0, offsetY)];
}

- (void)createTopCellWithIndex:(NSInteger)index {
    if (index < 0 || index >= self.totalCount) return;
    self.updateCell = self.topCell;
    self.topCell = [self cellForIndex:index];
    [self addSubview:self.topCell];
}

- (void)createCtrCellWithIndex:(NSInteger)index {
    if (index < 0 || index >= self.totalCount) return;
    self.updateCell = self.ctrCell;
    self.ctrCell = [self cellForIndex:index];
    [self addSubview:self.ctrCell];
}

- (void)createBtmCellWithIndex:(NSInteger)index {
    if (index < 0 || index >= self.totalCount) return;
    self.updateCell = self.btmCell;
    self.btmCell = [self cellForIndex:index];
    [self addSubview:self.btmCell];
}

- (void)createTopCellIfNeededWithIndex:(NSInteger)index {
    if (index < 0 || index >= self.totalCount) return;
    if (self.topCell) return;
    [self createTopCellWithIndex:index];
    [self updateLayout];
}

- (void)createBtmCellIfNeededWithIndex:(NSInteger)index {
    if (index < 0 || index >= self.totalCount) return;
    if (self.btmCell) return;
    [self createBtmCellWithIndex:index];
    [self updateLayout];
}

/// 上滑cell
- (void)updateUpScrollCellWithIndex:(NSInteger)index {
    if (index < 1 || index > self.totalCount - 2) return;
    // 上视图放入复用池
    [self saveReusableCell:self.topCell];
    // 中视图切换为上视图
    self.topCell = self.ctrCell;
    // 下视图切换为中视图
    self.ctrCell = self.btmCell;
    // 更新下视图
    self.btmCell = [self cellForIndex:index + 1];
    [self addSubview:self.btmCell];
    [self updateLayout];
}

/// 下滑cell
- (void)updateDownScrollCellWithIndex:(NSInteger)index {
    if (index < 1 || index > self.totalCount - 2) return;
    // 下视图放入复用池
    [self saveReusableCell:self.btmCell];
    // 中视图切换为下视图
    self.btmCell = self.ctrCell;
    // 上视图切换为中视图
    self.ctrCell = self.topCell;
    // 更新上视图
    self.topCell = [self cellForIndex:index - 1];
    [self addSubview:self.topCell];
    [self updateLayout];
}

- (GKVideoViewCell *)cellForIndex:(NSInteger)index {
    if (index < 0 || index >= self.totalCount) return nil;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    return [self.dataSource scrollView:self cellForRowAtIndexPath:indexPath];
}

#pragma mark - DisplayCell
// 延迟更新cell，处理上拉加载更多后的回弹问题
- (void)delayUpdateCellWithIndex:(NSInteger)index {
    if (self.isDelay) return;
    self.isDelay = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isDelay = NO;
        self.lastCount = 0;
        if (index != NSNotFound) {
            self.index = index;
            [self updateContentOffset:CGPointMake(0, self.viewHeight)];
            [self updateUpScrollCellWithIndex:self.index];
            [self didEndScrollingCell:self.ctrCell];
        }else {
            [self didEndScrollingCell:self.currentCell];
        }
    });
}

- (void)handleWillDisplayCell {
    if (!self.isDragging) return;
    if (self.willRemoveCell) return;

    CGFloat offsetY = self.contentOffset.y;
    if (offsetY < self.lastOffsetY) { // 下拉
        if (offsetY < 0) return; // 第一个cell下拉
        if (offsetY > self.viewHeight * 2) return; // 显示footer时下拉
        NSInteger index = self.currentIndex - 1;
        if (self.currentCell == self.ctrCell && (offsetY > 0 && offsetY < self.viewHeight)) {
            [self willDisplayCell:self.topCell forIndex:index];
        }else if (self.currentCell == self.btmCell && (offsetY > self.viewHeight)) {
            [self willDisplayCell:self.ctrCell forIndex:index];
            [self createTopCellIfNeededWithIndex:index - 1];
        }
    }else if (offsetY > self.lastOffsetY) { // 上拉
        if (offsetY > self.viewHeight * 2) return; // 最后一个cell上拉
        NSInteger index = self.currentIndex + 1;
        if (self.currentCell == self.topCell && (offsetY > 0 && offsetY < self.viewHeight)) {
            [self willDisplayCell:self.ctrCell forIndex:index];
            [self createBtmCellIfNeededWithIndex:index + 1];
        }else if (self.currentCell == self.ctrCell && (offsetY > self.viewHeight)) {
            [self willDisplayCell:self.btmCell forIndex:index];
        }
    }
}

- (void)willDisplayCell:(GKVideoViewCell *)cell forIndex:(NSInteger)index {
    if (index < 0 || index >= self.totalCount) return;
    if (!cell) return;
    if (self.lastWillDisplayCell == cell) return;
    self.lastWillDisplayCell = cell;
    if ([self.userDelegate respondsToSelector:@selector(scrollView:willDisplayCell:forRowAtIndexPath:)]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.userDelegate scrollView:self willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)didEndDisplayingCell:(GKVideoViewCell *)cell forIndex:(NSInteger)index {
    if (index < 0 || index >= self.totalCount) return;
    if (!cell) return;
    if (self.lastEndDisplayCell == cell) return;
    self.lastEndDisplayCell = cell;
    if ([self.userDelegate respondsToSelector:@selector(scrollView:didEndDisplayingCell:forRowAtIndexPath:)]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.userDelegate scrollView:self didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)didEndScrollingCell:(GKVideoViewCell *)cell forIndex:(NSInteger)index {
    if (index < 0 || index >= self.totalCount) return;
    if (!cell) return;
    if ([self.userDelegate respondsToSelector:@selector(scrollView:didEndScrollingCell:forRowAtIndexPath:)]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.userDelegate scrollView:self didEndScrollingCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)didEndScrollingCell:(GKVideoViewCell *)cell {
    if (self.changeIndex < 0) {
        self.changeIndex = 0;
    }else if (self.changeIndex >= self.totalCount) {
        self.changeIndex = self.totalCount - 1;
    }
    
    // 快速滑动处理
    if (cell && self.lastWillDisplayCell && !self.willRemoveCell) {
        if (cell != self.lastWillDisplayCell && self.currentIndex != self.changeIndex) {
            [self willDisplayCell:cell forIndex:self.changeIndex];
        }
    }
    // 清空上一次将要显示的cell，保证下一次正常显示
    self.lastWillDisplayCell = nil;
    self.lastEndDisplayCell = nil;
    
    // 隐藏cell
    if (self.currentIndex != self.changeIndex && !self.willRemoveCell) {
        if (self.totalCount <= 3 || self.isChanging || self.currentIndex == 0 || self.currentIndex == self.totalCount - 1) {
            [self didEndDisplayingCell:self.currentCell forIndex:self.currentIndex];
            self.lastEndDisplayCell = nil;
        }
    }
    
    // 显示新的cell
    self.currentCell = cell;
    self.currentIndex = self.changeIndex;
    
    if (self.willRemoveCell) {
        [self handleRemovePage];
    }
    
    // 更新滑动结束时显示的cell
    [self didEndScrollingCell:cell forIndex:self.currentIndex];
}

- (void)handleRemovePage {
    // 移除代理
    if ([self.userDelegate respondsToSelector:@selector(scrollView:didRemoveCell:forRowAtIndexPath:)]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.willRemoveIndex inSection:0];
        [self.userDelegate scrollView:self didRemoveCell:self.willRemoveCell forRowAtIndexPath:indexPath];
    }else {
        [NSException exceptionWithName:NSInternalInconsistencyException
                                reason:@"when using the `removeCurrentPageAnimated` method，you must implement the `scrollView:didRemoveCell:forRowAtIndexPath` protocol and remove the data for index"
                              userInfo:nil];
    }
    
    // 重新获取总数
    self.totalCount = [self getTotalCount];
    if (self.totalCount <= 0) return;
    
    // 显示cell
    if (self.currentIndex == self.totalCount) {
        self.currentIndex = self.totalCount - 1;
    }else {
        self.currentIndex = self.willRemoveIndex;
    }
    self.changeIndex = self.currentIndex;
    
    [self saveReusableCell:self.willRemoveCell];
    self.willRemoveCell = nil;
    self.willRemoveIndex = 0;
    
    // 即将显示
    [self willDisplayCell:self.currentCell forIndex:self.currentIndex];
    
    if (self.topCell != self.currentCell) {
        [self saveReusableCell:self.topCell];
        self.topCell = nil;
    }else {
        self.topCell = nil;
    }
    if (self.ctrCell != self.currentCell) {
        [self saveReusableCell:self.ctrCell];
        self.ctrCell = nil;
    }else {
        self.ctrCell = nil;
    }
    if (self.btmCell != self.currentCell) {
        [self saveReusableCell:self.btmCell];
        self.btmCell = nil;
    }else {
        self.btmCell = nil;
    }
    if (self.totalCount == 1) {
        self.topCell = self.currentCell;
        self.index = 0;
    }else if (self.totalCount == 2) {
        if (self.currentIndex == 0) {
            self.topCell = self.currentCell;
            [self createCtrCellWithIndex:self.currentIndex+1];
            self.index = 0;
        }else {
            self.ctrCell = self.currentCell;
            [self createTopCellWithIndex:self.currentIndex-1];
        }
    }else {
        if (self.currentIndex == 0) {
            self.topCell = self.currentCell;
            [self createCtrCellWithIndex:self.currentIndex+1];
            [self createBtmCellWithIndex:self.currentIndex+2];
            self.index = 0;
        }else if (self.currentIndex == self.totalCount - 1) {
            self.btmCell = self.currentCell;
            [self createTopCellWithIndex:self.currentIndex-2];
            [self createCtrCellWithIndex:self.currentIndex-1];
        }else {
            self.ctrCell = self.currentCell;
            [self createTopCellWithIndex:self.currentIndex-1];
            [self createBtmCellWithIndex:self.currentIndex+1];
        }
    }
    [self updateLayout];
    [self updateContentSize];
    [self updateContentOffset];
}

#pragma mark - update view
- (CGFloat)viewWidth {
    return self.bounds.size.width;
}

- (CGFloat)viewHeight {
    return self.bounds.size.height;
}

- (void)updateContentSize:(CGSize)size {
    if (CGSizeEqualToSize(self.contentSize, size)) return;
    self.isChangeOffset = YES;
    self.contentSize = size;
}

- (void)updateContentOffset:(CGPoint)offset {
    if (CGPointEqualToPoint(self.contentOffset, offset)) return;
    self.isChangeOffset = YES;
    self.contentOffset = offset;
}

- (void)updateLayout {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)fixContentOffsetY:(CGFloat *)offsetY  {
    CGFloat viewH = self.viewHeight;
    
    CGFloat diff = fabs(*offsetY - 0);
    if (diff > 0 && diff < 1) {
        *offsetY = 0;
        [self updateContentOffset:CGPointMake(0, 0)];
    }
    
    diff = fabs(*offsetY - viewH);
    if (diff > 0 && diff < 1) {
        *offsetY = viewH;
        [self updateContentOffset:CGPointMake(0, viewH)];
    }
    
    diff = fabs(*offsetY - 2 * viewH);
    if (diff > 0 && diff < 1) {
        *offsetY = 2 * viewH;
        [self updateContentOffset:CGPointMake(0, 2 * viewH)];
    }
}

@end

@interface GKVideoScrollView (UIScrollView)

@end

@implementation GKVideoScrollView (UIScrollView)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.userDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.userDelegate scrollViewDidScroll:scrollView];
    }
    if (self.isChanging) return;
    if (self.isChangeOffset) {
        self.isChangeOffset = NO;
        return;
    }
    // 处理cell显示
    [self handleWillDisplayCell];
    
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat viewH = self.viewHeight;
    
    // 小于等于3个，不用处理
    if (self.totalCount <= 3) {
        if (self.lastCount > 0 && self.lastCount < self.totalCount) {
            [self delayUpdateCellWithIndex:NSNotFound];
        }else {
            self.lastCount = self.totalCount;
        }
        return;
    }
    
    // 下滑到第一个
    if (self.index == 0 && offsetY <= viewH) {
        self.changeIndex = 0;
        return;
    }
    
    // 上滑到最后一个
    if (self.index > 0 && self.index == self.totalCount - 1 && offsetY > viewH) {
        if (self.lastCount == 0) {
            self.lastCount = self.totalCount;
        }
        return;
    }
    
    // 判断是从中间视图上滑还是下滑
    if (offsetY >= 2 * viewH) { // 上滑
        if (self.currentCell != self.btmCell && (self.isDragging || self.isDecelerating || self.isChangeToNext)) {
            if (self.isChangeToNext) self.isChangeToNext = NO;
            [self didEndDisplayingCell:self.currentCell forIndex:self.currentIndex];
        }
        if (self.index == 0) {
            if (self.lastCount > 0) {
                [self delayUpdateCellWithIndex:2];
            }else {
                self.index = 2;
                [self updateContentOffset:CGPointMake(0, viewH)];
                self.changeIndex = self.index;
                [self updateUpScrollCellWithIndex:self.index];
            }
        }else {
            if (self.index < self.totalCount - 1) {
                self.index += 1;
                if (self.index == self.totalCount - 1) {
                    if (self.lastCount > 0 && self.lastCount < self.totalCount) {
                        [self delayUpdateCellWithIndex:self.lastCount - 1];
                    }else {
                        self.changeIndex = self.index;
                        self.lastCount = self.totalCount;
                    }
                }else {
                    if (self.lastCount > 0 && self.lastCount < self.totalCount) {
                        [self delayUpdateCellWithIndex:(self.index == 2 ? 2 : self.lastCount - 1)];
                    }else {
                        if (self.isDelay) return;
                        [self updateContentOffset:CGPointMake(0, viewH)];
                        self.changeIndex = self.index;
                        [self updateUpScrollCellWithIndex:self.index];
                    }
                }
            }
        }
    }else if (offsetY <= 0) { // 下滑
        if (self.currentCell != self.topCell && (self.isDragging || self.isDecelerating || self.isChangeToNext)) {
            if (self.isChangeToNext) self.isChangeToNext = NO;
            [self didEndDisplayingCell:self.currentCell forIndex:self.currentIndex];
        }
        self.lastCount = 0;
        if (self.index == 1) {
            self.index -= 1;
            self.changeIndex = self.index;
            [self updateDownScrollCellWithIndex:self.index];
        }else {
            if (self.index == self.totalCount - 1) {
                self.index -= 2;
            }else {
                self.index -= 1;
            }
            [self updateContentOffset:CGPointMake(0, viewH)];
            self.changeIndex = self.index;
            [self updateDownScrollCellWithIndex:self.index];
        }
    }else {
        if (self.lastCount > 0 && self.lastCount < self.totalCount) {
            [self delayUpdateCellWithIndex:NSNotFound];
        }
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if ([self.userDelegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [self.userDelegate scrollViewDidZoom:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.userDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.userDelegate scrollViewWillBeginDragging:scrollView];
    }
    self.lastOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([self.userDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.userDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.userDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.userDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([self.userDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.userDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.userDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.userDelegate scrollViewDidEndDecelerating:scrollView];
    }
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([self.userDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.userDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
    
    if (self.totalCount <= 0) return;
    self.isChanging = NO;
    self.isChangeOffset = NO;
    self.isChangeToNext = NO;
    
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat viewH = self.viewHeight;
    
    if (offsetY > 0 && offsetY < viewH && self.currentCell && self.currentCell == self.topCell && self.currentIndex == 0) {
        [self setContentOffset:CGPointZero animated:YES];
        return;
    }
    
    [self fixContentOffsetY:&offsetY];
    
    if (self.totalCount <= 3) {
        self.changeIndex = offsetY / viewH + 0.5;
    }
    GKVideoViewCell *cell = nil;
    if (offsetY <= 0) {
        cell = self.topCell;
    }else if (offsetY >= viewH && offsetY < 2 * viewH) {
        if (self.totalCount > 3) {
            if (self.index == 0) {
                self.index += 1;
                self.changeIndex = self.index;
            }else if (self.index == self.totalCount - 1) {
                self.index -= 1;
                self.changeIndex = self.index;
            }
        }
        cell = self.ctrCell;
        if (offsetY != viewH) {
            [self updateContentOffset:CGPointMake(0, viewH)];
        }
    }else if (offsetY >= 2 * viewH) {
        if (!self.isDelay) {
            cell = self.btmCell;
        }
    }
    
    if (!cell) return;
    [self didEndScrollingCell:cell];
    
    if (self.totalCount >= 3 && offsetY == viewH) {
        [self createTopCellIfNeededWithIndex:self.currentIndex - 1];
        [self createBtmCellIfNeededWithIndex:self.currentIndex + 1];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if ([self.userDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return [self.userDelegate viewForZoomingInScrollView:scrollView];
    }
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if ([self.userDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [self.userDelegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if ([self.userDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [self.userDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    if ([self.userDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [self.userDelegate scrollViewShouldScrollToTop:scrollView];
    }
    return NO;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if ([self.userDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [self.userDelegate scrollViewDidScrollToTop:scrollView];
    }
}

- (void)scrollViewDidChangeAdjustedContentInset:(UIScrollView *)scrollView API_AVAILABLE(ios(11.0)) {
    if ([self.userDelegate respondsToSelector:@selector(scrollViewDidChangeAdjustedContentInset:)]) {
        [self.userDelegate scrollViewDidChangeAdjustedContentInset:scrollView];
    }
}

@end
