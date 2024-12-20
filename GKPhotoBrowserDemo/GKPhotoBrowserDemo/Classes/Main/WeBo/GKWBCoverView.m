//
//  GKWBCoverView.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2024/12/19.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import "GKWBCoverView.h"
#import <GKPhotoBrowser/GKPhotoBrowser.h>
#import <Masonry/Masonry.h>
#import "GKTimeLineModel.h"

@interface GKWBCoverView()

@property (nonatomic, strong) UILabel *countLabel;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *moreBtn;

@property (nonatomic, strong) UIButton *shareBtn;

@property (nonatomic, strong) UIButton *commentBtn;

@property (nonatomic, strong) UIButton *likeBtn;

@end

@implementation GKWBCoverView

@synthesize browser;

- (void)addCoverToView:(UIView *)view {
    [view addSubview:self.countLabel];
    [view addSubview:self.titleLabel];
    [view addSubview:self.moreBtn];
    [view addSubview:self.shareBtn];
    [view addSubview:self.commentBtn];
    [view addSubview:self.likeBtn];
    
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(10);
        make.top.equalTo(view).offset(GK_SAFEAREA_TOP + 30);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.centerY.equalTo(self.countLabel);
    }];
    
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view).offset(-10);
        make.centerY.equalTo(self.countLabel);
    }];
    
    [self.shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.commentBtn.mas_left).offset(-20);
        make.centerY.equalTo(self.likeBtn);
    }];
    
    [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.likeBtn.mas_left).offset(-20);
        make.centerY.equalTo(self.likeBtn);
    }];
    
    [self.likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view).offset(-10);
        make.bottom.equalTo(view).offset(-(GK_SAFEAREA_BTM + 30));
    }];
}

- (void)updateLayoutWithFrame:(CGRect)frame {
    
}

- (void)updateCoverWithPhoto:(GKPhoto *)photo {
    if ([photo.extraInfo isKindOfClass:GKTimeLineImage.class]) {
        GKTimeLineImage *image = (GKTimeLineImage *)photo.extraInfo;
        self.titleLabel.text = image.name;
    }
}

- (void)updateCoverWithCount:(NSInteger)count index:(NSInteger)index {
    self.countLabel.text = [NSString stringWithFormat:@"%zd/%zd", index+1, count];
}

- (void)willDisappear {
    self.countLabel.hidden = YES;
    self.titleLabel.hidden = YES;
    self.moreBtn.hidden = YES;
    self.shareBtn.hidden = YES;
    self.commentBtn.hidden = YES;
    self.likeBtn.hidden = YES;
}

- (void)didAppear {
    self.countLabel.hidden = NO;
    self.titleLabel.hidden = NO;
    self.moreBtn.hidden = NO;
    self.shareBtn.hidden = NO;
    self.commentBtn.hidden = NO;
    self.likeBtn.hidden = NO;
}

#pragma mark - lazy
- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.font = [UIFont systemFontOfSize:15];
        _countLabel.textColor = UIColor.whiteColor;
    }
    return _countLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textColor = UIColor.whiteColor;
    }
    return _titleLabel;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [[UIButton alloc] init];
        [_moreBtn setImage:[UIImage imageNamed:@"cm4_video_btn_more"] forState:UIControlStateNormal];
        [_moreBtn setImage:[UIImage imageNamed:@"cm4_video_btn_more_prs"] forState:UIControlStateHighlighted];
    }
    return _moreBtn;
}

- (UIButton *)shareBtn {
    if (!_shareBtn) {
        _shareBtn = [[UIButton alloc] init];
        [_shareBtn setImage:[UIImage imageNamed:@"cm2_list_detail_icn_share"] forState:UIControlStateNormal];
    }
    return _shareBtn;
}

- (UIButton *)commentBtn {
    if (!_commentBtn) {
        _commentBtn = [[UIButton alloc] init];
        [_commentBtn setImage:[UIImage imageNamed:@"cm2_list_detail_icn_cmt"] forState:UIControlStateNormal];
    }
    return _commentBtn;
}

- (UIButton *)likeBtn {
    if (!_likeBtn) {
        _likeBtn = [[UIButton alloc] init];
        [_likeBtn setImage:[UIImage imageNamed:@"cm2_poplay_icn_praise"] forState:UIControlStateNormal];
    }
    return _likeBtn;
}

@end
