# GKVideoScrollView

GKVideoScrollView是基于UIScrollView写的仿抖音上下滑动切换视图的库，使用方便类似UITableView，支持不同cell切换

- demo中有[ZFPlayer](https://github.com/renzifeng/ZFPlayer) 和[SJVideoPlayer](https://github.com/changsanjiang/SJVideoPlayer) 的使用示例，有需要的可下载查看

- demo中的视频数据来着[好看视频](https://haokan.baidu.com/)，仅供学习使用，请勿用作商业用途

[![CI Status](https://img.shields.io/travis/QuintGao/GKVideoScrollView.svg?style=flat)](https://travis-ci.org/QuintGao/GKVideoScrollView)
[![Version](https://img.shields.io/cocoapods/v/GKVideoScrollView.svg?style=flat)](https://cocoapods.org/pods/GKVideoScrollView)
[![License](https://img.shields.io/cocoapods/l/GKVideoScrollView.svg?style=flat)](https://cocoapods.org/pods/GKVideoScrollView)
[![Platform](https://img.shields.io/cocoapods/p/GKVideoScrollView.svg?style=flat)](https://cocoapods.org/pods/GKVideoScrollView)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

GKVideoScrollView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'GKVideoScrollView'
```

## Author

QuintGao

## License

GKVideoScrollView is available under the MIT license. See the LICENSE file for more info.

## 更新记录

* 2024.04.25 - 1.3.4 修复defaultIndex失效的问题 #8
* 2024.01.15 - 1.3.3 修复reloadDataWithIndex:方法引起的错乱问题
* 2024.01.10 - 1.3.2 修复可能出现的播放错乱问题
* 2024.01.05 - 1.3.1 1、清空数据后增加结束显示回调 2、cell创建逻辑优化
* 2023.09.21 - 1.3.0 加载更多逻辑优化
* 2023.09.19 - 1.2.0 新增移除cell方法及根据索引刷新cell的方法，部分问题优化
* 2023.09.01 - 1.1.0 修复滑动结束后可能位置不准确的问题
* 2023.08.22 - 1.0.9 修复快速切换时的问题
* 2023.08.16 - 1.0.8 1、修复快速滑动刷新后显示错乱的问题 2、切换到下一页功能优化
* 2023.08.09 - 1.0.7 1、修复上拉加载后显示错乱的问题 2、修复下拉刷新后出现重复cell的问题
* 2023.06.14 - 1.0.6 1、优化自动刷新逻辑 2、切换到下一页功能优化
* 2023.05.04 - 1.0.5 优化刷新逻辑，增加总个数为0时的处理
* 2023.04.25 - 1.0.4 1、优化加载逻辑，避免多次加载 2、cell需继承GKVideoViewCell，支持nib方式注册cell
* 2023.03.28 - 1.0.2 修复首次刷新bug，修复默认宽度bug
* 2023.03.21 - 1.0.1 新增方法可切换到任意索引位置，新增切换到下一页的方法（带动画）
