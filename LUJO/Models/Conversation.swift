//
//  ChatUser.swift
//  LUJO
//
//  Created by iMac on 27/07/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import MessageKit
import TwilioChatClient

struct Conversation {
    var channelDescriptor: TCHChannelDescriptor
    var lastMessageBody: String?
    var lastMessageDateTime:Date?
    
    init(channelDescriptor: TCHChannelDescriptor) {
        self.channelDescriptor = channelDescriptor
    }
}
