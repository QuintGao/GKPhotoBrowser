//
//  GKDefaultCoverView.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2024/12/11.
//

#import <UIKit/UIKit.h>
#import <GKPhotoBrowser/GKCoverViewProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDefaultCoverView : NSObject<GKCoverViewProtocol>

/// 数量Label，默认显示，若要隐藏需设置hidesCountLabel为YES
@property (nonatomic, strong) UILabel *countLabel;

/// 页码，默认显示，若要隐藏需设置hidesPageControl为YES
@property (nonatomic, strong) UIPageControl *pageControl;

/// 保存按钮，默认隐藏
@property (nonatomic, strong) UIButton *saveBtn;

@end

NS_ASSUME_NONNULL_END
