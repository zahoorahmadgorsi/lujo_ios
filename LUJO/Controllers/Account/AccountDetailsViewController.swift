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

    @IBOutlet weak var lblAllFirstMessage: UILabel!
    @IBOutlet weak var lblAllSecondMessage: UILabel!

    @IBOutlet weak var btnPurchaseDining: ActionButton!
    @IBOutlet weak var btnPurchaseAll: ActionButton!
    
    @IBOutlet weak var viewPersonalDetails: UIView!
    @IBOutlet weak var viewCreditDebit: UIView!
    @IBOutlet weak var viewAddressBook: UIView!
    
    
    private(set) var userFullname: String = ""
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
//         membershipPlan = "none"   //test case for none
//         membershipPlan = "dining"   //test case for dining
//         membershipPlan = "all"   //test case for all
        print(membershipPlan)
        if (membershipPlan == nil || (membershipPlan?.contains("dining") == false && membershipPlan?.contains("all") == false)){    //user has no membership plan
            title = "Purchase membership"
            self.lblDiningFirstMessage.text = "Purchase dining membership at"
            self.lblAllFirstMessage.text = "Purchase full membership at"
            
            print(PreloadDataManager.Memberships.memberships)
            //updatig dining and full membership price
            if let diningMembership = PreloadDataManager.Memberships.memberships.first(where: { $0.target.contains("dining") == true})
                ,let price = diningMembership.price?.amount{
                self.lblDiningSecondMessage.text = "$" + price
            }
            if let fullMembership = PreloadDataManager.Memberships.memberships.first(where: { $0.target.contains("all") == true})
                ,let price = fullMembership.price?.amount{
                self.lblAllSecondMessage.text = "$" + price
            }
            //adding gestures, when both dining and all cards are visible
            cardsContainerView.addGestureRecognizer(swipeLeft)
            cardsContainerView.addGestureRecognizer(swipeRight)
            

        } else if membershipPlan?.contains("dining") == true {  //user has dining plan hence upgrade able
            title = "Membership upgrade"

            if let dateTime = currentMembership?.expiration {
                let date = Date(timeIntervalSince1970: TimeInterval(dateTime))
                //updating second label's message for both dining only
                self.lblDiningSecondMessage.text = date.stripTime().whatsAppTimeFormat()
            }
            

            self.lblAllFirstMessage.text = "Purchase full membership at"
            if let fullMembership = PreloadDataManager.Memberships.memberships.first(where: { $0.target.contains("all") == true})
                ,let price = fullMembership.price?.amount{
                self.lblAllSecondMessage.text = "$" + price
            }

            //since user already has dining so upgrading button title to upgrdae to full access
//            self.btnPurchaseDining.setTitle("Upgrade to all access", for: .normal)
            self.btnPurchaseDining.isHidden = true //hiding this button as user already has purchased dining
            //adding gestures, when both dining and all cards are visible
            cardsContainerView.addGestureRecognizer(swipeLeft)
            cardsContainerView.addGestureRecognizer(swipeRight)
        } else {
            title = "Membership overview"
            
            diningContainerView.isHidden = currentMembership?.target.contains("all") == true
//            allAccessContainerView.isHidden = currentMembership?.target == "dining"
            //brining relevant card in the centre
            if diningContainerView.isHidden{//if dining is hidden then disable its constraint, which will automatically enable lower priority constraint allAccessCardCentre
                diningAccessCardCenter.isActive = false
                self.btnPurchaseAll.isHidden = true //becuase user is already having all access
            }
            //updating first label's message for both dining and all access, at one time either dining or all access one label would be hidden
            self.lblDiningFirstMessage.text = "Membership will expire on"
            self.lblAllFirstMessage.text = "Membership will expire on"

            if let dateTime = currentMembership?.expiration {
                let date = Date(timeIntervalSince1970: TimeInterval(dateTime))
                //updating second label's message for both dining and all access, at one time either dining or all access one label would be hidden
                self.lblDiningSecondMessage.text = date.stripTime().whatsAppTimeFormat()
                self.lblAllSecondMessage.text = date.stripTime().whatsAppTimeFormat()
            }
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
        let viewController = MembershipViewControllerNEW.instantiate(userFullname: userFullname
                                                                     , screenType: hasMembership ? .viewMembership : .buyMembership
                                                                     , paymentType: LujoSetup().getLujoUser()?.membershipPlan?.target.contains("dining") == true ? .dining : .all)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func viewPersonalDetailsTapped(_ sender:UITapGestureRecognizer){
        let viewController = UserProfileViewController.instantiate(user: user)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func viewCreditDebitCardsTapped(_ sender:UITapGestureRecognizer){
        let viewController = CardsViewController.instantiate()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func viewAddressBookTapped(_ sender:UITapGestureRecognizer){
        let viewController = AddressesViewController.instantiate()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

