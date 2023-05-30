Pod::Spec.new do |s|
  s.name         = "GKPhotoBrowser"
  s.version      = "2.5.9"
  s.summary      = "iOS可高度自定义的图片浏览器，支持图片浏览、视频播放等多种功能"
  s.homepage     = "https://github.com/QuintGao/GKPhotoBrowser"
  s.license      = "MIT"
  s.authors      = { "高坤" => "1094887059@qq.com" }
  s.social_media_url   = "https://github.com/QuintGao"
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/QuintGao/GKPhotoBrowser.git", :tag => s.version.to_s }
  
  s.default_subspec = 'Default'
  
  s.subspec 'Default' do |ss|
    ss.dependency 'GKPhotoBrowser/SD'
    ss.dependency 'GKPhotoBrowser/AVPlayer'
  end
  
  s.subspec 'Core' do |ss|
    ss.source_files = 'GKPhotoBrowser/Core'
    ss.resource = 'GKPhotoBrowser/GKPhotoBrowser.bundle'
    ss.dependency 'GKSliderView'
  end
  
  s.subspec 'SD' do |ss|
    ss.source_files = 'GKPhotoBrowser/SDWebImage'
    ss.dependency 'GKPhotoBrowser/Core'
    ss.dependency 'SDWebImage', '~> 5.0'
  end
  
  s.subspec 'YY' do |ss|
    ss.source_files = 'GKPhotoBrowser/YYWebImage'
    ss.dependency 'GKPhotoBrowser/Core'
    ss.dependency 'YYWebImage'
  end
  
  s.subspec 'AVPlayer' do |ss|
    ss.source_files = 'GKPhotoBrowser/AVPlayer'
    ss.dependency 'GKPhotoBrowser/Core'
  end
  
end
