//
//  GKTimelineModel.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/8.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

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

@property (nonatomic, assign) BOOL islocal;

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSURL *videoURL;

@property (nonatomic, copy) NSString *thumbnail_url;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) PHAsset *image_asset;

@property (nonatomic, copy) NSString *video_url;
@property (nonatomic, assign) BOOL   isVideo;

@property (nonatomic, strong) UIImage *coverImage;
@property (nonatomic, strong) PHAsset *video_asset;

@property (nonatomic, assign) BOOL isLivePhoto;

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

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat cellHeight;

- (void)updateFrameWithWidth:(CGFloat)width;

@end
