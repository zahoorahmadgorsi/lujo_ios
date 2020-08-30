//
//  DiningViewCell.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 8/12/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit

class DiningViewCell: UICollectionViewCell {
    static var identifier: String = "DiningViewCell"

    @IBOutlet var primaryImage: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var location: UILabel!
    @IBOutlet var locationContainerView: UIView!
    @IBOutlet var starCountLabel: UILabel!
    @IBOutlet var starImageContainerView: UIView!

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
        location.text = ""
        locationContainerView.isHidden = false
        starCountLabel.text = ""
        starImageContainerView.isHidden = false
    }
}
