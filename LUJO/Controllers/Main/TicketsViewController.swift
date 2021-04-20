//
//  TicketsViewController.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 11/22/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import SwiftMessages
import Mixpanel

class TicketsViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "TicketsViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate() -> TicketsViewController {
        return UIStoryboard.customRequest.instantiate(identifier)
    }
    
    //MARK:- Globals
    
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var numberLabel: UILabel!
    
    private var ticketsCount: Int = 0 {
        didSet {
            numberLabel.text = "\(ticketsCount)"
        }
    }
    private let naHUD = JGProgressHUD(style: .dark)
    
    //MARK:- Life cicyle

    override func viewDidLoad() {
        super.viewDidLoad()

        ticketsCount = 3
    }
    
    //MARK: - User interaction

    @IBAction func cancelButton_onClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func decreaseButton_onClick(_ sender: Any) {
        if ticketsCount > 1 {
            ticketsCount -= 1
        }
    }
    
    @IBAction func increaseButton_onClick(_ sender: Any) {
        ticketsCount += 1
    }
    
    @IBAction func requestButton_onClick(_ sender: Any) {
        guard let description = descriptionTextField.text, !description.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"Please enter what you are looking for.")
            return
        }
        
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"User does not exist or is not verified.")
            return
        }
        
        Mixpanel.mainInstance().track(event: "Tickets Custom Request",
                                      properties: ["Custom Request Description" : description])
        
        showNetworkActivity()
        CustomRequestAPIManager.shared.ticketsReqeust(desc: description, count: ticketsCount, token: token) { error in
            DispatchQueue.main.async {
                self.hideNetworkActivity()
                if let error = error {
                    self.showErrorPopup(withTitle: "Error", error:error)
                    return
                }
                
                showCardAlertWith(title: "Info", body: "Your request is being processed. We will get back to you shortly. You can follow the status of your request in My bookings.", buttonTitle: "Ok", cancelButtonTitle: nil, buttonTapHandler: {
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
    
    //MARK: - Logic
    
    func showNetworkActivity() {
        naHUD.show(in: view)
    }
    
    func hideNetworkActivity() {
        naHUD.dismiss()
    }
}
