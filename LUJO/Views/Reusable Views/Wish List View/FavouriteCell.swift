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
    @IBOutlet var primaryImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    private func reset() {
        //primaryImage.image = UIImage(named: "placeholder-img")
    }
    
}
