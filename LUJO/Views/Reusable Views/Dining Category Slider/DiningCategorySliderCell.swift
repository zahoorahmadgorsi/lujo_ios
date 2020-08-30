//
//  DiningCategorySliderCell.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 9/27/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit

class DiningCategorySliderCell: UICollectionViewCell {
    static var identifier: String = "DiningCategorySliderCell"
    
    @IBOutlet var primaryImage: UIImageView!
    @IBOutlet var name: UILabel!

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
        name.text = ""
    }

}
