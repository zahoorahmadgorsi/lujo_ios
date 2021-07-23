//
//  Chat.swift
//  LUJO
//
//  Created by iMac on 24/07/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import Foundation

struct ChatList: Codable {
    let message: String?
    var items: [ChatHeader]?
    
    enum CodingKeys: String, CodingKey {
        case message
        case items
    }
}

extension ChatList {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            message = try values.decodeIfPresent(String.self, forKey: .message)
            items = try values.decodeIfPresent([ChatHeader].self, forKey: .items)
            
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}

struct ChatHeader: Codable {
    let customerId: Int
    let authorName: String
    let conversationId: String
    let title: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case customerId = "customer_id"
        case authorName = "author_name"
        case conversationId = "conversation_id"
        case title
        case createdAt = "created_at"
    }
}

extension ChatHeader {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            customerId = try values.decode(Int.self, forKey: .customerId)
            authorName = try values.decode(String.self, forKey: .authorName)
            conversationId = try values.decode(String.self, forKey: .conversationId)
            title = try values.decode(String.self, forKey: .title)
            createdAt = try values.decode(String.self, forKey: .createdAt)
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            throw error
        }
    }
}
