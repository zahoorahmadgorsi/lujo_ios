//
//  WishListRouter.swift
//  LUJO
//
//  Created by I MAC on 05/11/2020.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import Alamofire
import FirebaseCrashlytics
import Foundation
import UIKit

//this router deals with wishlist and pushnotifications
enum WishListRouter: URLRequestConvertible {
    
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

    case getFavourites
    case setFavourites(String,String)
    case unSetFavourites(String,String)
    case getPushNotifications(Int)
    
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
        if let token = LujoSetup().getCurrentUser()?.token{
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        print("urlRequest:\(String(describing: urlRequest.url))")
        return urlRequest
    }

    func getHTTPMethod() -> HTTPMethod {
        switch self {
            case .getFavourites: fallthrough
            case .getPushNotifications  :
                return .get
            case .setFavourites:
                return .post
            case .unSetFavourites:
                return .post
        }
    }

    fileprivate func getRequestURL() -> URL {
        var newURLComponents = URLComponents()
        newURLComponents.scheme = EERouter.scheme
        newURLComponents.host = EERouter.baseURLString
        newURLComponents.path = EERouter.apiVersion

        switch self {
            case .getFavourites:
                newURLComponents.path.append("/favorites")
            case .setFavourites:
                newURLComponents.path.append("/favorites/set")
            case .unSetFavourites:
                newURLComponents.path.append("/favorites/unset")
            case let .getPushNotifications(pageNumber):
                newURLComponents.path.append("/notification")
                newURLComponents.queryItems = [
                    URLQueryItem(name: "page", value: String(pageNumber)),
                    URLQueryItem(name: "limit", value: "15")
            ]
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
            case .getFavourites:    fallthrough
        case .getPushNotifications:
                return nil
            case let .setFavourites(type, id):  fallthrough
            case let .unSetFavourites(type, id):
                return getFavouritesAsJSONData(type , id )
        }
    }
    
    fileprivate func getFavouritesAsJSONData(_ type: String , _ id : String) -> Data? {
        let body: [String: Any] = [
            "itemId": id,
            "type" : type
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
     
}
