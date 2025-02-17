//
//  ZLPhotoBrowserSwift.swift
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2024/12/19.
//  Copyright © 2024 QuintGao. All rights reserved.
//

import UIKit
import ZLPhotoBrowser

@objc class ZLPhotoBrowserSwift: NSObject {
    @objc class func getPhotos(_ model: ZLAlbumListModel) -> [ZLPhotoModel] {
        model.refetchPhotos()
        return model.models
    }
    
    @objc class func getModel(_ model: ZLPhotoModel, completion: @escaping (ZLPhotoResultModel) -> Void) {
        
        let m = ZLPhotoResultModel()
        m.ident = model.ident
        m.asset = model.asset
        m.type = model.type.toOC
        
        let width = UIScreen.main.bounds.width
        
        ZLPhotoManager.fetchImage(for: model.asset, size: CGSize(width: width, height: width)) { image, success in
            if !success {
                if let image {
                    m.image = image
                }
                completion(m)
            }
        }
    }
    
    @objc class func getVideo(_ asset: PHAsset, completion: @escaping (URL?, Error?) -> Void) {
        ZLVideoManager.exportVideo(for: asset) { url, error in
            completion(url, error)
        }
    }
}

@objc class ZLPhotoResultModel: NSObject {
    @objc
    public var image: UIImage?

    @objc
    public var ident: String = ""
    
    @objc
    public var asset: PHAsset?
    
    @objc
    public var type: ResultType = .unknown
    
    @objc
    enum ResultType: Int {
        case unknown
        case image
        case gif
        case livePhoto
        case video
    }
}

extension ZLPhotoModel.MediaType {
    var toOC: ZLPhotoResultModel.ResultType {
        switch self {
        case .unknown:
            return .unknown
        case .image:
            return .image
        case .gif:
            return .gif
        case .livePhoto:
            return .livePhoto
        case .video:
            return .video
        @unknown default:
            return .unknown
        }
    }
}
