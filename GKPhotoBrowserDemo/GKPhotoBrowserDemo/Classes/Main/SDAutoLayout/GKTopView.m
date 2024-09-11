//
//  GKTopView.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2018/8/14.
//  Copyright © 2018年 QuintGao. All rights reserved.
//

#import "GKTopView.h"
#import <SDAutoLayout/SDAutoLayout.h>

@interface GKTopView()

@property (nonatomic, strong) UILabel   *countLabel;

@property (nonatomic, strong) UIButton  *moreBtn;

@end

@implementation GKTopView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.countLabel];
        [self addSubview:self.moreBtn];
        
        self.countLabel.sd_layout
        .leftSpaceToView(self, 10)
        .bottomSpaceToView(self, 10)
        .widthIs(100)
        .heightIs(30);
        
        self.moreBtn.sd_layout
        .rightSpaceToView(self, 10)
        .centerYEqualToView(self.countLabel)
        .widthIs(41)
        .heightEqualToWidth();
    }
    return self;
}

- (void)setupCurrent:(NSInteger)current total:(NSInteger)total {
    self.countLabel.text = [NSString stringWithFormat:@"%zd/%zd", current, total];
}

#pragma mark - 懒加载
- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [UILabel new];
        _countLabel.font = [UIFont systemFontOfSize:15];
        _countLabel.textColor = [UIColor whiteColor];
    }
    return _countLabel;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [UIButton new];
        [_moreBtn setImage:[UIImage imageNamed:@"cm4_video_btn_more"] forState:UIControlStateNormal];
        [_moreBtn setImage:[UIImage imageNamed:@"cm4_video_btn_more_prs"] forState:UIControlStateHighlighted];
    }
    return _moreBtn;
}

@end
