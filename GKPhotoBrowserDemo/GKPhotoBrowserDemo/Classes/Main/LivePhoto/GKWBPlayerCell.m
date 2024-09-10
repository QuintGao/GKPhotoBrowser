//
//  GKWBPlayerCell.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2024/9/5.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import "GKWBPlayerCell.h"

@interface GKWBPlayerCell()

@end

@implementation GKWBPlayerCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.coverImgView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.coverImgView.frame = self.bounds;
}

- (void)loadData:(GKWBModel *)model {
    [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:model.cover_url]];
}

#pragma mark - lazy
- (UIImageView *)coverImgView {
    if (!_coverImgView) {
        _coverImgView = [[UIImageView alloc] init];
        _coverImgView.userInteractionEnabled = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _coverImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _coverImgView;
}

@end
