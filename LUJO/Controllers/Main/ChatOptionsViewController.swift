//
//  ChatOptionsViewController.swift
//  LUJO
//
//  Created by iMac on 08/09/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit

class ChatOptionsViewController: UIViewController {
    
    /// Class storyboard identifier.
    class var identifier: String { return "ChatOptionsViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate() -> ChatOptionsViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! ChatOptionsViewController
        return viewController
    }
    @IBOutlet weak var imgCross: UIImageView!
    @IBOutlet weak var innerContentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.innerContentView.addViewBorder(borderColor: UIColor.clear.cgColor, borderWidth: 0.0, borderCornerRadius: 18.0)
        //tap gesture on cross button
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imgCrossTapped))
        imgCross.isUserInteractionEnabled = true
        imgCross.addGestureRecognizer(tapGesture)

    }
    
    @objc func imgCrossTapped(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
    }
    
    
    @IBAction func btnFindATableTapped(_ sender: Any) {
        if ConversationsManager.sharedConversationsManager.getClient() != nil
        {
            let viewController = AdvanceChatViewController()
            viewController.product = Product(id: -1 , type: "restaurant" , name: "Restaurant Inquiry")
            let navController = UINavigationController(rootViewController:viewController)
            if #available(iOS 13.0, *) {
                let controller = navController.topViewController
                // Modal Dismiss iOS 13 onward
                //to call UIAdaptivePresentationControllerDelegate.presentationControllerDidDismiss at dismiss by pressing cross button
                controller?.presentationController?.delegate = self
            }
            //to call UIAdaptivePresentationControllerDelegate.presentationControllerDidDismiss at dismiss by dragging
            navController.presentationController?.delegate = self
            UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
        }else{
            let error = BackendError.parsing(reason: "Chat option is not available, please try again later")
            self.showError(error)
            print("Twilio: Not logged in")
        }
        
    }
    
    @IBAction func btnEventTapped(_ sender: Any) {
        if ConversationsManager.sharedConversationsManager.getClient() != nil
        {
            let viewController = AdvanceChatViewController()
            viewController.product = Product(id: -1 , type: "event" , name: "Event Inquiry")
            let navController = UINavigationController(rootViewController:viewController)
            if #available(iOS 13.0, *) {
                let controller = navController.topViewController
                // Modal Dismiss iOS 13 onward
                //to call UIAdaptivePresentationControllerDelegate.presentationControllerDidDismiss at dismiss by pressing cross button
                controller?.presentationController?.delegate = self
            }
            //to call UIAdaptivePresentationControllerDelegate.presentationControllerDidDismiss at dismiss by dragging
            navController.presentationController?.delegate = self
            UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
        }else{
            let error = BackendError.parsing(reason: "Chat option is not available, please try again later")
            self.showError(error)
            print("Twilio: Not logged in")
        }
        
    }
    
    @IBAction func btnAviationTapped(_ sender: Any) {
        if ConversationsManager.sharedConversationsManager.getClient() != nil
        {
            let viewController = AdvanceChatViewController()
            viewController.product = Product(id: -1 , type: "aviation" , name: "Aviation Inquiry")
            let navController = UINavigationController(rootViewController:viewController)
            if #available(iOS 13.0, *) {
                let controller = navController.topViewController
                // Modal Dismiss iOS 13 onward
                //to call UIAdaptivePresentationControllerDelegate.presentationControllerDidDismiss at dismiss by pressing cross button
                controller?.presentationController?.delegate = self
            }
            //to call UIAdaptivePresentationControllerDelegate.presentationControllerDidDismiss at dismiss by dragging
            navController.presentationController?.delegate = self
            UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
        }else{
            let error = BackendError.parsing(reason: "Chat option is not available, please try again later")
            self.showError(error)
            print("Twilio: Not logged in")
        }
        
    }
    
    @IBAction func btnCharterAYachtTapped(_ sender: Any) {
        if ConversationsManager.sharedConversationsManager.getClient() != nil
        {
            let viewController = AdvanceChatViewController()
            viewController.product = Product(id: -1 , type: "yacht" , name: "Yacht Inquiry")
            let navController = UINavigationController(rootViewController:viewController)
            if #available(iOS 13.0, *) {
                let controller = navController.topViewController
                // Modal Dismiss iOS 13 onward
                //to call UIAdaptivePresentationControllerDelegate.presentationControllerDidDismiss at dismiss by pressing cross button
                controller?.presentationController?.delegate = self
            }
            //to call UIAdaptivePresentationControllerDelegate.presentationControllerDidDismiss at dismiss by dragging
            navController.presentationController?.delegate = self
            UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
        }else{
            let error = BackendError.parsing(reason: "Chat option is not available, please try again later")
            self.showError(error)
            print("Twilio: Not logged in")
        }
        
    }
    
    @IBAction func btnVillaTapped(_ sender: Any) {
        if ConversationsManager.sharedConversationsManager.getClient() != nil
        {
            let viewController = AdvanceChatViewController()
            viewController.product = Product(id: -1 , type: "villa" , name: "Villa Inquiry")
            let navController = UINavigationController(rootViewController:viewController)
            if #available(iOS 13.0, *) {
                let controller = navController.topViewController
                // Modal Dismiss iOS 13 onward
                //to call UIAdaptivePresentationControllerDelegate.presentationControllerDidDismiss at dismiss by pressing cross button
                controller?.presentationController?.delegate = self
            }
            //to call UIAdaptivePresentationControllerDelegate.presentationControllerDidDismiss at dismiss by dragging
            navController.presentationController?.delegate = self
            UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
        }else{
            let error = BackendError.parsing(reason: "Chat option is not available, please try again later")
            self.showError(error)
            print("Twilio: Not logged in")
        }
        
    }
    
    @IBAction func btnTravelTapped(_ sender: Any) {
        if ConversationsManager.sharedConversationsManager.getClient() != nil
        {
            let viewController = AdvanceChatViewController()
            viewController.product = Product(id: -1 , type: "travel" , name: "Hotel Inquiry")
            let navController = UINavigationController(rootViewController:viewController)
            if #available(iOS 13.0, *) {
                let controller = navController.topViewController
                // Modal Dismiss iOS 13 onward
                //to call UIAdaptivePresentationControllerDelegate.presentationControllerDidDismiss at dismiss by pressing cross button
                controller?.presentationController?.delegate = self
            }
            //to call UIAdaptivePresentationControllerDelegate.presentationControllerDidDismiss at dismiss by dragging
            navController.presentationController?.delegate = self
            UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
        }else{
            let error = BackendError.parsing(reason: "Chat option is not available, please try again later")
            self.showError(error)
            print("Twilio: Not logged in")
        }
        
    }
    
    func showError(_ error: Error) {
        showErrorPopup(withTitle: "Chat Error", error: error)
    }
}

extension ChatOptionsViewController: UIAdaptivePresentationControllerDelegate {
    // Only called when the sheet is dismissed by DRAGGING as well as when tapped on cross button
    public func presentationControllerDidDismiss( _ presentationController: UIPresentationController) {
        if #available(iOS 13, *) {
            //Call viewWillAppear only in iOS 13
            //so that receivedNewMessage should stop calling on AdvanceChatViewController and start calling on homeViewcontroller
            
            if let tabbarController = self.presentingViewController as? MainTabBarController{
                if let navViewController = tabbarController.viewControllers?[0] as? UINavigationController {
                    if let viewController = navViewController.children.first as?  HomeViewController{
                        ConversationsManager.sharedConversationsManager.delegate = viewController
                    }
                }
            }
        }
    }
}
