//
//  GKSwiftViewController.swift
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2024/5/21.
//  Copyright © 2024 QuintGao. All rights reserved.
//

import UIKit
import GKNavigationBar
import GKPhotoBrowser
import Kingfisher

class GKSwiftViewController: UIViewController {
    
    let itemWH = (UIScreen.main.bounds.size.width - 40)/3
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWH, height: itemWH)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(GKSwiftCollectionViewCell.self, forCellWithReuseIdentifier: "GKSwiftCollectionViewCell")
        return collectionView
    }()
    
    let dataList: [GKSwiftModel] = [
        GKSwiftModel(img_url: "https://f7.baidu.com/it/u=1855219449,3123056628&fm=222&app=106&f=JPEG@f_auto?x-bce-process=image/quality,q_80/resize,m_fill,w_660,h_370", video_url: "https://vd2.bdstatic.com/mda-pcdktpwdmxw5vk0n/cae_h264/1678805071714276645/mda-pcdktpwdmxw5vk0n.mp4?abtest=peav_l52&appver=&auth_key=1680752204-0-0-dca00fd02bcb2a9797dbb24c00fccb06&bcevod_channel=searchbox_feed&cd=0&cr=0&did=cfcd208495d565ef66e7dff9f98764da&logid=404179787&model=&osver=&pd=1&pt=4&sl=426&sle=1&split=386564&vid=2482905209255354956&vt=1", isVideo: true),
        GKSwiftModel(img_url: "http://img1.mydrivers.com/img/20171008/s_da7893ed38074cbc994e0ff3d85adeb5.jpg", video_url: "", isVideo: false),
        GKSwiftModel(img_url: "https://f7.baidu.com/it/u=271976840,932511730&fm=222&app=106&f=JPEG@f_auto?x-bce-process=image/quality,q_80/resize,m_fill,w_660,h_370", video_url: "https://vd4.bdstatic.com/mda-pcekgt2uzhhuegqt/default/h264/1678890479874385171/mda-pcekgt2uzhhuegqt.mp4?abtest=peav_l52&appver=&auth_key=1680752423-0-0-4bd1b130e6dc6318f95ac68536d24da8&bcevod_channel=searchbox_feed&cd=0&cr=0&did=cfcd208495d565ef66e7dff9f98764da&logid=622881057&model=&osver=&pd=1&pt=4&sl=341&sle=1&split=403358&vid=10495600563257373332&vt=1", isVideo: true),
        GKSwiftModel(img_url: "https://img0.baidu.com/it/u=1273517628,1100314156&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1677949200&t=e2e2e91e169b024e624d5f02e59eca5e", video_url: "", isVideo: false),
        GKSwiftModel(img_url: "https://img1.baidu.com/it/u=1725096789,2988610435&fm=253&app=138&size=w931&n=0&f=JPEG&fmt=auto?sec=1678208400&t=aa00c7c959bc282054d84e091e7ba38b", video_url: "", isVideo: false),
        GKSwiftModel(img_url: "https://gimg2.baidu.com/image_search/src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fimages%2F20180116%2F2aa21001c71d45a3b08c5e0352c29e4d.gif&refer=http%3A%2F%2F5b0988e595225.cdn.sohucs.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1621408498&t=118dd0f478deff9a790ecfb205e113de", video_url: "", isVideo: false)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gk_navTitle = "Swift-Kingfisher-ZFPlayer"
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        collectionView.frame = CGRectMake(0, CGRectGetMaxY(gk_navigationBar.frame), view.frame.width, view.frame.height - CGRectGetMaxY(gk_navigationBar.frame))
    }
}

extension GKSwiftViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GKSwiftCollectionViewCell", for: indexPath) as? GKSwiftCollectionViewCell
        cell?.model = dataList[indexPath.item]
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photos: [GKPhoto] = dataList.enumerated().map { index, model in
            let photo = GKPhoto()
            photo.url = URL(string: model.img_url)!
            if model.isVideo {
                photo.videoUrl = URL(string: model.video_url)!
            }
            
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? GKSwiftCollectionViewCell {
                photo.sourceImageView = cell.imgView
            }
            
            return photo
        }
        
        let browser = GKPhotoBrowser(photos: photos, currentIndex: indexPath.item)
        browser.showStyle = .zoom
        browser.hideStyle = .zoomScale
        // 设置网络加载类
        browser.setupWebImageProtocol(GKKFWebImageManager())
        // 设置视频播放类
        browser.setupVideoPlayerProtocol(GKZFPlayerManager())
        browser.show(fromVC: self)
    }
}

struct GKSwiftModel {
    var img_url: String
    var video_url: String
    var isVideo: Bool
}

class GKSwiftCollectionViewCell: UICollectionViewCell {
    lazy var imgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        return imgView
    }()
    
    lazy var playBtn: UIButton = {
        let btn = UIButton()
        let img = GKPhotoBrowserConfigure.gk_image(withName: "gk_video_play")
        btn.setImage(img, for: .normal)
        btn.isHidden = true
        return btn
    }()
    
    var model: GKSwiftModel? {
        didSet {
            guard let model = model else { return }
            playBtn.isHidden = !model.isVideo
            imgView.kf.setImage(with: URL(string: model.img_url))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initUI()
    }
    
    func initUI() {
        addSubview(imgView)
        addSubview(playBtn)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgView.frame = bounds
        playBtn.frame = CGRectMake(0, 0, 50, 50)
        playBtn.center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2)
    }
}
