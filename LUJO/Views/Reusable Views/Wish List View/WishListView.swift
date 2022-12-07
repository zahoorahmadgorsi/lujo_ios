//
//  WishListView.swift
//  LUJO
//
//  Created by I MAC on 16/11/2020.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import UIKit
import AVFoundation

enum FavouriteType {
    case event
    case specialEvent
    case experience
    case restaurant
//    case hotel
    case villa
    case gift
    case yacht
}

enum CollectionSize:Int{
    case itemWidth = 175
    case itemHeight = 150
    case itemMargin = 16
}

protocol WishListViewProtocol:class {
    func didTappedOnSeeAll(itemType:FavouriteType)
    func didTappedOnItem(indexPath: IndexPath,itemType:FavouriteType, sender: WishListView)
    func didTappedOnHeartAt(index: Int,favouriteType:FavouriteType, sender: WishListView)
}

class WishListView: UIView {
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let contentView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        contentView.dataSource = self
        contentView.delegate = self
        contentView.register(UINib(nibName: FavouriteCell.identifier, bundle: nil), forCellWithReuseIdentifier: FavouriteCell.identifier)
        contentView.backgroundColor = .clear
        contentView.showsHorizontalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    @IBOutlet weak var imgTitle: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collContainerView: UIView!
    
    let nibName = "WishListView"
    var itemType:FavouriteType = .event //default
    weak var delegate: WishListViewProtocol?
    var timer = Timer()
    @IBOutlet weak var viewSeeAll: UIView!
    
    var itemsList: [Favourite] = [] {
        didSet {
            collectionView.reloadData()
            collectionView.layoutIfNeeded() //forces the reload to happen immediately instead of on the next runloop cycle.
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    
    
    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        self.collContainerView.addSubview(collectionView)
        applyConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(btnSeeAllTapped))
        viewSeeAll.isUserInteractionEnabled = true
        viewSeeAll.addGestureRecognizer(tapGesture)
    
    }
    
    private func applyConstraints() {
        collectionView.leadingAnchor.constraint(equalTo: self.collContainerView.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.collContainerView.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.collContainerView.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.collContainerView.bottomAnchor).isActive = true
//        self.collContainerView.heightAnchor.constraint(equalTo: collectionView.heightAnchor).isActive = true
        
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    @objc func btnSeeAllTapped(_ sender: Any) {
//        if let itemType = itemType{
            delegate?.didTappedOnSeeAll(itemType: itemType)
//        }
    }
    
//This method animates the Event and Experiences slider at the home screen
    func startPauseAnimation(isPausing : Bool  ) {
        var newOffsetX: CGFloat = 0.0
        
        if !isPausing{
            let randomNumber:TimeInterval = TimeInterval(Int(arc4random_uniform(UInt32(HomeViewController.animationInterval)))) //making start of animation as random
            //It’ll return a random number between 0 and this upper bound, minus 1.
            DispatchQueue.main.asyncAfter(deadline: .now() + randomNumber ) {
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
                RunLoop.current.add(self.timer, forMode: .common)
            }
        } else {
            timer.invalidate()
        }
    }
    
    
}
//
extension WishListView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavouriteCell.identifier, for: indexPath) as! FavouriteCell
        
        let model = itemsList[indexPath.row]
        if let mediaLink = model.primaryMedia?.mediaUrl, model.primaryMedia?.mediaType == "image" {
            cell.primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
        }//Zahoor started 20201026
        else if let firstImageLink = model.getGalleryImagesURL().first {
            cell.primaryImage.downloadImageFrom(link: firstImageLink, contentMode: .scaleAspectFill)
        }
        //Zahoor started 20201026
        cell.primaryImage.isHidden = false;
        cell.imgContainerView.removeLayer(layerName: "videoPlayer") //removing video player if was added
        var avPlayer: AVPlayer!
        if( model.primaryMedia?.mediaType == "video"){
            //Playing the video
            if let videoLink = URL(string: model.primaryMedia?.mediaUrl ?? ""){
                cell.primaryImage.isHidden = true;

                avPlayer = AVPlayer(playerItem: AVPlayerItem(url: videoLink))
                let avPlayerLayer = AVPlayerLayer(player: avPlayer)
                avPlayerLayer.name = "videoPlayer"
                avPlayerLayer.frame = cell.imgContainerView.bounds
                avPlayerLayer.videoGravity = .resizeAspectFill
                cell.imgContainerView.layer.insertSublayer(avPlayerLayer, at: 0)
                avPlayer.play()
                avPlayer.isMuted = true // To mute the sound
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { _ in
                    avPlayer?.seek(to: CMTime.zero)
                    avPlayer?.play()
                }
            }else
                if let mediaLink = model.primaryMedia?.thumbnail {
                cell.primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
            }
        }
        //checking favourite image red or white
        if (model.isFavourite ?? false){
            cell.imgHeart.image = UIImage(named: "heart_red")
        }else{
            cell.imgHeart.image = UIImage(named: "heart_white")
        }
        //Add tap gesture on favourite
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WishListView.tappedOnHeart(_:)))
        cell.viewHeart.isUserInteractionEnabled = true   //can also be enabled from IB
        cell.viewHeart.tag = indexPath.row
        cell.viewHeart.addGestureRecognizer(tapGestureRecognizer)

        //Zahoor end
        
        cell.lblTitle.text = model.name
        

        return cell
        // swiftlint:enable force_cast
    }
    
    
}



extension WishListView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didTappedOnItem(indexPath: indexPath, itemType:self.itemType,sender: self)
    }
    
    @objc func tappedOnHeart(_ sender:AnyObject){
        delegate?.didTappedOnHeartAt(index: sender.view.tag,favouriteType:self.itemType, sender: self)
    }
}

extension WishListView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: CollectionSize.itemWidth.rawValue, height: CollectionSize.itemHeight.rawValue)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: CGFloat(CollectionSize.itemMargin.rawValue), bottom: 0, right: CGFloat(CollectionSize.itemMargin.rawValue)) // .zero
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
        return CGFloat(CollectionSize.itemMargin.rawValue)
    }
    
    
}
