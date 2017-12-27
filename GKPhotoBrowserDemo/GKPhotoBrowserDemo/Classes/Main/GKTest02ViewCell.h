//
//  GKTest02ViewCell.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/27.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GKTest02ViewCell : UITableViewCell

@property (nonatomic, strong) NSArray *photos;

@property (nonatomic, copy) void(^imgClickBlock)(UIView *containerView, NSArray *photos, NSInteger index);

+ (CGFloat)cellHeightWithCount:(NSInteger)count;

@end
