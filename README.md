GKPhotoBrowser
==============

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/QuintGao/GKPhotoBrowser/master/LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/GKPhotoBrowser.svg?style=flat)](http://cocoapods.org/pods/GKPhotoBrowser)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/p/GKPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/GKPhotoBrowser)&nbsp;

iOS仿微信、今日头条等图片浏览器
==============

## 重要
如果在使用过程中遇到问题，请先检查使用的版本是否是最新版本（可在说明最上面的pod后面查看），如果不是最新版本，请先更新到最后版本，看看问题是否存在，如果依然存在，可提issue说明或加我QQ1094887059直接问我，最好能提供demo。

## 说明
GKPhotoBrowser一个可高度自定义的图片浏览器，demo里面实现的有仿微信、今日头条等的图片浏览器。

参考：
    [KSPhotoBrowser](https://github.com/skx926/KSPhotoBrowser)，
    [MJPhotoBrowser(已弃用)](https://github.com/Sunnyyoung/MJPhotoBrowser)
    对于gif图片的加载，参考了[LBPhotoBrowser](https://github.com/tianliangyihou/LBPhotoBrowser)

## 主要功能

    * 支持单击、双击手势，支持缩放
    * 支持多种显示方式（none，zoom，push）
    * 支持多种隐藏方式（zoom，zoomScale，zoomSlide)
    * 支持多种加载方式（不明确，不明确带阴影，明确进度）
    * 可自定义遮盖视图（支持SDAutoLayout 不支持Masonry）
    * 支持屏幕旋转
    * 支持gif图片加载
 
 ## 用法
 1、创建包含GKPhoto的数组
 ```
 NSMutableArray *photos = [NSMutableArray new];
 [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
 GKPhoto *photo = [GKPhoto new];
 photo.url = [NSURL URLWithString:obj];
 
 [photos addObject:photo];
 }];
 ```
 
 2、创建GKPhotoBrowser并显示
 ```
 GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photos currentIndex:indexPath.row];
 browser.showStyle = GKPhotoBrowserShowStyleNone;
 [browser showFromVC:self];
 ```
  3、自定义遮盖视图
  ```
  /**
  为浏览器添加自定义遮罩视图
  
  @param coverViews 视图数组
  @param layoutBlock 布局block
  */
  - (void)setupCoverViews:(NSArray *)coverViews layoutBlock:(layoutBlock)layoutBlock;
  
 ```
 
 ## 效果图
 
 1、仿微信
 
 ![wechat.gif](https://github.com/QuintGao/GKPhotoBrowser/blob/master/imgs/wechat.gif)
 
 2、今日头条
 
 ![toutiao.gif](https://github.com/QuintGao/GKPhotoBrowser/blob/master/imgs/toutiao.gif)
 
 3、简书
 
 ![jianshu.gif](https://github.com/QuintGao/GKPhotoBrowser/blob/master/imgs/jianshu.gif)
 
 ## 更新
 
```
2018.11.9
    优化只有一张图片显示时的细节
2018.9.18
    适配iPhone XS，iPhone XS Max，iPhone XR
2018.8.30
    1、修复删除图片时的图片重叠问题
    2、增加自定义浏览器背景颜色属性
2018.8.24
    修复加载失败时切换横竖屏加载视图位置不准及无法隐藏的问题
2018.8.20
    修复影响UITableview与UICollectionView滑动卡顿问题
2018.8.7
    1、移除FLAnimationImage
    2、优化gif图片的加载，增加属性isLowGifMemory，可减少gif图片的加载内存。
2018.8.1
    1、增加属性isAdaptiveSaveArea，控制是否自动适配安全区域
    2、图片超过屏幕高度不能滑动消失问题修复（超长图滑动隐藏效果不是很好，目前没找到更好的解决方案）
2018.7.30
    1、显示与隐藏动画优化
    2、增加删除图片方法，重置图片数组方法
2018.6.30
    1、去除多余注释
    2、增加属性isFullWidthForLandSpace 控制横屏显示
2018.6.13
    支持GIF图片的显示
2018.5.28
    修复本地图片不能双击放大的问题
2018.5.23
    全面适配iPhone X
2018.5.14
    1、修复创建子视图不更新布局bug
    2、内存泄漏问题修复
2018.4.1  
    1、修复长按方式执行多次的bug  
    2、新增支持多种加载方式
```
