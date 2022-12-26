//
//  PrefCollectionViewCell.swift
//  LUJO
//
//  Created by iMac on 08/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit

class AirportCollViewCell: UICollectionViewCell, MultiLineFilterProtocol {
    func setLeftRightImages(leftImageName: String, rightImageName: String) {
        //only used in gift filter
    }
    
    var identifier: String = "AirportCollViewCell"
    @IBOutlet weak var imgContainerView: UIView!
    @IBOutlet weak var lblTitle: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    internal func reset() {
        imgContainerView.addViewBorder( borderColor: UIColor.rgMid.cgColor, borderWidth: 1.0, borderCornerRadius: 6.0)
        lblTitle.text = ""
    }
    
    func setTitle(title:String){
        self.lblTitle.text = title
    }

}
