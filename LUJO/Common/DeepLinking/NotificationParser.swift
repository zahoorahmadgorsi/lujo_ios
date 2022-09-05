//
//  NotificationParser.swift
//  LUJO
//
//  Created by iMac on 19/08/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
// https://stasost.medium.com/ios-how-to-open-deep-links-notifications-and-shortcuts-253fb38e1696

import Foundation
class NotificationParser {
    
   static let shared = NotificationParser()
    
   private init() { }
    
    func handleNotification(_ userInfo: [AnyHashable : Any]) -> DeeplinkType? {
//        print(userInfo)
        if let data = userInfo["custom"] as? [String: Any] {
            if let a = data["a"] as? [String: Any] {
                if let type = a["type"] as? String , let id = a["id"] as? String {
                    return DeeplinkType.request(productType: type,id: id, pushNotificationId: a["_id"] as? String)
                }
            }
        }
        return nil
    }
    
}
