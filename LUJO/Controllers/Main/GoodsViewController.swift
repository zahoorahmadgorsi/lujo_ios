//
//  GoodsViewController.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 11/24/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD
import SwiftMessages

class GoodsViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "GoodsViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate() -> GoodsViewController {
        return UIStoryboard.customRequest.instantiate(identifier)
    }
    
    //MARK:- Globals
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var asGiftButton: UIButton!
    
    private let naHUD = JGProgressHUD(style: .dark)
    
    //MARK:- Life cicyle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: - User interaction
    
    @IBAction func cancelButton_onClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func asGiftButton_onClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func requestButton_onClick(_ sender: Any) {
        guard let description = descriptionTextView.text, !description.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"Please describe what you are looking for.")
            return
        }
        
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            showInformationPopup(withTitle: "Info", message:"User does not exist or is not verified.")
            return
        }
        
        let initialMessage = """
        Hi Concierge team,
        
        I am looking for \(description)\(asGiftButton.isSelected ? " to buy it as a gift" : ""), can you assist me?
        
        \(LujoSetup().getLujoUser()?.firstName ?? "User")
        """
        
        startChatWithInitialMessage(initialMessage)
        
        //showNetworkActivity()
        CustomRequestAPIManager.shared.goodsReqeust(desc: description, isGift: asGiftButton.isSelected, token: token) { error in
            DispatchQueue.main.async {
                //self.hideNetworkActivity()
                if let error = error {
                    print ("ERROR: \(error.localizedDescription)")
                    //self.showErrorPopup(withTitle: "Error", error:error)
                    return
                }
                
                print ("Success: custom request goods.")
                self.dismiss(animated: true, completion: nil)
                /*
                showCardAlertWith(title: "Info", body: "Your request is being processed. We will get back to you shortly. You can follow the status of your request in My bookings.", buttonTitle: "Ok", cancelButtonTitle: nil, buttonTapHandler: {
                    self.dismiss(animated: true, completion: nil)
                })
                */
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

extension GoodsViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        
        placeholderLabel.isHidden = numberOfChars > 0
        
        return numberOfChars < 301    // 301 Limit Value
    }
}
