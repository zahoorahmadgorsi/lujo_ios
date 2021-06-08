//
//  PrefCollectionViewCell.swift
//  LUJO
//
//  Created by iMac on 08/05/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit

class PrefImageCollViewCell: UICollectionViewCell {

    static var identifier: String = "PrefImageCollViewCell"
    @IBOutlet weak var viewContent: UIView!
    
    @IBOutlet weak var imgView: UIImageView!
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
//        viewContent.addViewBorder( borderColor: UIColor.rgMid.cgColor, borderWith: 1.0, borderCornerRadius: 6.0)
        lblTitle.text = ""
    }
    

}
