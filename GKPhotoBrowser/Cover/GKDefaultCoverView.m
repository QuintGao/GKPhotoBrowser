//
//  GKDefaultCoverView.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2024/12/11.
//

#import "GKDefaultCoverView.h"
#import "GKPhotoBrowser.h"

@implementation GKDefaultCoverView

#pragma mark - GKCoverViewProtocol
@synthesize browser;

- (void)addCoverToView:(UIView *)view {
    [view addSubview:self.countLabel];
    [view addSubview:self.pageControl];
    [view addSubview:self.saveBtn];
    
    self.pageControl.numberOfPages = self.browser.photos.count;
    CGSize size = [self.pageControl sizeForNumberOfPages:self.browser.photos.count];
    self.pageControl.bounds = CGRectMake(0, 0, size.width, size.height);
}

- (void)updateLayoutWithFrame:(CGRect)frame {
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    
    CGFloat centerX = width * 0.5;
    CGFloat centerY = 0;
    if (self.browser.isLandscape) {
        centerY = height - 20;
    }else {
        centerY = height - 20 - (self.browser.configure.isAdaptiveSafeArea ? kSafeBottomSpace : 0);
    }
    
    self.countLabel.center = CGPointMake(centerX, (KIsiPhoneX && !self.browser.isLandscape) ? (kSafeTopSpace + 10) : 30);
    CGSize size = [self.pageControl sizeForNumberOfPages:self.browser.photos.count];
    self.pageControl.bounds = CGRectMake(0, 0, size.width, size.height);
    self.pageControl.center = CGPointMake(centerX, centerY);
    self.saveBtn.center = CGPointMake(width - 60, centerY);
}

- (void)updateCoverWithCount:(NSInteger)count index:(NSInteger)index {
    self.countLabel.text = [NSString stringWithFormat:@"%zd/%zd", (long)(index + 1), (long)count];
    self.pageControl.currentPage = index;
}

- (void)updateCoverWithPhoto:(GKPhoto *)photo {
    if (photo.isVideo) {
        self.countLabel.hidden = YES;
        self.pageControl.hidden = YES;
        self.saveBtn.hidden = YES;
    }else {
        if (self.browser.configure.hidesCountLabel) {
            self.countLabel.hidden = YES;
        }else {
            self.countLabel.hidden = self.browser.photos.count <= 1;
        }
        
        if (self.browser.configure.hidesPageControl) {
            self.pageControl.hidden = YES;
        }else {
            if (self.pageControl.hidesForSinglePage) {
                self.pageControl.hidden = self.browser.photos.count <= 1;
            }
        }
        self.saveBtn.hidden = self.browser.configure.hidesSavedBtn;
    }
}

#pragma mark - action
- (void)saveBtnClick:(UIButton *)btn {
    if ([self.browser.delegate respondsToSelector:@selector(photoBrowser:onSaveBtnClick:image:)]) {
        [self.browser.delegate photoBrowser:self.browser onSaveBtnClick:self.browser.currentIndex image:self.browser.curPhotoView.imageView.image];
    }
}

#pragma mark - lazy
- (UILabel *)countLabel {
    if (!_countLabel) {
        UILabel *countLabel = [UILabel new];
        countLabel.textColor = UIColor.whiteColor;
        countLabel.font = [UIFont systemFontOfSize:16.0f];
        countLabel.textAlignment = NSTextAlignmentCenter;
        countLabel.bounds = CGRectMake(0, 0, 80, 30);
        countLabel.hidden = YES;
        _countLabel = countLabel;
    }
    return _countLabel;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        UIPageControl *pageControl = [UIPageControl new];
        pageControl.hidesForSinglePage = YES;
        pageControl.hidden = YES;
        pageControl.enabled = NO;
        if (@available(iOS 14.0, *)) {
            pageControl.backgroundStyle = UIPageControlBackgroundStyleMinimal;
        }
        _pageControl = pageControl;
    }
    return _pageControl;
}

- (UIButton *)saveBtn {
    if (!_saveBtn) {
        UIButton *saveBtn = [UIButton new];
        saveBtn.bounds = CGRectMake(0, 0, 50, 30);
        [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [saveBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        saveBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        saveBtn.layer.cornerRadius = 5;
        saveBtn.layer.masksToBounds = YES;
        saveBtn.layer.borderColor = UIColor.whiteColor.CGColor;
        saveBtn.layer.borderWidth = 1;
        saveBtn.hidden = YES;
        [saveBtn addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _saveBtn = saveBtn;
    }
    return _saveBtn;
}

@end
