//
//  BrandsCell.swift
//  LUJO
//
//  Created by Zahoor Gorsi on 24/02/2023.
//  Copyright © 2023 Baroque Access. All rights reserved.
//

import UIKit

class BrandCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    private func reset() {
        lblTitle.text = ""
    }
    
}
