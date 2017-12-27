//
//  GKToutiaoViewCell.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/9.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKToutiaoModel.h"

static NSString *const kToutiaoViewCellID = @"kToutiaoViewCellID";

@interface GKToutiaoViewCell : UITableViewCell

@property (nonatomic, strong) UIView *photosView;

@property (nonatomic, strong) GKToutiaoModel *model;

@end
