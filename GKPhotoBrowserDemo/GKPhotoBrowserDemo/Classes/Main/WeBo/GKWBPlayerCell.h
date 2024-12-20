//
//  GKWBPlayerCell.h
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2024/9/5.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import <GKVideoScrollView/GKVideoScrollView.h>
#import "GKWBModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKWBPlayerCell : GKVideoViewCell

@property (nonatomic, strong) UIImageView *coverImgView;

- (void)loadData:(GKWBModel *)model;

@end

NS_ASSUME_NONNULL_END
