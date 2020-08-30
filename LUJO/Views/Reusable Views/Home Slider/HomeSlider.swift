//
//  HomeSlider.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 7/31/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit

protocol DidSelectSliderItemProtocol: class {
    func didSelectSliderItemAt(indexPath: IndexPath, sender: HomeSlider)
}

class HomeSlider: UIView {
    var itemWidth:Int = 150
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
        print(indexPath)
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
