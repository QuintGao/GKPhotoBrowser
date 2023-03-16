
<p align="center">
<img src="https://upload-images.jianshu.io/upload_images/635942-092427e571756309.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" alt="ZFPlayer" title="ZFPlayer" width="557"/>
</p>

<p align="center">
<a href="https://img.shields.io/cocoapods/v/ZFPlayer.svg"><img src="https://img.shields.io/cocoapods/v/ZFPlayer.svg"></a>
<a href="https://img.shields.io/github/license/renzifeng/ZFPlayer.svg?style=flat"><img src="https://img.shields.io/github/license/renzifeng/ZFPlayer.svg?style=flat"></a>
<a href="http://cocoadocs.org/docsets/ZFPlayer"><img src="https://img.shields.io/cocoapods/p/ZFPlayer.svg?style=flat"></a>
<a href="http://weibo.com/zifeng1300"><img src="https://img.shields.io/badge/weibo-@%E4%BB%BB%E5%AD%90%E4%B8%B0-yellow.svg?style=flat"></a>
</p>

[中文说明](https://www.jianshu.com/p/90e55deb4d51)

[ZFPlayer 转屏适配](https://github.com/renzifeng/ZFPlayer/wiki/%E8%BD%AC%E5%B1%8F%E9%80%82%E9%85%8D)


Before this, you used ZFPlayer, are you worried about encapsulating avplayer instead of using or modifying the source code to support other players, the control layer is not easy to customize, and so on? In order to solve these problems, I have wrote this player template, for player SDK you can conform the `ZFPlayerMediaPlayback` protocol, for control view you can conform the `ZFPlayerMediaControl` protocol, can custom the player and control view.


![ZFPlayer思维导图](https://upload-images.jianshu.io/upload_images/635942-e99d76498cb01afb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 🔨 Requirements

- iOS 7+
- Xcode 8+

## 📲 Installation

ZFPlayer is available through [CocoaPods](https://cocoapods.org). To install it,use player template simply add the following line to your Podfile:

```objc
pod 'ZFPlayer', '~> 4.0'
```

Use default controlView simply add the following line to your Podfile:

```objc
pod 'ZFPlayer/ControlView', '~> 4.0'
```
Use AVPlayer simply add the following line to your Podfile:

```objc
pod 'ZFPlayer/AVPlayer', '~> 4.0'
```

Use ijkplayer simply add the following line to your Podfile:

```objc
pod 'ZFPlayer/ijkplayer', '~> 4.0'
```
[IJKMediaFramework SDK](https://gitee.com/renzifeng/IJKMediaFramework) support cocoapods


## 🐒 Usage

####  ZFPlayerController
Main classes,normal style initialization and list style initialization (tableView, collection,scrollView)

Normal style initialization 

```objc
ZFPlayerController *player = [ZFPlayerController playerWithPlayerManager:playerManager containerView:containerView];
ZFPlayerController *player = [[ZFPlayerController alloc] initwithPlayerManager:playerManager containerView:containerView];
```

List style initialization

```objc
ZFPlayerController *player = [ZFPlayerController playerWithScrollView:tableView playerManager:playerManager containerViewTag:containerViewTag];
ZFPlayerController *player = [ZFPlayerController alloc] initWithScrollView:tableView playerManager:playerManager containerViewTag:containerViewTag];
ZFPlayerController *player = [ZFPlayerController playerWithScrollView:scrollView playerManager:playerManager containerView:containerView];
ZFPlayerController *player = [ZFPlayerController alloc] initWithScrollView:tableView playerManager:playerManager containerView:containerView];
```

#### ZFPlayerMediaPlayback
For the playerMnager,you must conform `ZFPlayerMediaPlayback` protocol,custom playermanager can supports any player SDK，such as `AVPlayer`,`MPMoviePlayerController`,`ijkplayer`,`vlc`,`PLPlayerKit`,`KSYMediaPlayer`and so on，you can reference the `ZFAVPlayerManager`class.

```objc
Class<ZFPlayerMediaPlayback> *playerManager = ...;
```

#### ZFPlayerMediaControl
This class is used to display the control layer, and you must conform the ZFPlayerMediaControl protocol, you can reference the `ZFPlayerControlView` class.

```objc
UIView<ZFPlayerMediaControl> *controlView = ...;
player.controlView = controlView;
```

## 📷 Screenshots

![Picture effect](https://upload-images.jianshu.io/upload_images/635942-1b0e23b7f5eabd9e.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## Reference
- [ijkplayer](https://github.com/Bilibili/ijkplayer)
- [SJVideoPlayer](https://github.com/changsanjiang/SJVideoPlayer)

## 👨🏻‍💻 Author

- Weibo: [@任子丰](https://weibo.com/zifeng1300)
- Email: zifeng1300@gmail.com
- QQ群: 123449304


## 👮🏻 License

ZFPlayer is available under the MIT license. See the LICENSE file for more info.



