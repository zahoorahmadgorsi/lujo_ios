//
//  ChatViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/29/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JGProgressHUD

class ChatViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "ChatViewController" }
    private let naHUD = JGProgressHUD(style: .dark)
    
    /// Init method that will init and return view controller.
    class func instantiate() -> ChatViewController {
        return UIStoryboard.main.instantiate(identifier)
    }
    

    
    //MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getChatsList(showActivity: true)
    }
    
    func getChatsList(showActivity: Bool) {
        if showActivity {
            self.showNetworkActivity()
        }
        getChats() {information, error in
            self.hideNetworkActivity()
            
            if let error = error {
                self.showError(error)
                return
            }
            
            if let informations = information {
                    self.update(informations)
            } else {
                let error = BackendError.parsing(reason: "Could not obtain chat list")
                self.showError(error)
            }
        }
    }
    
    func update(_ information: ChatList?) {
        guard information != nil else {
            return
        }
        print (information as Any)
//        wishListInformations = information
//        updateContent()
//
//            // -------------------------------------------------------------------------------------
//            // Refresh control and data caching.
//
//            // Stop refresh control animation and allow scroll to sieze back refresh control space by
//            // scrolling up.
//            refreshControl.endRefreshing()
//
//            // Store data for later use inside preload reference.
//            //PreloadDataManager.DiningScreen.scrollViewData = information
//            // -------------------------------------------------------------------------------------
    }
    
    func getChats(completion: @escaping (ChatList?, Error?) -> Void) {
        guard let currentUser = LujoSetup().getCurrentUser(), let token = currentUser.token, !token.isEmpty else {
            completion(nil, LoginError.errorLogin(description: "User does not exist or is not verified"))
            return
        }
        
        GoLujoAPIManager().getChats(token: token) { items, error in
            guard error == nil else {
                Crashlytics.sharedInstance().recordError(error!)
                let error = BackendError.parsing(reason: "Could not obtain the chat list")
                completion(nil, error)
                return
            }
            completion(items, error)
        }
    }
    
    func showError(_ error: Error , isInformation:Bool = false) {
        if (isInformation){
            showErrorPopup(withTitle: "Information", error: error)
        }else{
            showErrorPopup(withTitle: "Chat Error", error: error)
        }
        
    }
    
    func showNetworkActivity() {
        // Safe guard to that won't display both loaders at same time.
//        if !refreshControl.isRefreshing {
            naHUD.show(in: view)
//        }
    }
    
    func hideNetworkActivity() {
        // Safe guard that will call dismiss only if HUD is shown on screen.
        if naHUD.isVisible {
            naHUD.dismiss()
        }
    }
}
