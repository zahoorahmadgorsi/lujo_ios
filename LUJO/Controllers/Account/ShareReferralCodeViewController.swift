//
//  ShareReferralCodeViewController.swift
//  LUJO
//
//  Created by iMac on 25/04/2022.
//  Copyright © 2022 Baroque Access. All rights reserved.
//

import Foundation
import UIKit

class ShareReferralCodeViewController: UIViewController {
    class var identifier: String { return "ShareReferralCodeViewController" }
    
    @IBOutlet weak var lblReferralCode: UILabel!
    @IBOutlet weak var lblShareCodeFor: UILabel!
    
    var referralCode:String?
    var discountTitle:String?
    
    class func instantiate(_ referralCode: String, _ discountTitle:String) -> ShareReferralCodeViewController {
        let viewController = UIStoryboard.accountNEW.instantiate(identifier) as! ShareReferralCodeViewController
        viewController.referralCode = referralCode
        viewController.discountTitle = discountTitle
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let code = referralCode{
            self.lblReferralCode.text = code
        }
        if let title = discountTitle{
            self.lblShareCodeFor.text = "You can share above code to grant" + " " + title
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Referral Code"
        activateKeyboardManager()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.title = ""
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    @IBAction func btnShareTapped(_ sender: Any) {
        if let code = referralCode{
            Utility.inviteFriend(code)
        }
    }
}
