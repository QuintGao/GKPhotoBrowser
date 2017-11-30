# GKPhotoBrowser
iOS仿微信、今日头条等图片浏览器

## 说明
GKPhotoBrowser一个可高度自定义的图片浏览器，demo里面实现的有仿微信、今日头条等的图片浏览器。

参考：
    [KSPhotoBrowser](https://github.com/skx926/KSPhotoBrowser)，
    [MJPhotoBrowser(已弃用)](https://github.com/Sunnyyoung/MJPhotoBrowser)

## 主要功能

    * 支持单击、双击手势，支持缩放
    * 可自定义显示方式（none，zoom，push）
    * 可自定义隐藏方式（zoom，zoomScale，zoomSlide）
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
