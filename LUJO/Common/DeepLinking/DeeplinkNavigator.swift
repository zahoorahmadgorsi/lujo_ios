//
//  DeeplinkNavigator.swift
//  LUJO
//
//  Created by iMac on 19/08/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
// https://stasost.medium.com/ios-how-to-open-deep-links-notifications-and-shortcuts-253fb38e1696

import Foundation
import UIKit

class DeeplinkNavigator {
    
    static let shared = DeeplinkNavigator()
    private init() { }
    
    var alertController = UIAlertController()
    var viewController = ProductDetailsViewController()
    
    func proceedToDeeplink(_ type: DeeplinkType) {
        switch type {
//        case .activity:
//            displayAlert(title: "Activity")
//        case .messages(.root):
//            displayAlert(title: "Messages Root")
//        case .messages(.details(id: let id)):
//            displayAlert(title: "Messages Details \(id)")
//        case .newListing:
//            displayAlert(title: "New Listing")
        case .request(productType: let type, id: let id):
            print("Product Type: \(type) and ProductID: \(id)")
//            displayAlert(title: "Product Type: \(type) and ProductID: \(id)")
            
            if !id.isEmpty{
                let product = Product(id: id,type: type)
                viewController = ProductDetailsViewController.instantiate(product: product)
                viewController.modalPresentationStyle = .overFullScreen

                let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                if let tabBar = keyWindow?.rootViewController as? UITabBarController, let window = tabBar.selectedViewController as? UINavigationController {
                    if (window.presentedViewController != nil){
                        window.dismiss(animated: true, completion: nil)
                    }else{
                        window.popToRootViewController(animated: true)
                    }
                    window.present(viewController, animated: true)
                }
            }
        }
    }
    
    private func displayAlert(title: String) {
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okButton)
        alertController.title = title
        if let vc = UIApplication.shared.keyWindow?.rootViewController {
            if vc.presentedViewController != nil {
                alertController.dismiss(animated: false, completion: {
                    vc.present(self.alertController, animated: true, completion: nil)
                })
            } else {
                vc.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

    
