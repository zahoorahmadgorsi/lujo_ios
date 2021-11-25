//
//  ChatUser.swift
//  LUJO
//
//  Created by iMac on 27/07/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import MessageKit
import TwilioConversationsClient

//class Conversation : NSObject, NSCoding{
//    var sid:String?
//    var type:String?
//    var friendlyName:String?
//    var unConsumedMessagesCount: NSNumber
//    var lastMessageBody: String?
//    var lastMessageDateTime: Date?
//
//
//    init(_ sid:String? , _ type:String? ,_ friendlyName:String? ,_ unConsumedMessageCount:NSNumber? ,_ lastMessageBody: String? ,_ lastMessageDateTime: Date? ) {
//        self.sid = sid
//        self.type = type
//        self.friendlyName = friendlyName
//        self.unConsumedMessagesCount = unConsumedMessageCount ?? 0
//        self.lastMessageBody = lastMessageBody
//        self.lastMessageDateTime = lastMessageDateTime
//    }
//
//    required convenience init(coder aDecoder: NSCoder) {
//        let sid = aDecoder.decodeObject(forKey: "sid") as! String
//        let type = aDecoder.decodeObject(forKey: "type") as! String
//        let friendlyName = aDecoder.decodeObject(forKey: "friendlyName") as! String
//        let unConsumedMessageCount = aDecoder.decodeObject(forKey: "unConsumedMessageCount") as! NSNumber
//        let lastMessageBody = aDecoder.decodeObject(forKey: "lastMessageBody") as! String
//        let lastMessageDateTime = aDecoder.decodeObject(forKey: "lastMessageDateTime") as! Date
//
//        self.init(sid,type,friendlyName,unConsumedMessageCount, lastMessageBody, lastMessageDateTime)
//    }
//
//    func encode(with aCoder: NSCoder){
//        aCoder.encode(sid, forKey: "sid")
//        aCoder.encode(type, forKey: "type")
//        aCoder.encode(friendlyName, forKey: "friendlyName")
//        aCoder.encode(unConsumedMessagesCount, forKey: "unConsumedMessageCount")
//        aCoder.encode(lastMessageBody, forKey: "lastMessageBody")
//        aCoder.encode(lastMessageDateTime, forKey: "lastMessageDateTime")
//    }
//}
