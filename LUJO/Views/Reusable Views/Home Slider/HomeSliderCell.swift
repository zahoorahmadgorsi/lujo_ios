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
    
    @IBOutlet weak var imgDate: UIImageView!
    @IBOutlet var date: UILabel!
    @IBOutlet var dateContainerView: UIView!
    @IBOutlet var tagContainerView: UIView!
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var primaryImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var viewTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewHeart: UIView!
    @IBOutlet weak var imgHeart: UIImageView!
    
    @IBOutlet weak var viewMeasurements: UIView!
    @IBOutlet weak var viewLength: UIView!
    @IBOutlet weak var lblLength: UILabel!
    @IBOutlet weak var viewNumberOfGuests: UIView!
    @IBOutlet weak var lblNumberOfGuests: UILabel!
    @IBOutlet weak var viewCabins: UIView!
    @IBOutlet weak var lblCabins: UILabel!
    @IBOutlet weak var viewWashrooms: UIView!
    @IBOutlet weak var lblWashrooms: UILabel!
    @IBOutlet weak var viewEmpty: UIView!
    
    
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
