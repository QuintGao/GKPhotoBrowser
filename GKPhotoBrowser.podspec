Pod::Spec.new do |s|
  s.name         = "GKPhotoBrowser"
  s.version      = "3.1.3"
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
    ss.dependency 'GKPhotoBrowser/SD'
    ss.dependency 'GKPhotoBrowser/AVPlayer'
    ss.dependency 'GKPhotoBrowser/Progress'
    ss.dependency 'GKPhotoBrowser/AF'
  end
  
  s.subspec 'Core' do |ss|
    ss.source_files = 'GKPhotoBrowser/Core/**/*.{h,m}'
    ss.dependency 'GKPhotoBrowser/Resources'
  end
  
  s.subspec 'Resources' do |ss|
    ss.resource = 'GKPhotoBrowser/Resources/*.{bundle}'
    ss.resource_bundles = { 'GKPhotoBrowser.Privacy' => 'GKPhotoBrowser/Resources/PrivacyInfo.xcprivacy' }
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
  
  s.subspec 'KF' do |ss|
    ss.source_files = 'GKPhotoBrowser/Kingfisher'
    ss.dependency 'GKPhotoBrowser/Core'
    ss.dependency 'Kingfisher'
  end
  
  s.subspec 'AF' do |ss|
    ss.source_files = 'GKPhotoBrowser/AFNetworking'
    ss.dependency 'GKPhotoBrowser/Core'
    ss.dependency 'GKLivePhotoManager'
    ss.dependency 'AFNetworking'
  end
  
  s.subspec 'Alamofire' do |ss|
    ss.source_files = 'GKPhotoBrowser/Alamofire'
    ss.dependency 'GKPhotoBrowser/Core'
    ss.dependency 'GKLivePhotoManager'
    ss.dependency 'Alamofire'
  end
  
  s.subspec 'AVPlayer' do |ss|
    ss.source_files = 'GKPhotoBrowser/AVPlayer'
    ss.dependency 'GKPhotoBrowser/Core'
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
  
  s.subspec 'Progress' do |ss|
    ss.source_files = 'GKPhotoBrowser/Progress'
    ss.dependency 'GKPhotoBrowser/Core'
    ss.dependency 'GKSliderView'
  end

end
