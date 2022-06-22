//
//  CardCell.swift
//  LUJO
//
//  Created by zahoor gorsi on 22/06/2022.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import UIKit

class CardCell: UITableViewCell {

    @IBOutlet weak var lblOwnerName: UILabel!
    @IBOutlet weak var lblCardNumber: UILabel!
    @IBOutlet weak var lblCardExpiry: UILabel!
    @IBOutlet weak var btnSetAsDefault: ActionButton!
    @IBOutlet weak var btnRemoveCard: ActionButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    private func reset() {
        lblOwnerName.text = ""
        lblCardNumber.text = ""
        lblCardExpiry.text = ""

    }
    
}
