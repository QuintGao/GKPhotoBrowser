//
//  GKVideoViewCell.h
//  GKVideoScrollView
//
//  Created by QuintGao on 2023/4/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKVideoViewCell : UIView

- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier;

// 唯一标识
@property (nonatomic, readonly, copy, nullable) NSString *reuseIdentifier;

// 准备重用时调用
- (void)prepareForReuse NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
