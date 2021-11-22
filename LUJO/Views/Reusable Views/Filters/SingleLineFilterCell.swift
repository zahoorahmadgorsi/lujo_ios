//
//  SingleLineFilterCell.swift
//  LUJO
//
//  Created by iMac on 23/10/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit

protocol SingleLineFilterCellProtocol:class {
    func didTappedOnCheckBox(index:Int)
}

class SingleLineFilterCell: UICollectionViewCell {
    
    static var identifier: String = "SingleLineFilterCell"

    
    @IBOutlet weak var viewImage: UIView!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var viewLabel: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var svBottom: UIStackView!
    var delegate:SingleLineFilterCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    private func reset() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTappedOnCheckBox))
        viewImage.isUserInteractionEnabled = true
        viewImage.addGestureRecognizer(tapGesture)
    }
    
    //this function will change the look and feel of the view
    public func changeCellLook(isTagLookAlike:Bool, isSelected:Bool) {
        self.viewImage.isHidden =  isTagLookAlike   //hide the checkbox image
        if (isTagLookAlike){
            self.lblTitle.textAlignment = .center
            if (isSelected){
                self.viewLabel.backgroundColor = UIColor.rgMid
                self.lblTitle.textColor = .white
            }else{
                self.lblTitle.textColor = .rgMid
                self.viewLabel.backgroundColor = .clear
            }
            self.viewLabel.addViewBorder(borderColor: UIColor.rgMid.cgColor, borderWidth: 1.0, borderCornerRadius: 4)
        }
    }
    
    
    @objc func didTappedOnCheckBox(_ sender: Any) {
        delegate?.didTappedOnCheckBox(index: imgView.tag)
    }
    
}


