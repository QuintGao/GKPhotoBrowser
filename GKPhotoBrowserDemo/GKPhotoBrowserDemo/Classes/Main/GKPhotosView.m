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

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
    
    // 防止出现重用
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (NSInteger i = 0; i < photos.count; i++) {
        SDAnimatedImageView *imgView = [SDAnimatedImageView new];
        imgView.tag = i;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        [self addSubview:imgView];
        
        imgView.userInteractionEnabled = YES;
        [imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick:)]];
        
        NSString *url = photos[i];
        
        if ([url hasPrefix:@"http"]) {
            [imgView sd_setImageWithURL:[NSURL URLWithString:url]];
        }else {
            imgView.image = [UIImage imageNamed:url];
        }
    }
}

- (void)setImages:(NSArray *)images {
    _images = images;
    
    // 防止出现重用
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (NSInteger i = 0; i < images.count; i++) {
        SDAnimatedImageView *imgView = [SDAnimatedImageView new];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        imgView.tag = i;
        [self addSubview:imgView];
        
        imgView.userInteractionEnabled = YES;
        [imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick:)]];
        
        GKTimeLineImage *image = images[i];
        
        if ([image.url hasPrefix:@"http"]) {
            NSString *urlStr = image.thumbnail_url ? image.thumbnail_url : image.url;
            [imgView sd_setImageWithURL:[NSURL URLWithString:urlStr]];
//            [imgView sd_setImageWithURL:[NSURL URLWithString:urlStr] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//                // 裁剪图片，显示中间区域
//                imgView.image = [self cropImage:image];
//            }];
        }else {
            imgView.image = [UIImage imageNamed:image.url];
        }
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
        UIImageView *subview = self.subviews.firstObject;
        
        if (self.images) {
            GKTimeLineImage *image = self.images.firstObject;
            
            if (image.width > maxWidth) {
                photoW = maxWidth;
                photoH = maxWidth / image.scale;
            }else {
                photoW = image.width;
                photoH = image.height;
            }
        }else {
            photoW = subview.image.size.width;
            photoH = subview.image.size.height;
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
        photosW = 100;
        photosH = 200;
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
