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
//    var delegate: ProductDetailDelegate?
    
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
        let viewController = BasicChatViewController()
        viewController.product = Product(id: -1 , type: "restaurant" , name: "Restaurant Inquiry")
        let navController = UINavigationController(rootViewController:viewController)
        UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func btnEventTapped(_ sender: Any) {
        let viewController = BasicChatViewController()
        viewController.product = Product(id: -1 , type: "event" , name: "Event Inquiry")
        let navController = UINavigationController(rootViewController:viewController)
        UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func btnAviationTapped(_ sender: Any) {
        let viewController = BasicChatViewController()
        viewController.product = Product(id: -1 , type: "aviation" , name: "Aviation Inquiry")
        let navController = UINavigationController(rootViewController:viewController)
        UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func btnCharterAYachtTapped(_ sender: Any) {
        let viewController = BasicChatViewController()
        viewController.product = Product(id: -1 , type: "yacht" , name: "Yacht Inquiry")
        let navController = UINavigationController(rootViewController:viewController)
        UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func btnVillaTapped(_ sender: Any) {
        let viewController = BasicChatViewController()
        viewController.product = Product(id: -1 , type: "villa" , name: "Villa Inquiry")
        let navController = UINavigationController(rootViewController:viewController)
        UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func btnTravelTapped(_ sender: Any) {
        let viewController = BasicChatViewController()
        viewController.product = Product(id: -1 , type: "travel" , name: "Hotel Inquiry")
        let navController = UINavigationController(rootViewController:viewController)
        UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
    }
}
