//
//  HomeSlider.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 7/31/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import AVFoundation

protocol DidSelectSliderItemProtocol: class {
    func didSelectSliderItemAt(indexPath: IndexPath, sender: HomeSlider)
    func didTappedOnHeartAt(index: Int, sender: HomeSlider)
}

class HomeSlider: UIView {
    var itemWidth:Int = 175
    var eventItemHeight:Int = 172
    var experienceItemHeight:Int = 148
    var itemMargin:Int = 16
    
    
    lazy var homeSliderView: UICollectionView = {
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

    var itemsList: [EventsExperiences] = [] {
        didSet {
            homeSliderView.reloadData()
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
        addSubview(homeSliderView)
        setupLayout()
    }

    private func setupLayout() {
        NSLayoutConstraint.activate(
            [homeSliderView.topAnchor.constraint(equalTo: topAnchor),
             homeSliderView.bottomAnchor.constraint(equalTo: bottomAnchor),
             homeSliderView.leadingAnchor.constraint(equalTo: leadingAnchor),
             homeSliderView.trailingAnchor.constraint(equalTo: trailingAnchor)]
        )
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
   
}

extension HomeSlider: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = homeSliderView.dequeueReusableCell(withReuseIdentifier: HomeSliderCell.identifier,
                                                      for: indexPath) as! HomeSliderCell
        
        let model = itemsList[indexPath.row]
        if let mediaLink = model.primaryMedia?.mediaUrl, model.primaryMedia?.type == "image" {
            cell.primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
        }
        //Zahoor started 20201026
        cell.primaryImage.isHidden = false;
        cell.containerView.removeLayer(layerName: "videoPlayer") //removing video player if was added
        var avPlayer: AVPlayer!
        if( model.primaryMedia?.type == "video"){
            //Playing the video
            if let videoLink = URL(string: model.primaryMedia?.mediaUrl ?? ""){
                cell.primaryImage.isHidden = true;

                avPlayer = AVPlayer(playerItem: AVPlayerItem(url: videoLink))
                let avPlayerLayer = AVPlayerLayer(player: avPlayer)
                avPlayerLayer.name = "videoPlayer"
                avPlayerLayer.frame = cell.containerView.bounds
                avPlayerLayer.videoGravity = .resizeAspectFill
                cell.containerView.layer.insertSublayer(avPlayerLayer, at: 0)
                avPlayer.play()
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
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HomeSlider.tappedOnHeart(_:)))
        cell.imgHeart.isUserInteractionEnabled = true   //can also be enabled from IB
        cell.imgHeart.tag = indexPath.row
        cell.imgHeart.addGestureRecognizer(tapGestureRecognizer)

        //Zahoor end
        
        cell.name.text = model.name

        if model.type == "event" {
            cell.dateContainerView.isHidden = false

            let startDateText = EventDetailsViewController.convertDateFormate(date: model.startDate!)
            var startTimeText = EventDetailsViewController.timeFormatter.string(from: model.startDate!)

            var endDateText = ""
            if let eventEndDate = model.endDate {
                endDateText = EventDetailsViewController.convertDateFormate(date: eventEndDate)
            }
            
            if let timezone = model.timezone {
                startTimeText = "\(startTimeText) (\(timezone))"
            }
            
            cell.date.text = endDateText != "" ? "\(startDateText) - \(endDateText)" : "\(startDateText) \(startTimeText)"
        } else {
            cell.dateContainerView.isHidden = true
        }

        if model.tags?.count ?? 0 > 0, let fistTag = model.tags?[0] {
            cell.tagContainerView.isHidden = false
            cell.tagLabel.text = fistTag.name.uppercased()
        } else {
            cell.tagContainerView.isHidden = true
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
        if itemsList.first?.type == "event" {
            //return CGSize(width: 150, height: 172)
            return CGSize(width: itemWidth, height: eventItemHeight) //150x172
        }
        //return CGSize(width: 150, height: 148)
        return CGSize(width: itemWidth, height: experienceItemHeight)  //150x148
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
