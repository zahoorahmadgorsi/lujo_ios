//
//  ChatUser.swift
//  LUJO
//
//  Created by iMac on 27/07/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import MessageKit

struct ChatUser: SenderType, Equatable {
    var senderId: String
    var displayName: String
    var avatar:String?
    
    init(senderId: String,displayName: String, avatar:String = "https://www.golujo.com/_assets/media/icons/footer-logo.svg") {
        self.senderId = senderId
        self.displayName = displayName
        self.avatar = avatar
    }
}
