//
//  YYAnimatedImageView+GKExtension.m
//  GKPhotoBrowserDemo
//
//  Created by gaokun on 2020/12/9.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import "YYAnimatedImageView+GKExtension.h"

@implementation YYAnimatedImageView (GKExtension)

+ (void)load {
    
    Method displayLayerMethod = class_getInstanceMethod(self, @selector(displayLayer:));
   
    Method displayLayerNewMethod = class_getInstanceMethod(self, @selector(gk_displayLayer:));
 
    method_exchangeImplementations(displayLayerMethod, displayLayerNewMethod);
}

- (void)gk_displayLayer:(CALayer *)layer {
    
    Ivar imgIvar = class_getInstanceVariable([self class], "_curFrame");
    UIImage *img = object_getIvar(self, imgIvar);
    if (img) {
        layer.contents = (__bridge id)img.CGImage;
    } else {
        if (@available(iOS 14.0, *)) {
            [super displayLayer:layer];
        }
    }
}

@end
