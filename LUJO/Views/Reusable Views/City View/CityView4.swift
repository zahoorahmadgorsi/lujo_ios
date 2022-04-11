//
//  CityView4.swift
//  LUJO
//
//  Created by hafsa lodhi on 25/01/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit
import AVFoundation

//protocol CityView4Protocol:class {
//    func seeAllProductsForCity(city: Cities)
//    func didTappedOnProductAt(product: Product)
//    func didTappedOnHeartAt(city: Cities, itemIndex: Int)
//}

class CityView4: UIView {

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
    
    @IBOutlet weak var product2ContainerView: UIStackView!
    @IBOutlet weak var product2ImageContainer: UIView!
    @IBOutlet weak var product2ImageView: UIImageView!
    @IBOutlet weak var product2NameLabel: UILabel!
    @IBOutlet weak var svProduct2Dates: UIStackView!
    @IBOutlet weak var lblProduct2Dates: UILabel!
    @IBOutlet weak var imgProduct2Date: UIImageView!
    @IBOutlet weak var viewHeart2: UIView!
    @IBOutlet weak var imgHeart2: UIImageView!
    
    @IBOutlet weak var product3ContainerView: UIStackView!
    @IBOutlet weak var product3ImageContainer: UIView!
    @IBOutlet weak var product3ImageView: UIImageView!
    @IBOutlet weak var product3NameLabel: UILabel!
    @IBOutlet weak var svProduct3Dates: UIStackView!
    @IBOutlet weak var lblProduct3Dates: UILabel!
    @IBOutlet weak var imgProduct3Date: UIImageView!
    @IBOutlet weak var viewHeart3: UIView!
    @IBOutlet weak var imgHeart3: UIImageView!
    
    @IBOutlet weak var product4ContainerView: UIStackView!
    @IBOutlet weak var product4ImageContainer: UIView!
    @IBOutlet weak var product4ImageView: UIImageView!
    @IBOutlet weak var product4NameLabel: UILabel!
    @IBOutlet weak var svProduct4Dates: UIStackView!
    @IBOutlet weak var lblProduct4Dates: UILabel!
    @IBOutlet weak var imgProduct4Date: UIImageView!
    @IBOutlet weak var viewHeart4: UIView!
    @IBOutlet weak var imgHeart4: UIImageView!
    
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
        Bundle.main.loadNibNamed("CityView4", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(btnSeeAllTapped))
        viewSeeAll.isUserInteractionEnabled = true
        viewSeeAll.addGestureRecognizer(tapGesture)
        
        //Adding tap gesture on whole product1 view
        let tgrOnProduct1 = UITapGestureRecognizer(target: self, action: #selector(CityView4.tappedOnProduct(_:)))
        product1ContainerView.addGestureRecognizer(tgrOnProduct1)
        //Add tap gestures on heart1 image
        let tgrOnHeart1 = UITapGestureRecognizer(target: self, action: #selector(CityView4.tappedOnHeart(_:)))
        viewHeart1.addGestureRecognizer(tgrOnHeart1)
        
        //Adding tap gesture on whole product2 view
        let tgrOnProduct2 = UITapGestureRecognizer(target: self, action: #selector(CityView4.tappedOnProduct(_:)))
        product2ContainerView.addGestureRecognizer(tgrOnProduct2)
        //Add tap gestures on heart2 image
        let tgrOnHeart2 = UITapGestureRecognizer(target: self, action: #selector(CityView4.tappedOnHeart(_:)))
        viewHeart2.addGestureRecognizer(tgrOnHeart2)
        
        //Adding tap gesture on whole product3 view
        let tgrOnProduct3 = UITapGestureRecognizer(target: self, action: #selector(CityView4.tappedOnProduct(_:)))
        product3ContainerView.addGestureRecognizer(tgrOnProduct3)
        //Add tap gestures on heart3 image
        let tgrOnHeart3 = UITapGestureRecognizer(target: self, action: #selector(CityView4.tappedOnHeart(_:)))
        viewHeart3.addGestureRecognizer(tgrOnHeart3)
        
        //Adding tap gesture on whole product4 view
        let tgrOnProduct4 = UITapGestureRecognizer(target: self, action: #selector(CityView4.tappedOnProduct(_:)))
        product4ContainerView.addGestureRecognizer(tgrOnProduct4)
        //Add tap gestures on heart4 image
        let tgrOnHeart4 = UITapGestureRecognizer(target: self, action: #selector(CityView4.tappedOnHeart(_:)))
        viewHeart4.addGestureRecognizer(tgrOnHeart4)
    }
    
    private func setupViewUI() {
        cityNameLabel.text = city?.name
        
        for (index, product) in city?.items?.enumerated() ?? [].enumerated() {
            if index == 0 {
                if (product.primaryMedia?.type == "image"){
                    if let mediaLink = product.primaryMedia?.mediaUrl {
                        print(mediaLink)
                        product1ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                    }else if let firstImageLink = product.getGalleryImagesURL().first {
                        print(firstImageLink)
                        product1ImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
                    }
                }else if( product.primaryMedia?.type == "video"){
                    var avPlayer: AVPlayer!
                    //Playing the video
                    if let videoLink = URL(string: product.primaryMedia?.mediaUrl ?? ""){
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
                    }else if let mediaLink = product.primaryMedia?.mediaUrl {
                            print(mediaLink)
                            product1ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                        }else if let firstImageLink = product.getGalleryImagesURL().first {
                            print(firstImageLink)
                            product1ImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
                        }
                    
                }
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
            else if index == 1 {
                if (product.primaryMedia?.type == "image"){
                    if let mediaLink = product.primaryMedia?.mediaUrl {
                        print(mediaLink)
                        product2ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                    }else if let firstImageLink = product.getGalleryImagesURL().first {
                        print(firstImageLink)
                        product2ImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
                    }
                }else if( product.primaryMedia?.type == "video"){
                    var avPlayer: AVPlayer!
                    //Playing the video
                    if let videoLink = URL(string: product.primaryMedia?.mediaUrl ?? ""){
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
                    }else if let mediaLink = product.primaryMedia?.mediaUrl {
                            print(mediaLink)
                            product2ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                        }else if let firstImageLink = product.getGalleryImagesURL().first {
                            print(firstImageLink)
                            product2ImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
                        }
                    
                }
                product2NameLabel.text = product.name

                if product.type == "event" {
                    svProduct2Dates.isHidden = false
                    
                    let startDateText = ProductDetailsViewController.convertDateFormate(date: product.startDate!)
                    var startTimeText = ProductDetailsViewController.timeFormatter.string(from: product.startDate!)
                    
                    var endDateText = ""
                    if let eventEndDate = product.endDate {
                        endDateText = ProductDetailsViewController.convertDateFormate(date: eventEndDate)
                    }
                    
                    if let timezone = product.timezone {
                        startTimeText = "\(startTimeText) (\(timezone))"
                    }
                    
                    lblProduct2Dates.text = endDateText != "" ? "\(startDateText) - \(endDateText)" : "\(startDateText) \(startTimeText)"
                }else { //showing location if available
                    //cell.dateContainerView.isHidden = true
                    let locationText = product.getLocation()
                    lblProduct2Dates.text = locationText.uppercased()
                    svProduct2Dates.isHidden = locationText.isEmpty
                    imgProduct2Date.image = UIImage(named: "Location White")
                }
                //checking favourite image red or white
                if (product.isFavourite ?? false){
                    imgHeart2.image = UIImage(named: "heart_red")
                }else{
                    imgHeart2.image = UIImage(named: "heart_white")
                }
                //setting indecies to handle the tap events
                product2ContainerView.tag = index
                viewHeart2.tag = index
            }else if index == 2 {
                if (product.primaryMedia?.type == "image"){
                    if let mediaLink = product.primaryMedia?.mediaUrl {
                        print(mediaLink)
                        product3ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                    }else if let firstImageLink = product.getGalleryImagesURL().first {
                        print(firstImageLink)
                        product3ImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
                    }
                }else if( product.primaryMedia?.type == "video"){
                    var avPlayer: AVPlayer!
                    //Playing the video
                    if let videoLink = URL(string: product.primaryMedia?.mediaUrl ?? ""){
                        product3ImageView.isHidden = true;
                        product3ImageContainer.removeLayer(layerName: "videoPlayer") //removing video player if was added
                        
                        avPlayer = AVPlayer(playerItem: AVPlayerItem(url: videoLink))
                        let avPlayerLayer = AVPlayerLayer(player: avPlayer)
                        avPlayerLayer.name = "videoPlayer"
                        avPlayerLayer.frame = product3ImageContainer.bounds
                        avPlayerLayer.videoGravity = .resizeAspectFill
                        product3ImageContainer.layer.insertSublayer(avPlayerLayer, at: 0)
                        avPlayer.play()
                        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { _ in
                            avPlayer?.seek(to: CMTime.zero)
                            avPlayer?.play()
                        }
                    }else if let mediaLink = product.primaryMedia?.mediaUrl {
                            print(mediaLink)
                            product3ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                        }else if let firstImageLink = product.getGalleryImagesURL().first {
                            print(firstImageLink)
                            product3ImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
                        }
                    
                }
                product3NameLabel.text = product.name

                if product.type == "event" {
                    svProduct3Dates.isHidden = false
                    
                    let startDateText = ProductDetailsViewController.convertDateFormate(date: product.startDate!)
                    var startTimeText = ProductDetailsViewController.timeFormatter.string(from: product.startDate!)
                    
                    var endDateText = ""
                    if let eventEndDate = product.endDate {
                        endDateText = ProductDetailsViewController.convertDateFormate(date: eventEndDate)
                    }
                    
                    if let timezone = product.timezone {
                        startTimeText = "\(startTimeText) (\(timezone))"
                    }
                    
                    lblProduct3Dates.text = endDateText != "" ? "\(startDateText) - \(endDateText)" : "\(startDateText) \(startTimeText)"
                }else { //showing location if available
                    //cell.dateContainerView.isHidden = true
                    let locationText = product.getLocation()
                    lblProduct3Dates.text = locationText.uppercased()
                    svProduct3Dates.isHidden = locationText.isEmpty
                    imgProduct3Date.image = UIImage(named: "Location White")
                }
                //checking favourite image red or white
                if (product.isFavourite ?? false){
                    imgHeart3.image = UIImage(named: "heart_red")
                }else{
                    imgHeart3.image = UIImage(named: "heart_white")
                }
                //setting indecies to handle the tap events
                product3ContainerView.tag = index
                viewHeart3.tag = index
            }else if index == 3 {
                if (product.primaryMedia?.type == "image"){
                    if let mediaLink = product.primaryMedia?.mediaUrl {
                        print(mediaLink)
                        product4ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                    }else if let firstImageLink = product.getGalleryImagesURL().first {
                        print(firstImageLink)
                        product4ImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
                    }
                }else if( product.primaryMedia?.type == "video"){
                    var avPlayer: AVPlayer!
                    //Playing the video
                    if let videoLink = URL(string: product.primaryMedia?.mediaUrl ?? ""){
                        product4ImageView.isHidden = true;
                        product4ImageContainer.removeLayer(layerName: "videoPlayer") //removing video player if was added
                        
                        avPlayer = AVPlayer(playerItem: AVPlayerItem(url: videoLink))
                        let avPlayerLayer = AVPlayerLayer(player: avPlayer)
                        avPlayerLayer.name = "videoPlayer"
                        avPlayerLayer.frame = product4ImageContainer.bounds
                        avPlayerLayer.videoGravity = .resizeAspectFill
                        product4ImageContainer.layer.insertSublayer(avPlayerLayer, at: 0)
                        avPlayer.play()
                        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { _ in
                            avPlayer?.seek(to: CMTime.zero)
                            avPlayer?.play()
                        }
                    }else if let mediaLink = product.primaryMedia?.mediaUrl {
                            print(mediaLink)
                            product4ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                        }else if let firstImageLink = product.getGalleryImagesURL().first {
                            print(firstImageLink)
                            product4ImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
                        }
                    
                }
                product4NameLabel.text = product.name

                if product.type == "event" {
                    svProduct4Dates.isHidden = false
                    
                    let startDateText = ProductDetailsViewController.convertDateFormate(date: product.startDate!)
                    var startTimeText = ProductDetailsViewController.timeFormatter.string(from: product.startDate!)
                    
                    var endDateText = ""
                    if let eventEndDate = product.endDate {
                        endDateText = ProductDetailsViewController.convertDateFormate(date: eventEndDate)
                    }
                    
                    if let timezone = product.timezone {
                        startTimeText = "\(startTimeText) (\(timezone))"
                    }
                    
                    lblProduct4Dates.text = endDateText != "" ? "\(startDateText) - \(endDateText)" : "\(startDateText) \(startTimeText)"
                }else { //showing location if available
                    //cell.dateContainerView.isHidden = true
                    let locationText = product.getLocation()
                    lblProduct4Dates.text = locationText.uppercased()
                    svProduct4Dates.isHidden = locationText.isEmpty
                    imgProduct4Date.image = UIImage(named: "Location White")
                }
                //checking favourite image red or white
                if (product.isFavourite ?? false){
                    imgHeart4.image = UIImage(named: "heart_red")
                }else{
                    imgHeart4.image = UIImage(named: "heart_white")
                }
                //setting indecies to handle the tap events
                product4ContainerView.tag = index
                viewHeart4.tag = index
            }
        }
    }
    
    @objc func btnSeeAllTapped(_ sender: Any) {
        if let city = city {
            delegate?.seeAllProductsForCity(city: city)
        }
    }
    

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

