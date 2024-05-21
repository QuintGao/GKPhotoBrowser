//
//  ViewController.swift
//  SwiftExample
//
//  Created by QuintGao on 2024/5/20.
//

import UIKit
import GKPhotoBrowser
import Kingfisher
import TZImagePickerController
//import GKPhotoBrowser.GKKFWebImageManager

class ViewController: UIViewController {

    lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.isUserInteractionEnabled = true
        imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imgClick)))
        return imgView
    }()
    
//    let url = "https://img0.baidu.com/it/u=4280799984,2586302663&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500"
    let url = "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fitem%2F202003%2F27%2F20200327020248_xYXtz.thumb.1000_0.gif&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1718785540&t=7ecfeafa6e914f6572e98f998844a564"
    
    var imageAsset: PHAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "GKPhotoBrowser"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "相册", style: .plain, target: self, action: #selector(imgSelect))
        
        imageView.frame = CGRectMake(100, 100, 100, 100)
        view.addSubview(imageView)
        
        imageView.kf.setImage(with: URL(string: url))
    }
    
    @objc func imgSelect() {
        let pickerVC = TZImagePickerController(maxImagesCount: 1, delegate: self)
        pickerVC?.allowPickingGif = true
        present(pickerVC!, animated: true)
    }
    
    @objc func imgClick() {
        let photo = GKPhoto()
        if let imageAsset = imageAsset {
            photo.imageAsset = imageAsset
        }else {
            photo.url = URL(string: url)!
        }
        photo.sourceImageView = imageView
        
        let browser = GKPhotoBrowser(photos: [photo], currentIndex: 0)
        browser.showStyle = .zoom
        browser.hideStyle = .zoomScale
        browser.setupWebImageProtocol(GKKFWebImageManager())
//        browser.setupWebImageProtocol(GKSDWebImageManager())
        browser.show(fromVC: self)
    }
}

extension ViewController: TZImagePickerControllerDelegate {
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingGifImage animatedImage: UIImage!, sourceAssets asset: PHAsset!) {
        imageAsset = asset
        imageView.image = animatedImage
    }
}

