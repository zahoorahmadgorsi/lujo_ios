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
    @IBOutlet weak var txtCurrency: LujoTextField!
    @IBOutlet weak var txtMinimum: UITextField!
    @IBOutlet weak var txtMaximum: UITextField!
    
    var selectedItem:Taxonomy?    //for currency
    var picker: ikDataPickerManger?
    var strPickerSelection:String?  //what user has picked from the picker would be saved here
    var pickerItems: [[String]] = [[]] {
        didSet {
//            collectionView.reloadData()
        }
    }
    
//    var items: [Taxonomy] = [] {
//        didSet {
//        }
//    }
    
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
 
        txtCurrency.delegate = self //to make it unediitable and to open the picker
        txtMinimum.delegate = self //to make it uneditable
        txtMaximum.delegate = self //to make it uneditable
    }
    
    private func setupViewUI() {
        
    }
    
    func loadCurrencies(textField: UITextField){
        self.parentViewController?.view.endEditing(true)
        
        if picker == nil {
            picker = ikDataPickerManger.create(owner: self.parentViewController!, sourceView: textField , title: "Please select one", dataSource: pickerItems, callback: { [self] values in
                if values.count > 0{
    //                self.lblPickerSelection.text = values[0]
                    self.txtCurrency.text = values[0]
                    self.strPickerSelection = values[0]
                }
            })
        }
        picker?.present()
    }
}

extension MinMaxFilter:  UITextFieldDelegate{
    //making preffered destination field uneditable
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.tag == FilterType.EventPrice.rawValue{   //event currency
            if textField == self.txtCurrency {
                let viewController = DestinationSelectionViewController.instantiate(prefInformationType: .currency)
                viewController.delegate = self
                self.parentViewController?.present(viewController, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
}

extension MinMaxFilter:DestinationSearchViewDelegate{
    //WHen user has selected some destination region
    func select(_ destination: Taxonomy) {
        if self.tag == FilterType.EventPrice.rawValue{
            self.selectedItem = destination
            self.txtCurrency.text = self.selectedItem?.name
            self.selectedItem?.isSelected = true
        }
    }
}

