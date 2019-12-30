<p align="center">
  <img src="https://github.com/QuintGao/GKPhotoBrowser/blob/master/GKPhotoBrowser_logo.png" title="GKPhotoBrowser logo" float=left>
</p>


[![Build Status](http://img.shields.io/travis/QuintGao/GKPhotoBrowser/master.svg?style=flat)](https://travis-ci.org/QuintGao/GKPhotoBrowser)
[![Pod Version](http://img.shields.io/cocoapods/v/GKPhotoBrowser.svg?style=flat)](https://cocoapods.org/pods/GKPhotoBrowser)
[![Pod Platform](http://img.shields.io/cocoapods/p/GKPhotoBrowser.svg?style=flat)](https://cocoadocs.org/docsets/GKPhotoBrowser/)
[![Pod License](http://img.shields.io/cocoapods/l/GKPhotoBrowser.svg?style=flat)](https://www.apache.org/licenses/LICENSE-2.0.html)
[![languages](https://img.shields.io/badge/language-objective--c-blue.svg)](#) 
[![support](https://img.shields.io/badge/support-ios%208%2B-orange.svg)](#) 
 
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
2019.10.20  优化长图闪动问题，适配iOS13
2019.10.12  优化长图放大后点击隐藏时的闪动问题
2019.08.15  1、修复只有一张图片时的滑动问题
            2、增加隐藏图片浏览器的方法
2019.07.24  增加方法可跳转到指定位置的图片
2019.07.02  1、修复禁止屏幕旋转后出现的不能滑动隐藏的bug
            2、增加maxZoomScale属性，可自己设置最大缩放比例
2019.05.31  修复循环引用导致的内存溢出问题
2019.05.06  修复长图不能上滑问题
2019.05.05  细节优化，修复可能出现的黑圈闪动问题
2019.04.26  增加支持查看原图功能
2019.04.15  bug fixed 1、修复WillAppear可能出现的CALayer position contains NaN: [nan nan]问题
                      2、修复某些机型可能出现的zoom恢复原图后，不能滑动隐藏的问题
2019.03.28  增加GKPhotoBrowserFailStyle，可自定义图片加载失败后的显示方式
2019.03.21  适配SDWebImage 5.x版本
2019.03.18  修复图片加载器不显示问题
2019.01.09  增加浏览器完全消失后的回调
2018.12.29  优化图片隐藏时的图片旋转问题
2018.12.28  优化长图从底部滑动隐藏时出现的问题
2018.12.18  优化图片显示时的加载问题
2018.12.17  修复只传入sourceFrame时的显示问题
2018.12.10  增加是否开启处理手势冲突的属性isPopGestureEnabled
2018.11.09  优化只有一张图片显示时的细节
2018.09.18  适配iPhone XS，iPhone XS Max，iPhone XR
2018.08.30  1、修复删除图片时的图片重叠问题
            2、增加自定义浏览器背景颜色属性
2018.08.24  修复加载失败时切换横竖屏加载视图位置不准及无法隐藏的问题
2018.08.20  修复影响UITableview与UICollectionView滑动卡顿问题
2018.08.07  1、移除FLAnimationImage
            2、优化gif图片的加载，增加属性isLowGifMemory，可减少gif图片的加载内存。
2018.08.01  1、增加属性isAdaptiveSafeArea，控制是否自动适配安全区域
            2、图片超过屏幕高度不能滑动消失问题修复（超长图滑动隐藏效果不是很好，目前没找到更好的解决方案）
2018.07.30  1、显示与隐藏动画优化
            2、增加删除图片方法，重置图片数组方法
2018.06.30  1、去除多余注释
            2、增加属性isFullWidthForLandSpace 控制横屏显示
2018.06.13  支持GIF图片的显示
2018.05.28  修复本地图片不能双击放大的问题
2018.05.23  全面适配iPhone X
2018.05.14  1、修复创建子视图不更新布局bug
            2、内存泄漏问题修复
2018.04.01  1、修复长按方式执行多次的bug  
            2、新增支持多种加载方式
```
