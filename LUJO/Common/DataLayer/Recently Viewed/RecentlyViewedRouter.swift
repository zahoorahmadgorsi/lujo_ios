//
//  RecentlyViewedRouter.swift
//  LUJO
//
//  Created by I MAC on 03/11/2020.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import Alamofire
import FirebaseCrashlytics
import Foundation
import UIKit

enum RecentlyViewedRouter: URLRequestConvertible {    

    case setRecentlyViewed(String,String)
    
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
        urlRequest.print()
        return urlRequest
    }
    
    func getHTTPMethod() -> HTTPMethod {
        switch self {
        case .setRecentlyViewed:
            return .post
        }
    }
    
    fileprivate func getRequestURL() -> URL {
        var newURLComponents = URLComponents()
        newURLComponents.scheme = EERouter.scheme
        newURLComponents.host = EERouter.baseURLString
        newURLComponents.path = EERouter.apiVersion

        switch self {
            case .setRecentlyViewed:
                newURLComponents.path.append("/recent/set")
            do {
                let callURL = try newURLComponents.asURL()
                return callURL
            } catch {
                Crashlytics.crashlytics().record(error: error)
            }
            return URL(string: "https://\(EERouter.baseURLString)")!
        }
    }
    
    fileprivate func getBodyData() -> Data? {
        switch self {
            case let .setRecentlyViewed(type, id):
               return getSettingRecentlyViewedAsJSONData(type: type , id:id)
        }
    }
    
    fileprivate func getSettingRecentlyViewedAsJSONData(type: String , id: String) -> Data? {
        let body: [String: Any] = [
            "type" : type,
            "itemId": id
        ]
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
}
