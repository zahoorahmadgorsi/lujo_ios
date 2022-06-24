//
//  CardCell.swift
//  LUJO
//
//  Created by zahoor gorsi on 22/06/2022.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import UIKit

class CardCell: UITableViewCell {

    @IBOutlet weak var lblCardHolderName: UILabel!
    @IBOutlet weak var lblCardNumber: UILabel!
    @IBOutlet weak var lblCardExpiry: UILabel!
    @IBOutlet weak var viewSetAsDefault: UIView!
    @IBOutlet weak var lblCardSetAsDefault: UILabel!    //set as default label on card, there is an other label having title set as default
    @IBOutlet weak var viewRemoveCard: UIView!
    @IBOutlet weak var lblRemoveCard: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    private func reset() {
        lblCardHolderName.text = ""
        lblCardNumber.text = ""
        lblCardExpiry.text = ""
        lblCardSetAsDefault.text = ""
        
        //adding background image
        self.contentView.addBackGroundImage(imageName: "card_background")
        
        viewRemoveCard.backgroundColor = UIColor.grayButton
//        viewSetAsDefault.addViewBorder( borderColor: UIColor.rgMid.cgColor, borderWidth: 1.0, borderCornerRadius: 0.0)
    }
    
}
