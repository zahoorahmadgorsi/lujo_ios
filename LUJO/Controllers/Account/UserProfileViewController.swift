//
//  UserProfileViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/30/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD

class UserProfileViewController: UIViewController {
    
    //MARK: - 🎲 - Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "UserProfileViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(user: LujoUser) -> UserProfileViewController {
        let viewController = UIStoryboard.accountNEW.instantiate(identifier) as! UserProfileViewController
        viewController.user = user
        return viewController
    }
    
    //MARK:- Globals
    
    private(set) var user: LujoUser!
    
    @IBOutlet var countryCodeContainer: UIView!
    @IBOutlet var phoneNumberContainer: UIView!
    
    @IBOutlet var firstNameTF: LujoTextField!
    @IBOutlet var lastNameTF: LujoTextField!
    
    @IBOutlet var countryCodeLabel: UILabel!
    @IBOutlet var prefixLabel: UILabel!
    
    @IBOutlet var phoneNumberTF: UITextField!
    @IBOutlet var emailAddressTF: LujoTextField!
    @IBOutlet var emailConfirmationTF: LujoTextField!
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    private var phonePrefix: PhoneCountryCode!
    
    fileprivate func updatePrefixLabels() {
        countryCodeLabel.text = phonePrefix.alpha2Code
        prefixLabel.text = phonePrefix.phonePrefix
    }
    
    override func viewDidLoad() {
        navigationItem.title = "Edit Profile"
    
        firstNameTF.text = user.firstName
        lastNameTF.text = user.lastName
        phonePrefix = LujoSetup().getCode(for: user.phoneNumber.countryCode) ??
            PhoneCountryCode(id: 238, alpha2Code: "US", phonePrefix: "+1", nationality: "American", country: "United States of America", flag: "https://seeklogo.net/wp-content/uploads/2013/05/flag-of-serbia-vector-logo.png")
        
        phoneNumberTF.text = user.phoneNumber.number
        emailAddressTF.text = user.email
        
        updatePrefixLabels()
        
        countryCodeContainer.layer.borderColor = UIColor.inputBorderNoFocus.cgColor
        phoneNumberContainer.layer.borderColor = UIColor.inputBorderNoFocus.cgColor
        
//        naHUD.textLabel.text = "Updating ..."
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func countryCodeButton_onClick(_ sender: Any) {
        showCountryCodes()
    }
    
    @IBAction func updateUserProfile(_ sender: Any) {
        guard let firstName = firstNameTF.text,
            let lastName = lastNameTF.text,
            let phoneNumber = phoneNumberTF.text,
            let email = emailAddressTF.text
            else {
                let error = LoginError.errorLogin(description: "All fields are mandatory")
                showError(error)
                return
        }
        
        guard !firstName.isEmpty, !lastName.isEmpty, !phoneNumber.isEmpty, !email.isEmpty else {
            let error = LoginError.errorLogin(description: "All fields are mandatory")
            showError(error)
            return
        }
        
        guard phoneNumber.count > 5 else {
            let error = LoginError.errorLogin(description: "Phone number must have at least 6 digits.")
            showError(error)
            return
        }
        
        if email != user.email {
            guard email == emailConfirmationTF.text else {
                let error = LoginError.errorLogin(description: "Email confirmation does not match")
                showError(error)
                return
            }
        }
        
        user.firstName = firstName
        user.lastName = lastName
        user.email = email
        user.phoneNumber = PhoneNumber(countryCode: phonePrefix.phonePrefix, number: phoneNumber)
        
        updateProfile(for: user)
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
}

extension UserProfileViewController: CountrySelectionDelegate {
    private func showCountryCodes() {
        let stbrd = UIStoryboard(name: "Login", bundle: nil)
        // swiftlint:disable force_cast
        let codes = stbrd.instantiateViewController(withIdentifier: "CountrySelect") as! CountryCodeSelectionView
        codes.delegate = self
        present(codes, animated: true, completion: nil)
    }
    
    func didSelect(_ country: PhoneCountryCode, at view: CountryCodeSelectionView) {
        view.dismiss(animated: true, completion: nil)
        phonePrefix = country
        updatePrefixLabels()
    }
}
