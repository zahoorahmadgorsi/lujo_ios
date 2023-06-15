//
//  CityView3.swift
//  LUJO
//
//  Created by hafsa lodhi on 25/01/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit
import AVFoundation

class GalleryView4: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imgView1Container: UIView!
    @IBOutlet weak var imgView1: UIImageView!
    @IBOutlet weak var imgView2Container: UIView!
    @IBOutlet weak var imgView2: UIImageView!
    @IBOutlet weak var imgView3ImageContainer: UIView!
    @IBOutlet weak var imgView3: UIImageView!
    @IBOutlet weak var imgView4Container: UIView!
    @IBOutlet weak var imgView4: UIImageView!
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
        Bundle.main.loadNibNamed("GalleryView4", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        //Adding tap gesture on whole product view
        let tgrOnProduct1 = UITapGestureRecognizer(target: self, action: #selector(GalleryView4.tappedOnImage(_:)))
        imgView1Container.addGestureRecognizer(tgrOnProduct1)
        
        //Adding tap gesture on whole product view
        let tgrOnProduct2 = UITapGestureRecognizer(target: self, action: #selector(GalleryView4.tappedOnImage(_:)))
        imgView2Container.addGestureRecognizer(tgrOnProduct2)
        
        //Adding tap gesture on whole product view
        let tgrOnProduct3 = UITapGestureRecognizer(target: self, action: #selector(GalleryView4.tappedOnImage(_:)))
        imgView3ImageContainer.addGestureRecognizer(tgrOnProduct3)
        
        //Adding tap gesture on whole product view
        let tgrOnProduct4 = UITapGestureRecognizer(target: self, action: #selector(GalleryView4.tappedOnImage(_:)))
        imgView4Container.addGestureRecognizer(tgrOnProduct4)
    }
    
    private func setupViewUI() {
        for (index, media) in gallery?.filter({ $0.type == "image" || $0.type == "video" }).enumerated() ?? [].enumerated() {
            if index == 0 {
                if (media.type == "image"){
                    imgView1.downloadImageFrom(link: media.mediaUrl, contentMode: .scaleAspectFill)
                    
                }else if( media.type == "video"){
                    var avPlayer: AVPlayer!
                    //Playing the video
                    if let videoLink = URL(string: media.mediaUrl ){
                        imgView1.isHidden = true;
                        imgView1Container.removeLayer(layerName: "videoPlayer") //removing video player if was added
                        
                        avPlayer = AVPlayer(playerItem: AVPlayerItem(url: videoLink))
                        let avPlayerLayer = AVPlayerLayer(player: avPlayer)
                        avPlayerLayer.name = "videoPlayer"
                        avPlayerLayer.frame = imgView1Container.bounds
                        avPlayerLayer.videoGravity = .resizeAspectFill
                        imgView1Container.layer.insertSublayer(avPlayerLayer, at: 0)
                        avPlayer.play()
                        avPlayer.isMuted = true // To mute the sound
                        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { _ in
                            avPlayer?.seek(to: CMTime.zero)
                            avPlayer?.play()
                        }
                    }
                }
            }else if index == 1 {
                if (media.type == "image"){
                    imgView2.downloadImageFrom(link: media.mediaUrl, contentMode: .scaleAspectFill)
                    
                }else if( media.type == "video"){
                    var avPlayer: AVPlayer!
                    //Playing the video
                    if let videoLink = URL(string: media.mediaUrl ){
                        imgView2.isHidden = true;
                        imgView2Container.removeLayer(layerName: "videoPlayer") //removing video player if was added
                        
                        avPlayer = AVPlayer(playerItem: AVPlayerItem(url: videoLink))
                        let avPlayerLayer = AVPlayerLayer(player: avPlayer)
                        avPlayerLayer.name = "videoPlayer"
                        avPlayerLayer.frame = imgView2Container.bounds
                        avPlayerLayer.videoGravity = .resizeAspectFill
                        imgView2Container.layer.insertSublayer(avPlayerLayer, at: 0)
                        avPlayer.play()
                        avPlayer.isMuted = true // To mute the sound
                        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { _ in
                            avPlayer?.seek(to: CMTime.zero)
                            avPlayer?.play()
                        }
                    }
                }
            }else if index == 2 {
                if (media.type == "image"){
                    imgView3.downloadImageFrom(link: media.mediaUrl, contentMode: .scaleAspectFill)
                    
                }else if( media.type == "video"){
                    var avPlayer: AVPlayer!
                    //Playing the video
                    if let videoLink = URL(string: media.mediaUrl ){
                        imgView3.isHidden = true;
                        imgView3ImageContainer.removeLayer(layerName: "videoPlayer") //removing video player if was added
                        
                        avPlayer = AVPlayer(playerItem: AVPlayerItem(url: videoLink))
                        let avPlayerLayer = AVPlayerLayer(player: avPlayer)
                        avPlayerLayer.name = "videoPlayer"
                        avPlayerLayer.frame = imgView3ImageContainer.bounds
                        avPlayerLayer.videoGravity = .resizeAspectFill
                        imgView3ImageContainer.layer.insertSublayer(avPlayerLayer, at: 0)
                        avPlayer.play()
                        avPlayer.isMuted = true // To mute the sound
                        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { _ in
                            avPlayer?.seek(to: CMTime.zero)
                            avPlayer?.play()
                        }
                    }
                }
            }else if index == 3 {
                if (media.type == "image"){
                    imgView4.downloadImageFrom(link: media.mediaUrl, contentMode: .scaleAspectFill)
                    
                }else if( media.type == "video"){
                    var avPlayer: AVPlayer!
                    //Playing the video
                    if let videoLink = URL(string: media.mediaUrl ){
                        imgView4.isHidden = true;
                        imgView4Container.removeLayer(layerName: "videoPlayer") //removing video player if was added
                        
                        avPlayer = AVPlayer(playerItem: AVPlayerItem(url: videoLink))
                        let avPlayerLayer = AVPlayerLayer(player: avPlayer)
                        avPlayerLayer.name = "videoPlayer"
                        avPlayerLayer.frame = imgView4Container.bounds
                        avPlayerLayer.videoGravity = .resizeAspectFill
                        imgView4Container.layer.insertSublayer(avPlayerLayer, at: 0)
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
        //        print(sender.view.tag)
//        delegate?.didTappedOnViewGallery()
        delegate?.didTappedOnImage(itemIndex: sender.view.tag)
    }

    @IBAction func btnSeeAllTapped(_ sender: Any) {
        delegate?.didTappedOnViewGallery()
    }

}

