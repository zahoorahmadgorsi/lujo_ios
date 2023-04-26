//
//  CityView2.swift
//  LUJO
//
//  Created by hafsa lodhi on 25/01/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit
import AVFoundation

//protocol CityView2Protocol:class {
//    func seeAllProductsForCity(city: Cities)
//    func didTappedOnProductAt(product: Product)
//    func didTappedOnHeartAt(city: Cities, itemIndex: Int)
//}

class CityView2: UIView {

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
    
    @IBOutlet weak var viewMeasurements1: UIView!
    @IBOutlet weak var viewLength1: UIView!
    @IBOutlet weak var lblLength1: UILabel!
    @IBOutlet weak var viewNumberOfGuests1: UIView!
    @IBOutlet weak var lblNumberOfGuests1: UILabel!
    @IBOutlet weak var viewCabins1: UIView!
    @IBOutlet weak var lblCabins1: UILabel!
    @IBOutlet weak var viewWashrooms1: UIView!
    @IBOutlet weak var lblWashrooms1: UILabel!
    @IBOutlet weak var viewEmpty1: UIView!
    
    @IBOutlet weak var product2ContainerView: UIStackView!
    @IBOutlet weak var product2ImageContainer: UIView!
    @IBOutlet weak var product2ImageView: UIImageView!
    @IBOutlet weak var product2NameLabel: UILabel!
    @IBOutlet weak var svProduct2Dates: UIStackView!
    @IBOutlet weak var lblProduct2Dates: UILabel!
    @IBOutlet weak var imgProduct2Date: UIImageView!
    @IBOutlet weak var viewHeart2: UIView!
    @IBOutlet weak var imgHeart2: UIImageView!
    
    @IBOutlet weak var viewMeasurements2: UIView!
    @IBOutlet weak var viewLength2: UIView!
    @IBOutlet weak var lblLength2: UILabel!
    @IBOutlet weak var viewNumberOfGuests2: UIView!
    @IBOutlet weak var lblNumberOfGuests2: UILabel!
    @IBOutlet weak var viewCabins2: UIView!
    @IBOutlet weak var lblCabins2: UILabel!
    @IBOutlet weak var viewWashrooms2: UIView!
    @IBOutlet weak var lblWashrooms2: UILabel!
    @IBOutlet weak var viewEmpty2: UIView!
    
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
        Bundle.main.loadNibNamed("CityView2", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(btnSeeAllTapped))
        viewSeeAll.isUserInteractionEnabled = true
        viewSeeAll.addGestureRecognizer(tapGesture)
        
        //Adding tap gesture on whole product1 view
        let tgrOnProduct1 = UITapGestureRecognizer(target: self, action: #selector(CityView2.tappedOnProduct(_:)))
        product1ContainerView.addGestureRecognizer(tgrOnProduct1)
        //Add tap gestures on heart1 image
        let tgrOnHeart1 = UITapGestureRecognizer(target: self, action: #selector(CityView2.tappedOnHeart(_:)))
        viewHeart1.addGestureRecognizer(tgrOnHeart1)
        
        //Adding tap gesture on whole product1 view
        let tgrOnProduct2 = UITapGestureRecognizer(target: self, action: #selector(CityView2.tappedOnProduct(_:)))
        product2ContainerView.addGestureRecognizer(tgrOnProduct2)
        //Add tap gestures on heart1 image
        let tgrOnHeart2 = UITapGestureRecognizer(target: self, action: #selector(CityView2.tappedOnHeart(_:)))
        viewHeart2.addGestureRecognizer(tgrOnHeart2)
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
                        avPlayer.isMuted = true // To mute the sound
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
                    let locationText = product.getCityCountry()
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
                
                if  product.type == "villa" || product.type == "yacht"{  //showing number of passenger, cabins, washroom and length
                    svProduct1Dates.isHidden = true     //hiding dates
                    viewMeasurements1.isHidden = false   //showing measurements
        //            if let constraint = viewTitleHeightConstraint{
        //                viewTitle.addConstraint(constraint)
        //                viewEmpty.isHidden = false  //other wise viewempty will grow bigger instead of viewTitle
        //            }
                    
                    if product.type == "villa"{
                        
                        viewLength1.isHidden = true     //villa dont have length
                        if let val = product.numberOfGuests, val > 0{
                            viewNumberOfGuests1.isHidden = false
                            lblNumberOfGuests1.text = String(val)
                        }else{
                            viewNumberOfGuests1.isHidden = true
                        }
                        if let val = product.numberOfBedrooms, val > 0{
                            viewCabins1.isHidden = false
                            lblCabins1.text = String(val)
                        }else{
                            viewCabins1.isHidden = true
                        }
                        if let val = product.numberOfBathrooms, val > 0{
                            viewWashrooms1.isHidden = false
                            lblWashrooms1.text = String(val)
                        }else{
                            viewWashrooms1.isHidden = true
                        }
                    }else if product.type == "yacht"{
                        viewWashrooms1.isHidden = true      //yacht dont have washroom
                        if let val = product.lengthM, val.count > 0{
                            viewLength1.isHidden = false
                            lblLength1.text = val
                        }else{
                            viewLength1.isHidden = true
                        }
                        if let val = product.guestsNumber, val.count > 0{
                            viewNumberOfGuests1.isHidden = false
                            lblNumberOfGuests1.text = val
                        }else{
                            viewNumberOfGuests1.isHidden = true
                        }
                        if let val = product.cabinNumber, val.count > 0{
                            viewCabins1.isHidden = false
                            lblCabins1.text = val
                        }else{
                            viewCabins1.isHidden = true
                        }
                        
                    }
                }else {
//                    svProduct1Dates.isHidden = false    //showing dates
                    viewMeasurements1.isHidden = true   //measurements arent required other then yachts and properties
        //            if product.type == "gift"{    //gifts dont have location and/or measurements so let it's title grow in height
        //                //it will make the viewTitle grow to show multilines title for gifts especially
        //                if let constraint = viewTitleHeightConstraint{
        //                    viewTitle.removeConstraint(constraint)
        //                    viewEmpty.isHidden = true  //other wise viewempty will grow bigger instead of viewTitle
        //                }
        //            }
                }
            }
            else if index == 1 {
                if (product.thumbnail?.mediaType == "image"){
                    if let mediaLink = product.thumbnail?.mediaUrl {
                        print(mediaLink)
                        product2ImageView.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                    }else if let firstImageLink = product.getGalleryImagesURL().first {
                        print(firstImageLink)
                        product2ImageView.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
                    }
                }else if( product.thumbnail?.mediaType == "video"){
                    var avPlayer: AVPlayer!
                    //Playing the video
                    if let videoLink = URL(string: product.thumbnail?.mediaUrl ?? ""){
                        product2ImageView.isHidden = true;
                        product2ImageContainer.removeLayer(layerName: "videoPlayer") //removing video player if was added
                        
                        avPlayer = AVPlayer(playerItem: AVPlayerItem(url: videoLink))
                        let avPlayerLayer = AVPlayerLayer(player: avPlayer)
                        avPlayerLayer.name = "videoPlayer"
                        avPlayerLayer.frame = product2ImageContainer.bounds
                        avPlayerLayer.videoGravity = .resizeAspectFill
                        product2ImageContainer.layer.insertSublayer(avPlayerLayer, at: 0)
                        avPlayer.play()
                        avPlayer.isMuted = true // To mute the sound
                        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { _ in
                            avPlayer?.seek(to: CMTime.zero)
                            avPlayer?.play()
                        }
                    }else if let mediaLink = product.thumbnail?.mediaUrl {
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
                    let locationText = product.getCityCountry()
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
                
                if  product.type == "villa" || product.type == "yacht"{  //showing number of passenger, cabins, washroom and length
                    svProduct2Dates.isHidden = true     //hiding dates
                    viewMeasurements2.isHidden = false   //showing measurements
        //            if let constraint = viewTitleHeightConstraint{
        //                viewTitle.addConstraint(constraint)
        //                viewEmpty.isHidden = false  //other wise viewempty will grow bigger instead of viewTitle
        //            }
                    
                    if product.type == "villa"{
                        
                        viewLength2.isHidden = true     //villa dont have length
                        if let val = product.numberOfGuests, val > 0{
                            viewNumberOfGuests2.isHidden = false
                            lblNumberOfGuests2.text = String(val)
                        }else{
                            viewNumberOfGuests2.isHidden = true
                        }
                        if let val = product.numberOfBedrooms, val > 0{
                            viewCabins2.isHidden = false
                            lblCabins2.text = String(val)
                        }else{
                            viewCabins2.isHidden = true
                        }
                        if let val = product.numberOfBathrooms, val > 0{
                            viewWashrooms2.isHidden = false
                            lblWashrooms2.text = String(val)
                        }else{
                            viewWashrooms2.isHidden = true
                        }
                    }else if product.type == "yacht"{
                        viewWashrooms2.isHidden = true      //yacht dont have washroom
                        if let val = product.lengthM, val.count > 0{
                            viewLength2.isHidden = false
                            lblLength2.text = val
                        }else{
                            viewLength2.isHidden = true
                        }
                        if let val = product.guestsNumber, val.count > 0{
                            viewNumberOfGuests2.isHidden = false
                            lblNumberOfGuests2.text = val
                        }else{
                            viewNumberOfGuests2.isHidden = true
                        }
                        if let val = product.cabinNumber, val.count > 0{
                            viewCabins2.isHidden = false
                            lblCabins2.text = val
                        }else{
                            viewCabins2.isHidden = true
                        }
                        
                    }
                }else {
//                    svProduct2Dates.isHidden = false    //showing dates
                    viewMeasurements2.isHidden = true   //measurements arent required other then yachts and properties
        //            if product.type == "gift"{    //gifts dont have location and/or measurements so let it's title grow in height
        //                //it will make the viewTitle grow to show multilines title for gifts especially
        //                if let constraint = viewTitleHeightConstraint{
        //                    viewTitle.removeConstraint(constraint)
        //                    viewEmpty.isHidden = true  //other wise viewempty will grow bigger instead of viewTitle
        //                }
        //            }
                }
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

