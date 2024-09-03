//
//  UIImage+GKPhotoBrowser.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2024/8/30.
//

#import "UIImage+GKPhotoBrowser.h"

@implementation UIImage (GKPhotoBrowser)

+ (UIImage *)gkbrowser_imageNamed:(NSString *)name {
    if (name.length <= 0) return nil;
    static NSBundle *resourceBundle = nil;
    if (!resourceBundle) {
        NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"GKPhotoBrowser")];
        NSURL *bundleURL = [bundle URLForResource:@"GKPhotoBrowser" withExtension:@"bundle"];
        if (bundleURL == nil) {
            NSURL *associatedBundleURL = [NSBundle.mainBundle URLForResource:@"Frameworks" withExtension:nil];
            NSURL *url = [[associatedBundleURL URLByAppendingPathComponent:@"GKPhotoBrowser"] URLByAppendingPathExtension:@"framework"];
            if (url) {
                NSBundle *associatedBundle = [NSBundle bundleWithURL:url];
                bundleURL = [associatedBundle URLForResource:@"GKPhotoBrowser" withExtension:@"bundle"];
            }
        }
        resourceBundle = [NSBundle bundleWithURL:bundleURL] ?: bundle;
    }
    UIImage *image = [UIImage imageNamed:name inBundle:resourceBundle compatibleWithTraitCollection:nil];
    if (!image) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:nil];
        if (url) {
            NSData *data = [NSData dataWithContentsOfURL:url];
            image = [self gkbrowser_imageWithData:data];
        }
        
        if (!image) {
            image = [UIImage imageNamed:name inBundle:NSBundle.mainBundle compatibleWithTraitCollection:nil];
        }
    }
    return image;
}

+ (UIImage *)gkbrowser_imageWithData:(NSData *)data {
    if (!data) return nil;
    // 创建图片源
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    // 判断是否是图片
    CFStringRef type = CGImageSourceGetType(source);
    
    if (type == NULL) {
        CFRelease(source);
        return [UIImage imageWithData:data];
    }
    
    NSString *typeString = [NSString stringWithFormat:@"%@", type];
    if (![typeString isEqualToString:@"com.compuserve.gif"]) {
        return [UIImage imageWithData:data];
    }
    
    // 获取图片帧数
    size_t count = CGImageSourceGetCount(source);
    
    // 创建可变数组，用来存储每一帧图片
    NSMutableArray *images = [NSMutableArray array];
    
    // 遍历每一帧
    for (size_t i = 0; i < count; i++) {
        // 从图片源中获取每一帧的CGImage
        CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
        [images addObject:[UIImage imageWithCGImage:image]];
        CGImageRelease(image);
    }
    
    CFRelease(source);
    
    // 设置动画图片数组和持续时间
    UIImage *animatedImage = [UIImage animatedImageWithImages:images duration:count * 0.1];
    
    return animatedImage;
}

@end
