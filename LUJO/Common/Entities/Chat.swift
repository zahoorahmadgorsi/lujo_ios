//
//  Chat.swift
//  LUJO
//
//  Created by iMac on 24/07/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import Foundation
import TwilioConversationsClient

class Conversation: NSObject, NSCoding {  //conforming NSObject, NSCoding  to store in user defaults
    var tchConversation: TCHConversation?
    var tchMessage: TCHMessage?
    //primitive data types to be used for storing in user defaults
    //variables of tchConversation
    var type: String?
    var friendlyName: String?
    var dateCreatedAsDate: Date?
    var lastMessageDate: Date?
    //variable of tchMessage
    var lastMessageBody: String?
//    var unReadMessagesCount: String?
    
    init(_ tchConversation:TCHConversation){
        self.tchConversation = tchConversation
        //variables of tchConversation
        self.type = tchConversation.attributes()?.dictionary?["type"] as? String
        self.friendlyName = tchConversation.friendlyName
        self.dateCreatedAsDate = tchConversation.dateCreatedAsDate
        self.lastMessageDate = tchConversation.lastMessageDate
    }
    
    required init(coder aDecoder: NSCoder) {
        self.type = aDecoder.decodeObject(forKey: "type") as? String
        self.friendlyName = aDecoder.decodeObject(forKey: "friendlyName") as? String
        self.dateCreatedAsDate = aDecoder.decodeObject(forKey: "dateCreatedAsDate") as? Date
        self.lastMessageDate = aDecoder.decodeObject(forKey: "lastMessageDate") as? Date
        self.lastMessageBody = aDecoder.decodeObject(forKey: "lastMessageBody") as? String
//        self.unReadMessagesCount = aDecoder.decodeObject(forKey: "unReadMessagesCount") as? String
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.type, forKey: "type")
        aCoder.encode(self.friendlyName, forKey: "friendlyName")
        aCoder.encode(self.dateCreatedAsDate, forKey: "dateCreatedAsDate")
        aCoder.encode(self.lastMessageDate, forKey: "lastMessageDate")
        aCoder.encode(self.lastMessageBody, forKey: "lastMessageBody")
//        aCoder.encode(self.unReadMessagesCount, forKey: "unReadMessagesCount")
    }
    
}

struct Meta: Codable {
    let id: Int?
    let sfid: String?
    let avatar: String?

    enum CodingKeys: String, CodingKey {
        case id
        case sfid
        case avatar
    }
}

extension Meta {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decodeIfPresent(Int.self, forKey: .id)
            sfid = try values.decodeIfPresent(String.self, forKey: .sfid)
            avatar = try values.decodeIfPresent(String.self, forKey: .avatar)
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}
