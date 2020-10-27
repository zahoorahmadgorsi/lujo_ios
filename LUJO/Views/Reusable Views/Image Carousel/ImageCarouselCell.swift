//
//  ImageCarouselCell.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 6/18/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit

class ImageCarouselCell: UICollectionViewCell {
    static var identifier: String = "ImageCarouselCell"

    @IBOutlet weak var containerView: UIView!
    @IBOutlet var primaryImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!

    @IBOutlet var tagsContainerView: UIView!
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var locationContainerView: UIView!
    @IBOutlet var starsLabel: UILabel!
    @IBOutlet var starsContainerView: UIView!
    
    @IBOutlet var gradientImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    private func reset() {
        primaryImage.image = UIImage(named: "placeholder-img")!
        titleLabel.text = ""
        categoryLabel.text = ""
        locationLabel.text = ""
        locationContainerView.isHidden = false
        starsLabel.text = ""
        starsContainerView.isHidden = false
        tagsContainerView.alpha = 0
    }
}
