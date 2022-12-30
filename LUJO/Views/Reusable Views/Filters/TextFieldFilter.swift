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

class TextFieldFilter: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtName: UITextField!
    
    @IBOutlet weak var bntPleaseSelect: UIButton!
    @IBOutlet weak var viewPicker: UIView!
    @IBOutlet weak var lblPickerSelection: UILabel! //Initially place holder and later what user has picked from the picker would be saved here
    var txtPickerSelection:String?  //what user has picked from the picker would be saved here
    var picker: ikDataPickerManger?
    
    var items: [[String]] = [[]] {
        didSet {
//            collectionView.reloadData()
        }
    }
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
        Bundle.main.loadNibNamed("TextFieldFilter", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        bntPleaseSelect.layer.borderWidth = 1
        bntPleaseSelect.layer.borderColor = UIColor.inputBorderNoFocus.cgColor
        
        
//        if self.tag == 9{   //for region
            txtName.delegate = self //to make it uneditable
//        }
    }
    
    private func setupViewUI() {
        
    }

    @IBAction func btnTappedOnPicker(_ sender: Any) {
        self.parentViewController?.view.endEditing(true)
        
        if picker == nil {
            picker = ikDataPickerManger.create(owner: self.parentViewController!, sourceView: sender as? UIView, title: "Please select one", dataSource: items, callback: { [self] values in
                self.lblPickerSelection.text = values[0]
                self.txtPickerSelection = values[0]
            })
        }
        picker?.present()
    }
    
 

}

extension TextFieldFilter:  UITextFieldDelegate{
    //making preffered destination field uneditable
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print (self.tag)
        if textField == self.txtName {
            if self.tag == FilterType.EventLocation.rawValue{   //event region
                let viewController = DestinationSelectionViewController.instantiate(prefInformationType: .eventLocation)   
                viewController.delegate = self
                self.parentViewController?.present(viewController, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
}

extension TextFieldFilter:DestinationSearchViewDelegate{
    //WHen user has selected some destination region
    func select(_ destination: Taxonomy) {
        self.selectedItem = destination
        self.txtName.text = self.selectedItem?.name
        self.selectedItem?.isSelected = true
    }
}
