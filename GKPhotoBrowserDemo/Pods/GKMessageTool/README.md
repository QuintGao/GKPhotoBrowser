# GKMessageTool  基于MBProgressHUD 1.0.0的简单封装工具类

支持CocoaPods：  pod 'GKMessageTool'

介绍：

```
1. GKMessageTool 是一个基于MBProgressHUD 1.0.0版本进行封装的工具类
2. 可以用一行代码实现iOS中常用的加载提示框，非常简单易用
```

方法：

GKMessageTool提供了以下几种方法

1. 弹出成功框

```
/**
 显示成功
 */
+ (void)showSuccess:(NSString *)success;
+ (void)showSuccess:(NSString *)success toView:(UIView *)toView;
```

2. 弹出失败框

```
/**
 显示失败
 */
+ (void)showError:(NSString *)error;
+ (void)showError:(NSString *)error toView:(UIView *)toView;
```

3. 弹出加载框及因此加载框
```
/**
 显示加载中
 */
+ (void)showMessage:(NSString *)message;
+ (void)showMessage:(NSString *)message toView:(UIView *)toView;

/**
 隐藏加载中
 */
+ (void)hideMessage;
```


更新：
```
2. 1.0.4版本：2020.03.17，适配MBProgressHUD 1.2.0
1. 0.0.1版本：2017.01.22，首次发布
```
