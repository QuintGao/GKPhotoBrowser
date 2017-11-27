//
//  GKTimeLineViewCell.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/8.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKPhotosView.h"
#import "GKTimeLineModel.h"

static NSString *const kTimeLineViewCellID = @"kTimeLineViewCellID";

@interface GKTimeLineViewCell : UITableViewCell

@property (nonatomic, strong) GKPhotosView *photosView;

@property (nonatomic, strong) GKTimeLineFrame *timeLineFrame;

@property (nonatomic, copy) void(^photosImgClickBlock)(GKTimeLineViewCell *cell, NSInteger index);

@end
