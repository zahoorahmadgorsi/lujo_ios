//
//  MainTabBarController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/27/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import Intercom

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "MainTabBarController" }
    
    /// Init method that will init and return view controller.
    class func instantiate() -> MainTabBarController {
        return UIStoryboard.main.instantiate(identifier)
    }
    
    
    //MARK:- Globals

    
    //MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegate
        self.delegate = self
        
        // Change unselected color.
        self.tabBar.unselectedItemTintColor = UIColor.white
        self.tabBar.clipsToBounds = true
        
        // Preload view controllers.
        for viewController in viewControllers! {
            viewController.loadViewIfNeeded()
        }
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.barTintColor = UIColor(named: "Navigation Bar")
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.chatLog_onNewEvent()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(chatLog_onNewEvent),
                                               name: NSNotification.Name.IntercomUnreadConversationCountDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(openChatWindow),
                                               name: Notification.Name(rawValue: "openChatWindow"),
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK:- User Interaction
    
    
    //MARK:- Utilities
    
    @objc func chatLog_onNewEvent() {
        let count = Intercom.unreadConversationCount()
        self.tabBar.items?[2].badgeValue = count > 0 ? String(count) : nil
    }
    
    //MARK:- User Interaction
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is ChatViewController {
            openChatWindow()
            return false
        }
        return true
    }
    
    @objc func openChatWindow(){
        if LujoSetup().getLujoUser()?.membershipPlan != nil {
            Intercom.presentMessenger()
        } else {
            showInformationPopup(withTitle: "Information", message: "24/7 agent chat is only available to Lujo members. Please upgrade to enjoy full benefits of Lujo.")
        }
    }
    //MARK:- Utilities
}
