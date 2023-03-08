//
//  GKMessageTool.m
//  GKMessageTool
//
//  Created by 高坤 on 2017/1/21.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKMessageTool.h"

static MBProgressHUD *_hud;

@interface GKMessageTool()

@property (nonatomic, strong) MBProgressHUD *showMessage;

@end

@implementation GKMessageTool

+ (void)load {
    
    CGFloat systemVersion = [UIDevice currentDevice].systemVersion.floatValue;
    
    UIActivityIndicatorView *indicatorView = nil;
    if (systemVersion >= 9.0) {
        indicatorView = [UIActivityIndicatorView appearanceWhenContainedInInstancesOfClasses:@[[MBProgressHUD class]]];
    }else {
        indicatorView = [UIActivityIndicatorView appearanceWhenContainedIn:[MBProgressHUD class], nil];
    }
    // 设置指示器颜色
    indicatorView.color = [UIColor whiteColor];
}

+ (instancetype)shareInstance {
    static GKMessageTool *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [GKMessageTool new];
    });
    return tool;
}

#pragma mark - Public Method
/**
 显示文字
 */
+ (void)showText:(NSString *)text {
    [kMessageTool showText:text toView:nil bgColor:nil];
}

+ (void)showText:(NSString *)text toView:(UIView *)toView {
    [kMessageTool showText:text toView:toView bgColor:nil];
}

+ (void)showText:(NSString *)text toView:(UIView *)toView bgColor:(UIColor *)color {
    [kMessageTool showText:text toView:toView bgColor:color];
}

+ (void)showSuccess:(NSString *)success {
    [kMessageTool showMessage:success toView:nil isSuccess:YES];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)toView {
    [kMessageTool showMessage:success toView:toView isSuccess:YES];
}

+ (void)showSuccess:(NSString *)success imageName:(NSString *)imageName {
    [kMessageTool showMessage:success toView:nil imageName:imageName bgColor:nil];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)toView imageName:(NSString *)imageName {
    [kMessageTool showMessage:success toView:toView imageName:imageName bgColor:nil];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)toView imageName:(NSString *)imageName bgColor:(UIColor *)bgColor {
    [kMessageTool showMessage:success toView:toView imageName:imageName bgColor:bgColor];
}

+ (void)showError:(NSString *)error {
    [kMessageTool showMessage:error toView:nil isSuccess:NO];
}

+ (void)showError:(NSString *)error toView:(UIView *)toView {
    [kMessageTool showMessage:error toView:toView isSuccess:NO];
}

+ (void)showError:(NSString *)error imageName:(NSString *)imageName {
    [kMessageTool showMessage:error toView:nil imageName:imageName bgColor:nil];
}

+ (void)showError:(NSString *)error toView:(UIView *)toView imageName:(NSString *)imageName {
    [kMessageTool showMessage:error toView:toView imageName:imageName bgColor:nil];
}

+ (void)showError:(NSString *)error toView:(UIView *)toView imageName:(NSString *)imageName bgColor:(UIColor *)color {
    [kMessageTool showMessage:error toView:toView imageName:imageName bgColor:color];
}

+ (void)showTips:(NSString *)tips {
    NSString *imageName = [NSString stringWithFormat:@"GKMessageTool.bundle/%@", @"info_white.png"];
    [kMessageTool showMessage:tips toView:nil imageName:imageName bgColor:nil];
}

+ (void)showTips:(NSString *)tips toView:(UIView *)toView {
    NSString *imageName = [NSString stringWithFormat:@"GKMessageTool.bundle/%@", @"info_white.png"];
    [kMessageTool showMessage:tips toView:toView imageName:imageName bgColor:nil];
}

+ (void)showMessage:(NSString *)message {
    _hud = [self showLoadMessage:message toView:nil];
}

+ (void)showMessage:(NSString *)message toView:(UIView *)toView {
    _hud = [self showLoadMessage:message toView:toView];
}

+ (MBProgressHUD *)showLoadMessage:(NSString *)message toView:(UIView *)toView {
    [kMessageTool showLoadMessage:message toView:toView canClick:YES];
    
    return kMessageTool.showMessage;
}

+ (void)showNoClickMessage:(NSString *)message {
    _hud = [self showNoClickLoadMessage:message toView:nil];
}

+ (void)showNoClickMessage:(NSString *)message toView:(UIView *)toView {
    _hud = [self showNoClickLoadMessage:message toView:toView];
}

+ (MBProgressHUD *)showNoClickLoadMessage:(NSString *)message toView:(UIView *)toView {
    [kMessageTool showLoadMessage:message toView:toView canClick:NO];
    
    return kMessageTool.showMessage;
}

+ (void)showCustomView:(UIView *)customView text:(NSString *)text {
    _hud = [self showHudCustomView:customView toView:nil text:text];
}

+ (void)showCustomView:(UIView *)customView toView:(UIView *)toView text:(NSString *)text {
    _hud = [self showHudCustomView:customView toView:toView text:text];
}

+ (MBProgressHUD *)showHudCustomView:(UIView *)customView toView:(UIView *)toView text:(NSString *)text {
    [kMessageTool showCustomView:customView toView:toView text:text canClick:YES];
    
    return kMessageTool.showMessage;
}

+ (void)hideMessage {
    [_hud hideAnimated:YES];
}

#pragma mark - Private Method

/**
 获取当前最顶层的window
 */
- (UIWindow *)getTopLevelWindow {
    return [UIApplication sharedApplication].keyWindow;
}

- (void)hideMessage {
    [self.showMessage hideAnimated:YES afterDelay:1.0];
}

- (void)showMessage:(NSString *)message toView:(UIView *)toView isSuccess:(BOOL)success {
    NSString *imageName = [NSString stringWithFormat:@"GKMessageTool.bundle/%@",success ? @"success_white.png" : @"error_white.png"];
    
    [self showMessage:message toView:toView imageName:imageName bgColor:nil];
}

- (void)showText:(NSString *)text toView:(UIView *)toView bgColor:(UIColor *)bgColor {
    if (self.showMessage) [self.showMessage removeFromSuperview];
    
    if (!toView) toView = [self getTopLevelWindow];
    
    // 创建指示器
    self.showMessage = [MBProgressHUD showHUDAddedTo:toView animated:YES];
    
    // 设置text模式
    self.showMessage.mode = MBProgressHUDModeText;
    // 隐藏时从父控件中移除
    self.showMessage.removeFromSuperViewOnHide = YES;
    // 设置背景色，设置为纯色背景
    self.showMessage.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    self.showMessage.bezelView.color = bgColor ? bgColor : [UIColor blackColor];
    self.showMessage.bezelView.layer.cornerRadius = 10.0;
    
    // 设置文字属性
    self.showMessage.label.text      = text;
    self.showMessage.label.font      = [UIFont systemFontOfSize:14.0];
    self.showMessage.label.textColor = [UIColor whiteColor];
    
    [self performSelectorOnMainThread:@selector(hideMessage) withObject:nil waitUntilDone:YES];
}

- (void)showMessage:(NSString *)message toView:(UIView *)toView imageName:(NSString *)imageName bgColor:(UIColor *)bgColor{
    if (self.showMessage) [self.showMessage removeFromSuperview];
    
    if (!toView) toView = [self getTopLevelWindow];
    
    // 创建指示器
    self.showMessage = [MBProgressHUD showHUDAddedTo:toView animated:YES];
    // 设置为自定义模式
    self.showMessage.mode = MBProgressHUDModeCustomView;
    // 隐藏时从父控件中移除
    self.showMessage.removeFromSuperViewOnHide = YES;
    // 设置将要显示的图片
    UIImage *image = [UIImage imageNamed:imageName];
    // 设置自定义视图
    self.showMessage.customView = [[UIImageView alloc] initWithImage:image];
    // 设置bezelView背景色
    self.showMessage.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    self.showMessage.bezelView.color = bgColor ? bgColor : [UIColor blackColor];
    self.showMessage.bezelView.layer.cornerRadius = 10.0;
    
    // 设置显示的文字内容
    self.showMessage.label.text = message;
    self.showMessage.label.font = [UIFont systemFontOfSize:14.0];
    self.showMessage.label.textColor = [UIColor whiteColor];
    
    [self performSelectorOnMainThread:@selector(hideMessage) withObject:nil waitUntilDone:YES];
}

- (void)showLoadMessage:(NSString *)message toView:(UIView *)toView canClick:(BOOL)canClick {
    if (self.showMessage) [self.showMessage removeFromSuperview];
    if (!toView) toView = [self getTopLevelWindow];
    
    // 创建hud
    self.showMessage = [MBProgressHUD showHUDAddedTo:toView animated:YES];
    self.showMessage.userInteractionEnabled = canClick;
    // 设置背景颜色和圆角
    self.showMessage.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    self.showMessage.bezelView.color = [UIColor blackColor];
    self.showMessage.bezelView.layer.cornerRadius = 10.0;
    // 设置文字内容和颜色
    self.showMessage.label.text = message;
    self.showMessage.label.textColor = [UIColor whiteColor];
}

- (void)showCustomView:(UIView *)customView toView:(UIView *)toView text:(NSString *)text canClick:(BOOL)canClick {
    if (self.showMessage) [self.showMessage removeFromSuperview];
    if (!toView) toView = [self getTopLevelWindow];
    
    // 创建HUD
    self.showMessage = [MBProgressHUD showHUDAddedTo:toView animated:YES];
    self.showMessage.userInteractionEnabled = canClick;
    // 设置为自定义模式
    self.showMessage.mode = MBProgressHUDModeCustomView;
    // 隐藏时从父控件中移除
    self.showMessage.removeFromSuperViewOnHide = YES;
    
    // 设置自定义视图
    self.showMessage.customView = customView;
    // 设置bezelView背景色
    self.showMessage.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    self.showMessage.bezelView.color = [UIColor blackColor];
    self.showMessage.bezelView.layer.cornerRadius = 10.0;
    
    // 设置文字内容和颜色
    self.showMessage.label.text = text;
    self.showMessage.label.font = [UIFont systemFontOfSize:14.0];
    self.showMessage.label.textColor = [UIColor whiteColor];
}

@end
