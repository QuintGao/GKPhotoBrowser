//
//  GKTest01ViewCell.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/25.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKTest01ViewCell.h"

@implementation GKTest01ViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.imgView = [UIImageView new];
        [self.contentView addSubview:self.imgView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imgView.frame = self.contentView.bounds;
}

@end
