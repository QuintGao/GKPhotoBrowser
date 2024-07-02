//
//  GKKFWebImageManager.swift
//  SwiftExample
//
//  Created by QuintGao on 2024/5/20.
//

import UIKit
import Kingfisher

@objc open class GKKFWebImageManager: NSObject, GKWebImageProtocol {
    public var browser: GKPhotoBrowser?
    
    public func imageViewClass() -> AnyClass {
        return UIImageView.self
    }
    
    public func setImageFor(_ imageView: UIImageView?, url: URL?, placeholderImage: UIImage?, progress progressBlock: GKWebImageProgressBlock?, completion completionBlock: GKWebImageCompletionBlock? = nil) {
        
        imageView?.kf.setImage(with: url, placeholder: placeholderImage, progressBlock: { resiveSize, totalSize in
            progressBlock?(Int(resiveSize), Int(totalSize))
        }, completionHandler: { result in
            switch result {
            case .success(let imageResult):
                completionBlock?(imageResult.image, imageResult.source.url, true, nil)
                break
            case .failure(let error):
                completionBlock?(nil, nil, false, error)
                break
            }
        })
    }
    
    public func cancelImageRequest(with imageView: UIImageView?) {
        imageView?.kf.cancelDownloadTask()
    }
    
    public func imageFromMemory(for url: URL?) -> UIImage? {
        return ImageCache.default.retrieveImageInMemoryCache(forKey: url?.absoluteString ?? "")
    }
    
    public func image(with data: Data?) -> UIImage? {
        guard let data = data else { return nil }
        let options = ImageCreatingOptions(scale: 1, duration: 0.0, preloadAll: true, onlyFirstFrame: false)
        return KingfisherWrapper.image(data: data, options: options)
    }
    
    public func clearMemory(for url: URL?) {
        ImageCache.default.removeImage(forKey: url?.absoluteString ?? "")
    }
    
    public func clearMemory() {
        ImageCache.default.clearMemoryCache()
    }
}
