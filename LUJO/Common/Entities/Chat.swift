//
//  Chat.swift
//  LUJO
//
//  Created by iMac on 24/07/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import Foundation
import FirebaseCrashlytics

struct ConversationList: Codable {
    let message: String?
    var items: [ChatHeader]?
    
    enum CodingKeys: String, CodingKey {
        case message
        case items
    }
}

extension ConversationList {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            message = try values.decodeIfPresent(String.self, forKey: .message)
            items = try values.decodeIfPresent([ChatHeader].self, forKey: .items)
            
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}

struct ChatHeader: Codable {
    let customerId: Int?
    let authorName: String
    let conversationId: String
    let title: String
    let createdAt: String
    let meta:Meta?
    
    enum CodingKeys: String, CodingKey {
        case customerId = "customer_id"
        case authorName = "author_name"
        case conversationId = "conversation_id"
        case title
        case createdAt = "created_at"
        case meta
    }
}

extension ChatHeader {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            customerId = try values.decodeIfPresent(Int.self, forKey: .customerId)
            authorName = try values.decode(String.self, forKey: .authorName)
            conversationId = try values.decode(String.self, forKey: .conversationId)
            title = try values.decode(String.self, forKey: .title)
            createdAt = try values.decode(String.self, forKey: .createdAt)
            meta = try values.decodeIfPresent(Meta.self, forKey: .meta)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
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
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}

struct ConversationDetails: Codable {
    let message: String?
    var items: [Message]?
    
    enum CodingKeys: String, CodingKey {
        case message
        case items
    }
}

extension ConversationDetails {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            message = try values.decodeIfPresent(String.self, forKey: .message)
            items = try values.decodeIfPresent([Message].self, forKey: .items)
            
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}


struct Message: Codable {
    let body: String
    let author: String
    let createdAt: CreatedAt
    let meta:Meta?
    
    enum CodingKeys: String, CodingKey {
        case body
        case author
        case createdAt = "created_at"
        case meta
    }
}

extension Message {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            body = try values.decode(String.self, forKey: .body)
            author = try values.decode(String.self, forKey: .author)
            createdAt = try values.decode(CreatedAt.self, forKey: .createdAt)
            meta = try values.decodeIfPresent(Meta.self, forKey: .meta)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}

struct CreatedAt: Codable {
    let date: String
    let timezoneType: Int
    let timezone: String

    
    enum CodingKeys: String, CodingKey {
        case date
        case timezoneType = "timezone_type"
        case timezone
    }
}

extension CreatedAt {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            date = try values.decode(String.self, forKey: .date)
            timezoneType = try values.decode(Int.self, forKey: .timezoneType)
            timezone = try values.decode(String.self, forKey: .timezone)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}

struct SendMessageResponse: Codable {
    let conversationId: String
    let messageId: String

    
    enum CodingKeys: String, CodingKey {
        case conversationId = "conversation_id"
        case messageId = "message_id"
    }
}

extension SendMessageResponse {
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            conversationId = try values.decode(String.self, forKey: .conversationId)
            messageId = try values.decode(String.self, forKey: .messageId)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}

struct myDate{
    static var  serverDateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        result.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        return result
    }()
    
    static var  localDateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.dateStyle = .medium
        result.timeStyle = .medium
        return result
    }()
}
