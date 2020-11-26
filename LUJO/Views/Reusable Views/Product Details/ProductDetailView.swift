//
//  ProductDetailView.swift
//  LUJO
//
//  Created by I MAC on 26/11/2020.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import UIKit
enum ProductType {
    case summary
    case price
    case amenities
}

enum ProdCollSize:Int{
    case itemWidth = 175
    case itemHeight = 50
    case itemMargin = 16
}

class ProductDetail{
    internal init(lblTopLeft: String? = nil, lblTopRight: String? = nil, lblBottom: String? = nil) {
        self.lblTopLeft = lblTopLeft
        self.lblTopRight = lblTopRight
        self.lblBottom = lblBottom
    }
    var lblTopLeft: String?
    var lblTopRight: String?
    var lblBottom: String?
}

class ProductDetailView: UIView {

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
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collContainerView: UIView!
    
    let nibName = "ProductDetailView"
    var itemType:ProductType = .summary //default
    
    var itemsList: [ProductDetail] = [] {
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
            //to make animation random
            let randomNumber:TimeInterval = TimeInterval(Int(arc4random_uniform(3)))
            //It’ll return a random number between 0 and this upper bound, minus 1.
            DispatchQueue.main.asyncAfter(deadline: .now() + randomNumber ) {
               
            }
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


}

extension ProductDetailView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductDetailCell.identifier, for: indexPath) as! ProductDetailCell
        
        let model = itemsList[indexPath.row]
        
        cell.lblTopLeft.text = model.lblTopLeft
        cell.lblTopRight.text = model.lblTopRight
        cell.lblBottom.text = model.lblBottom
        
        if (itemType == .summary){
            cell.imgDot.isHidden = true
            cell.lblTopRight.isHidden = true
        }else if (itemType == .price){
            cell.imgDot.isHidden = true
            cell.lblBottom.isHidden = true
        }else if (itemType == .amenities){
            cell.lblTopLeft.isHidden = true
            cell.lblBottom.isHidden = true
        }

        return cell
        // swiftlint:enable force_cast
    }
    
    
}

extension ProductDetailView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: ProdCollSize.itemWidth.rawValue, height: ProdCollSize.itemHeight.rawValue)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: CGFloat(ProdCollSize.itemMargin.rawValue), bottom: 0, right: CGFloat(ProdCollSize.itemMargin.rawValue)) // .zero
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
        return CGFloat(ProdCollSize.itemMargin.rawValue)
    }
    
    
}
