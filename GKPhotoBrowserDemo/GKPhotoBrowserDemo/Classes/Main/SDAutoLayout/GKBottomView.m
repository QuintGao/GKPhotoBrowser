//
//  GKSDBottomView.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2018/8/13.
//  Copyright © 2018年 QuintGao. All rights reserved.
//

#import "GKBottomView.h"

@interface GKBottomView()

@property (nonatomic, strong) UILabel   *textLabel;

@property (nonatomic, strong) UIButton  *shareBtn;
@property (nonatomic, strong) UIButton  *commentBtn;
@property (nonatomic, strong) UIButton  *praiseBtn;

@end

@implementation GKBottomView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.textLabel];
        [self addSubview:self.shareBtn];
        [self addSubview:self.commentBtn];
        [self addSubview:self.praiseBtn];
        
        self.textLabel.sd_layout.leftSpaceToView(self, 5).topEqualToView(self).heightIs(28.0f).widthIs(KScreenW);
        
        self.praiseBtn.sd_layout.rightSpaceToView(self, 5).topSpaceToView(self, 24).widthIs(40).heightEqualToWidth();
        
        self.commentBtn.sd_layout.rightSpaceToView(self.praiseBtn, 10).centerYEqualToView(self.praiseBtn).widthIs(40).heightEqualToWidth();
        
        self.shareBtn.sd_layout.rightSpaceToView(self.commentBtn, 10).centerYEqualToView(self.praiseBtn).widthIs(40).heightEqualToWidth();
    }
    return self;
}

- (void)setText:(NSString *)text {
    _text = text;
    
    self.textLabel.text = text;
}

#pragma mark - 懒加载
- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [UILabel new];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    return _textLabel;
}

- (UIButton *)shareBtn {
    if (!_shareBtn) {
        _shareBtn = [UIButton new];
        [_shareBtn setImage:[UIImage imageNamed:@"cm2_list_detail_icn_share"] forState:UIControlStateNormal];
    }
    return _shareBtn;
}

- (UIButton *)commentBtn {
    if (!_commentBtn) {
        _commentBtn = [UIButton new];
        [_commentBtn setImage:[UIImage imageNamed:@"cm2_list_detail_icn_cmt"] forState:UIControlStateNormal];
    }
    return _commentBtn;
}

- (UIButton *)praiseBtn {
    if (!_praiseBtn) {
        _praiseBtn = [UIButton new];
        [_praiseBtn setImage:[UIImage imageNamed:@"cm2_poplay_icn_praise"] forState:UIControlStateNormal];
    }
    return _praiseBtn;
}

@end
