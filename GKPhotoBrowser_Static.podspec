Pod::Spec.new do |s|
  s.name         = "GKPhotoBrowser_Static"
  s.version      = "3.2.1"
  s.summary      = "iOS可高度自定义的图片浏览器，支持图片浏览、视频播放等多种功能"
  s.homepage     = "https://github.com/QuintGao/GKPhotoBrowser"
  s.license      = "MIT"
  s.authors      = { "QuintGao" => "1094887059@qq.com" }
  s.social_media_url   = "https://github.com/QuintGao"
  s.ios.deployment_target = "10.0"
  s.source       = { :git => "https://github.com/QuintGao/GKPhotoBrowser.git", :tag => s.version.to_s }
  s.swift_version = '5.0'
  s.default_subspec = 'Default'
  s.static_framework = true

  s.subspec 'Default' do |ss|
    ss.dependency 'GKPhotoBrowser/Default'
  end

  s.subspec 'ZFPlayer' do |ss|
    ss.source_files = 'GKPhotoBrowser/ZFPlayer'
    ss.dependency 'GKPhotoBrowser/Core'
    ss.dependency 'ZFPlayer/AVPlayer'
  end

  s.subspec 'IJKPlayer' do |ss|
    ss.source_files = 'GKPhotoBrowser/IJKPlayer'
    ss.dependency 'GKPhotoBrowser/Core'
    ss.dependency 'IJKMediaFramework'
  end

end
