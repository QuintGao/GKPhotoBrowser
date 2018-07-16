# GKPhotoBrowser
iOS仿微信、今日头条等图片浏览器

## 说明
GKPhotoBrowser一个可高度自定义的图片浏览器，demo里面实现的有仿微信、今日头条等的图片浏览器。

参考：
    [KSPhotoBrowser](https://github.com/skx926/KSPhotoBrowser)，
    [MJPhotoBrowser(已弃用)](https://github.com/Sunnyyoung/MJPhotoBrowser)

## 主要功能

    * 支持单击、双击手势，支持缩放
    * 支持多种显示方式（none，zoom，push）
    * 支持多种隐藏方式（zoom，zoomScale，zoomSlide)
    * 支持多种加载方式（不明确，不明确带阴影，明确进度）
    * 可自定义遮盖视图
    * 支持屏幕旋转
 
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
