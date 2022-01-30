//
//  MainTabBarController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/27/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import TwilioConversationsClient

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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(openChatWindow),
                                               name: Notification.Name(rawValue: "openChatWindow"),
                                               object: nil)

//        self.chatLog_onNewEvent() //it will not work here as it requires to login to twilio which takes some seconds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    //MARK:- User Interaction


    //MARK:- Utilities
    
@objc func showBadgeValue() {
    ConversationsManager.sharedConversationsManager.getTotalUnReadMessagesCount(completion: { (count) in
        print("Twilio: Total UnRead messages count:\(count)")
        self.tabBar.items?[2].badgeValue = count > 0 ? String(count) : nil
    })
}

    //MARK:- User Interaction


func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    if viewController.restorationIdentifier == "ChatListNavigationController" {
        if LujoSetup().getLujoUser()?.membershipPlan != nil {
            let viewController = ChatOptionsViewController.instantiate()
            self.present(viewController, animated: true, completion: nil)
        }else{
            openChatWindow()
        }
        return false
    }
    return true
}

    @objc func openChatWindow(){
        if LujoSetup().getLujoUser()?.membershipPlan != nil {
            //            Intercom.presentMessenger()
        } else {
            showInformationPopup()
        }
    }
}
