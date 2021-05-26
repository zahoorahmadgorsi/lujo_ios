//
//  PrefCollectionViewCell.swift
//  LUJO
//
//  Created by iMac on 08/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit

class ProdCategoryCollViewCell: UICollectionViewCell {

    static var identifier: String = "ProdCategoryCollViewCell"
    @IBOutlet weak var imgContainerView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgProduct: UIImageView!
//    @IBOutlet weak var imgProductWidthConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    private func reset() {
//        imgContainerView.addViewBorder( borderColor: UIColor.rgMid.cgColor, borderWith: 1.0,borderCornerRadius: 2.0)
        lblTitle.text = ""
    }
    

}
