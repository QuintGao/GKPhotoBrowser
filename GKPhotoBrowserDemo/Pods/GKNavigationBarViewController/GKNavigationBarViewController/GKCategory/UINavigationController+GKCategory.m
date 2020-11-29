//
//  UINavigationController+GKCategory.m
//  GKNavigationBarViewController
//
//  Created by QuintGao on 2017/7/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "UINavigationController+GKCategory.h"
#import "GKNavigationBarViewController.h"
#import "GKNavigationInteractiveTransition.h"
#import <objc/runtime.h>

@implementation UINavigationController (GKCategory)

+ (instancetype)rootVC:(UIViewController *)rootVC translationScale:(BOOL)translationScale {
    return [[self alloc] initWithRootVC:rootVC translationScale:translationScale];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
 
- (instancetype)initWithRootVC:(UIViewController *)rootVC translationScale:(BOOL)translationScale {
    if (self = [super init]) {
        self.gk_openGestureHandle = YES;
        self.gk_translationScale = translationScale;
        [self pushViewController:rootVC animated:YES];
    }
    return self;
}

#pragma clang diagnostic pop

// 方法交换
+ (void)load {
    // 保证其只执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gk_swizzled_method(@"gkNav", self, @"viewDidLoad", self);
    });
}

- (void)gkNav_viewDidLoad {
    if (self.gk_openGestureHandle) {
        // 处理特殊控制器
        if ([self isKindOfClass:[UIImagePickerController class]]) return;
        if ([self isKindOfClass:[UIVideoEditorController class]]) return;
        
        // 设置背景色
        self.view.backgroundColor = [UIColor blackColor];
        
        // 设置代理
        self.delegate = self.interactiveTransition;
        self.interactivePopGestureRecognizer.enabled = NO;
        
        // 注册控制器属性改变通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:GKViewControllerPropertyChangedNotification object:nil];
    }
    
    [self gkNav_viewDidLoad];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GKViewControllerPropertyChangedNotification object:nil];
}

#pragma mark - Notification Handle
- (void)handleNotification:(NSNotification *)notify {
    // 获取通知传递的控制器
    UIViewController *vc = (UIViewController *)notify.object[@"viewController"];
    
    // 不处理导航控制器和tabbar控制器
    if ([vc isKindOfClass:[UINavigationController class]]) return;
    if ([vc isKindOfClass:[UITabBarController class]]) return;
    if (!vc.navigationController) return;
    if (vc.navigationController != self) return;
    
    __block BOOL exist = NO;
    [GKConfigure.shiledGuestureVCs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj class] isSubclassOfClass:[UIViewController class]]) {
            if ([vc isKindOfClass:[obj class]]) {
                exist = YES;
                *stop = YES;
            }
        }else if ([obj isKindOfClass:[NSString class]]) {
            if ([NSStringFromClass(vc.class) isEqualToString:obj]) {
                exist = YES;
                *stop = YES;
            }else if ([NSStringFromClass(vc.class) containsString:obj]) {
                exist = YES;
                *stop = YES;
            }
        }
    }];
    if (exist) return;
    
    if (vc.gk_interactivePopDisabled) { // 禁止滑动
        [self.view removeGestureRecognizer:self.screenPanGesture];
        [self.view removeGestureRecognizer:self.panGesture];
    }else if (vc.gk_fullScreenPopDisabled) { // 禁止全屏滑动
        [self.view removeGestureRecognizer:self.panGesture];
        [self.view addGestureRecognizer:self.screenPanGesture];
        [self.screenPanGesture addTarget:self.systemTarget action:self.systemAction];
    }else {
        [self.view removeGestureRecognizer:self.screenPanGesture];
        [self.view addGestureRecognizer:self.panGesture];
        [self.panGesture addTarget:self.systemTarget action:self.systemAction];
    }
}

#pragma mark - getter
- (BOOL)gk_translationScale {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)gk_openScrollLeftPush {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)gk_openGestureHandle {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (UIScreenEdgePanGestureRecognizer *)screenPanGesture {
    UIScreenEdgePanGestureRecognizer *panGesture = objc_getAssociatedObject(self, _cmd);
    if (!panGesture) {
        panGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self.interactiveTransition action:@selector(panGestureAction:)];
        panGesture.edges = UIRectEdgeLeft;
        panGesture.delegate = self.interactiveTransition;
        
        objc_setAssociatedObject(self, _cmd, panGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGesture;
}

- (UIPanGestureRecognizer *)panGesture {
    UIPanGestureRecognizer *panGesture = objc_getAssociatedObject(self, _cmd);
    if (!panGesture) {
        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.interactiveTransition action:@selector(panGestureAction:)];
        panGesture.maximumNumberOfTouches = 1;
        panGesture.delegate = self.interactiveTransition;
        
        objc_setAssociatedObject(self, _cmd, panGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGesture;
}

static char kAssociatedObjectKey_interactiveTransition;
- (GKNavigationInteractiveTransition *)interactiveTransition {
    GKNavigationInteractiveTransition *transition = objc_getAssociatedObject(self, &kAssociatedObjectKey_interactiveTransition);
    if (!transition) {
        transition = [[GKNavigationInteractiveTransition alloc] init];
        transition.navigationController = self;
        transition.systemTarget = self.systemTarget;
        transition.systemAction = self.systemAction;
        
        objc_setAssociatedObject(self, &kAssociatedObjectKey_interactiveTransition, transition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return transition;
}

- (id)systemTarget {
    NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
    id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
    return internalTarget;
}

- (SEL)systemAction {
    return NSSelectorFromString(@"handleNavigationTransition:");
}

#pragma mark - setter
- (void)setGk_translationScale:(BOOL)gk_translationScale {
    objc_setAssociatedObject(self, @selector(gk_translationScale), @(gk_translationScale), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setGk_openScrollLeftPush:(BOOL)gk_openScrollLeftPush {
    objc_setAssociatedObject(self, @selector(gk_openScrollLeftPush), @(gk_openScrollLeftPush), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setGk_openGestureHandle:(BOOL)gk_openGestureHandle {
    objc_setAssociatedObject(self, @selector(gk_openGestureHandle), @(gk_openGestureHandle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
