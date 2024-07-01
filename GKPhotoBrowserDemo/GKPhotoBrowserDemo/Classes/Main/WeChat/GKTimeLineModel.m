//
//  GKTimelineModel.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/8.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKTimeLineModel.h"
#import "GKPhotosView.h"

@implementation GKTimeLineModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"images"        : [GKTimeLineImage class],
             @"icon"          : [GKTimeLineImage class]
             };
}

- (NSArray *)imageUrls {
    if (!_imageUrls) {
        NSMutableArray *imageUrls = [NSMutableArray new];
        for (GKTimeLineImage *image in self.images) {
            [imageUrls addObject:image.url];
        }
        
        _imageUrls = imageUrls;
    }
    return _imageUrls;
}

@end

@implementation GKTimeLineImage

- (CGFloat)scale {
    return self.width / self.height;
}

- (BOOL)isVideo {
    return !self.isLivePhoto && (self.video_url.length > 0 || self.video_asset || self.videoURL);
}

@end

@implementation GKTimeLineFrame

- (void)setModel:(GKTimeLineModel *)model {
    _model = model;
    
    [self updateFrameWithWidth:self.width];
}

- (void)updateFrameWithWidth:(CGFloat)width {
    CGFloat iconX = 10;
    CGFloat iconY = 15;
    CGFloat iconWH = 40;
    _iconF = (CGRect){{iconX, iconY}, {iconWH, iconWH}};
    
    CGFloat nameX = CGRectGetMaxX(_iconF) + 10;
    CGFloat nameY = iconY + 2;
    CGSize nameSize = [self sizeWithText:_model.name font:kNameFont];
    _nameF = (CGRect){{nameX, nameY}, nameSize};
    
    CGFloat contentX = nameX;
    CGFloat contentY = CGRectGetMaxY(_nameF) + 10;
    CGFloat maxW = width - contentX - 50;
    CGSize contentSize = [self sizeWithText:_model.content font:kTextFont maxW:maxW];
    _contentF = (CGRect){{contentX, contentY}, {maxW, contentSize.height}};
    
    CGFloat photosX = contentX;
    CGFloat photosY = CGRectGetMaxY(_contentF) + 10;
    CGFloat photosW = maxW - 20;
    CGSize photosSize = [GKPhotosView sizeWithImages:_model.images width:photosW andMargin:5];
    _photosF = (CGRect){{photosX, photosY}, photosSize};
    
    CGFloat lineX = 0;
    CGFloat lineY = CGRectGetMaxY(_photosF) + 10;
    CGFloat lineW = width;
    CGFloat lineH = 0.5;
    _lineF = CGRectMake(lineX, lineY, lineW, lineH);
    
    _cellHeight = CGRectGetMaxY(_lineF);
}

- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font {
    return [text sizeWithAttributes:@{NSFontAttributeName: font}];
}

- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxW:(CGFloat)maxW {
    CGSize size = CGSizeMake(maxW, CGFLOAT_MAX);
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:size options:options attributes:attrs context:nil].size;
}

@end
