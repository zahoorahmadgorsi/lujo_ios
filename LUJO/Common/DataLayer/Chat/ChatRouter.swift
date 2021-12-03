//
//  ChatRouter.swift
//  LUJO
//
//  Created by iMac on 24/07/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import Alamofire
import FirebaseCrashlytics
import Foundation
import UIKit

enum ChatRouter: URLRequestConvertible {
    
    // Obtain backend URL from configuration
    static let baseURLString: String = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BACKEND_URL") as? String else {
            return ""
        }
        return urlString
    }()

    static let apiVersion: String = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BACKEND_API_VERSION") as? String else {
            return ""
        }
        return "/" + urlString
    }()

    static let scheme: String = {
        guard let scheme = Bundle.main.object(forInfoDictionaryKey: "BACKEND_SCHEME") as? String else {
            return "https"
        }
        return scheme
    }()

//    case getFavourites(String)
//    case setFavourites(String,Int)
//    case unSetFavourites(String,Int)
    case getConversations(String)
    case getConversationDetails(String,String)
    case sendMessage(String,String,String,String,String)
    
    func asURLRequest() throws -> URLRequest {
        var method: HTTPMethod {
            return getHTTPMethod()
        }

        let requestUrl: URL = {
            getRequestURL()
        }()

        let body: Data? = {
            getBodyData()
        }()

        var urlRequest = URLRequest(url: requestUrl)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        return urlRequest
    }

    func getHTTPMethod() -> HTTPMethod {
        switch self {
//        case .getFavourites:
//            return .get
//        case .setFavourites: fallthrough
//        case .unSetFavourites:  fallthrough
        case .getConversations: fallthrough
        case .getConversationDetails: fallthrough
        case .sendMessage:
            return .post
        }
    }

    fileprivate func getRequestURL() -> URL {
        var newURLComponents = URLComponents()
        newURLComponents.scheme = EERouter.scheme
        newURLComponents.host = EERouter.baseURLString
        newURLComponents.path = EERouter.apiVersion

        switch self {
        case .getConversations:
            newURLComponents.path.append("/twilio/conversation-list")
        case .getConversationDetails:
            newURLComponents.path.append("/twilio/conversation-details")
        case .sendMessage:
            newURLComponents.path.append("/twilio/send-message")
        }
        
        do {
            let callURL = try newURLComponents.asURL()
            return callURL
        } catch {
            Crashlytics.crashlytics().record(error: error)
        }

        return URL(string: "https://\(EERouter.baseURLString)")!
            
            
        
        
    }
    
    fileprivate func getBodyData() -> Data? {
        switch self {
//            case .getFavourites:
//                return nil
//            case let .setFavourites(token, id): fallthrough
//            case let .unSetFavourites(token, id):
//                return getFavouritesAsJSONData(token: token , id : id)
        case let .getConversations(token):
            return getChatsAsJSONData(token: token)
        case let .getConversationDetails(token, conversationID):
            return getConversationDetailsAsJSONData(token: token, conversationID:conversationID)
        case let .sendMessage(token,message,conversation_id,title,sales_force_id):
            return getSendMessageAsJSONData(token: token, message: message, conversation_id: conversation_id, title: title, sales_force_id: sales_force_id)
        }
    }
    
    fileprivate func getChatsAsJSONData(token: String) -> Data? {
        let body: [String: Any] = [
            "token": token
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
    
    fileprivate func getConversationDetailsAsJSONData(token: String, conversationID: String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"conversation_id": conversationID
            ,"page" : "1"
            ,"size" : "20"
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
     
    fileprivate func getSendMessageAsJSONData(token: String,message: String,conversation_id: String,title: String,sales_force_id: String) -> Data? {
        let body: [String: Any] = [
            "token": token
            ,"message": message
            ,"conversation_id": conversation_id
            ,"title": title
            ,"sales_force_id": sales_force_id
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
}
