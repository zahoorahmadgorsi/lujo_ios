//
//  DeepLinkManager.swift
//  LUJO
//
//  Created by iMac on 19/08/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
// https://stasost.medium.com/ios-how-to-open-deep-links-notifications-and-shortcuts-253fb38e1696

import Foundation
import UIKit

enum DeeplinkType {
//    enum Messages {
//        case root
//        case details(id: String)
//    }
//    case messages(Messages)
//    case activity
//    case newListing
    case request(productType: String , id: String, pushNotificationId: String?)
}

//Singleton
let Deeplinker = DeepLinkManager()
class DeepLinkManager {
    fileprivate init() {}
    
    private var deeplinkType: DeeplinkType?

    func handleRemoteNotification(_ notification: [AnyHashable: Any]) {
        deeplinkType = NotificationParser.shared.handleNotification(notification)
    }
    
//    @discardableResult
//    func handleShortcut(item: UIApplicationShortcutItem) -> Bool {
//        deeplinkType = ShortcutParser.shared.handleShortcut(item)
//        return deeplinkType != nil
//    }
    
//    @discardableResult
//    func handleDeeplink(url: URL) -> Bool {
//        deeplinkType = DeeplinkParser.shared.parseDeepLink(url)
//        return deeplinkType != nil
//    }
    
    // check existing deeplink and perform action
    func checkDeepLink() {
        guard let deeplinkType = self.deeplinkType else {
            return
        }
        DeeplinkNavigator.shared.proceedToDeeplink(deeplinkType)
        
        // reset deeplink after handling
        self.deeplinkType = nil
    }
}
