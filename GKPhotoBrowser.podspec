Pod::Spec.new do |s|
  s.name         = "GKPhotoBrowser"
  s.version      = "2.0.3"
  s.summary      = "iOS自定义图片浏览器，支持CocoaPods"
  s.homepage     = "https://github.com/QuintGao/GKPhotoBrowser"
  s.license      = "MIT"
  s.authors      = { "高坤" => "1094887059@qq.com" }
  s.social_media_url   = "https://github.com/QuintGao"
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/QuintGao/GKPhotoBrowser.git", :tag => s.version.to_s }
  
  s.default_subspec = 'SD'
  s.resource = 'GKPhotoBrowser/GKPhotoBrowser.bundle'
  
  s.subspec 'SD' do |sd|
    sd.source_files = 'GKPhotoBrowser/*.{h,m}', 'GKPhotoBrowser/SDWebImage/*.{h,m}'
    sd.dependency 'SDWebImage', '~> 5.0'
  end
  
  s.subspec 'YY' do |yy|
    yy.source_files = 'GKPhotoBrowser/*.{h,m}', 'GKPhotoBrowser/YYWebImage/*.{h,m}'
    yy.dependency 'YYWebImage', '~> 1.0.5'
  end
end
