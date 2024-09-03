//
//  UIImage+GKPhotoBrowser.h
//  GKPhotoBrowser
//
//  Created by QuintGao on 2024/8/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (GKPhotoBrowser)

+ (UIImage *)gkbrowser_imageNamed:(NSString *)name;

+ (UIImage *)gkbrowser_imageWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
