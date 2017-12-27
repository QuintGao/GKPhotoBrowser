//
//  GKToutiaoModel.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/9.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kContentFont [UIFont systemFontOfSize:15.0]
#define kPhotoW kScreenW - 30
#define kPhotoH 80

@class GKToutiaoImage;

@interface GKToutiaoModel : NSObject

@property (nonatomic, assign) NSInteger type;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, strong) NSArray<GKToutiaoImage *> *images;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, assign) CGFloat cellHeight;

@end

@interface GKToutiaoImage : NSObject

@property (nonatomic, copy) NSString *url;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGFloat scale;

@property (nonatomic, copy) NSString *desc;

@end
