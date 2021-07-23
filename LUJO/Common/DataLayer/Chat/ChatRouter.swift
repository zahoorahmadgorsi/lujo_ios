//
//  ChatRouter.swift
//  LUJO
//
//  Created by iMac on 24/07/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import Alamofire
import Crashlytics
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
    case getChats(String)
    
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
        case .getChats:
            return .post
        }
    }

    fileprivate func getRequestURL() -> URL {
        var newURLComponents = URLComponents()
        newURLComponents.scheme = EERouter.scheme
        newURLComponents.host = EERouter.baseURLString
        newURLComponents.path = EERouter.apiVersion

        switch self {
//            case let .getFavourites(token):
//                newURLComponents.path.append("/favorites")
//                newURLComponents.queryItems = [
//                    URLQueryItem(name: "token", value: token)
//                ]
//            case .setFavourites:
//                newURLComponents.path.append("/favorites/set")
//            case .unSetFavourites:
//                newURLComponents.path.append("/favorites/unset")
        case .getChats:
            newURLComponents.path.append("/twilio/conversation-list")
        }
        
        do {
            let callURL = try newURLComponents.asURL()
            return callURL
        } catch {
            Crashlytics.sharedInstance().recordError(error)
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
        case let .getChats(token):
            return getChatsAsJSONData(token: token)
        }
    }
    
//    fileprivate func getFavouritesAsJSONData(token: String , id : Int) -> Data? {
//        let body: [String: Any] = [
//            "id": id,
//            "token": token
//        ]
//        return try? JSONSerialization.data(withJSONObject: body, options: [])
//    }
    
    fileprivate func getChatsAsJSONData(token: String) -> Data? {
        let body: [String: Any] = [
            "token": token
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
     
}
