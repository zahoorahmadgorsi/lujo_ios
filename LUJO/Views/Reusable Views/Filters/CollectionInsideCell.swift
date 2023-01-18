//
//  GiftFilterCell.swift
//  LUJO
//
//  Created by Zahoor Gorsi on 26/12/2022.
//  Copyright © 2022 Baroque Access. All rights reserved.
//


import UIKit

class CollectionInsideCell: UICollectionViewCell, UICollectionViewDelegate, MultiLineFilterProtocol {
    var delegate: TapOnCellProtocol?
    
    
    var cell: MultiLineFilterProtocol!
    var scrollDirection: UICollectionView.ScrollDirection!
    var items: [Taxonomy] = [] {
        didSet {
            collectionView.reloadData()
//            print(self.titleView.frame.height,self.collectionViewParent.frame)
            //setting the view height to dynamic
//            self.collectionViewParentHeightConstraint.constant =  self.titleView.frame.height + (self.collectionViewParent.frame.height * CGFloat(items.count))
            self.collectionView.layoutIfNeeded()    //to make it dynammic height
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = self.scrollDirection
        let contentView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        contentView.dataSource = self
        contentView.delegate = self
        contentView.register(UINib(nibName: cell.identifier, bundle: nil), forCellWithReuseIdentifier: cell.identifier)
        contentView.backgroundColor = .clear
        contentView.showsHorizontalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    var identifier: String = "CollectionInsideCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    private func setupLayout() {
        NSLayoutConstraint.activate(
            [collectionView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
             collectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
             collectionView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
             collectionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)]
        )
    }
    
    internal func reset() {
        setupLayout()
    }
    
    func setTitle(title: String) {
        print("Allah ho akbar")
    }

    func setLeftRightImages(leftImageName: String, rightImageName: String) {
//        if leftImageName.count > 0{
//            self.imgLeft.image = UIImage(named: leftImageName)
//        }else{
//            self.viewLeft.isHidden = true
//        }
//        if rightImageName.count > 0{
//            self.imgRight.image = UIImage(named: rightImageName)
//        }else{
//            self.viewRight.isHidden = true
//        }
    }
}



extension CollectionInsideCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cell.identifier, for: indexPath) as? MultiLineFilterProtocol{
            
            let model = items[indexPath.row]
            
            cell.setTitle(title: model.name)
//            cell.setLeftRightImages(leftImageName: self.leftImageName, rightImageName: self.rightImageName)

            return cell as! UICollectionViewCell
        }
        return UICollectionViewCell()
    }
    
    
    
}
