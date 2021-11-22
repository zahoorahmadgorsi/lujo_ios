//
//  TextFieldFilter.swift
//  LUJO
//
//  Created by iMac on 22/10/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//


import UIKit
import AVFoundation

//protocol CityViewProtocol:class {
//    func seeAllProductsForCity(city: Cities)
//    func didTappedOnProductAt(product: Product, itemIndex: Int)
//    func didTappedOnHeartAt(city: Cities, itemIndex: Int)
//}

class MinMaxFilter: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtMinimum: UITextField!
    @IBOutlet weak var txtMaximum: UITextField!
    
    var selectedItem:Taxonomy?    //for region
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("MinMaxFilter", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
 
        txtMinimum.delegate = self //to make it uneditable
        txtMaximum.delegate = self //to make it uneditable
    }
    
    private func setupViewUI() {
        
    }
}

extension MinMaxFilter:  UITextFieldDelegate{
    //making preffered destination field uneditable
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        let min =  self.txtMinimum.text ?? ""
//        let max = self.txtMaximum.text ?? ""
//        if min.count > 0 ,  max.count > 0 , Int(max) ?? 0 < Int(min) ?? 0{
//            return false
//        }
        return true
    }
}
