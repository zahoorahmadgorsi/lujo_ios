//
//  HomeSlider.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 7/31/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import AVFoundation

protocol DidSelectSliderItemProtocol: AnyObject {
    func didSelectSliderItemAt(indexPath: IndexPath, sender: HomeSlider)
    func didTappedOnHeartAt(index: Int, sender: HomeSlider)
}

class HomeSlider: UIView {
    var itemWidth:Int = 175
    var itemHeight:Int = 172
//    var giftItemHeight:Int = 148
    var itemMargin:Int = 16
    var timer: Timer?
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let contentView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        contentView.dataSource = self
        contentView.delegate = self
        contentView.register(UINib(nibName: HomeSliderCell.identifier, bundle: nil), forCellWithReuseIdentifier: HomeSliderCell.identifier)
        contentView.backgroundColor = .clear
        contentView.showsHorizontalScrollIndicator = false
        //        contentView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()

    weak var delegate: DidSelectSliderItemProtocol?

    var itemsList: [Product] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear
        addSubview(collectionView)
        setupLayout()
        //to make animation random
//        let randomNumber:TimeInterval = TimeInterval(Int(arc4random_uniform(5)))
//        //It’ll return a random number between 0 and this upper bound, minus 1.
//        DispatchQueue.main.asyncAfter(deadline: .now() + randomNumber ) {
//            self.startAnimation()
//        }
    }

    private func setupLayout() {
        NSLayoutConstraint.activate(
            [collectionView.topAnchor.constraint(equalTo: topAnchor),
             collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
             collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
             collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)]
        )
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
   
//This method animates the Event and Experiences slider at the home screen, it also stops animation if user has navigate away from controller
//    func startAnimation( ) {
    func startAnimation(isPausing : Bool ) {
        if !isPausing{
            let randomNumber:TimeInterval = TimeInterval(Int(arc4random_uniform(UInt32(HomeViewController.animationInterval)))) //making start of animation as random
            //It’ll return a random number between 0 and this upper bound, minus 1.
            DispatchQueue.main.asyncAfter(deadline: .now() + randomNumber ) {
                var newOffsetX: CGFloat = 0.0

                self.timer = Timer(fire: Date(), interval: HomeViewController.animationInterval, repeats: true) { (timer) in
                let initailPoint = CGPoint(x: newOffsetX,y :0)
                if __CGPointEqualToPoint(initailPoint, self.collectionView.contentOffset) {
                    let itemWidthWithMargin = Int(CollectionSize.itemWidth.rawValue + CollectionSize.itemMargin.rawValue) // 166 , total width of a collectionview item
                    if newOffsetX < self.collectionView.contentSize.width {   //total content width of collectionview is more then 800 for 5 items
                        newOffsetX += CGFloat(itemWidthWithMargin) //keep increasing the offset to the one colllection view item
                    }
                    //CALCULATING TO WHAT POINT WE SHOULD MOVE THE SLIDER AND WHEN TO RESET IT TO 0
                    let collectionWidth:Int = Int(self.collectionView.frame.size.width)  //414, collectionview frame size almost same as mobile screen width
                    let fullyVisibleItemCount = collectionWidth.quotientAndRemainder(dividingBy: itemWidthWithMargin).quotient// 414/166 = 2, reset the animation till last item is displayed fully, so getting the quotient by dividing frame width by by width of collection item which will give us number of items can be fully displayed at a single moment
                //                print(fullyVisibleItemCount)
                    let offsetShiftTill = itemWidthWithMargin * fullyVisibleItemCount // 166 * 2 , offset till fullyVisibleItemCount items are being displayed
                //                print(self.newOffsetX,offsetShiftTill)
                    if newOffsetX > self.collectionView.contentSize.width - CGFloat(offsetShiftTill) { //846-332
                            newOffsetX = 0 //reset to 0 if offset has increased enough that items cant be see as equal to fullyVisibleItemCount
                    }

                    self.collectionView.setContentOffset(CGPoint(x: newOffsetX,y :0), animated: true)

                } else {
                    newOffsetX = self.collectionView.contentOffset.x
                }
                }
                RunLoop.current.add(self.timer!, forMode: .common)
            }
        } else {
            timer?.invalidate()
        }
    }
}

extension HomeSlider: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeSliderCell.identifier,
                                                      for: indexPath) as! HomeSliderCell
        
        let model = itemsList[indexPath.row]
        cell.primaryImage.isHidden = false;
        cell.containerView.removeLayer(layerName: "videoPlayer") //removing video player if was added
        var avPlayer: AVPlayer!
        
        //This function first checks if thumbnail type is video or image. If video then it checks its media URL, if not found then it looks for video's thumbnail
        //if it is image then it tries to get media URL, if image or image media url is not found then it tries to get the first image of the gallery.
        if( model.thumbnail?.mediaType == "video"){
            //Playing the video
            if let videoLink = URL(string: model.thumbnail?.mediaUrl ?? ""){
                cell.primaryImage.isHidden = true;

                avPlayer = AVPlayer(playerItem: AVPlayerItem(url: videoLink))
                let avPlayerLayer = AVPlayerLayer(player: avPlayer)
                avPlayerLayer.name = "videoPlayer"
                avPlayerLayer.frame = cell.containerView.bounds
                avPlayerLayer.videoGravity = .resizeAspectFill
                cell.containerView.layer.insertSublayer(avPlayerLayer, at: 0)
                avPlayer.play()
                avPlayer.isMuted = true // To mute the sound

                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { _ in
                    avPlayer?.seek(to: CMTime.zero)
                    avPlayer?.play()
                }
            }else if let mediaLink = model.thumbnail?.videoThumbnail {
                cell.primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
            }
        }else if model.thumbnail?.mediaType == "image", let mediaLink = model.thumbnail?.mediaUrl {
            cell.primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
        }
        else if let firstImageLink = model.getGalleryImagesURL().first {
            cell.primaryImage.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
        }
        
        //checking favourite image red or white
        if (model.isFavourite ?? false){
            cell.imgHeart.image = UIImage(named: "heart_red")
        }else{
            cell.imgHeart.image = UIImage(named: "heart_white")
        }
        //Add tap gesture on favourite
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HomeSlider.tappedOnHeart(_:)))
        cell.viewHeart.isUserInteractionEnabled = true   //can also be enabled from IB
        cell.viewHeart.tag = indexPath.row
        cell.viewHeart.addGestureRecognizer(tapGestureRecognizer)
        //Zahoor end
        
        cell.name.text = model.name
        print("model.type:\(model.type)")
        if model.type == "event" || model.type == "special-event" {  //showing start - end date in case of event
            cell.dateContainerView.isHidden = false

            let startDateText = ProductDetailsViewController.convertDateFormate(date: model.startDate!)
            var startTimeText = ProductDetailsViewController.timeFormatter.string(from: model.startDate!)

            var endDateText = ""
            if let eventEndDate = model.endDate {
                endDateText = ProductDetailsViewController.convertDateFormate(date: eventEndDate)
            }
            
            if let timezone = model.timezone {
                startTimeText = "\(startTimeText) (\(timezone))"
            }

            cell.date.text = endDateText != "" ? "\(startDateText) - \(endDateText)" : "\(startDateText) \(startTimeText)"
            cell.imgDate.image = UIImage(named: "calendar_home_white")
        } else { //showing location if available
            //cell.dateContainerView.isHidden = true
            let locationText = model.getCityCountry()
            cell.date.text = locationText.uppercased()
            cell.dateContainerView.isHidden = locationText.isEmpty
            cell.imgDate.image = UIImage(named: "Location White")
        }

        if model.tags?.count ?? 0 > 0, let fistTag = model.tags?[0] {
            cell.tagContainerView.isHidden = false
            cell.tagLabel.text = fistTag.name.uppercased()
        } else {
            cell.tagContainerView.isHidden = true
        }
        
        print("model.type:\(model.type)")
        if  model.type == "villa" || model.type == "yacht"{  //showing number of passenger, cabins, washroom and length
            cell.viewMeasurements.isHidden = false
//            if let constraint = cell.viewTitleHeightConstraint{
//                cell.viewTitle.addConstraint(constraint)
//                cell.viewEmpty.isHidden = false  //other wise viewempty will grow bigger instead of viewTitle
//            }
            
            if model.type == "villa"{
                
                cell.viewLength.isHidden = true     //villa dont have length
                if let val = model.numberOfGuests, val > 0{
                    cell.viewNumberOfGuests.isHidden = false
                    cell.lblNumberOfGuests.text = String(val)
                }else{
                    cell.viewNumberOfGuests.isHidden = true
                }
                if let val = model.numberOfBedrooms, val > 0{
                    cell.viewCabins.isHidden = false
                    cell.lblCabins.text = String(val)
                }else{
                    cell.viewCabins.isHidden = true
                }
                if let val = model.numberOfBathrooms, val > 0{
                    cell.viewWashrooms.isHidden = false
                    cell.lblWashrooms.text = String(val)
                }else{
                    cell.viewWashrooms.isHidden = true
                }
            }else if model.type == "yacht"{
                cell.viewWashrooms.isHidden = true      //yacht dont have washroom
                if let val = model.lengthM, val.count > 0{
                    cell.viewLength.isHidden = false
                    cell.lblLength.text = val
                }else{
                    cell.viewLength.isHidden = true
                }
                if let val = model.guestsNumber, val.count > 0{
                    cell.viewNumberOfGuests.isHidden = false
                    cell.lblNumberOfGuests.text = val
                }else{
                    cell.viewNumberOfGuests.isHidden = true
                }
                if let val = model.cabinNumber, val.count > 0{
                    cell.viewCabins.isHidden = false
                    cell.lblCabins.text = val
                }else{
                    cell.viewCabins.isHidden = true
                }
                
            }
        }else {
            cell.viewMeasurements.isHidden = true   //measurements arent required other then yachts and properties
//            if model.type == "gift"{    //gifts dont have location and/or measurements so let it's title grow in height
//                //it will make the viewTitle grow to show multilines title for gifts especially
//                if let constraint = cell.viewTitleHeightConstraint{
//                    cell.viewTitle.removeConstraint(constraint)
//                    cell.viewEmpty.isHidden = true  //other wise viewempty will grow bigger instead of viewTitle
//                }
//            }
        }
        return cell
        // swiftlint:enable force_cast
    }
}



extension HomeSlider: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectSliderItemAt(indexPath: indexPath, sender: self)
    }
    
    //Zahoor
    @objc func tappedOnHeart(_ sender:AnyObject){
        delegate?.didTappedOnHeartAt(index: sender.view.tag, sender: self)
    }
}

extension HomeSlider: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if itemsList.first?.type == "gift" {
//            //return CGSize(width: 150, height: 172)
//            return CGSize(width: itemWidth, height: giftItemHeight)  //150x148
//        }
        //return CGSize(width: 150, height: 148)
        return CGSize(width: itemWidth, height: itemHeight) //150x172
        
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: CGFloat(itemMargin), bottom: 0, right: CGFloat(itemMargin)) // .zero
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        //return 16
        return CGFloat(itemMargin)
    }
}
