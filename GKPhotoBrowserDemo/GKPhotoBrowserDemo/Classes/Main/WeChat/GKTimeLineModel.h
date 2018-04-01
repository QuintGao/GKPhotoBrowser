//
//  GKTimelineModel.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/8.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNameFont [UIFont systemFontOfSize:16.0]
#define kTextFont [UIFont systemFontOfSize:15.0]

@class GKTimeLineModel, GKTimeLineImage;

@interface GKTimeLineModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) GKTimeLineImage *icon;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, strong) NSArray<GKTimeLineImage *> *images;

@property (nonatomic, strong) NSArray *imageUrls;

@end

@interface GKTimeLineImage : NSObject

@property (nonatomic, copy) NSString *thumbnail_url;
@property (nonatomic, copy) NSString *url;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

/** 宽高比 = 宽/高 */
@property (nonatomic, assign) CGFloat scale;

@end

@interface GKTimeLineFrame : NSObject

@property (nonatomic, strong) GKTimeLineModel *model;

@property (nonatomic, assign) CGRect nameF;
@property (nonatomic, assign) CGRect iconF;
@property (nonatomic, assign) CGRect contentF;
@property (nonatomic, assign) CGRect photosF;

@property (nonatomic, assign) CGRect lineF;

@property (nonatomic, assign) CGFloat cellHeight;

@end
