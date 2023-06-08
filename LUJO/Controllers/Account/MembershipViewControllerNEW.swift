//
//  MembershipViewControllerNEW.swift
//  LUJO
//
//  Created by Iker Kristian on 8/30/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import Foundation
import FirebaseCrashlytics

enum MembershipScreenType {
    case buyMembership
    case upgradeMembership
    case viewMembership
}

enum MembershipType: Int {
    case none
    case all
    case dining
}

class MembershipViewControllerNEW: UIViewController {
    
    //MARK: - 🎲 - Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "MembershipViewControllerNEW" }
    
    /// Init method that will init and return view controller.
    class func instantiate(userFullname: String, screenType: MembershipScreenType, paymentType: MembershipType) -> MembershipViewControllerNEW {
        let viewController = UIStoryboard.accountNEW.instantiate(identifier) as! MembershipViewControllerNEW
        viewController.userFullname = userFullname
        viewController.screenType = screenType
        viewController.paymentType = paymentType
        return viewController
    }
    
    //MARK:- Globals
    
    @IBOutlet weak var cardsContainerView: UIView!
    @IBOutlet weak var allAccessContainerView: UIView!
    @IBOutlet weak var diningContainerView: UIView!
    @IBOutlet weak var userNameAllLabel: UILabel!
    @IBOutlet weak var userNameDiningLabel: UILabel!
    @IBOutlet var allAccessCardCenter: NSLayoutConstraint!
    @IBOutlet weak var pageNumLabel: UILabel!
    @IBOutlet weak var pagerContainerView: UIView!
    @IBOutlet weak var eventsContainerView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var luxaryContainerView: UIView!
    @IBOutlet weak var separator2View: UIView!
    @IBOutlet weak var hotelsContainerView: UIView!
    @IBOutlet weak var separator3View: UIView!
    @IBOutlet weak var paymentInfoView: UIView!
    @IBOutlet weak var oldPriceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceSeparatorView: UIView!
    @IBOutlet weak var referralTextField: LujoTextField!
    @IBOutlet weak var payButtonContainerView: UIView!
    @IBOutlet weak var payNowButton: ActionButton!
    
    
    private(set) var userFullname: String = ""
    private var screenType: MembershipScreenType = .buyMembership
    private var paymentType: MembershipType! {  //user has come to this screen to pay for "dining" or "all"
        didSet {
            selectedMembership = PreloadDataManager.Memberships.memberships.first(where: { $0.accessTo.contains(where: {$0.caseInsensitiveCompare((paymentType == .all ? "all" : "dining")) == .orderedSame}) == true})
        }
    }
    private var price: Int = 500
    private var currentDiscount: Int = 0
    private var hasValidCode: Bool = false {
        didSet {
            updatePrice()
        }
    }
    private var currentMembership: Membership?
    private var selectedMembership: Membership?
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.referralTextField.autocapitalizationType = .allCharacters
        if self.isModal{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "X", style: .plain, target: self, action: #selector(cancelTapped))
        }
        
    }
    
    private var navigationBarBackgroundColor: UIColor?
    private var navigationBarTintColor: UIColor?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        self.updateUI()
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func cancelTapped() {
        if self.isModal{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func payNowButton_onClick(_ sender: Any) {
        if screenType == .viewMembership {
            self.navigationController?.pushViewController(MembershipViewControllerNEW.instantiate(userFullname: userFullname, screenType: .upgradeMembership, paymentType: .all), animated: true)
        } else {
            if price > 0{
                let viewController = PurchaseViewController.instantiate(amount: Double(price), screenType: .membership)
                viewController.paymentDelegate = self
                self.present(viewController, animated: true, completion: nil)
            }else{
                guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty, let membershipPlan = selectedMembership else {
                    LoginError.errorLogin(description: "User does not exist or is not verified or there is no valid membeship plan")
                    return
                }
                showNetworkActivity()
                confirmMembershipPayment(membershipPlan.id,nil,Double(price),hasValidCode ? referralTextField.text! : nil){ error in
                    self.hideNetworkActivity()
                    if error == nil{
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        print(error?.localizedDescription as Any)
                    }
                }
            }
        }
    }
    
    @objc private func handleGesture(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            if !allAccessCardCenter.isActive {
                allAccessCardCenter.isActive = true
                eventsContainerView.isHidden = false
                separatorView.isHidden = false
                luxaryContainerView.isHidden = false
                separator2View.isHidden = false
                hotelsContainerView.isHidden = false
                separator3View.isHidden = false
                pageNumLabel.text = "1"
                paymentType = .all
                updatePrice()
                UIView.animate(withDuration: 0.25) {
                    self.view.updateConstraintsIfNeeded()
                    self.view.layoutIfNeeded()
                }
            }
        }
        else if gesture.direction == .left {
            if allAccessCardCenter.isActive {
                allAccessCardCenter.isActive = false
                eventsContainerView.isHidden = true
                separatorView.isHidden = true
                luxaryContainerView.isHidden = true
                separator2View.isHidden = true
                hotelsContainerView.isHidden = true
                separator3View.isHidden = true
                pageNumLabel.text = "2"
                paymentType = .dining
                updatePrice()
                UIView.animate(withDuration: 0.25) {
                    self.view.updateConstraintsIfNeeded()
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    private func updateUI() {
        currentMembership = LujoSetup().getLujoUser()?.membershipPlan
//        print(PreloadDataManager.Memberships.memberships)

        if let price = selectedMembership?.price?.amount{
            self.price = Int(price) ?? -1
        }

        //selected membership is initialized before loading this viewcontroller i.e instantiate
        print(currentMembership?.plan,selectedMembership?.plan)
        if screenType == .buyMembership {
            title = "Purchase membership"
            
            updatePrice()
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
            swipeLeft.direction = .left
            
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
            swipeRight.direction = .right
            
            cardsContainerView.addGestureRecognizer(swipeLeft)
            cardsContainerView.addGestureRecognizer(swipeRight)
            
            allAccessCardCenter.isActive = paymentType == .all
            eventsContainerView.isHidden = paymentType != .all
            separatorView.isHidden = paymentType != .all
            luxaryContainerView.isHidden = paymentType != .all
            separator2View.isHidden = paymentType != .all
            hotelsContainerView.isHidden = paymentType != .all
            separator3View.isHidden = paymentType != .all
            
            pageNumLabel.text = paymentType == .dining ? "2" : "1"
        } else if screenType == .upgradeMembership {
            title = "Membership upgrade"
            
            diningContainerView.isHidden = true
            pagerContainerView.isHidden = true
//            price = 500
            priceLabel.text = formatPrice(amount: price)
            oldPriceLabel.text = ""
            referralTextField.isHidden = true
            priceSeparatorView.isHidden = true
            payNowButton.setTitle("P U R C H A S E  P L A N", for: .normal)
        } else {
            title = "Membership overview"
            
            diningContainerView.isHidden = currentMembership?.accessTo.contains(where: {$0.caseInsensitiveCompare("all") == .orderedSame}) == true
            allAccessContainerView.isHidden = currentMembership?.accessTo.contains(where: {$0.caseInsensitiveCompare("dining") == .orderedSame}) == true
            allAccessCardCenter.isActive = currentMembership?.accessTo.contains(where: {$0.caseInsensitiveCompare("all") == .orderedSame}) == true
            pagerContainerView.isHidden = true
            eventsContainerView.isHidden = currentMembership?.accessTo.contains(where: {$0.caseInsensitiveCompare("dining") == .orderedSame}) == true
            separatorView.isHidden = currentMembership?.accessTo.contains(where: {$0.caseInsensitiveCompare("dining") == .orderedSame}) == true
            luxaryContainerView.isHidden = currentMembership?.accessTo.contains(where: {$0.caseInsensitiveCompare("dining") == .orderedSame}) == true
            separator2View.isHidden = currentMembership?.accessTo.contains(where: {$0.caseInsensitiveCompare("dining") == .orderedSame}) == true
            hotelsContainerView.isHidden = currentMembership?.accessTo.contains(where: {$0.caseInsensitiveCompare("dining") == .orderedSame}) == true
            separator3View.isHidden = currentMembership?.accessTo.contains(where: {$0.caseInsensitiveCompare("dining") == .orderedSame}) == true
            paymentInfoView?.removeFromSuperview()
            if currentMembership?.accessTo.contains(where: {$0.caseInsensitiveCompare("dining") == .orderedSame}) == true {
                payNowButton.setTitle("U P G R A D E  M E M B E R S H I P", for: .normal)
            } else {
                payButtonContainerView.removeFromSuperview()
            }
        }
        
        // Update UI.
        userNameAllLabel.text = userFullname
        userNameDiningLabel.text = userFullname
        referralTextField?.font = UIFont.systemFont(ofSize: 15, weight: .light)
    }
    
    private func formatPrice(amount: Int) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.usesSignificantDigits = true
        
        return formatter.string(for: amount)
    }
    
    private func updatePrice() {
        var oldPriceText = ""
        var selectedPrice = 0
        
        if let price = selectedMembership?.price?.amount{
            selectedPrice = Int(price) ?? -1
        }
//        let currentDiscount = selectedMembership?.discount ?? 0
        
        if hasValidCode {
            price = selectedPrice - selectedPrice * currentDiscount/100
            oldPriceText = "\(selectedPrice)"
        } else {
            price = selectedPrice
        }
        
        let attributeString =  NSMutableAttributedString(string: oldPriceText)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                     value: NSUnderlineStyle.single.rawValue,
                                     range: NSMakeRange(0, attributeString.length))
        self.oldPriceLabel.attributedText = attributeString
        
        priceLabel.text = formatPrice(amount: price)
        if price <= 0{
            payNowButton.setTitle("A V A I L   N O W", for: .normal)
        }else{
            payNowButton.setTitle("P A Y   N O W", for: .normal)
        }
    }
    
    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Error", error: error)
    }
    
    func showFeedback(_ message: String) {
        showInformationPopup(withTitle: "Information", message: message)
    }
    
    func showNetworkActivity() {
        naHUD.show(in: view)
    }
    
    func hideNetworkActivity() {
        naHUD.dismiss()
    }
    
    private func confirmMembershipPayment(_ membershipId: String,_ transactionId:String?, _ amount:Double?, _ code: String?, completion: @escaping (Error?) -> Void ){
        
        PaymentAPIManagerNEW.shared.confirmMembershipPayment(membershipId, transactionId, amount, code) { membership, error in
            if let membership = membership {
                let user = LujoSetup().getLujoUser()
                user?.membershipPlan = membership
                LujoSetup().store(userInfo: user!)
            }
            
            completion(error)
        }
    }
}

extension MembershipViewControllerNEW: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            if updatedText.count < 6 {
                self.hasValidCode = false
            } else if updatedText.count == 6 {
                textField.resignFirstResponder()
                textField.text = updatedText
                
                guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
                    self.showError(LoginError.errorLogin(description: "User does not exist or is not verified"))
                    return false
                }
                
                showNetworkActivity()
                if let membershipId = selectedMembership?.id{
                    PaymentAPIManagerNEW.shared.validateReferralCode(updatedText,membershipId) { referralValidation, error in
                        self.hideNetworkActivity()
                        guard error == nil  else {
                            Crashlytics.crashlytics().record(error: error!)
                            if error?._code == 403{
                                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                appDelegate.logoutUser()
                            }else{
                                BackendError.parsing(reason: "Referral code is not valid.")
                            }
                            return
                        }
                        
                        if referralValidation?.status == true {
                            self.currentDiscount = referralValidation?.discountPercentage ?? 0
                            self.hasValidCode = true
                        } else {
                            self.currentDiscount = 0
                            self.hasValidCode = false
                            self.showError(LoginError.errorLogin(description: "Referral code is not valid."))
                        }
                    }
                }
                
                return false
            } else if updatedText.count > 6 {
                return false
            }
        }
        
        return true
    }
}

extension MembershipViewControllerNEW: PurchasePaymentDelegate {

    func paymentCompleted() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func paymentFished(with result: PaymentResult, at session: PaymentSession?, completion: @escaping (Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty, let membershipPlan = selectedMembership else {
            return completion(LoginError.errorLogin(description: "User does not exist or is not verified or there is no valid membeship plan"))
        }
        
        PaymentAPIManagerNEW.shared.confirmMembershipPayment(membershipPlan.id, result.reference, result.amount, hasValidCode ? referralTextField.text! : nil) { membership, error in
            
            if let membership = membership {
                let user = LujoSetup().getLujoUser()
                user?.membershipPlan = membership
                LujoSetup().store(userInfo: user!)
            }
            
            completion(error)
        }
    }
}
