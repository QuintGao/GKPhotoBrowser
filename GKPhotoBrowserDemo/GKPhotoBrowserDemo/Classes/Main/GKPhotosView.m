//
//  GKPhotosView.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/6.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

static NSInteger photosMaxCol = 3;
static CGFloat   maxWidth;
static CGFloat   photoMargin;
static CGFloat   photoW;
static CGFloat   photoH;

#import "GKPhotosView.h"
#import "GKTimeLineModel.h"
#import <SDWebImage/SDWebImage.h>
#import <GKPhotoBrowser/GKPhotoBrowser.h>

@interface GKPhotosView()

@end

@implementation GKPhotosView

+ (instancetype)photosViewWithWidth:(CGFloat)width andMargin:(CGFloat)photoMargin {
    return [[self alloc] initWithWidth:width margin:photoMargin];
}

- (instancetype)initWithWidth:(CGFloat)width margin:(CGFloat)margin {
    if (self = [super init]) {
        maxWidth    = width;
        photoMargin = margin;
        
        photoW      = (width - (photosMaxCol - 1) * margin) / photosMaxCol;
        photoH      = photoW;
    }
    return self;
}

- (void)updateWidth:(CGFloat)width {
    maxWidth = width;
    photoW = (width - (photosMaxCol - 1) * photoMargin) / photosMaxCol;
    photoH = photoW;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
    
    // 防止出现重用
//    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (self.subviews.count > 0) return;
    
    for (NSInteger i = 0; i < photos.count; i++) {
        UIImageView *imgView = [NSClassFromString(@"SDAnimatedImageView") new];
        if (!imgView) {
            imgView = [UIImageView new];
        }
        
        imgView.tag = i;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        [self addSubview:imgView];
        
        imgView.userInteractionEnabled = YES;
        [imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick:)]];
        
        NSString *url = photos[i];
        
        if ([url hasPrefix:@"http"]) {
            [imgView sd_setImageWithURL:[NSURL URLWithString:url]];
        }else if ([url hasSuffix:@"gif"]){
            imgView.image = [SDAnimatedImage imageNamed:url];
        }else {
            imgView.image = [UIImage imageNamed:url];
        }
    }
}

- (void)setImages:(NSArray *)images {
    _images = images;
    
    // 防止出现重用
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    if (self.subviews.count > 0) return;
    
    for (NSInteger i = 0; i < images.count; i++) {
        UIImageView *imgView = [NSClassFromString(@"SDAnimatedImageView") new];
        if (!imgView) {
            imgView = [UIImageView new];
        }
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        imgView.tag = i;
        [self addSubview:imgView];
        
        imgView.userInteractionEnabled = YES;
        [imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick:)]];
        
        GKTimeLineImage *image = images[i];
        
        if (image.islocal && image.imageURL) {
            NSData *data = [NSData dataWithContentsOfURL:image.imageURL];
            imgView.image = [UIImage imageWithData:data];
        }else {
            if (image.islocal && image.url) {
                NSURL *url = [NSURL fileURLWithPath:image.url];
                [imgView sd_setImageWithURL:url];
            }else if (image.coverImage) {
                imgView.image = image.coverImage;
            }else if ([image.url hasPrefix:@"http"]) {
                NSString *urlStr = image.thumbnail_url ? image.thumbnail_url : image.url;
                [imgView sd_setImageWithURL:[NSURL URLWithString:urlStr]];
            }else if ([image.url hasSuffix:@"gif"]){
                imgView.image = [SDAnimatedImage imageNamed:image.url];
            }else {
                imgView.image = [UIImage imageNamed:image.url];
            }
        }
        
        if (image.isLivePhoto) {
            UILabel *label = [[UILabel alloc] init];
            label.frame = CGRectMake(0, 0, 40, 20);
            label.text = @"Live";
            label.font = [UIFont systemFontOfSize:14];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = UIColor.whiteColor;
            label.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.6];
            [imgView addSubview:label];
        }
        
        if (image.isVideo) {
            UIImageView *playView = [[UIImageView alloc] init];
            playView.image = GKPhotoBrowserImage(@"gk_video_play");
            [imgView addSubview:playView];
            playView.bounds = CGRectMake(0, 0, 30, 30);
            playView.center = imgView.center;
        }
    }
}

- (void)setPhotoImages:(NSArray *)photoImages {
    _photoImages = photoImages;
    
    // 防止出现重用
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (NSInteger i = 0; i < photoImages.count; i++) {
        UIImageView *imgView = [NSClassFromString(@"SDAnimatedImageView") new];
        if (!imgView) {
            imgView = [UIImageView new];
        }
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        imgView.tag = i;
        [self addSubview:imgView];
        
        imgView.userInteractionEnabled = YES;
        [imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick:)]];
        
        imgView.image = photoImages[i];
    }
}

- (UIImage *)cropImage:(UIImage *)image {
    CGRect rect;
    
    if (image.size.width > image.size.height) {
        rect = CGRectMake((image.size.width - image.size.height) / 2, 0, image.size.height, image.size.height);
    }else if (image.size.width < image.size.height) {
        rect = CGRectMake(0, (image.size.height - image.size.width) / 2, image.size.width, image.size.width);
    }else {
        rect = CGRectMake(0, 0, image.size.width, image.size.height);
    }
    
    rect = CGRectMake(ceilf(rect.origin.x), ceilf(rect.origin.y), ceilf(rect.size.width), ceilf(rect.size.height));
    
    UIGraphicsBeginImageContext(rect.size);
    [image drawAtPoint:CGPointMake(-rect.origin.x, -rect.origin.y)];
    
    UIImage *cropImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return cropImage;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.subviews.count == 1) {
        if (self.images) {
            GKTimeLineImage *image = self.images.firstObject;
            
            if (image.width == 0) {
                image.width = self.frame.size.width;
            }
            
            if (image.width > maxWidth) {
                photoW = maxWidth;
                photoH = maxWidth / image.scale;
            }else {
                photoW = image.width;
                photoH = image.height;
                
                
                if (image.width == 0 || image.height == 0) {
                    photoW = (self.frame.size.width - (photosMaxCol - 1) * 10) / photosMaxCol;
                    photoH = photoW;
                }
            }
        }else {
            photoW = self.frame.size.width;
            photoH = self.frame.size.height;
        }
    }else {
        photoW = (maxWidth - (photosMaxCol - 1) * photoMargin) / photosMaxCol;
        photoH = photoW;
    }
    
    // 布局
    __block CGFloat x = 0;
    __block CGFloat y = 0;
    CGFloat w = photoW;
    CGFloat h = photoH;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSInteger maxCol = self.subviews.count == 4 ? 2 : photosMaxCol;
        
        NSInteger col = idx % maxCol;
        NSInteger row = idx / maxCol;
        
        x = col * (photoW + photoMargin);
        y = row * (photoH + photoMargin);
        
        obj.frame = CGRectMake(x, y, w, h);
        
        if (obj.subviews.count > 0) {
            [obj.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop) {
                obj1.center = CGPointMake(w / 2, h / 2);
            }];
        }
        
        if (obj.subviews) {
            UIView *subview = obj.subviews.firstObject;
            if ([subview isKindOfClass:UILabel.class]) {
                subview.frame = CGRectMake(w - subview.frame.size.width, h - subview.frame.size.height, subview.frame.size.width, subview.frame.size.height);
            }
        }
    }];
}

- (void)imgClick:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(photoTapped:)]) {
        [self.delegate photoTapped:(UIImageView *)tap.view];
    }
}

+ (CGSize)sizeWithCount:(NSInteger)count {
    
    CGFloat photosW = 0;
    CGFloat photosH = 0;
    
    if (count == 1) {
        photosW = photoW;
        photosH = photoH;
    }else {
        NSInteger cols = count == 4 ? 2 : photosMaxCol;
        NSInteger rows = (count + cols - 1) / cols;
        
        photosW = photoW * cols + (cols - 1) * photoMargin;
        photosH = photoH * rows + (rows - 1) * photoMargin;
    }
    
    return CGSizeMake(photosW, photosH);
}

+ (CGSize)sizeWithCount:(NSInteger)count width:(CGFloat)width andMargin:(CGFloat)margin {
    CGFloat photoW = (width - (photosMaxCol - 1) * margin) / photosMaxCol;
    CGFloat photoH = photoW;
    
    CGFloat photosW = 0;
    CGFloat photosH = 0;
    
    if (count == 1) {
        photosW = photoW;
        photosH = photoH;
    }else {
        NSInteger cols = count == 4 ? 2 : photosMaxCol;
        NSInteger rows = (count + cols - 1) / cols;
        
        photosW = photoW * cols + (cols - 1) * margin;
        photosH = photoH * rows + (rows - 1) * margin;
    }
    
    return CGSizeMake(photosW, photosH);
}

+ (CGSize)sizeWithImages:(NSArray *)images width:(CGFloat)width andMargin:(CGFloat)margin {
    NSInteger count = images.count;
    
    CGFloat photoW = (width - (photosMaxCol - 1) * margin) / photosMaxCol;
    CGFloat photoH = photoW;
    
    CGFloat photosW = 0;
    CGFloat photosH = 0;
    
    if (count == 1) {
        GKTimeLineImage *image = images.firstObject;
        
        if (image.width > width) {
            photosW = width;
            photosH = width / image.scale;
        }else {
            photosW = image.width;
            photosH = image.height;
            
            if (image.width == 0 || image.height == 0) {
                photosW = photoW;
                photosH = photoH;
            }
        }
    }else {
        NSInteger cols = count == 4 ? 2 : photosMaxCol;
        NSInteger rows = (count + cols - 1) / cols;
        
        photosW = photoW * cols + (cols - 1) * margin;
        photosH = photoH * rows + (rows - 1) * margin;
    }
    
    return CGSizeMake(photosW, photosH);
}

@end
