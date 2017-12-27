//
//  GKToutiaoModel.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/9.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKToutiaoModel.h"

@implementation GKToutiaoModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"images"        : [GKToutiaoImage class]};
}

- (CGFloat)cellHeight {
    if (!_cellHeight) {
        _cellHeight = 15;
        
        _cellHeight += [self sizeWithText:self.content font:kContentFont maxW:kPhotoW].height;
        
        _cellHeight += 5;
        
        _cellHeight += kPhotoH;
        
        _cellHeight += 15;
    }
    return _cellHeight;
}

- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxW:(CGFloat)maxW {
    CGSize size = CGSizeMake(maxW, CGFLOAT_MAX);
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:size options:options attributes:attrs context:nil].size;
}

@end

@implementation GKToutiaoImage

- (CGFloat)scale {
    return self.width / self.height;
}

@end
