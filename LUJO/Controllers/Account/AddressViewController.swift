//
//  addressViewController.swift
//  LUJO
//
//  Created by Zahoor Gorsi on 22/06/2022.
//  Copyright © 2022 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import FirebaseCrashlytics

class AddressViewController: UIViewController {
    
    //MARK: - 🎲 - Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "AddressViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate() -> AddressViewController {
        let viewController = UIStoryboard.accountNEW.instantiate(identifier) as! AddressViewController
        return viewController
    }
    
    //MARK:- Globals
    @IBOutlet var countryContainer: UIView!
    @IBOutlet var cityContainer: UIView!
    @IBOutlet var lblCountry: UILabel!
    @IBOutlet var lblCity: UILabel!
    @IBOutlet var txtAddress: LujoTextField!
    @IBOutlet var txtApartmentSuit: LujoTextField!
    @IBOutlet var txtPostZipCode: LujoTextField!
    @IBOutlet weak var viewHome: UIView!
    @IBOutlet weak var viewOffice: UIView!
    @IBOutlet weak var viewOther: UIView!
    @IBOutlet weak var viewSetAsDefault: UIView!
    @IBOutlet weak var imgIsHome: UIImageView!
    @IBOutlet weak var imgIsOffice: UIImageView!
    @IBOutlet weak var imgIsOther: UIImageView!
    @IBOutlet weak var imgIsSetAsDefault: UIImageView!
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    private var selectedCountry:Taxonomy?{
        didSet{
            self.lblCountry.text = selectedCountry?.name
        }
    }
    private var selectedCity:Taxonomy?{
        didSet{
            self.lblCity.text = selectedCity?.name
        }
    }
    private var isHome:Bool = true{
        didSet{
            if isHome{
                self.imgIsHome.image = UIImage(named: "address_check")
            }else{
                self.imgIsHome.image = UIImage(named: "address_uncheck")
            }
        }
    }
    private var isOffice:Bool = false{
        didSet{
            if isOffice{
                self.imgIsOffice.image = UIImage(named: "address_check")
            }else{
                self.imgIsOffice.image = UIImage(named: "address_uncheck")
            }
        }
    }
    private var isOther:Bool = false{
        didSet{
            if isOther{
                self.imgIsOther.image = UIImage(named: "address_check")
            }else{
                self.imgIsOther.image = UIImage(named: "address_uncheck")
            }
        }
    }
    private var isSetAsDefault:Bool = true{
        didSet{
            if isSetAsDefault{
                self.imgIsSetAsDefault.image = UIImage(named: "address_check")
            }else{
                self.imgIsSetAsDefault.image = UIImage(named: "address_uncheck")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Address"
        countryContainer.layer.borderColor = UIColor.inputBorderNoFocus.cgColor
        cityContainer.layer.borderColor = UIColor.inputBorderNoFocus.cgColor
        //setting tapp gesture on home, office, other and set as default
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.tappedOnView (_:)))
        self.viewHome.addGestureRecognizer(gesture)
        let gestureOffice = UITapGestureRecognizer(target: self, action:  #selector (self.tappedOnView (_:)))
        self.viewOffice.addGestureRecognizer(gestureOffice)
        let gestureOther = UITapGestureRecognizer(target: self, action:  #selector (self.tappedOnView (_:)))
        self.viewOther.addGestureRecognizer(gestureOther)
        let gestureSetAsDefault = UITapGestureRecognizer(target: self, action:  #selector (self.tappedOnView (_:)))
        self.viewSetAsDefault.addGestureRecognizer(gestureSetAsDefault)
        //setting textfields as a delegate to self, to limit max char entered
        self.txtAddress.delegate = self
        self.txtApartmentSuit.delegate = self
        self.txtPostZipCode.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func tappedOnCountry(_ sender: Any) {
        showCountries()
    }
    
    @IBAction func tappedOnCity(_ sender: Any) {
        showCities()
    }
    
    @objc func tappedOnView(_ sender:UITapGestureRecognizer){
        if let tag = sender.view?.tag{
            if tag == 0{
                self.isHome = !self.isHome
                self.isOffice = !self.isHome
                self.isOther = !self.isHome
            }else if tag == 1{
                self.isOffice = !self.isOffice
                self.isHome = !self.isOffice
                self.isOther = !self.isOffice
            }else if tag == 2{
                self.isOther = !self.isOther
                self.isHome = !self.isOther
                self.isOffice = !self.isOther
            }else if tag == 3{
                self.isSetAsDefault = !self.isSetAsDefault
            }
        }
    }
    
    @IBAction func updateAddress(_ sender: Any) {
        guard
            let country = selectedCountry,
            let city = selectedCity,
            let address = txtAddress.text,
            let apartment = txtApartmentSuit.text,
            let postZip = txtPostZipCode.text
            else {
                let error = LoginError.errorLogin(description: "All fields are mandatory")
                showError(error)
                return
        }
        
        guard !address.isEmpty, !apartment.isEmpty, !postZip.isEmpty else {
            let error = LoginError.errorLogin(description: "All fields are mandatory")
            showError(error)
            return
        }
        
        var address_type:String = "Home"   //by default is home
        if isOffice{
            address_type = "Office"
        }else if isOther{
            address_type = "Other"
        }
        
        let item = Address("", country, city,address, apartment, postZip, address_type, isSetAsDefault)
        showNetworkActivity()
        GoLujoAPIManager().addressAdd(item) { response, error in
            self.hideNetworkActivity()
            guard error == nil else {
                Crashlytics.crashlytics().record(error: error!)
                let description = error?.localizedDescription ?? "Address could not be added."
                let error = BackendError.parsing(reason: description)
                self.showError(error)
                return
            }
            //pop in case of success, and on previous UI latest data would be shown
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func updateProfile(for user: LujoUser) {
        showNetworkActivity()
        updateProfile(for: user) { error in
            self.hideNetworkActivity()
            
            if let error = error {
                self.showError(error)
            } else {
                
                LujoSetup().updateDefaults {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    func updateProfile(for user: LujoUser, completion: @escaping (Error?) -> Void) {
        GoLujoAPIManager().update(user: user) { error in
            completion(error)
        }
    }
    
    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Profile Error", error: error)
    }
    
    func showNetworkActivity() {
        naHUD.show(in: view)
    }
    
    func hideNetworkActivity() {
        naHUD.dismiss()
    }
    
    func showCountries(){
        let viewController = CityCountrySelectionViewController.instantiate(.country, nil)
        viewController.delegate = self
        self.navigationController?.present(viewController, animated: true)
    }
    
    func showCities(){
        let viewController = CityCountrySelectionViewController.instantiate(.city, selectedCountry)
        viewController.delegate = self
        self.navigationController?.present(viewController, animated: true)
    }
}

extension AddressViewController: CityCountrySelectionDelegate {
    func didSelect(_ item: Taxonomy, _ selectionType:SelectionType, at view: CityCountrySelectionViewController) {
        if (selectionType == .country){
            selectedCountry = item
        }else if (selectionType == .city){
            selectedCity = item
        }
    }
}

extension AddressViewController: UITextFieldDelegate{  // Set delegate to class
    //maximum 50 character are allowed in the text
    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                           replacementString string: String) -> Bool
    {
        let maxLength = 50
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =  currentString.replacingCharacters(in: range, with: string) as NSString

        return newString.length <= maxLength
    }
}
