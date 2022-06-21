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
    //which screen to show for current user's membership type. e.g. for "none" membership we will show screen of "dining" and "all", for "dining" membership we will show "dining" and "all" screen, for all membershiptype we will show "all" screen
//    private var screenForCurrentMembershipType: MembershipScreenType = .buyMembership
//    private var membershipType: MembershipType! {
//        didSet {
//            selectedMembership = PreloadDataManager.Memberships.memberships.first(where: { $0.target == (membershipType == .all ? "all" : "dining")})
//        }
//    }

//    private var currentMembership: Membership?
//    private var selectedMembership: Membership?
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureViewPersonalDetails = UITapGestureRecognizer(target: self, action:  #selector (self.viewPersonalDetailsTapped (_:)))
        self.viewPersonalDetails.addGestureRecognizer(gestureViewPersonalDetails)
        let gestureViewCreditDebitCards = UITapGestureRecognizer(target: self, action:  #selector (self.viewCreditDebitCardsTapped (_:)))
        self.viewCreditDebit.addGestureRecognizer(gestureViewCreditDebitCards)
        let gestureViewAddressBook = UITapGestureRecognizer(target: self, action:  #selector (self.viewAddressBookTapped (_:)))
        self.viewAddressBook.addGestureRecognizer(gestureViewAddressBook)
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
        // Update name on the card
        userNameAllLabel.text = userFullname
        userNameDiningLabel.text = userFullname
        
        //creating gestures here but adding laters, in if else statements
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right

        
        let currentMembership = LujoSetup().getLujoUser()?.membershipPlan
        let membershipPlan = user.membershipPlan?.target
//        let membershipPlan = "none"   //test case for none
//        let membershipPlan = "dining"   //test case for dining
//        let membershipPlan = "all"   //test case for all
        if membershipPlan != "dining" && membershipPlan != "all" {    //user has no membership plan
            title = "Purchase membership"
            //hiding first and second labels
            self.lblDiningFirstMessage.isHidden = true
            self.lblDiningSecondMessage.isHidden = true
            self.lblAllFirstMessage.isHidden = true
            self.lblAllSecondMessage.isHidden = true
            //Updating the content of third labels
            self.lblDiningThirdMessage.text = "Purchase dining membership at"
            self.lblAllThirdMessage.text = "Purchase full membership at"
            //adding gestures, when both dining and all cards are visible
            cardsContainerView.addGestureRecognizer(swipeLeft)
            cardsContainerView.addGestureRecognizer(swipeRight)
            

        } else if membershipPlan == "dining" {  //user has dining plan hence upgrade able
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
            //adding gestures, when both dining and all cards are visible
            cardsContainerView.addGestureRecognizer(swipeLeft)
            cardsContainerView.addGestureRecognizer(swipeRight)
        } else {
            title = "Membership overview"
            
            diningContainerView.isHidden = currentMembership?.target == "all"
//            allAccessContainerView.isHidden = currentMembership?.target == "dining"
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
        //updatig dining and full membership price
        if let diningMembership = PreloadDataManager.Memberships.memberships.first(where: { $0.target == "dining"}){
            self.lblDiningFourthMessage.text = "$" + String(diningMembership.price)
        }
        if let fullMembership = PreloadDataManager.Memberships.memberships.first(where: { $0.target == "all"}){
            self.lblAllFourthMessage.text = "$" + String(fullMembership.price)
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

    @IBAction func btnPurchaseTapped(_ sender: Any) {
        let userFullname = "\(user.firstName) \(user.lastName)"
        let hasMembership = user.membershipPlan ?? nil != nil
        let viewController = MembershipViewControllerNEW.instantiate(userFullname: userFullname, screenType: hasMembership ? .viewMembership : .buyMembership, paymentType: LujoSetup().getLujoUser()?.membershipPlan?.target == "dining" ? .dining : .all)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func viewPersonalDetailsTapped(_ sender:UITapGestureRecognizer){
        let viewController = UserProfileViewController.instantiate(user: user)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func viewCreditDebitCardsTapped(_ sender:UITapGestureRecognizer){
        print("Allah")
    }
    
    @objc func viewAddressBookTapped(_ sender:UITapGestureRecognizer){
        print("Allah ho akbar")
    }
}

