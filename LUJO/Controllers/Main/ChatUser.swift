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
}
