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
    case experience
}

enum CollectionSize:Int{
    case itemWidth = 175
    case itemHeight = 150
    case itemMargin = 16
}

protocol WishListViewProtocol:class {
    func didTappedOnSeeAll(itemType:FavouriteType)
    func didTappedOnItem()
    func didTappedOnHeartAt()
}

class WishListView: UIView {

//    var itemWidth:Int = 175
//    var itemHeight:Int = 150
//    var itemMargin:Int = 16
    
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
    var itemType:FavouriteType?
    weak var delegate: WishListViewProtocol?
    
    var itemsList: [Favourite] = [] {
        didSet {
            collectionView.reloadData()
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
        view.backgroundColor = .green
        self.addSubview(view)
        self.collContainerView.backgroundColor = .yellow
        self.collContainerView.addSubview(collectionView)
        applyConstraints()
    }
    
    private func applyConstraints() {
        collectionView.leadingAnchor.constraint(equalTo: self.collContainerView.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.collContainerView.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.collContainerView.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.collContainerView.bottomAnchor).isActive = true

    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    @IBAction func btnSeeAllTapped(_ sender: Any) {
        if let type = itemType{
            delegate?.didTappedOnSeeAll(itemType: type)
        }
    }
    
}

extension WishListView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavouriteCell.identifier, for: indexPath) as! FavouriteCell
        cell.backgroundColor = .blue
//        let model = itemsList[indexPath.row]
//        if let mediaLink = model.primaryMedia?.mediaUrl, model.primaryMedia?.type == "image" {
//            cell.primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
//        }
        

        return cell
        // swiftlint:enable force_cast
    }
}



extension WishListView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didTappedOnItem()
    }
    
    //Zahoor
    @objc func tappedOnHeart(_ sender:AnyObject){
        delegate?.didTappedOnHeartAt()
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
