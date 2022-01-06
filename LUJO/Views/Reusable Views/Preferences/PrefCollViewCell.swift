//
//  PrefCollectionViewCell.swift
//  LUJO
//
//  Created by iMac on 08/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit

class PrefCollViewCell: UICollectionViewCell {

    static var identifier: String = "PrefCollViewCell"
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lblTitle: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    private func reset() {
        containerView.addViewBorder( borderColor: UIColor.rgMid.cgColor, borderWidth: 1.0, borderCornerRadius: 6.0)
        lblTitle.text = ""
    }
    

}
