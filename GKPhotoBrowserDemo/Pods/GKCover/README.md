# GKCover

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/QuintGao/GKCover/master/LICENSE)&nbsp;&nbsp;
[![platform](http://img.shields.io/cocoapods/p/GKCover.svg?style=flat)](http://cocoadocs.org/docsets/GKCover)&nbsp;&nbsp;
[![languages](https://img.shields.io/badge/language-objective--c-blue.svg)](#) &nbsp;&nbsp;
[![cocoapods](http://img.shields.io/cocoapods/v/GKCover.svg?style=flat)](https://cocoapods.org/pods/GKCover)&nbsp;&nbsp;
[![support](https://img.shields.io/badge/support-ios%208%2B-orange.svg)](#) 

一行代码实现遮罩视图，让你的弹窗更easy
==============

## 说明
    关于iPhone X及iOS 11的适配问题，在底部弹出视图时，建议自行将弹出视图的底部距离增加安全区域的距离，防止遮挡。

## 版本说明
    版本2.4.0更新：分离遮罩弹出和隐藏时的动画，当前隐藏遮罩方法[GKCover hideCover]

    最新版本2.3.1已支持判断遮罩是否存在的方法：[GKCover hasCover]

## 使用方法

1.底部弹窗

```
    UIView *redView = [UIView new];
    redView.backgroundColor = [UIColor redColor];
    redView.gk_size = CGSizeMake(KScreenW, 200);

    [GKCover translucentCoverFrom:self.view content:redView animated:YES];
    
```
2.中间弹窗

```
    UIView *greenView = [UIView new];
    greenView.backgroundColor = [UIColor greenColor];
    greenView.gk_size = CGSizeMake(240, 160);
    
    [GKCover translucentWindowCenterCoverContent:greenView animated:YES];
```
3.自定义弹窗

```
    GKCover *cover = [GKCover transparentCoverWithTarget:self action:@selector(hidden)];
    cover.frame = self.view.bounds;
    [self.view addSubview:cover];
    self.cover = cover;
    
    UIView *customView = [UIView new];
    customView.backgroundColor = [UIColor purpleColor];
    customView.frame = CGRectMake((KScreenW -  300)/2, 0, 300, 200);
    [self.view addSubview:customView];
    self.customView = customView;
    
    [UIView animateWithDuration:0.25 animations:^{
        customView.gk_y = (KScreenH - 200)/2;
    }];
```

4.显示和隐藏block

```
UIView *customView = [UIView new];
    customView.gk_size = CGSizeMake(KScreenW, 200);
    customView.backgroundColor = [UIColor blackColor];
    
    [GKCover translucentCoverFrom:self.view content:customView animated:YES showBlock:^{
        // 显示出来时的block
        NSLog(@"弹窗显示了，6不6");
    } hideBlock:^{
        // 移除后的block
        NSLog(@"弹窗消失了，555");
    }];


```

5.新增一行代码实现各种弹窗

```
/**
显示遮罩

@param fromView    显示的视图上
@param contentView 显示的视图
@param style       遮罩类型
@param showStyle   显示类型
@param animStyle   动画类型
@param notClick    是否不可点击
*/
+ (void)coverFrom:(UIView *)fromView contentView:(UIView *)contentView style:(GKCoverStyle)style showStyle:(GKCoverShowStyle)showStyle animStyle:(GKCoverAnimStyle)animStyle notClick:(BOOL)notClick;

最全方法：增加遮罩显示和隐藏的block方法

+ (void)coverFrom:(UIView *)fromView contentView:(UIView *)contentView style:(GKCoverStyle)style showStyle:(GKCoverShowStyle)showStyle animStyle:(GKCoverAnimStyle)animStyle notClick:(BOOL)notClick showBlock:(showBlock)showBlock hideBlock:(hideBlock)hideBlock;


```

## Demo效果图：

![image](https://github.com/QuintGao/GKCover/blob/master/GKCoverDemo/GKCoverDemo-gif.gif)

新增demo效果图：

顶部弹出

![image](https://github.com/QuintGao/GKCover/blob/master/GKCoverDemo/demo_top.png)

中间弹出

![image](https://github.com/QuintGao/GKCover/blob/master/GKCoverDemo/demo_center.png)

底部弹出

![image](https://github.com/QuintGao/GKCover/blob/master/GKCoverDemo/demo_bottom.png)

更新日志：

```
1.0.0版本：添加底部遮罩和中间遮罩
1.0.1版本：添加自定义遮罩
1.0.2版本：添加使用方法
1.0.3版本：修改一个全透明遮罩不能点击消失的bug
1.0.4版本：更新Demo工程，添加更多使用方法
1.0.5版本：遮罩支持显示和隐藏的block，可以在block中添加要实现的方法
1.0.6版本：添加外部调用隐藏方法

2.0.0版本：2016.09.01，重大更新，优化代码内容，新增是否能点击遮罩的判断值，使用更方便。
2.1.0版本：2016.09.02，新增毛玻璃效果
2.2.0版本：2016.11.02，重大更新
    1.增加类型的判断（毛玻璃，全透明，半透明）
    2.增加显示类型的判断（上，中，下）
    3.增加动画类型的判断（从上弹出，中间弹出，底部弹出，无动画）
2.3.0版本：2016.11.17
    1. 部分内容优化
    2. 增加2.2.0的使用方法demo
2.3.1版本：2017.2.21
    1. 新增判断遮罩是否已存在的方法[GKCover hasCover];
2.4.0版本：2017.2.28
    1. 分离弹出和隐藏时的动画
    2. 当前版本的隐藏方法改为[GKCover hideCover]防止与以前版本的冲突
2.4.2版本：2017.8.23
    新增遮罩遮盖状态栏的方法
2.5.2版本：2018.6.6
    新增调用隐藏方法时加入block
2.5.3版本：2018.6.6
    新增改变遮罩背景色方法
2.5.4版本：2019.3.11
    优化代码，防止内存泄漏
2.5.5版本：2020.04.11
    优化，解决多处调用隐藏block可以导致的bug
2.6.0版本：2021.03.26
    新增自定义中间弹窗动画功能
2.6.1版本：2021.05.08
    新增无动画隐藏遮罩方法
```

## 技术支持：

[csdn博客地址](http://blog.csdn.net/u010565269/article/details/52332027)

[简书地址](http://www.jianshu.com/p/866a79a95963)

本人QQ:1094887059
交流群：529040270
