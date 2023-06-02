//
//  GKLargeImageView.h
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2023/6/1.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GKPhotoBrowser/GKPhotoBrowser.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKLargeImageView : UIImageView

@property (nonatomic, strong) NSURL *url;

- (void)addTiledLayerWithImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
