//
//  UINavigationController+GKCategory.h
//  GKNavigationBarViewController
//
//  Created by QuintGao on 2017/7/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+GKCategory.h"
#import "UIBarButtonItem+GKCategory.h"
#import "GKDelegateHandler.h"

@interface UINavigationController (GKCategory)

+ (instancetype)rootVC:(UIViewController *)rootVC translationScale:(BOOL)translationScale;

- (instancetype)initWithRootVC:(UIViewController *)rootVC translationScale:(BOOL)translationScale;

/** 导航栏转场时是否缩放,此属性只能在初始化导航栏的时候有效，在其他地方设置会导致错乱 */
@property (nonatomic, assign, readonly) BOOL gk_translationScale;

/** 是否开启左滑push操作，默认是NO，此时不可禁用控制器的滑动返回手势 */
@property (nonatomic, assign) BOOL gk_openScrollLeftPush;

/** 是否禁止导航控制器的手势处理，默认NO，如果设置为YES，则手势操作将失效(包括全屏手势和边缘手势) */
@property (nonatomic, assign) BOOL gk_disabledGestureHandle;

@end
