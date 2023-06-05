//
//  GKLargeImageView.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2023/6/1.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKLargeImageView.h"

@interface GKLargeView : UIView

@property (nonatomic, assign) NSInteger tiledCount;

@end

@implementation GKLargeView {
    UIImage *originImage;
    CGRect imageRect;
    CGFloat imageScale;
}

+ (Class)layerClass {
    return CATiledLayer.class;
}

- (instancetype)init {
    if (self = [super init]) {
        self.tiledCount = 100;
    }
    return self;
}

- (void)setImage:(UIImage *)image completion:(void(^)(void))completion {
    originImage = image;
    imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    imageScale = self.frame.size.width / imageRect.size.width;
    CATiledLayer *tiledLayer = (CATiledLayer *)self.layer;
    int lev = ceil(log2(1 / imageScale)) + 1;
    tiledLayer.levelsOfDetail = 1;
    tiledLayer.levelsOfDetailBias = lev;
    NSInteger tileSizeScale = sqrt(self.tiledCount) / 2;
    CGSize tileSize = self.bounds.size;
    tileSize.width /= tileSizeScale;
    tileSize.height /= tileSizeScale;
    tiledLayer.tileSize = tileSize;
    [self setNeedsDisplay];
    !completion ?: completion();
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (CGRectEqualToRect(imageRect, CGRectZero)) return;
    
    imageScale = self.frame.size.width / imageRect.size.width;
    CATiledLayer *tiledLayer = (CATiledLayer *)self.layer;
    NSInteger tileSizeScale = sqrt(self.tiledCount) / 2;
    CGSize tileSize = self.bounds.size;
    tileSize.width /= tileSizeScale;
    tileSize.height /= tileSizeScale;
    tiledLayer.tileSize = tileSize;
}

- (void)drawRect:(CGRect)rect {
    if (!originImage) return;
    
    //将视图frame映射到实际图片的frame
    CGRect imageCutRect = CGRectMake(rect.origin.x / imageScale, rect.origin.y / imageScale,rect.size.width / imageScale,rect.size.height / imageScale);
    
    //截取指定图片区域，重绘
    @autoreleasepool {
        CGImageRef imageRef = CGImageCreateWithImageInRect(originImage.CGImage, imageCutRect);
        UIImage *tileImage = [UIImage imageWithCGImage:imageRef];
        CGContextRef context = UIGraphicsGetCurrentContext();
        UIGraphicsPushContext(context);
        [tileImage drawInRect:rect];
        UIGraphicsPopContext();
        CGImageRelease(imageRef);
    }
}

@end

@interface GKLargeImageView()

@property (nonatomic, strong) GKLargeView *largeView;

@end

@implementation GKLargeImageView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.largeView.frame = self.bounds;
}

- (void)addTiledLayerWithImage:(UIImage *)image {
    self.largeView = [[GKLargeView alloc] init];
    self.largeView.frame = self.bounds;
    [self addSubview:self.largeView];
    
    [self.largeView setImage:image completion:nil];
}

@end
