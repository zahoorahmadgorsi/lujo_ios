//
//  addressesViewController.swift
//  LUJO
//
//  Created by Zahoor Gorsi on 22/06/2022.
//  Copyright © 2022 Baroque Access. All rights reserved.
//

import Foundation
import UIKit
import JGProgressHUD
import FirebaseCrashlytics

class AddressesViewController: UIViewController {
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "AddressesViewController" }
    private let naHUD = JGProgressHUD(style: .dark)
    var addresses = [Address](){
        didSet{
            tblView.reloadData()
        }
    }
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnAddANewAddress: ActionButton!
    
    /// Init method that will init and return view controller.
    class func instantiate() -> AddressesViewController {
        return UIStoryboard.accountNEW.instantiate(identifier)
    }
    var deleteIndexPath: IndexPath? = nil //used while deleting at swipe left
    var boolSetAsDefault:Bool = false
    //MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addViewBorder(borderColor: UIColor.clear.cgColor, borderWidth: 1.0, borderCornerRadius: 24.0)
        self.tblView.dataSource = self;
        self.tblView.delegate = self;
        self.title = "Addresses"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.getAddresses()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func getAddresses(showActivity: Bool = true) {
        if (showActivity){
            self.showNetworkActivity()  //if no data is cached then fetch openly else silently
        }
        getAddresses() {addresses, error in
            self.hideNetworkActivity()
            if let error = error {
                self.showError(error)
                return
            }
            if let informations = addresses {
                if informations.count > 0{  //it will contain zero in case of hard coded values
                    self.addresses.removeAll()
                    self.addresses = informations
                    self.tblView.reloadData()
                }
            } else {
                if error?._code == 403{
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.logoutUser()
                }else{
                    let error = BackendError.parsing(reason: "Could not obtain the list of addresses")
                    self.showError(error)
                }
            }
        }
    }
    
    func getAddresses(completion: @escaping ([Address]?, Error?) -> Void) {
        GoLujoAPIManager().getAddresses() { addresses, error in
            guard error == nil else {
                Crashlytics.crashlytics().record(error: error!)
                if error?._code == 403{
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.logoutUser()
                }else{
                    let description = error?.localizedDescription ?? "Could not obtain the list of addresses"
                    let error = BackendError.parsing(reason: description)
                    completion(nil, error)
                }
                return
            }
            completion(addresses, error)
        }
    }
    
    func showError(_ error: Error , isInformation:Bool = false) {
        if (isInformation){
            showErrorPopup(withTitle: "Information", error: error)
        }else{
            showErrorPopup(withTitle: "Address Error", error: error)
        }
        
    }
    
    func showNetworkActivity() {
        // Safe guard to that won't display both loaders at same time.
            naHUD.show(in: view)
    }
    
    func hideNetworkActivity() {
        // Safe guard that will call dismiss only if HUD is shown on screen.
        if naHUD.isVisible {
            naHUD.dismiss()
        }
    }
    
    @IBAction func btnAddANewAddressTapped(_ sender: Any) {
        let viewController = AddressViewController.instantiate()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension AddressesViewController: UITableViewDelegate, UITableViewDataSource{

    //The basic idea is to create a new section (rather than a new row) for each array item. The sections can then be spaced using the section header height.
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.addresses.count == 0 {
            self.tblView.setEmptyMessage("No address(s) are available", txtColor: .white)
        }else{
            self.tblView.restore()
        }
        return self.addresses.count
        }
        
    
        // There is just one row in every section
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }
        
        // Set the spacing between sections
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 1
        }
        
        // Make the background color show through
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerView = UIView()
            headerView.backgroundColor = UIColor.clear
            return headerView
        }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell") as! AddressCell
        let index = indexPath.section
        let model = addresses[index]

        //Title of the address
        cell.lblType.text = model.address_type
        cell.lblNumber.text = model.apartment
        cell.lblAddress.text = model.address
        cell.lblPostalCode.text = model.zip_code
        cell.lblCity.text = model.city.name
        cell.lblCountry.text = model.country.name
        
        //Setting tap gesture on tap to edit
        let gestureEdit = UITapGestureRecognizer(target: self, action:  #selector (self.tappedOnEdit (_:)))
        cell.viewTapToEdit.tag = indexPath.section
        cell.viewTapToEdit.addGestureRecognizer(gestureEdit)
        
        if(model.default_address){ //if default is true then update button title
            cell.lblAddressSetAsDefault.text =  "D E F A U L T"
            cell.viewSetAsDefault.backgroundColor = UIColor.lightGrey
            cell.lblAddressSetAsDefault.textColor = UIColor.white
        }else{
            cell.viewSetAsDefault.tag = indexPath.section
            cell.lblAddressSetAsDefault.text =  "S E T   A S   D E F A U L T"
            cell.viewSetAsDefault.backgroundColor = UIColor.rgMid
            cell.lblAddressSetAsDefault.textColor = UIColor.white
            let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.tappedOnLblSetAsDefault (_:)))
            cell.viewSetAsDefault.addGestureRecognizer(gesture)
        }
        
        //settings tags on cell and both buttons so that i can catch the tapp
        cell.tag = index
        cell.viewRemoveAddress.tag = index
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.tappedOnRemoveAddress (_:)))
        cell.viewRemoveAddress.addGestureRecognizer(gesture)
        
        cell.contentView.addViewBorder( borderColor: UIColor.clear.cgColor, borderWidth: 1.0, borderCornerRadius: 12.0)

        
        return cell
    }
    
    @objc func tappedOnEdit(_ sender:UITapGestureRecognizer){
        if let tag = sender.view?.tag{
            let address = addresses[tag]
            let viewController = AddressViewController.instantiate(address: address)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @objc func tappedOnRemoveAddress(_ sender:UITapGestureRecognizer){
        if let tag = sender.view?.tag{
            let address = addresses[tag]
            self.deleteIndexPath = IndexPath(row:0, section: tag)
            confirmDelete(address)
        }
        
    }
    
    @objc func tappedOnLblSetAsDefault(_ sender:UITapGestureRecognizer){
        if let tag = sender.view?.tag{
            var address = addresses[tag]
            address.default_address = true
            showNetworkActivity()
            GoLujoAPIManager().addressUpdate(address) { stringResponse, error in
                self.hideNetworkActivity()
                guard error == nil else {
                    Crashlytics.crashlytics().record(error: error!)
                    if error?._code == 403{
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.logoutUser()
                    }else{
                        let description = error?.localizedDescription ?? "Address could not be updated."
                        let error = BackendError.parsing(reason: description)
                        self.showError(error)
                    }
                    return
                }
                self.getAddresses(showActivity: false)
            }
        }
    }
    
    func confirmDelete(_ address: Address) {
        let alert = UIAlertController(title: "Delete Confirmation", message: "Are you sure you want to permanently delete this address?", preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteAddress)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: handleCancelChannel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
   }
    
    func handleDeleteAddress(alertAction: UIAlertAction! ) -> Void {
        if let indexPath = self.deleteIndexPath {
            let index = indexPath.section
            let address = addresses[index]
            showNetworkActivity()
            GoLujoAPIManager().addressDelete(address) { stringResponse, error in
                self.hideNetworkActivity()
                guard error == nil else {
                    let description = error?.localizedDescription ?? "Address can not be deleted."
                    AlertService.showAlert(style: .actionSheet, title: nil, message: description)
                    return
                }
//                // Note that indexPath is wrapped in an array:  [indexPath]
                self.addresses.remove(at: index)
                self.tblView.reloadData()
                self.deleteIndexPath = nil
//                self.getAddresses(showActivity: false)
            }
        }
    }
    
    func handleCancelChannel(alertAction: UIAlertAction! ) -> Void {
        deleteIndexPath = nil       //re setting the index
    }
    

}
