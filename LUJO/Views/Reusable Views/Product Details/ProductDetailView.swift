//
//  ProductDetailView.swift
//  LUJO
//
//  Created by I MAC on 26/11/2020.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import UIKit
enum ProductType:String {
    case summary = "Summary"
    case price = "Price"
    case amenities = "Amenities"
}

enum ProdCollSize:Int{
    case itemWidth = 170    // donn't increase else UI wont look nice on smaller phone i.e. iphone 11
    case summaryHeight = 40
    case priceHeight = 60
    case amenitiesHeight = 20
    case itemMargin = 16
}

class ProductDetail{
    internal init(key: String, value: String, isHighSeason:Bool? ) {
        self.key = key
        self.value = value
        self.isHighSeason = isHighSeason
    }
    var key: String?
    var value: String?
    var isHighSeason: Bool?
}

class ProductDetailView: UIView {
       lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let contentView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        contentView.dataSource = self
        contentView.delegate = self
        contentView.register(UINib(nibName: ProductDetailCell.identifier, bundle: nil), forCellWithReuseIdentifier: ProductDetailCell.identifier)
        contentView.backgroundColor = .clear
        contentView.showsHorizontalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collContainerView: UIView!
    @IBOutlet weak var viewSeeMore: UIView!
    
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
        
        cell.lblTopLeft.text = model.key
        cell.lblTopRight.text = model.value
        cell.lblBottom.text = model.value
        cell.lblPrice.text = model.value
        
        if (itemType == .summary ){
            cell.imgDot.isHidden = true
            cell.lblTopRight.isHidden = true
            cell.svPrice.isHidden = true
        }
        else if (itemType == .price){
            cell.imgDot.isHidden = true
            cell.lblTopRight.isHidden = true
//            cell.lblBottom.isHidden = false
            cell.svPrice.isHidden = false
            if(model.isHighSeason == true){
                cell.lblBottom.text = "(High Season)"
            }else if(model.isHighSeason == false){
                cell.lblBottom.text = "(Low Season)"
            }else{
                cell.lblBottom.text = ""
            }
            cell.lblBottom.font = UIFont.italicSystemFont(ofSize: 11) // cell.lblBottom.font.withSize(11)
            //cell.lblBottom.font = UIFont(name: "SF Pro Display",size: 9)
            cell.lblBottom.textColor = .lightGray
        }
        else if (itemType == .amenities){
            cell.lblTopLeft.isHidden = true
            cell.lblBottom.isHidden = true
            cell.svPrice.isHidden = true
        }

        return cell
        // swiftlint:enable force_cast
    }
    
    
}

extension ProductDetailView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (self.itemType == .summary){
            return CGSize(width: ProdCollSize.itemWidth.rawValue, height: ProdCollSize.summaryHeight.rawValue)
        }else if (self.itemType == .price){
            return CGSize(width: ProdCollSize.itemWidth.rawValue, height: ProdCollSize.priceHeight.rawValue)
        }else{
            return CGSize(width: ProdCollSize.itemWidth.rawValue, height: ProdCollSize.amenitiesHeight.rawValue)
        }
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
