//
//  ProductDetailCell.swift
//  LUJO
//
//  Created by I MAC on 26/11/2020.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import UIKit

class ProductDetailCell: UICollectionViewCell {
    static var identifier: String = "ProductDetailCell"
//    var itemType:ProductType = .summary //default
//    var dictionary =  [String:String]()
    
    @IBOutlet weak var imgDot: UIImageView!
    @IBOutlet weak var lblTopLeft: UILabel!
    @IBOutlet weak var lblTopRight: UILabel!
    @IBOutlet weak var lblBottom: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    private func reset() {
        lblTopLeft.text = ""
        lblTopRight.text = ""
        lblBottom.text = ""
    }
    

}
