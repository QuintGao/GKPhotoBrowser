//
//  GKTest02ViewCell.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/27.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

// 一行最大的个数
#define kMaxCols 3
#define margin 10
#define imageW (kScreenW - (kMaxCols + 1) * margin) / kMaxCols
#define imageH imageW

#import "GKTest02ViewCell.h"
#import "GKPhotosView.h"

@interface GKTest02ViewCell()<GKPhotosViewDelegate>

@property (nonatomic, strong) GKPhotosView *photosView;

@end

@implementation GKTest02ViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.photosView = [GKPhotosView photosViewWithWidth:kScreenW - 20 andMargin:10];
        self.photosView.delegate = self;
        [self.contentView addSubview:self.photosView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = [GKPhotosView sizeWithCount:self.photos.count];
    
    self.photosView.frame = CGRectMake(10, 10, size.width, size.height);
}

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
    
    self.photosView.photos = photos;
}

#pragma mark - GKPhotosViewDelegate
- (void)photoTapped:(UIImageView *)imgView {
    !self.imgClickBlock ? : self.imgClickBlock(self.photosView, self.photos, imgView.tag);
}

+ (CGFloat)cellHeightWithCount:(NSInteger)count {
//    return [GKPhotosView sizeWithCount:count].height + 20;
    return [GKPhotosView sizeWithCount:count width:kScreenW - 20 andMargin:10].height + 20;
}

@end
