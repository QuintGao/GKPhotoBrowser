//
//  GKTimeLineViewCell.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/8.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKTimeLineViewCell.h"

@interface GKTimeLineViewCell()<GKPhotosViewDelegate>

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UIView *lineView;

@end

@implementation GKTimeLineViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.iconView = [UIImageView new];
        [self.contentView addSubview:self.iconView];
        
        self.nameLabel = [UILabel new];
        self.nameLabel.textColor = [UIColor blueColor];
        self.nameLabel.font = kNameFont;
        [self.contentView addSubview:self.nameLabel];
        
        self.contentLabel = [UILabel new];
        self.contentLabel.textColor = [UIColor blackColor];
        self.contentLabel.font = kTextFont;
        self.contentLabel.numberOfLines = 0;
        [self.contentView addSubview:self.contentLabel];
        
        CGFloat photoW = kScreenW - 60 - 50 - 20;
        self.photosView = [GKPhotosView photosViewWithWidth:photoW andMargin:5];
        self.photosView.delegate = self;
        [self.contentView addSubview:self.photosView];
        
        self.lineView = [UIView new];
        self.lineView.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:self.lineView];
    }
    return self;
}

- (void)setTimeLineFrame:(GKTimeLineFrame *)timeLineFrame {
    _timeLineFrame = timeLineFrame;
    
    GKTimeLineModel *model = timeLineFrame.model;
    
    self.iconView.frame = timeLineFrame.iconF;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:model.icon.url]];
    
    self.nameLabel.frame    = timeLineFrame.nameF;
    self.nameLabel.text     = model.name;
    
    self.contentLabel.frame = timeLineFrame.contentF;
    self.contentLabel.text  = model.content;
    
    self.photosView.frame   = timeLineFrame.photosF;
    self.photosView.images  = model.images;
    
    self.lineView.frame = timeLineFrame.lineF;
}

#pragma mark - GKPhotosViewDelegate
- (void)photoTapped:(UIImageView *)imgView {
    
    !self.photosImgClickBlock ? : self.photosImgClickBlock(self, imgView.tag);
    
}

@end
