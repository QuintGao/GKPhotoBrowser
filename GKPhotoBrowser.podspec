Pod::Spec.new do |s|
  s.name         = "GKPhotoBrowser"
  s.version      = "2.1.7"
  s.summary      = "iOS自定义图片浏览器，支持CocoaPods"
  s.homepage     = "https://github.com/QuintGao/GKPhotoBrowser"
  s.license      = "MIT"
  s.authors      = { "高坤" => "1094887059@qq.com" }
  s.social_media_url   = "https://github.com/QuintGao"
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/QuintGao/GKPhotoBrowser.git", :tag => s.version.to_s }
  
  s.default_subspec = 'SD'
  
  s.subspec 'Core' do |core|
    core.source_files = 'GKPhotoBrowser/Core'
    core.resource = 'GKPhotoBrowser/GKPhotoBrowser.bundle'
  end
  
  s.subspec 'SD' do |sd|
    sd.source_files = 'GKPhotoBrowser/SDWebImage'
    sd.dependency 'GKPhotoBrowser/Core'
    sd.dependency 'SDWebImage', '~> 5.0'
  end
  
  s.subspec 'YY' do |yy|
    yy.source_files = 'GKPhotoBrowser/YYWebImage'
    yy.dependency 'GKPhotoBrowser/Core'
    yy.dependency 'YYWebImage'
  end
end
