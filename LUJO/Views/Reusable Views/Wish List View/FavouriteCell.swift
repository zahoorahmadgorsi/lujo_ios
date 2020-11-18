//
//  FavouriteCell.swift
//  LUJO
//
//  Created by I MAC on 17/11/2020.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import UIKit

class FavouriteCell: UICollectionViewCell {
    static var identifier: String = "FavouriteCell"
    @IBOutlet weak var imgContainerView: UIView!
    @IBOutlet var primaryImage: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgHeart: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    private func reset() {
        primaryImage.image = UIImage(named: "placeholder-img")
        lblTitle.text = ""
        imgHeart.image = UIImage(named: "heart_white")
    }
    
}
