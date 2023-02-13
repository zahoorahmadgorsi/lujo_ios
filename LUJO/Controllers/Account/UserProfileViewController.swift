//
//  UserProfileViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/30/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import DropDown
import HCaptcha
import WebKit

class UserProfileViewController: UIViewController {
    
    //MARK: - 🎲 - Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "UserProfileViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(user: LujoUser) -> UserProfileViewController {
        let viewController = UIStoryboard.accountNEW.instantiate(identifier) as! UserProfileViewController
        viewController.user = user
//        viewController.updatedUser = user
        return viewController
    }
    
    //MARK:- Globals
    
    private(set) var user: LujoUser!
//    private(set) var updatedUser: LujoUser? //user having ONLY updated email/phone
    
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
    let dropDown = DropDown()
    
    let hcaptcha = try? HCaptcha(
        apiKey: Constants.hCaptchaKey,
        baseURL: URL(string: Constants.hCaptchaURL)!
    )
    var captchaWebView: WKWebView?
    
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
        
        setupNavigationBar()
        
        //configuring webview for captcha
        hcaptcha?.configureWebView { [weak self] webview in
            webview.frame = self?.view.bounds ?? CGRect.zero
            
            // could use this option if using an enterprise passive sitekey:
            // webview.isHidden = true
            // seems to prevent flickering on latest iOS 15.2
            webview.isOpaque = false
            webview.backgroundColor = UIColor.clear
            webview.scrollView.backgroundColor = UIColor.clear
            
            self?.captchaWebView = webview
        }
        hcaptcha?.onEvent { (event, data) in
            if event == .open {
                print("captcha open")
            }else if event == .close{
                print(" captcha closed")
                self.captchaWebView?.removeFromSuperview()  //if we wont remove then screen will become irresponsive
            }else if event == .error {
                let error = data as? HCaptchaError
                print("captcha onEvent error: \(String(describing: error))")
                self.captchaWebView?.removeFromSuperview()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func setupNavigationBar() {
        // Create right bar buttons
        let imgMenuVertical    = UIImage(named: "menu_vertical")!
        let btnSearch   = UIBarButtonItem(image: imgMenuVertical,  style: .plain, target: self, action: #selector(menu_onClick(_:)))
        navigationItem.rightBarButtonItems = [btnSearch]
        
        
        // The view to which the drop down will appear on
        dropDown.anchorView = btnSearch // UIView or UIBarButtonItem

        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = ["Delete Account"]
        //background and text color
        dropDown.textColor = .white
        dropDown.backgroundColor = .blackBackgorund
        
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
          print("Selected item: \(item) at index: \(index)")
            if index == 0{
                deleteAccount()
            }
        }
    }
    
    @objc func menu_onClick(_ sender: UIBarButtonItem) {
        // Will set a custom width instead of the anchor view width
        dropDown.width = 125
        
        dropDown.dismissMode = .onTap
        dropDown.direction = .any
        // Top of drop down will be below the anchorView
        dropDown.bottomOffset = CGPoint(x: -100, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.show()

    }
    
    @objc func deleteAccount() {
        showCardAlertWith(title: "Delete Account", body: "Are you sure you want to delete your account?", buttonTitle: "Yes", cancelButtonTitle: "No") {
            guard let currentUser = LujoSetup().getLujoUser() else {
                let error = LoginError.errorLogin(description: "No user exist")
                self.showError(error)
                return
            }
            guard let currentUserToken = LujoSetup().getCurrentUser()?.token else {
                let error = LoginError.errorLogin(description: "No user is logged in.")
                self.showError(error)
                return
            }
            self.showNetworkActivity()
            GoLujoAPIManager().deleteAccount() { unSubscribeResponse, error in
//            GoLujoAPIManager().unSubscribe(currentUserToken,"zahoor@mgail.com") { unSubscribeResponse, error in
                self.hideNetworkActivity()
                
                if let error = error {
                    self.showError(error)
                }else{
                    self.logoutUser()
                }
            }
        }
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
            guard email.lowercased() == emailConfirmationTF.text?.lowercased() else {
                let error = LoginError.errorLogin(description: "Email confirmation does not match")
                showError(error)
                return
            }
        }
        
        
//        user.firstName = firstName
//        user.lastName = lastName
//        user.email = email
//        user.phoneNumber = PhoneNumber(countryCode:  phonePrefix.phonePrefix, number: phoneNumber)
        //if new number's is not changed i.e. both prefix and number
        var newNumber = PhoneNumber(countryCode:  phonePrefix.phonePrefix, number: phoneNumber)
        if user.phoneNumber.readableNumber == newNumber.readableNumber {
            newNumber = PhoneNumber(countryCode:  "", number: "")
            let updatedUser: LujoUser = LujoUser(firstName: firstName,
                                                 lastName: lastName,
                                                 email: user.email == email ? "" : email,
                                                 phoneNumber: PhoneNumber(countryCode: newNumber.countryCode,
                                                                          number: newNumber.number))
            
            updateProfile(for: updatedUser)
        }else{
            validateCaptchaThenUpdate(firstName, lastName, user.email == email ? "" : email, newNumber)
        }

    }
    
    func validateCaptchaThenUpdate(_ firstName:String,_ lastName:String,_ email:String,_ newNumber:PhoneNumber) {
        hcaptcha?.validate(on: view) { [weak self] (result: HCaptchaResult) in
//            print(try? result.dematerialize() as Any)
            self?.captchaWebView?.removeFromSuperview()
            let _captchaToken = try? result.dematerialize()
            //After successful validation signup the user
            let updatedUser: LujoUser = LujoUser(firstName: firstName,
                                                 lastName: lastName,
                                                 email: email,
                                                 phoneNumber: PhoneNumber(countryCode: newNumber.countryCode,
                                                                          number: newNumber.number),
                                                 captchaToken: _captchaToken ?? "")
            
            self?.updateProfile(for: updatedUser)
        }
    }
    
    func updateProfile(for _user: LujoUser) {
        showNetworkActivity()
        updateProfile(for: _user) { error in
            self.hideNetworkActivity()
            let _emailVerificationTitle = "Please verify your email"
            let _emailVerificationText = "Your email address will only be updated if you will tap on the verification link which we have sent to '\(_user.email)'."
            if let error = error {
                self.showError(error)
            } else {
                //email and phone both has been updated
                if (!_user.email.isEmpty && (self.user.email != _user.email)) &&
                    (!_user.phoneNumber.readableNumber.isEmpty && ( self.user.phoneNumber.readableNumber != _user.phoneNumber.readableNumber)){
                    self.showInformationPopup(withTitle: _emailVerificationTitle, message: _emailVerificationText, btnTitle: "Ok" , btnTapHandler: { () in
                        LujoSetup().updateDefaults {
                            DispatchQueue.main.async {
                                print("navigate to the OTP screen")
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    })
                }
                if !_user.email.isEmpty && ( self.user.email != _user.email){   //only email has been updated
                    self.showInformationPopup(withTitle: _emailVerificationTitle, message: _emailVerificationText, btnTitle: "Ok" , btnTapHandler: { () in
                        LujoSetup().updateDefaults {
                            DispatchQueue.main.async {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    })
                }else if !_user.phoneNumber.readableNumber.isEmpty && (self.user.phoneNumber.readableNumber != _user.phoneNumber.readableNumber){   //Only Phone has been updated
                    print("navigate to the OTP screen")
                    self.navigationController?.popViewController(animated: true)
                }else{
                    LujoSetup().updateDefaults {
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
                
            }
        }
    }
    
    func updateProfile(for _user: LujoUser, completion: @escaping (Error?) -> Void) {
        GoLujoAPIManager().update(user: _user) { error in
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

extension UserProfileViewController {
    
    func logoutUser() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //deleting every thing from user defaults
        let appDomain = Bundle.main.bundleIdentifier!
        //Calling this method is equivalent to initializing a user defaults object with init(suiteName:) passing domainName, and calling the removeObject(forKey:) method on each of its keys.
        UserDefaults.standard.removePersistentDomain(forName: appDomain)

        guard let userId = LujoSetup().getLujoUser()?.id else {
//            print("NO USER ID ERROR!!!")
            // Present login view controller using VIPER.
            appDelegate.windowRouter.navigate(from: "/", data: [:])
            return
        }
        
        showNetworkActivity()
        logoutUser { _ in
            self.hideNetworkActivity()
            appDelegate.removePushToken(userId: userId)
            // Present login view controller using VIPER.
            appDelegate.windowRouter.navigate(from: "/", data: [:])
        }
    }
    
    func logoutUser(completion: @escaping (Error?) -> Void) {
        LujoSetup().deleteCurrentUser()
        completion(nil)
    }
    
}
