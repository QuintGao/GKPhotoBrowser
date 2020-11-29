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

@interface UINavigationController (GKCategory)

+ (instancetype)rootVC:(UIViewController *)rootVC translationScale:(BOOL)translationScale;

- (instancetype)initWithRootVC:(UIViewController *)rootVC translationScale:(BOOL)translationScale;

/** 导航栏转场时是否缩放,此属性只能在初始化导航栏的时候有效，在其他地方设置会导致错乱 */
@property (nonatomic, assign, readonly) BOOL gk_translationScale;

/** 是否开启左滑push操作，默认是NO，此时不可禁用控制器的滑动返回手势 */
@property (nonatomic, assign) BOOL gk_openScrollLeftPush;

/// 是否开启手势处理，默认为NO
/// 只能通过上面的两个初始化方法开启
@property (nonatomic, assign, readonly) BOOL gk_openGestureHandle;

@end
