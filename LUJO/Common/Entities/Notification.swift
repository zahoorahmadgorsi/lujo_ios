//
//  Chat.swift
//  LUJO
//
//  Created by Zahoor Gorsi on 17/08/2022
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import Foundation
import TwilioConversationsClient
import FirebaseCrashlytics

class PushNotification: Codable{//}, NSCoding {  //conforming NSObject, NSCoding  to store in user defaults
    
    var id: String
    var title: String?
    var subTitle: String?
    var sendType: String
    var viewType: String
    var message: String
    var createdAt: String
    var updatedAt: String
    var payload: Payload?
    var isRead: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case subTitle = "sub_title"
        case sendType = "send_type"
        case viewType = "view_type"
        case message
        case createdAt
        case updatedAt
        case payload
        case isRead
    }
  
    required init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            id = try values.decode(String.self, forKey: .id)
            title = try values.decodeIfPresent(String.self, forKey: .title)
            subTitle = try values.decodeIfPresent(String.self, forKey: .subTitle)
            sendType = try values.decode(String.self, forKey: .sendType)
            viewType = try values.decode(String.self, forKey: .viewType)
            message = try values.decode(String.self, forKey: .message)
            createdAt = try values.decode(String.self, forKey: .createdAt)
            updatedAt = try values.decode(String.self, forKey: .updatedAt)
            payload = try values.decodeIfPresent(Payload.self, forKey: .payload)
            isRead = try values.decode(Bool.self, forKey: .isRead)

        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
    
//    required init(coder aDecoder: NSCoder) {
//        self.read = aDecoder.decodeObject(forKey: "read") as? Bool
//        self.id = aDecoder.decodeObject(forKey: "id") as? String
//        self.send_type = aDecoder.decodeObject(forKey: "send_type") as? String
//        self.view_type = aDecoder.decodeObject(forKey: "view_type") as? String
//        self.message = aDecoder.decodeObject(forKey: "message") as? String
//        self.createdAt = aDecoder.decodeObject(forKey: "createdAt") as? Date
//        self.updatedAt = aDecoder.decodeObject(forKey: "updatedAt") as? Date
//    }

//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(self.type, forKey: "type")
//        aCoder.encode(self.friendlyName, forKey: "friendlyName")
//        aCoder.encode(self.dateCreatedAsDate, forKey: "dateCreatedAsDate")
//        aCoder.encode(self.lastMessageDate, forKey: "lastMessageDate")
//        aCoder.encode(self.lastMessageBody, forKey: "lastMessageBody")
////        aCoder.encode(self.unReadMessagesCount, forKey: "unReadMessagesCount")
//    }
    
}

class Payload: Codable{
    var id: String
    var type: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
  
    required init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            id = try values.decode(String.self, forKey: .id)
            type = try values.decode(String.self, forKey: .type)

        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}
