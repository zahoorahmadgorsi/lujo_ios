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
    var tchConversation: TCHConversation
    var tchMessage: TCHMessage?
    var unReadMessageCount: String?
    
    init(_ tchConversation:TCHConversation ,_ tchMessage:TCHMessage? = nil,_ unReadMessageCount:String? = nil){
        self.tchConversation = tchConversation
        self.tchMessage = tchMessage
        self.unReadMessageCount = unReadMessageCount
    }
    
    required init(coder aDecoder: NSCoder) {
        self.tchConversation = aDecoder.decodeObject(forKey: "tchConversation") as! TCHConversation
        self.tchMessage = aDecoder.decodeObject(forKey: "tchMessage") as? TCHMessage
        self.unReadMessageCount = aDecoder.decodeObject(forKey: "unReadMessageCount") as? String ?? ""
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.tchConversation, forKey: "tchConversation")
        aCoder.encode(self.tchMessage, forKey: "tchMessage")
        aCoder.encode(self.unReadMessageCount, forKey: "unReadMessageCount")
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
