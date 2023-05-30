//
//  GKChatViewCell.h
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2023/5/25.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKTimeLineModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKChatViewCell : UITableViewCell

@property (nonatomic, strong) GKTimeLineModel *model;
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, copy) void(^imgClickBlock)(NSInteger index);

@property (nonatomic, strong) UIImageView *imgView;

@end

NS_ASSUME_NONNULL_END
