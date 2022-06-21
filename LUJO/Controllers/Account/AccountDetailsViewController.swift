//
//  AccountDetailsViewController.swift
//  LUJO
//
//  Created by Zahoor Gorsi on 21/06/2022.
//  Copyright © 2022 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import Foundation
import FirebaseCrashlytics

class AccountDetailsViewController: UIViewController {
    
    //MARK: - 🎲 - Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "AccountDetailsViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(user: LujoUser) -> AccountDetailsViewController {
        let viewController = UIStoryboard.accountNEW.instantiate(identifier) as! AccountDetailsViewController
        viewController.user = user
        viewController.userFullname = user.firstName + " " + user.lastName
        viewController.paymentType = .dining//user.membershipPlan?.target == "dining" ? .dining : .all
        let hasMembership = user.membershipPlan ?? nil != nil
        if hasMembership{   //if user has some membership, if dining then give option to upgrade else view
            viewController.screenType = (viewController.paymentType == .dining ? .upgradeMembership : .viewMembership)
        }else{
            viewController.screenType = .buyMembership  //no option to upgrade but buy
        }
        
        return viewController
    }
    
    //MARK:- Globals
    private(set) var user: LujoUser!
    @IBOutlet weak var cardsContainerView: UIView!
    @IBOutlet weak var allAccessContainerView: UIStackView!
    @IBOutlet weak var diningContainerView: UIStackView!
    @IBOutlet weak var userNameAllLabel: UILabel!
    @IBOutlet weak var userNameDiningLabel: UILabel!
    @IBOutlet var diningAccessCardCenter: NSLayoutConstraint!
    
    @IBOutlet weak var lblDiningFirstMessage: UILabel!
    @IBOutlet weak var lblDiningSecondMessage: UILabel!
    @IBOutlet weak var lblDiningThirdMessage: UILabel!
    @IBOutlet weak var lblDiningFourthMessage: UILabel!

    @IBOutlet weak var lblAllFirstMessage: UILabel!
    @IBOutlet weak var lblAllSecondMessage: UILabel!
    @IBOutlet weak var lblAllThirdMessage: UILabel!
    @IBOutlet weak var lblAllFourthMessage: UILabel!

    @IBOutlet weak var btnPurchaseDining: ActionButton!
    @IBOutlet weak var btnPurchaseAll: ActionButton!
    
    @IBOutlet weak var viewPersonalDetails: UIView!
    @IBOutlet weak var viewCreditDebit: UIView!
    @IBOutlet weak var viewAddressBook: UIView!
    
    
    private(set) var userFullname: String = ""
    private var screenType: MembershipScreenType = .buyMembership
    private var paymentType: MembershipType! {
        didSet {
            selectedMembership = PreloadDataManager.Memberships.memberships.first(where: { $0.target == (paymentType == .all ? "all" : "dining")})
        }
    }

    private var currentMembership: Membership?
    private var selectedMembership: Membership?
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
//        if screenType == .viewMembership {
//            self.navigationController?.pushViewController(AccountDetailsViewController.instantiate(userFullname: userFullname, screenType: .upgradeMembership, paymentType: .all), animated: true)
//        } else {
//            if price > 0{
//                let viewController = PurchaseViewController.instantiate(amount: Double(price), screenType: .membership)
//                viewController.paymentDelegate = self
//                self.present(viewController, animated: true, completion: nil)
//            }else{
//                guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty, let membershipPlan = selectedMembership else {
//                    LoginError.errorLogin(description: "User does not exist or is not verified or there is no valid membeship plan")
//                    return
//                }
//                showNetworkActivity()
//                confirmMembershipPayment(membershipPlan.id,nil,Double(price),hasValidCode ? referralTextField.text! : nil){ error in
//                    self.hideNetworkActivity()
//                    if error == nil{
//                        self.navigationController?.popViewController(animated: true)
//                    }else{
//                        print(error?.localizedDescription as Any)
//                    }
//                }
//            }
//        }
    }
    
    @objc private func handleGesture(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            if !diningAccessCardCenter.isActive {
                diningAccessCardCenter.isActive = true
                
                UIView.animate(withDuration: 0.25) {
                    self.view.updateConstraintsIfNeeded()
                    self.view.layoutIfNeeded()
                }
            }
        }
        else if gesture.direction == .left {
            if diningAccessCardCenter.isActive {
                diningAccessCardCenter.isActive = false

                UIView.animate(withDuration: 0.25) {
                    self.view.updateConstraintsIfNeeded()
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    private func updateUI() {
        //updatig dining and full membership price
        if let diningMembership = PreloadDataManager.Memberships.memberships.first(where: { $0.target == "dining"}){
            self.lblDiningFourthMessage.text = "$" + String(diningMembership.price)
        }
        if let fullMembership = PreloadDataManager.Memberships.memberships.first(where: { $0.target == "all"}){
            self.lblAllFourthMessage.text = "$" + String(fullMembership.price)
        }
        
        currentMembership = LujoSetup().getLujoUser()?.membershipPlan
        selectedMembership = PreloadDataManager.Memberships.memberships.first(where: { $0.target == (paymentType == .all ? "all" : "dining")})

        
        if screenType == .buyMembership {
            title = "Purchase membership"
            //hiding first and second labels
            self.lblDiningFirstMessage.isHidden = true
            self.lblDiningSecondMessage.isHidden = true
            self.lblAllFirstMessage.isHidden = true
            self.lblAllSecondMessage.isHidden = true
            //Updating the content of third labels
            self.lblDiningThirdMessage.text = "Purchase dining membership at"
            self.lblAllThirdMessage.text = "Purchase full membership at"

            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
            swipeLeft.direction = .left
            
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
            swipeRight.direction = .right
            
            cardsContainerView.addGestureRecognizer(swipeLeft)
            cardsContainerView.addGestureRecognizer(swipeRight)

        } else if screenType == .upgradeMembership {
            title = "Membership upgrade"

            //hiding first and second message of all access, but not related to dining
            self.lblAllFirstMessage.isHidden = true
            self.lblAllSecondMessage.isHidden = true
            if let dateTime = currentMembership?.expiration {
                let date = Date(timeIntervalSince1970: TimeInterval(dateTime))
                //updating second label's message for both dining only
                self.lblDiningSecondMessage.text = date.stripTime().whatsAppTimeFormat()
            }
            
            //Updating the content of third label of all accesss
            self.lblAllThirdMessage.text = "Purchase full membership at"
            //price has already been updated at the top of this method
            //since user already has dining so upgrading button title to upgrdae to full access
//            self.btnPurchaseDining.setTitle("Upgrade to all access", for: .normal)
            self.btnPurchaseDining.isHidden = true //hiding this button as user already has purchased dining
            //adding swiping gestures
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
            swipeLeft.direction = .left
            
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
            swipeRight.direction = .right
            
            cardsContainerView.addGestureRecognizer(swipeLeft)
            cardsContainerView.addGestureRecognizer(swipeRight)
        } else {
            title = "Membership overview"
            
            diningContainerView.isHidden = currentMembership?.target == "all"
            allAccessContainerView.isHidden = currentMembership?.target == "dining"
            //brining relevant card in the centre
            if diningContainerView.isHidden{//if dining is hidden then disable its constraint, which will automatically enable lower priority constraint allAccessCardCentre
                diningAccessCardCenter.isActive = false
                self.btnPurchaseAll.isHidden = true //becuase user is already having all access
            }
            //updating first label's message for both dining and all access, at one time either dining or all access one label would be hidden
            self.lblDiningFirstMessage.text = "Membership will automatically renew on"
            self.lblAllFirstMessage.text = "Membership will automatically renew on"

            if let dateTime = currentMembership?.expiration {
                let date = Date(timeIntervalSince1970: TimeInterval(dateTime))
                //updating second label's message for both dining and all access, at one time either dining or all access one label would be hidden
                self.lblDiningSecondMessage.text = date.stripTime().whatsAppTimeFormat()
                self.lblAllSecondMessage.text = date.stripTime().whatsAppTimeFormat()
            }
            self.lblDiningThirdMessage.text = "for another one year at a cost of"
            self.lblAllThirdMessage.text = "for another one year at a cost of"
        }
        
        // Update UI.
        userNameAllLabel.text = userFullname
        userNameDiningLabel.text = userFullname
//        referralTextField?.font = UIFont.systemFont(ofSize: 15, weight: .light)
    }
    
    private func formatPrice(amount: Int) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.usesSignificantDigits = true
        
        return formatter.string(for: amount)
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

extension AccountDetailsViewController: PurchasePaymentDelegate {

    func paymentCompleted() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func paymentFished(with result: PaymentResult, at session: PaymentSession?, completion: @escaping (Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty, let membershipPlan = selectedMembership else {
            return completion(LoginError.errorLogin(description: "User does not exist or is not verified or there is no valid membeship plan"))
        }
        
//        PaymentAPIManagerNEW.shared.confirmMembershipPayment(membershipPlan.id, result.reference, result.amount, hasValidCode ? referralTextField.text! : nil) { membership, error in
//
//            if let membership = membership {
//                let user = LujoSetup().getLujoUser()
//                user?.membershipPlan = membership
//                LujoSetup().store(userInfo: user!)
//            }
//
//            completion(error)
//        }
    }
}

