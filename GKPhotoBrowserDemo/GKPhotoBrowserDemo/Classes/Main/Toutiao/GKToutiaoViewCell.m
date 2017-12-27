//
//  GKToutiaoViewCell.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/9.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKToutiaoViewCell.h"

@interface GKToutiaoViewCell()

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UIButton *countBtn;

@end

@implementation GKToutiaoViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.contentLabel = [UILabel new];
        self.contentLabel.font = kContentFont;
        self.contentLabel.textColor = [UIColor blackColor];
        self.contentLabel.numberOfLines = 0;
        [self.contentView addSubview:self.contentLabel];
        
        self.photosView = [UIView new];
        [self.contentView addSubview:self.photosView];
        
        for (NSInteger i = 0; i < 3; i++) {
            UIImageView *imgView = [UIImageView new];
            [self.photosView addSubview:imgView];
        }
        
        self.countBtn = [UIButton new];
        self.countBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.countBtn.layer.cornerRadius = 5;
        self.countBtn.layer.masksToBounds = YES;
        [self.contentView addSubview:self.countBtn];
    }
    return self;
}

- (void)setModel:(GKToutiaoModel *)model {
    _model = model;
    
    self.contentLabel.text = model.content;
    self.contentLabel.frame = CGRectMake(15, 15, 0, 0);
    self.contentLabel.width = kPhotoW;
    [self.contentLabel sizeToFit];
    
    self.photosView.frame = CGRectMake(15, CGRectGetMaxY(self.contentLabel.frame) + 5, kPhotoW, kPhotoH);
    [self.photosView.subviews enumerateObjectsUsingBlock:^(__kindof UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        GKToutiaoImage *image = model.images[idx];
        
        [obj sd_setImageWithURL:[NSURL URLWithString:image.url]];
        CGFloat w = (kPhotoW - 2 * 5) / 3;
        CGFloat h = kPhotoH;
        CGFloat x = idx * (w + 5);
        CGFloat y = 0;
        obj.frame = CGRectMake(x, y, w, h);
    }];
    
    // 图片个数
    NSString *countText = [NSString stringWithFormat:@"%zd图", model.images.count];
    
    [self.countBtn setTitle:countText forState:UIControlStateNormal];
    self.countBtn.frame = CGRectMake(self.photosView.right - 50 - 10, self.photosView.bottom - 30 - 10, 50, 30);
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = [UIColor grayColor];
    lineView.frame = CGRectMake(15, CGRectGetMaxY(self.photosView.frame) + 15, kPhotoW, 0.5);
    [self.contentView addSubview:lineView];
}

@end
