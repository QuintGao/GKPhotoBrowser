//
//  GKChatViewCell.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2023/5/25.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKChatViewCell.h"
#import <Masonry/Masonry.h>

@interface GKChatViewCell()

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) UIImageView *playImgView;

@end

@implementation GKChatViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.iconView];
    [self.contentView addSubview:self.imgView];
    [self.contentView addSubview:self.playImgView];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.iconView.mas_left).offset(-10);
        make.centerY.equalTo(self.iconView);
    }];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10);
        make.top.equalTo(self).offset(10);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.nameLabel.mas_right);
        make.top.equalTo(self.iconView.mas_bottom).offset(20);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(80);
    }];
    
    [self.playImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.imgView);
    }];
}

- (void)setModel:(GKTimeLineModel *)model {
    _model = model;
    
    self.nameLabel.text = model.name;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:model.icon.url]];
    
    GKTimeLineImage *img = model.images.firstObject;
    if (img.coverImage) {
        self.imgView.image = img.coverImage;
    }else {
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:img.url]];        
    }
    
    self.playImgView.hidden = !img.isVideo;
}

- (void)imgClick {
    !self.imgClickBlock ?: self.imgClickBlock(self.index);
}

#pragma mark - Lazy
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = UIColor.blackColor;
    }
    return _nameLabel;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.layer.cornerRadius = 20;
        _iconView.layer.masksToBounds = YES;
    }
    return _iconView;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
        _imgView.userInteractionEnabled = YES;
        [_imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick)]];
    }
    return _imgView;
}

- (UIImageView *)playImgView {
    if (!_playImgView) {
        _playImgView = [[UIImageView alloc] init];
        _playImgView.image = [UIImage imageNamed:@"ic_play3"];
    }
    return _playImgView;
}

@end
