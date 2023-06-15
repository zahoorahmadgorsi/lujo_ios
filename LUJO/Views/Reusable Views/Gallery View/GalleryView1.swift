//
//  CityView1.swift
//  LUJO
//
//  Created by hafsa lodhi on 25/01/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit
import AVFoundation

protocol GalleryViewProtocol:class {
    func didTappedOnImage(itemIndex: Int)
    func didTappedOnViewGallery()
}

class GalleryView1: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var ImgView1Container: UIView!
    @IBOutlet weak var ImgView1: UIImageView!
    weak var delegate: GalleryViewProtocol?
    
    var gallery: [Gallery]?{
        didSet {
            setupViewUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("GalleryView1", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        //Adding tap gesture on whole product view
        let tgrOnProduct1 = UITapGestureRecognizer(target: self, action: #selector(GalleryView1.tappedOnImage(_:)))
        ImgView1Container.addGestureRecognizer(tgrOnProduct1)
        
    }
    
    private func setupViewUI() {
        
        for (index, media) in gallery?.filter({ $0.type == "image" || $0.type == "video" }).enumerated() ?? [].enumerated() {
            if index == 0 {
                if (media.type == "image"){
                    ImgView1.downloadImageFrom(link: media.mediaUrl, contentMode: .scaleAspectFill)
                    
                }else if( media.type == "video"){
                    var avPlayer: AVPlayer!
                    //Playing the video
                    if let videoLink = URL(string: media.mediaUrl ){
                        ImgView1.isHidden = true;
                        ImgView1Container.removeLayer(layerName: "videoPlayer") //removing video player if was added
                        
                        avPlayer = AVPlayer(playerItem: AVPlayerItem(url: videoLink))
                        let avPlayerLayer = AVPlayerLayer(player: avPlayer)
                        avPlayerLayer.name = "videoPlayer"
                        avPlayerLayer.frame = ImgView1Container.bounds
                        avPlayerLayer.videoGravity = .resizeAspectFill
                        ImgView1Container.layer.insertSublayer(avPlayerLayer, at: 0)
                        avPlayer.play()
                        avPlayer.isMuted = true // To mute the sound
                        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { _ in
                            avPlayer?.seek(to: CMTime.zero)
                            avPlayer?.play()
                        }
                    }
                }
            }
        }
    }
    
    @objc func tappedOnImage(_ sender:AnyObject){
//        if let product = gallery?.items?[sender.view.tag] {
//            delegate?.didTappedOnProductAt(product: product)
//        }
//        print(sender.view.tag)
        delegate?.didTappedOnImage(itemIndex: sender.view.tag)
    }

    @IBAction func btnSeeAllTapped(_ sender: Any) {
        delegate?.didTappedOnViewGallery()
    }
    
    
}

