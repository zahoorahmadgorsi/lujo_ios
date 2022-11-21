//
//  CityView1.swift
//  LUJO
//
//  Created by hafsa lodhi on 25/01/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit
import AVFoundation

protocol CityViewProtocol:class {
    func seeAllProductsForCity(city: Cities)
    func didTappedOnProductAt(product: Product, itemIndex: Int)
    func didTappedOnHeartAt(city: Cities, itemIndex: Int)
}

class CityView1: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var viewSeeAll: UIView!
    
    
    @IBOutlet weak var product1ContainerView: UIStackView!
    @IBOutlet weak var product1ImageContainer: UIView!
    @IBOutlet weak var product1ImageView: UIImageView!
    @IBOutlet weak var product1NameLabel: UILabel!
    
    @IBOutlet weak var svProduct1Dates: UIStackView!
    @IBOutlet weak var lblProduct1Dates: UILabel!
    @IBOutlet weak var imgProduct1Date: UIImageView!
    
    @IBOutlet weak var viewHeart1: UIView!
    @IBOutlet weak var imgHeart1: UIImageView!
    
    weak var delegate: CityViewProtocol?
    
    var city: Cities? {
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
        Bundle.main.loadNibNamed("CityView1", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(btnSeeAllTapped))
        viewSeeAll.isUserInteractionEnabled = true
        viewSeeAll.addGestureRecognizer(tapGesture)
        
        //Adding tap gesture on whole product view
        let tgrOnProduct1 = UITapGestureRecognizer(target: self, action: #selector(CityView1.tappedOnProduct(_:)))
        product1ContainerView.addGestureRecognizer(tgrOnProduct1)
        //Add tap gestures on heart image
        let tgrOnHeart1 = UITapGestureRecognizer(target: self, action: #selector(CityView1.tappedOnHeart(_:)))
        viewHeart1.addGestureRecognizer(tgrOnHeart1)
    }
    
    private func setupViewUI() {
        cityNameLabel.text = city?.name
        
        for (index, product) in city?.items?.enumerated() ?? [].enumerated() {
            if index == 0 {
                if (product.thumbnail?.mediaType == "image"){
                    if let mediaLink = product.thumbnail?.mediaUrl {
                        print(mediaLink)
                        product1ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                    }else if let firstImageLink = product.getGalleryImagesURL().first {
                        print(firstImageLink)
                        product1ImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
                    }
                }else if( product.thumbnail?.mediaType == "video"){
                    var avPlayer: AVPlayer!
                    //Playing the video
                    if let videoLink = URL(string: product.thumbnail?.mediaUrl ?? ""){
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
                    }else if let mediaLink = product.thumbnail?.mediaUrl {
                            print(mediaLink)
                            product1ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                        }else if let firstImageLink = product.getGalleryImagesURL().first {
                            print(firstImageLink)
                            product1ImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
                        }
                    
                }
//                product1ImageView.downloadImageFrom(link: "http://admin-stage.golujo.com/wp-content/uploads/07a8a464c98a71c796bd8a02a750d7be_user_297-1-768x576.png", contentMode: .scaleAspectFill)
                product1NameLabel.text = product.name

                if product.type == "event" {
                    svProduct1Dates.isHidden = false
                    
                    let startDateText = ProductDetailsViewController.convertDateFormate(date: product.startDate!)
                    var startTimeText = ProductDetailsViewController.timeFormatter.string(from: product.startDate!)
                    
                    var endDateText = ""
                    if let eventEndDate = product.endDate {
                        endDateText = ProductDetailsViewController.convertDateFormate(date: eventEndDate)
                    }
                    
                    if let timezone = product.timezone {
                        startTimeText = "\(startTimeText) (\(timezone))"
                    }
                    
                    lblProduct1Dates.text = endDateText != "" ? "\(startDateText) - \(endDateText)" : "\(startDateText) \(startTimeText)"
                }else { //showing location if available
                    //cell.dateContainerView.isHidden = true
                    var locationText = product.getLocation()
                    lblProduct1Dates.text = locationText.uppercased()
                    svProduct1Dates.isHidden = locationText.isEmpty
                    imgProduct1Date.image = UIImage(named: "Location White")
                }
                //checking favourite image red or white
                if (product.isFavourite ?? false){
                    imgHeart1.image = UIImage(named: "heart_red")
                }else{
                    imgHeart1.image = UIImage(named: "heart_white")
                }
                //setting indecies to handle the tap events
                product1ContainerView.tag = index
                viewHeart1.tag = index
            }
        }
    }
    
    @objc func btnSeeAllTapped(_ sender: Any) {
        if let city = city {
            delegate?.seeAllProductsForCity(city: city)
        }
    }
    
//    @IBAction func seeProductDetailsButton_onClick(_ sender: UIButton) {
//        if let product = city?.products[sender.tag] {
//            delegate?.seeSelectedProduct(product: product)
//        }
//    }
    

    @objc func tappedOnHeart(_ sender:AnyObject){
        if let currentCity = city {
            delegate?.didTappedOnHeartAt(city:currentCity  , itemIndex: sender.view.tag)
        }
    }
    
    @objc func tappedOnProduct(_ sender:AnyObject){
        if let product = city?.items?[sender.view.tag] {
            delegate?.didTappedOnProductAt(product: product, itemIndex: sender.view.tag)
        }
    }

}

