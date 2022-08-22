//
//  ikDataPickerViewController.swift
//  Aqtive
//
//  Created by Kristian Iker on 12/1/17.
//  Copyright Â© 2017 Kristian Iker. All rights reserved.
//

import UIKit

class ikDataPickerManger {
    
    private let dataPickViewController: ikDataPickerViewController
    
    private init() {
        self.dataPickViewController = ikDataPickerViewController()
    }
    
    func present() {
        dataPickViewController.present()
    }
    
    func setTintColor(_ color: UIColor) {
        dataPickViewController.pickerView.tintColor = color
    }
    
    func setStartValues(_ values: [String]) {
        dataPickViewController.startValues = values
    }
    
    
    class func create(owner: UIViewController, sourceView: UIView?, title: String?, dataSource: [[String]], okTitle:String?="OK" , cancelTitle:String? = "Cancel" , callback: (([String])->(Void))? = nil) -> ikDataPickerManger {

        let instance = ikDataPickerManger()
        instance.dataPickViewController.owner = owner
        instance.dataPickViewController.sourceView = sourceView
        instance.dataPickViewController.pickerTitle = title
        instance.dataPickViewController.dataSource = dataSource
        instance.dataPickViewController.callback = callback
        instance.dataPickViewController.okTitle = okTitle ?? "OK"
        instance.dataPickViewController.cancelTitle = cancelTitle ?? "Cancel"
        return instance
    }
    
    class func destroy(_ manager: ikDataPickerManger) {
        manager.dataPickViewController.owner = nil
        manager.dataPickViewController.callback = nil
    }
    
    fileprivate class ikDataPickerViewController: UIViewController {
        
        fileprivate var owner: UIViewController!
        fileprivate var sourceView: UIView?
        fileprivate var pickerTitle: String?
        fileprivate var okTitle: String?
        fileprivate var cancelTitle: String?
        fileprivate var dataSource: [[String]] = []
        fileprivate var callback: (([String])->(Void))?
        fileprivate var startValues: [String] = []
        
        lazy var pickerView: UIPickerView = {
            let pickerView = UIPickerView()
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                print ("Usao iphone")
                pickerView.frame = CGRect(x: 30, y: 30, width: UIScreen.main.bounds.size.width - 80, height: 200)
            } else {
                print ("Usao tablet")
                pickerView.frame = CGRect(x: 0, y: 30, width: 300, height: 200)
            }
            
            pickerView.delegate = self
            pickerView.dataSource = self
            pickerView.tintColor = owner.view.tintColor
            return pickerView
        }()
        
        fileprivate var selectedValues: [String] = []
        
        fileprivate func present() {
            let body =  "\n\n\n\n\n\n\n\n\n"
            let alertController = UIAlertController(title: pickerTitle, message: body, preferredStyle: .actionSheet)
            
            pickerView.reloadAllComponents()
            
            if selectedValues.count == 0 {
                for (index, value) in startValues.enumerated() {
                    if let row = dataSource[index].index(of: value) {
                        pickerView.selectRow(row, inComponent: index, animated: false)
                    }
                }
            }
            
            alertController.view.addSubview(pickerView)
            alertController.view.tintColor = UIColor.rgMid
            
            alertController.addAction(UIAlertAction(title: self.cancelTitle, style: .cancel, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.selectedValues = []
                strongSelf.callback?(strongSelf.selectedValues)
            }))
            alertController.addAction(UIAlertAction(title: self.okTitle, style: .default, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.selectedValues = []
                for (component, data) in strongSelf.dataSource.enumerated() {
                    if data.count > 0 {
                        strongSelf.selectedValues.append(data[strongSelf.pickerView.selectedRow(inComponent: component)])
                    }
                }
                strongSelf.callback?(strongSelf.selectedValues)
            }))
            
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 22, width: 0, height: 0)
            
            owner.present(alertController, animated: true, completion: nil)
        }
        
    }
    
}

extension ikDataPickerManger.ikDataPickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource[component].count
    }
}

extension ikDataPickerManger.ikDataPickerViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[component][row]
    }
    
}

