//
//  GKMessageTool.h
//  GKMessageTool
//
//  Created by 高坤 on 2017/1/21.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD/MBProgressHUD.h>

#define kMessageTool [GKMessageTool shareInstance]

@interface GKMessageTool : NSObject<MBProgressHUDDelegate>

/**
 单例
 */
+ (instancetype)shareInstance;

/**
 显示文字
 */
+ (void)showText:(NSString *)text;
+ (void)showText:(NSString *)text toView:(UIView *)toView;
+ (void)showText:(NSString *)text toView:(UIView *)toView bgColor:(UIColor *)color;

/**
 显示成功
 */
+ (void)showSuccess:(NSString *)success;
+ (void)showSuccess:(NSString *)success toView:(UIView *)toView;
+ (void)showSuccess:(NSString *)success imageName:(NSString *)imageName;
+ (void)showSuccess:(NSString *)success toView:(UIView *)toView imageName:(NSString *)imageName;
+ (void)showSuccess:(NSString *)success toView:(UIView *)toView imageName:(NSString *)imageName bgColor:(UIColor *)bgColor;


/**
 显示失败
 */
+ (void)showError:(NSString *)error;
+ (void)showError:(NSString *)error toView:(UIView *)toView;
+ (void)showError:(NSString *)error imageName:(NSString *)imageName;
+ (void)showError:(NSString *)error toView:(UIView *)toView imageName:(NSString *)imageName;
+ (void)showError:(NSString *)error toView:(UIView *)toView imageName:(NSString *)imageName bgColor:(UIColor *)color;

/**
 显示提示
 */
+ (void)showTips:(NSString *)tips;
+ (void)showTips:(NSString *)tips toView:(UIView *)toView;


/**
 显示加载中
 */
+ (void)showMessage:(NSString *)message;
+ (void)showMessage:(NSString *)message toView:(UIView *)toView;

+ (void)showNoClickMessage:(NSString *)message;
+ (void)showNoClickMessage:(NSString *)message toView:(UIView *)toView;

/**
 显示自定义视图
 */
+ (void)showCustomView:(UIView *)customView text:(NSString *)text;
+ (void)showCustomView:(UIView *)customView toView:(UIView *)toView text:(NSString *)text;

/**
 隐藏加载中
 */
+ (void)hideMessage;

@end
