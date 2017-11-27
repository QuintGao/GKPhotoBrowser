//
//  GKPhotosView.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/6.
//  Copyright © 2017年 QuintGao. All rights reserved.
//  创建九宫格的视图

#import <UIKit/UIKit.h>

@protocol GKPhotosViewDelegate<NSObject>

- (void)photoTapped:(UIImageView *)imgView;

@end

@interface GKPhotosView : UIView

/**
 代理
 */
@property (nonatomic, weak) id<GKPhotosViewDelegate> delegate;
/**
 存储图片地址或路径的数组
 */
@property (nonatomic, strong) NSArray *photos;

@property (nonatomic, strong) NSArray *images;

+ (GKPhotosView *)photosViewWithWidth:(CGFloat)width andMargin:(CGFloat)photoMargin;

+ (CGSize)sizeWithCount:(NSInteger)count;

+ (CGSize)sizeWithCount:(NSInteger)count width:(CGFloat)width andMargin:(CGFloat)photoMargin;

+ (CGSize)sizeWithImages:(NSArray *)images width:(CGFloat)width andMargin:(CGFloat)photoMargin;

@end
