//
//  CityView2.swift
//  LUJO
//
//  Created by hafsa lodhi on 25/01/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit
import AVFoundation

class GalleryView2: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var product1ImageContainer: UIView!
    @IBOutlet weak var product1ImageView: UIImageView!
    @IBOutlet weak var product2ImageContainer: UIView!
    @IBOutlet weak var product2ImageView: UIImageView!
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
        Bundle.main.loadNibNamed("GalleryView2", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        //Adding tap gesture on whole product view
        let tgrOnProduct1 = UITapGestureRecognizer(target: self, action: #selector(GalleryView2.tappedOnProduct(_:)))
        product1ImageContainer.addGestureRecognizer(tgrOnProduct1)
        
        //Adding tap gesture on whole product view
        let tgrOnProduct2 = UITapGestureRecognizer(target: self, action: #selector(GalleryView2.tappedOnProduct(_:)))
        product2ImageContainer.addGestureRecognizer(tgrOnProduct2)
    }
    
    private func setupViewUI() {
        for (index, media) in gallery?.enumerated() ?? [].enumerated() {
            if index == 0 {
                if (media.type == "image"){
                    product1ImageView.downloadImageFrom(link: media.mediaUrl, contentMode: .scaleAspectFill)
                    
                }else if( media.type == "video"){
                    var avPlayer: AVPlayer!
                    //Playing the video
                    if let videoLink = URL(string: media.mediaUrl ){
                        product1ImageView.isHidden = true;
                        product1ImageContainer.removeLayer(layerName: "videoPlayer") //removing video player if was added
                        
                        avPlayer = AVPlayer(playerItem: AVPlayerItem(url: videoLink))
                        let avPlayerLayer = AVPlayerLayer(player: avPlayer)
                        avPlayerLayer.name = "videoPlayer"
                        avPlayerLayer.frame = product1ImageContainer.bounds
                        avPlayerLayer.videoGravity = .resizeAspectFill
                        product1ImageContainer.layer.insertSublayer(avPlayerLayer, at: 0)
                        avPlayer.play()
                        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { _ in
                            avPlayer?.seek(to: CMTime.zero)
                            avPlayer?.play()
                        }
                    }
                }
            }else if index == 1 {
                if (media.type == "image"){
                    product2ImageView.downloadImageFrom(link: media.mediaUrl, contentMode: .scaleAspectFill)
                    
                }else if( media.type == "video"){
                    var avPlayer: AVPlayer!
                    //Playing the video
                    if let videoLink = URL(string: media.mediaUrl ){
                        product2ImageView.isHidden = true;
                        product2ImageContainer.removeLayer(layerName: "videoPlayer") //removing video player if was added
                        
                        avPlayer = AVPlayer(playerItem: AVPlayerItem(url: videoLink))
                        let avPlayerLayer = AVPlayerLayer(player: avPlayer)
                        avPlayerLayer.name = "videoPlayer"
                        avPlayerLayer.frame = product2ImageContainer.bounds
                        avPlayerLayer.videoGravity = .resizeAspectFill
                        product2ImageContainer.layer.insertSublayer(avPlayerLayer, at: 0)
                        avPlayer.play()
                        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { _ in
                            avPlayer?.seek(to: CMTime.zero)
                            avPlayer?.play()
                        }
                    }
                }
            }
        }
    }
    
    @objc func tappedOnProduct(_ sender:AnyObject){
//        if let product = gallery?.items?[sender.view.tag] {
//            delegate?.didTappedOnProductAt(product: product)
//        }
        delegate?.didTappedOnViewGallery()
    }

    @IBAction func btnSeeAllTapped(_ sender: Any) {
        delegate?.didTappedOnViewGallery()
    }

}

