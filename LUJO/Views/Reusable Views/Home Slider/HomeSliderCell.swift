//
//  HomeSliderCell.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 7/31/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit


class HomeSliderCell: UICollectionViewCell {
    static var identifier: String = "HomeSliderCell"

    @IBOutlet weak var containerView: UIView!
    @IBOutlet var primaryImage: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var dateContainerView: UIView!
    @IBOutlet var tagContainerView: UIView!
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var primaryImageHeight: NSLayoutConstraint!
    private var isVideo = false
    
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
        date.text = ""
        dateContainerView.isHidden = false
    }
}
