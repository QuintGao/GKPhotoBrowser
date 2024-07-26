//
//  GKAlamofireLivePhotoManager.swift
//  GKPhotoBrowser
//
//  Created by QuintGao on 2024/7/1.
//

import UIKit
import Alamofire
import GKLivePhotoManager
import CommonCrypto

@objc open class GKAlamofireLivePhotoManager: NSObject, GKLivePhotoProtocol {
    public var browser: GKPhotoBrowser?
    
    public lazy var livePhotoView: PHLivePhotoView? = {
        let livePhotoView = PHLivePhotoView()
        livePhotoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        livePhotoView.delegate = self
        return livePhotoView
    }()
    
    public var photo: GKPhoto?
    
    public var liveStatusChanged: ((any GKLivePhotoProtocol, GKLivePlayStatus) -> Void)?
    
    var progressBlock: ((Float) -> Void)?
    var completioBlock: ((Bool) -> Void)?
    
    lazy var fileDirectory: String = {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        guard let path else { return "" }
        let fileDirectory = path + "/livePhoto"
        if !FileManager.default.fileExists(atPath: fileDirectory) {
           try? FileManager.default.createDirectory(atPath: fileDirectory, withIntermediateDirectories: true)
        }
        return fileDirectory
    }()
    
    var filePathList = [String]()
    
    let progressRatio: Float = 4 / 5.0
    
    deinit {
        if let browser, browser.isClearMemoryForLivePhoto {
            gk_clear()
        }
    }
    
    public func loadLivePhoto(with photo: GKPhoto, targetSize: CGSize, progressBlock: ((Float) -> Void)?, completion: ((Bool) -> Void)? = nil) {
        self.photo = photo
        self.progressBlock = progressBlock
        self.completioBlock = completion
        
        if let asset = photo.imageAsset, asset.mediaSubtypes == .photoLive {
            loadLivePhoto(asset, targetSize: targetSize)
        }else if let videoUrl = photo.videoUrl {
            let fileManager = FileManager.default
            // 如果传入的是本地地址，判断是否存在
            if fileManager.fileExists(atPath: videoUrl.path) {
                loadLivePhoto(with: videoUrl.path, imagePath: photo.url?.path ?? nil, targetSize: targetSize)
                return
            }
            
            // 本地视频地址
            let videoPath = filePath(with: videoUrl, ext: "mov")
            // 本地图片地址
            var imagePath: String? = nil
            if let url = photo.url {
                imagePath = filePath(with: url, ext: "jpg")
            }
            
            // 判断是否下载过，下载过直接加载
            if fileManager.fileExists(atPath: videoPath) {
                loadLivePhoto(with: videoPath, imagePath: imagePath, targetSize: targetSize)
                return
            }
            
            try? fileManager.removeItem(atPath: videoPath)
            if let imagePath {
                try? fileManager.removeItem(atPath: imagePath)
            }
            
            let videoFileURL = URL(fileURLWithPath: videoPath)
            let imageFileURL = URL(fileURLWithPath: imagePath ?? "")
            
            let videoFileDest: DownloadRequest.Destination = { _,_ in
                (videoFileURL, [])
            }
            let imageFileDst: DownloadRequest.Destination = { _,_ in
                (imageFileURL, [])
            }
            
            if photo.url != nil {
                var isVideoFinished = false
                var isImageFinished = false
                
                var videoProgress: Float = 0
                var imageProgress: Float = 0
                
                AF.download(videoUrl, to: videoFileDest)
                    .downloadProgress { [weak self] progress in
                        guard let self else { return }
                        videoProgress = Float(progress.completedUnitCount/progress.totalUnitCount)
                        let progress = (videoProgress + imageProgress) / 2
                        self.progressBlock?(progress * self.progressRatio)
                    }
                    .response { [weak self] response in
                        guard let self else { return }
                        if response.error != nil {
                            self.completioBlock?(false)
                            return
                        }
                        isVideoFinished = true
                        if let fileURL = response.fileURL {
                            if #available(iOS 16.0, *) {
                                self.filePathList.append(fileURL.path(percentEncoded: true))
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                        if isVideoFinished && isImageFinished {
                            self.loadLivePhoto(with: videoPath, imagePath: imagePath, targetSize: targetSize)
                        }
                    }
                    .resume()
                
                AF.download(photo.url!, to: imageFileDst)
                    .downloadProgress { [weak self] progress in
                        guard let self else { return }
                        imageProgress = Float(progress.completedUnitCount/progress.totalUnitCount)
                        let progress = (videoProgress + imageProgress) / 2
                        self.progressBlock?(progress * self.progressRatio)
                    }
                    .response { [weak self] response in
                        guard let self else { return }
                        if response.error != nil {
                            self.completioBlock?(false)
                            return
                        }
                        isImageFinished = true
                        if let fileURL = response.fileURL {
                            self.filePathList.append(fileURL.path)
                        }
                        if isVideoFinished && isImageFinished {
                            self.loadLivePhoto(with: videoPath, imagePath: imagePath, targetSize: targetSize)
                        }
                    }
                    .resume()
            }else {
                AF.download(videoUrl, to: videoFileDest)
                    .downloadProgress { [weak self] progress in
                        guard let self else { return }
                        let videoProgress = Float(progress.completedUnitCount/progress.totalUnitCount)
                        self.progressBlock?(videoProgress * self.progressRatio)
                    }
                    .response { [weak self] response in
                        guard let self else { return }
                        if response.error != nil {
                            self.completioBlock?(false)
                            return
                        }
                        if let fileURL = response.fileURL {
                            self.filePathList.append(fileURL.path)
                        }
                        self.loadLivePhoto(with: videoPath, imagePath: imagePath, targetSize: targetSize)
                    }
                    .resume()
            }
        }
    }
    
    public func gk_play() {
        livePhotoView?.startPlayback(with: .full)
    }
    
    public func gk_stop() {
        livePhotoView?.stopPlayback()
    }
    
    public func gk_clear() {
        let fileManager = FileManager.default
        filePathList.forEach {
            try? fileManager.removeItem(atPath: $0)
        }
        
        guard let photo else { return }
        if let videoUrl = photo.videoUrl {
            let videoPath = filePath(with: videoUrl, ext: "mov")
            try? fileManager.removeItem(atPath: videoPath)
        }
        if let url = photo.url {
            let imagePath = filePath(with: url, ext: "jpg")
            try? fileManager.removeItem(atPath: imagePath)
        }
    }
    
    public func gk_updateFrame(_ frame: CGRect) {
        livePhotoView?.frame = frame
    }
    
    // MARK: private
    private func loadLivePhoto(_ asset: PHAsset, targetSize: CGSize) {
        var size = targetSize
        if size == .zero {
            size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        }
        
        GKLivePhotoManager.default().createLivePhoto(with: asset, targetSize: targetSize) { [weak self] progress in
            guard let self else { return }
            self.progressBlock?(progress);
        } completion: { [weak self] livePhoto, error in
            guard let self else { return }
            if let livePhoto {
                self.livePhotoView?.livePhoto = livePhoto
                self.completioBlock?(true)
            }else {
                self.completioBlock?(false)
            }
        }
    }
    
    private func loadLivePhoto(with videoPath: String, imagePath: String?, targetSize: CGSize) {
        var size = targetSize
        if size == .zero {
            let asset = AVAsset(url: URL(fileURLWithPath: videoPath))
            let track = asset.tracks(withMediaType: .video).first
            size = track?.naturalSize ?? .zero
        }
        
        if !FileManager.default.fileExists(atPath: videoPath) {
            completioBlock?(false)
            return
        }
        
        var imgPath = imagePath
        if let imagePath = imagePath, !FileManager.default.fileExists(atPath: imagePath) {
            imgPath = nil
        }
        
        GKLivePhotoManager.default().handleData(withVideoPath: videoPath, imagePath: imgPath) { [weak self] progress in
            self?.progressBlock?(progress);
        } completion: { [weak self] outVideoPath, outImagePath, error in
            guard let self else { return }
            if error != nil {
                self.completioBlock?(false)
                return
            }
            self.createLivePhoto(outVideoPath, outImagePath, targetSize)
        }
    }
    
    private func createLivePhoto(_ videoPath: String?, _ imagePath: String?, _ targetSize: CGSize) {
        guard let videoPath, let imagePath else {
            self.completioBlock?(false)
            return
        }
        GKLivePhotoManager.default().createLivePhoto(withVideoPath: videoPath, imagePath: imagePath, targetSize: targetSize) { [weak self] livePhoto, error in
            guard let self else { return }
            if let livePhoto {
                self.livePhotoView?.livePhoto = livePhoto
                self.progressBlock?(1)
                self.completioBlock?(true)
            }else {
                self.completioBlock?(false)
            }
        }
    }
    
    private func filePath(with url: URL, ext: String) -> String {
        var name = url.absoluteString.md5()
        name = name + "." + ext
        return fileDirectory + "/" + name
    }
}

extension GKAlamofireLivePhotoManager: PHLivePhotoViewDelegate {
    public func livePhotoView(_ livePhotoView: PHLivePhotoView, canBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) -> Bool {
        true
    }
    
    public func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        autoresize(to: livePhotoView)
        liveStatusChanged?(self, .begin)
    }
    
    public func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        liveStatusChanged?(self, .ended)
    }
    
    private func autoresize(to view: UIView) {
        for view in view.subviews {
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            autoresize(to: view)
        }
    }
}

extension String {
    func md5() -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        if let data = self.data(using: .utf8) as? NSData {
            CC_MD5(data.bytes, CC_LONG(data.length), &digest)
        }
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        return digestHex
    }
}
