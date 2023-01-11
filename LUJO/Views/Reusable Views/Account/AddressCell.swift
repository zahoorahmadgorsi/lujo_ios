//
//  AddressCell.swift
//  LUJO
//
//  Created by zahoor gorsi on 22/06/2022.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import UIKit

class AddressCell: UITableViewCell {
    
    @IBOutlet weak var viewTapToEdit: UIView!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblNumber: UILabel!  //apartment, suit, office number
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblPostalCode: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var viewSetAsDefault: UIView!
    @IBOutlet weak var lblAddressSetAsDefault: UILabel!    //set as default label on address, there is an other label having title set as default
    @IBOutlet weak var viewRemoveAddress: UIView!


    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    private func reset() {
        lblNumber.text = ""
        lblAddress.text = ""
        lblPostalCode.text = ""
        lblCity.text = ""
        lblCountry.text = ""
        //adding background image
        self.contentView.addBackGroundImage(imageName: "card_background")
        
        viewRemoveAddress.backgroundColor = UIColor.grayButton
//        viewSetAsDefault.addViewBorder( borderColor: UIColor.rgMid.cgColor, borderWidth: 1.0, borderCornerRadius: 0.0)
    }
    
    
}
