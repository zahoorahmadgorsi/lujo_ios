//
//  GiftFilterCell.swift
//  LUJO
//
//  Created by Zahoor Gorsi on 26/12/2022.
//  Copyright © 2022 Baroque Access. All rights reserved.
//


import UIKit



protocol TapOnGiftCellProtocol {
    func didTappedOnItem(at index:Int , filterCellType: FilterCellType?)
}

class GiftFilterCell: UICollectionViewCell, GiftFilterProtocol {
    var delegate: TapOnGiftCellProtocol?
    
    var identifier: String = "GiftFilterCell"
    var filterCellType:FilterCellType?
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var viewLeft: UIView!
    @IBOutlet weak var imgLeft: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewRight: UIView!
    @IBOutlet weak var imgRight: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    internal func reset() {
        lblTitle.text = ""
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTappedOnMainView))
        mainView.isUserInteractionEnabled = true
        mainView.addGestureRecognizer(tapGesture)
    }
    
    func setLeftRightImages(leftImageName: String, rightImageName: String = "filters_uncheck"){
        if leftImageName.count > 0{
            self.imgLeft.image = UIImage(named: leftImageName)
        }else{
            self.viewLeft.isHidden = true
        }
        if rightImageName.count > 0{
            self.imgRight.image = UIImage(named: rightImageName)
        }else{
            self.viewRight.isHidden = true
        }
    }
    
    func setTitle(title: String) {
        self.lblTitle.text = title
    }
    
    @objc func didTappedOnMainView(_ sender: Any) {
        delegate?.didTappedOnItem(at: self.mainView.tag, filterCellType: self.filterCellType)
    }
}
